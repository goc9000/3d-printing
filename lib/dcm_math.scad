/* Sums the values in a vector. */
function sum(values) = __sum(values, 0);

function __sum(values, n) =
    n >= len(values) ? 0 : values[n] + __sum(values, n + 1);

/* Cumulative sum. Given a vector [a0, a1, a2, ... aN], computes
   [a0, a0+a1, a0+a1+a2, ..., a0+a1+...+aN] */
function cumsum(values) = concat(0, __cumsum(values, 0, 0));

function __cumsum(values, n, running) =
    n >= len(values) ? [] : concat(
        [running + values[n]],
        __cumsum(values, n + 1, running + values[n])
    );
