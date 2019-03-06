# GPUArrays

*Abstract GPU Array package for Julia's various GPU backends.*

[![][docs-stable-img]][docs-stable-url] [![][docs-dev-img]][docs-dev-url]

[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-stable-url]: http://JuliaGPU.github.io/GPUArrays.jl/stable/
[docs-dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[docs-dev-url]: http://JuliaGPU.github.io/GPUArrays.jl/dev/


[Benchmarks](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/results/results.md)

This package is the counterpart of Julia's `Base.AbstractArray` interface, but
for GPU array types. Currently, you either need to install
[CLArrays](https://github.com/JuliaGPU/CLArrays.jl) or
[CuArrays](https://github.com/JuliaGPU/CuArrays.jl) for a concrete
implementation.


# Why another GPU array package in yet another language?

Julia offers great advantages for programming the GPU.
This [blog post](http://mikeinnes.github.io/2017/08/24/cudanative.html) outlines a few of those.

E.g., we can use Julia's JIT to generate optimized kernels for map/broadcast operations.

This works even for things like complex arithmetic, since we can compile what's already in Julia Base.
This isn't restricted to Julia Base, GPUArrays works with all kind of user defined types and functions!

GPUArrays relies heavily on Julia's dot broadcasting.
The great thing about dot broadcasting in Julia is, that it
[actually fuses operations syntactically](http://julialang.org/blog/2017/01/moredots), which is vital for performance on the GPU.
E.g.:

```Julia
out .= a .+ b ./ c .+ 1
#turns into this one broadcast (map):
broadcast!(out, a, b, c) do a, b, c
    a + b / c + 1
end
```

Will result in one GPU kernel call to a function that combines the operations without any extra allocations.
This allows GPUArrays to offer a lot of functionality with minimal code.

Also, when compiling Julia for the GPU, we can use all the cool features from Julia, e.g.
higher order functions, multiple dispatch, meta programming and generated functions.
Checkout the examples, to see how this can be used to emit specialized code while not losing flexibility:

[<img src="https://raw.githubusercontent.com/JuliaGPU/GPUBenchmarks.jl/master/results/plots/juliaset_result.png" height="150">](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/results/results.md)
[<img src="https://user-images.githubusercontent.com/1010467/40832645-12ca1f50-658c-11e8-9fb4-170871db2499.png" height="150">](https://juliagpu.github.io/GPUShowcases.jl/latest/)

In theory, we could go as far as inspecting user defined callbacks (we can get the complete AST), count operations and estimate register usage and use those numbers to optimize our kernels!


# Scope

Interface offered for all backends:

```Julia
map(f, ::GPUArray...)
map!(f, dest::GPUArray, ::GPUArray...)

broadcast(f, ::GPUArray...)
broadcast!(f, dest::GPUArray, ::GPUArray...)

mapreduce(f, op, ::GPUArray...) # so support for sum/mean/minimum etc comes for free

getindex, setindex!, push!, append!, splice!, append!, copy!, reinterpret, convert

From (CL/CU)FFT
fft!/fft/ifft/ifft! and the matching plan_fft functions.
From (CL/CU)BLAS
gemm!, scal!, gemv! and the high level functions that are implemented with these, like A * B, A_mul_B!, etc.
```

# Currently supported subset of Julia Code

working with immutable isbits (not containing pointers) type should be completely supported
non allocating code (so no constructs like `x = [1, 2, 3]`). Note that tuples are isbits, so this works x = (1, 2, 3).
Transpiler/OpenCL has problems with putting GPU arrays on the gpu into a struct - so no views and actually no multidimensional indexing. For that `size` is needed which would need to be part of the array struct. A fix for that is in sight, though.

# JLArray

The `JLArray` is a `GPUArray` which doesn't run on the GPU and rather uses Julia's async constructs as its backend. It serves as a fallback for testing compatibility with `GPUArray`s in cases where a GPU does not exist and as a reference implementation. It is constructed as follows:

```julia
gA = JLArray(A)
```

# TODO / up for grabs

* stencil operations, convolutions
* more tests and benchmarks
* tests, that only switch the backend but use the same code
* performance improvements!!
* interop between OpenCL, CUDA and OpenGL is there as a protype, but needs proper hooking up via `Base.copy!` / `convert`


# Installation

See CuArrays or CLArrays for installation instructions.
