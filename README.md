# Rafts test

[![Build Status](https://travis-ci.org/mbauman/Rafts.jl.svg?branch=master)](https://travis-ci.org/mbauman/Rafts.jl)

Float on top of your data without getting bogged down by the weight of it all.

## Design brainstorm:

### Goals:

1. Decouple navigation (moving around the data) from the stored data itself
    - Use proxy objects (Rafts) that wrap and display their contents easily
    - Defer loading large datasets until it is requested
2. Allow quick and easy plotting and inspection of data
    - Should proxies themselves be plot-able? If so: How does dispatch work?
    - How would I write a function for a proxy containing both spiketimes and snippets, for example? Should I? Perhaps better just to pass data explicitly
    - Or perhaps all proxies are parameterized by a name?  E.g., Raft{:Spikes}
3. What about script access? Does it make sense to store scripts alongside data?
    - Or maybe the data folder is accompanied by a code folder? Specific to the depth of navigation? Or the name? Seems finicky.
4. Use the navigatability to enable generic searches!
5. Potentially add a simple validation schema
    - Enforce required elements
    - Specify optional elements (preventing unknown elements)
    - Validate at access-time.

### Potential interface:

A user can instantiate a Raft at any point, simply by calling:

    r = Raft() # with Raft() = construct(DirectoryRaft(pwd()))

This will go through all the files in that directory (including folders, but
not their contents) and create a summary of each. I suppose folders won't have
summaries. This only instantiates the rafts to represent each supported file;
it won't fully construct them until they are requested to prevent recursive
hell.

Now, should I flatten (or splat) the FileRaft variables into the parent
DirectoryRaft? That certainly would be the most convenient way to go about it.
But what happens on a name clash? Should Rafts totally bail? I'd like to think
of filenames as being *optionally* an implementation detail, whereas the
variable names themselves are often the part the user cares about. Let's make it configurable.

What about arrays? An experiment has multiple trials. Trials are a very
high-level raft. How would an array of them be represented on disk? Perhaps
trailing numerics would be treated specially? Would dates cause trouble as
false-positives? Or should they be handled as arrays, too?

    experiment/trial_1/datas
             …/trial_2/datas
             …/trial_4/datas
    # Or maybe: (both?)
    experiment/trial/1/datas
                   …/2/datas
                   …/4/datas

I think they should all get aggregated together as 'trials' in a dict. Perhaps
they become a GroupedRaft{Int}... which wraps an Dict{Int,Raft}. This could
then support dates, too. I think that'd work. The config could specify which,
or it could try to guess. Maybe the config could be built-up interactively,
too! When a Raft gets something wrong, you could correct it and save the
correction for the future.

What about DataRafts? They represent actual data themselves (but with deferred
loading). Should I try to defer their access until they're actually used? That
may be trying to be too smart, but it would allow for incremental loading from,
e.g., HDF5. The simplest thing to do here is to load them as soon as the user
directly references them, at which point they get constructed.

## Implementation

### Configuration

Rafts are configurable.  A Raft will look through all its parent directories for a .raftconfig file, stopping at the first one it finds (similar to how .git works).  There are three configurable options:

1. **Ignore files**.  If a path matches an ignore pattern, it will be ignored. By default, all dotfiles are ignored.
2. **Splatted files**.  If a path matches a splat pattern, its children will be placed directly into the parent, effectively skipping a level.  This is nice as many data file formats store the variable names explicitly within the file, and the file name is essentially an implementation detail. By default, all files starting with an underscore are splatted into their parents.
3. **Grouped files**.  This one is more tricky but very important.  If a path matches a grouped pattern, it will be combined with all other paths matching that pattern into a dictionary like interface.  The hard part is deciding *how* to split the filename into the common group name and unique keys.  By default, the common prefix and postfix are removed from each file, and the longer of the two is used as the group name. How does this work?  All matching filenames are sent to a function which returns the common field name and an array of indices.  But how is this function specified? Could it be done through multiple-dispatch?
