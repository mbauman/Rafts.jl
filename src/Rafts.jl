module Rafts

# A Raft "floats" over data within directories for interactive data exploration

Raft() = Raft(pwd())
function Raft(path::String)
    isdir(path) && return DirectoryRaft(path)
    files = readdir(path)
    # remove dot-files
    filter!(f->!beginswith(f, "."), files)
    
    splat_mask = [beginswith(f, "_") for f in files]
    
    children = Dict{Any, Raft}()
    sizehint(children, sum(splat_mask))
    for f in files[!splat_mask]
        children[f] = Raft(joinpath(path, f), false)
    end
    if all(f->isdir(f) && files)
    end
end

end # module
