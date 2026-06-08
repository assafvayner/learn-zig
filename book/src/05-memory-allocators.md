# Memory & Allocators

## No Hidden Allocation

Zig has no global heap. Every function that needs dynamic memory receives a `std.mem.Allocator` as a parameter. This makes allocation visible, testable, and swappable — you can substitute a test allocator, an arena, or a fixed buffer without changing any logic.

## The Allocator Interface

`std.mem.Allocator` is a comptime-erased interface. Any concrete allocator exposes `.allocator()` which returns one. The two core pairs:

| Operation | Purpose |
|---|---|
| `alloc.alloc(T, n)` | allocate a slice `[]T` of length `n` |
| `alloc.free(slice)` | free a slice |
| `alloc.create(T)` | allocate a single `*T` |
| `alloc.destroy(ptr)` | free a single pointer |

Both `alloc` and `create` return errors (`error.OutOfMemory`), so they are called with `try`.

The canonical idiom pairs allocation with a `defer` so the free is co-located with the alloc and runs even on error paths:

```zig
const buf = try alloc.alloc(u8, n);
defer alloc.free(buf);

const node = try alloc.create(Node);
defer alloc.destroy(node);
node.* = .{ ... };
```

## The Four Allocators

### `std.heap.DebugAllocator`

The default choice for development. Detects leaks, double-frees, and use-after-free. `deinit()` returns `.leak` or `.ok` and prints a report.

```zig
var gpa: std.heap.DebugAllocator(.{}) = .init;
defer _ = gpa.deinit();
const alloc = gpa.allocator();
```

Use it everywhere during development. Switch to `page_allocator` or a release-mode wrapper for production binaries.

### `std.heap.ArenaAllocator`

Allocates from a backing allocator; `deinit()` frees everything at once. There are no individual frees — call `alloc.create` or `alloc.alloc` freely, then tear down in one shot. Ideal for request-scoped or parse-scoped work.

```zig
var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
defer arena.deinit();
const alloc = arena.allocator();
```

### `std.heap.FixedBufferAllocator`

Bump-allocates into a caller-supplied byte array. No OS calls, no fragmentation. Fails with `OutOfMemory` when the buffer is exhausted. Good for stack-local scratch space or embedded targets.

```zig
var buf: [4096]u8 = undefined;
var fba = std.heap.FixedBufferAllocator.init(&buf);
const alloc = fba.allocator();
```

### `std.heap.page_allocator`

Calls the OS directly (`mmap`/`VirtualAlloc`). No bookkeeping overhead, but granularity is a full page (4 KiB+). Use as the backing allocator for arenas, or for large one-shot allocations.

## `std.testing.allocator`

In tests, use `std.testing.allocator` instead of a `DebugAllocator`. It runs the same leak detection and **fails the test** automatically if anything is not freed — no manual check required.

```zig
test "no leaks" {
    const alloc = std.testing.allocator;
    const buf = try alloc.alloc(u8, 16);
    defer alloc.free(buf);
    // ... use buf ...
}
```

Remove the `defer alloc.free(buf)` and the test will fail with a detailed leak report.

## Exercises

- **01** `01_dynamic_buffer.zig` — allocate a `[]u8`, fill it, print it, free it with `DebugAllocator`.
- **02** `02_linked_list.zig` — build a linked list with `ArenaAllocator`; free everything via `arena.deinit()`.
- **03** `03_leak_test.zig` — write tests with `std.testing.allocator`; observe the automatic leak failure.
