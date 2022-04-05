mutable struct stats
    # Number of overflows that have happened within insert!
    overflows
end

struct bucket{T}
    transactions::ds.SortedSet{transaction{T}}
    max
    stats
end

function first(b::bucket)
    ds.first(b.transactions)
end

function element_type(_::bucket{T}) where{T}
    T
end

function isempty(b::bucket)
    isempty(b.transactions)
end

function length(b::bucket)
    length(b.transactions)
end

function bucket(; type = transaction_type_default, bucket_max = bucket_max_default)
    bucket(ds.SortedSet{transaction{type}}(), bucket_max, stats(0))
end

function in(tx, b::bucket)
    tx ∈ b.transactions
end

function transactions(b::bucket)
    result = Set{transaction{element_type(b)}}(b.transactions)
end

function full(b::bucket)
    length(b.transactions) >= b.max
end

function insert!(b::bucket, tx)
    if full(b)
        delete!(b.transactions, last(b.transactions))
        b.stats.overflows += 1
    end
    insert!(b.transactions, tx)
end

function load_factor(b::bucket)
    return length(b.transactions) / b.max
end
