type Config
    splatters::Array{Regex, 1}
    groupers::Array{Regex, 1}
    ignorers::Array{Regex, 1}
end

const defaultconfig = Config(Regex[g"**/_*"], Regex[], Regex[g"**/.*"])

function Config(path::String)
    !isdir(path) && (path = dirname(path))
    # Search for the topmost .raftconfig file
    while !isempty(path)
        f = joinpath(path, ".raftconfig")
        isfile(f) && return parseconfig(f)
        
        path = dirname(path)
    end
    
    # Not found; use default configuration
    return defaultconfig
end