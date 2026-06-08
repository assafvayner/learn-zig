# Chapter 10 — Concurrency: `parallel`

Implement the three functions in `src/parallel.zig` using only the
0.16 primitives that still exist: raw threads (`std.Thread.spawn`/`join`),
partitioned data (each thread owns its own slot or disjoint slice region),
and `std.atomic.Value` for a genuinely shared counter. Do not reach for
`std.Thread.Mutex`/`Pool`/`WaitGroup` — they were removed in 0.16.

1. `parallelSum` — split the slice into 4 chunks, sum each on its own thread
   into a private partial, join, then add the partials.
2. `atomicCounter` — N threads each `fetchAdd(1, .seq_cst)` on one shared
   `std.atomic.Value(u64)`.
3. `parallelMap` — square each element into a disjoint range of the output.

Run the tests until they pass:

```sh
zig build test
```

Then run the demo:

```sh
zig build run
```

Expected output:

```
parallel sum 0..999 = 499500
atomic counter = 8000
parallel_map[9] = 81
```
