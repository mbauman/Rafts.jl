# A DirectoryRaft gathers Rafts of all files and folders within its path
type DirectoryRaft <: Raft
    path::UTF8String
    
    children::Vector{UTF8String}
end

function DirectoryRaft(path)
    return DirectoryRaft(path, readdir(path))
end
