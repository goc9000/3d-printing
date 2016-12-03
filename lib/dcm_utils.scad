/* Concatenates all items in a vector. */
function concat_all(items) = __concat_all(items, 0);

function __concat_all(items, pos) =
    pos < len(items) ? concat(items[pos], __concat_all(items, pos + 1)) : [];
