# Concurrency

This chapter teaches *a little* concurrency: the primitives that are small, safe, and present in Zig 0.16.0. You spawn OS threads with `std.Thread`, avoid data races by **partitioning** the data so no two threads touch the same memory, and use `std.atomic.Value` when you genuinely need one shared counter.

> **0.16 changed the concurrency story.** The "I/O as an interface" rework **removed** `std.Thread.Mutex`, `std.Thread.Pool`, and `std.Thread.WaitGroup`. They will not compile. Their replacements live behind the new `std.Io` interface (`std.Io.Mutex`, `std.Io.Group`, `std.Io.async`). This chapter sticks to raw threads + atomics, which still exist and need no `Io` object. See the closing section for where things are heading.

---

## Spawning and joining threads

`std.Thread.spawn(config, function, args_tuple)` starts a function on a new OS thread. `args_tuple` is an anonymous tuple of the function's arguments. The returned handle must be joined (or detached); `join()` blocks until the thread finishes.

```zig
fn worker(id: usize) void {
    std.debug.print("hello from {d}\n", .{id});
}

const t = try std.Thread.spawn(.{}, worker, .{0});
t.join();
```

For a fixed number of workers, store the handles in an array — spawn in one loop, join in another:

```zig
var threads: [4]std.Thread = undefined;
for (&threads, 0..) |*t, i| t.* = try std.Thread.spawn(.{}, worker, .{i});
for (threads) |t| t.join();
```

Spawning all of them before joining any is what makes the work overlap. If you joined inside the first loop you would just run them one at a time.

---

## Data races, and avoiding them by partitioning

A **data race** is two threads accessing the same memory concurrently with at least one write, and no synchronization. The result is undefined — torn values, lost updates, or worse. The compiler will not catch it for you.

The simplest fix is to never share mutable memory in the first place. Give each thread its **own** output slot, or its **own disjoint region** of an output slice, and combine the results only after every thread has joined. No locks, no atomics, no races.

```zig
fn sumChunk(chunk: []const u64, out: *u64) void {
    var acc: u64 = 0;
    for (chunk) |v| acc += v;
    out.* = acc; // each thread owns a different `out`
}

var partials: [4]u64 = .{0} ** 4;
// thread i reads data[start..end] and writes only partials[i]
// ... spawn, then join ...
var total: u64 = 0;
for (partials) |p| total += p; // combine after the join barrier
```

Because thread `i` writes only `partials[i]`, and the slices `data[start..end]` never overlap, there is no shared write target. The `join` calls are the only synchronization needed: once they return, all writes are visible to the main thread. The same pattern works for an output slice — partition the index range and let each thread own `[start, end)`.

---

## `std.atomic.Value` for a genuinely shared counter

When the threads really must update one shared value — a counter, an accumulator — wrap it in `std.atomic.Value(T)`. Its read-modify-write operations are indivisible, so concurrent updates are not lost. No mutex required.

```zig
var counter = std.atomic.Value(u64).init(0);

fn bump(c: *std.atomic.Value(u64)) void {
    var i: usize = 0;
    while (i < 1000) : (i += 1) _ = c.fetchAdd(1, .seq_cst);
}
// 8 threads each call bump -> final value is exactly 8000
const final = counter.load(.seq_cst);
```

The `.seq_cst` argument is the **memory ordering** — sequential consistency, the strongest and easiest to reason about. Weaker orderings (`.monotonic`, `.acquire`, `.release`) exist for performance, but reach for them only once you can prove the looser guarantee is enough. `fetchAdd` returns the previous value; `load` reads the current one.

---

## Where Zig is heading: `std.Io` structured concurrency

The future of concurrency in Zig is the `std.Io` interface. You pass an `Io` to your code, and the *caller* chooses whether it is backed by threads, a single-threaded event loop, or `io_uring`. A `std.Io.Group` gives **structured concurrency**: tasks spawned into the group are guaranteed to finish (or be canceled) by the time you `await` it.

```zig
// Taste only — needs a real `Io` instance to run.
var group: std.Io.Group = .init;
group.async(io, worker, .{0});
group.async(io, worker, .{1});
try group.await(io); // blocks until both tasks complete
```

`std.Io.Mutex` and `std.Io.async` round out the picture. The exercises below intentionally **do not** use any of this — threads plus atomics are enough to learn the core ideas, and they run without an `Io` object.

---

## Exercises

Project `parallel` (`zig build test`, then `zig build run`). Implement the three functions in `src/parallel.zig`:

- **`parallelSum`** — sum a `[]const u64` by splitting it into 4 chunks, summing each chunk on its own thread into a private partial, joining, then adding the partials. Test: sum of `0..=999` is `499500`.
- **`atomicCounter`** — 8 threads each `fetchAdd(1, .seq_cst)` 1000 times on one shared `std.atomic.Value(u64)`. Test: final value is `8000`.
- **`parallelMap`** — square each input element into a disjoint range of the output slice, one range per thread, no synchronization. Test: `out[i] == i * i`.
