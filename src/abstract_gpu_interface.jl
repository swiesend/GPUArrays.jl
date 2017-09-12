#=
Abstraction over the GPU thread indexing functions.
Uses CUDA like names
=#
for f in (:blockidx, :blockdim, :threadidx), sym in (:x, :y, :z)
    fname = Symbol(string(f, '_', sym))
    @eval $fname(state)::Cuint = error("Not implemented")
    @eval export $fname
end
"""
in CUDA terms `__synchronize`
"""
function synchronize_threads(state)
    error("Not implemented")
end

"""
linear index in a GPU kernel
"""
@inline function linear_index(state)
    Cuint((blockidx_x(state) - Cuint(1)) * blockdim_x(state) + threadidx_x(state))
end

"""
Blocks until all operations are finished on `A`
"""
function synchronize(A::GPUArray)
    # fallback is a noop, for backends not needing synchronization. This
    # makes it easier to write generic code that also works for AbstractArrays
end
"""
Gets the device associated to the Array `A`
"""
function device(A::GPUArray)
    # fallback is a noop, for backends not needing synchronization. This
    # makes it easier to write generic code that also works for AbstractArrays
end


@inline function synchronize_threads(A)
    CUDAnative.__syncthreads()
end

macro linearidx(A, statesym = :state)
  quote
    A = $(esc(A))
    i = linear_index($(esc(statesym)))
    i > length(A) && return
    i
  end
end
macro cartesianidx(A, statesym = :state)
    quote
        A = $(esc(A))
        i = @linearidx(A, $(esc(statesym)))
        gpu_ind2sub(A, i)
    end
end


"""
`A` must be an GPUArray and will help to dispatch to the correct GPU backend
and supplies queues and contexts.
Calls kernel with `kernel(state, args...)`, where state is dependant on the backend
and can be used for e.g getting an index into A with `linear_index(state)`.
Optionally, number of blocks threads can be specified.
Falls back to some heuristic dependant on the size of `A`
"""
function gpu_call(kernel, A::AbstractArray, args::Tuple, blocks = length(A), threads = nothing)
    kernel(args...)
end
