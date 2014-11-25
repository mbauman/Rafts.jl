# A GroupedRaft gathers "arrays" of rafts for grouped container-like access
type GroupedRaft <: AbstractRaft
    path::UTF8String
end
