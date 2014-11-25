# A FileRaft represents all the variables stored inside some file of type T
type FileRaft{T} <: Raft
    path::UTF8String  # Path to the file itself
    group::UTF8String # For HDF5-like sub-groupings within the file
    file::T
    
    parent::Raft    
    children::Dict{UTF8String, Raft}
end

# A DataRaft represents exactly one stored variable inside a FileRaft
type DataRaft{T<:FileRaft} <: Raft
    name::UTF8String
    desc::UTF8String
    
    parent::T
end