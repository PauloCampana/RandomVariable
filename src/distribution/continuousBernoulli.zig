//! Support: X ∈ [0,1]
//!
//! Parameters:
//! - λ: `shape` ∈ (0,1)

const std = @import("std");
const assert = std.debug.assert;
const isFinite = std.math.isFinite;
const isNan = std.math.isNan;
const inf = std.math.inf(f64);

/// p(x) = 2 / (1 - 2λ) arctanh(1 - 2λ) λ^x (1 - λ)^(1 - x).
pub fn density(x: f64, shape: f64) f64 {
    assert(0 < shape and shape < 1);
    assert(!isNan(x));
    if (x < 0 or x > 1) {
        return 0;
    }
    if (shape == 0.5) {
        return 1;
    }
    const c = 1 - 2 * shape;
    const constant = 2 / c * std.math.atanh(c);
    const inc = std.math.pow(f64, shape, x);
    const dec = std.math.pow(f64, 1 - shape, 1 - x);
    return constant * inc * dec;
}

/// F(q) = (λ^q (1 - λ)^(1 - q) + λ - 1) / (2λ - 1).
pub fn probability(q: f64, shape: f64) f64 {
    assert(0 < shape and shape < 1);
    assert(!isNan(q));
    if (q <= 0) {
        return 0;
    }
    if (q >= 1) {
        return 1;
    }
    if (shape == 0.5) {
        return q;
    }
    const inc = std.math.pow(f64, shape, q);
    const dec = std.math.pow(f64, 1 - shape, 1 - q);
    return (inc * dec + shape - 1) / (2 * shape - 1);
}

/// Q(p) = ln(((2λ - 1)p - λ + 1) / (1 - λ)) / ln(λ / (1 - λ)).
pub fn quantile(p: f64, shape: f64) f64 {
    assert(0 < shape and shape < 1);
    assert(0 <= p and p <= 1);
    if (shape == 0.5) {
        return p;
    }
    const shape2 = 1 - shape;
    const num = ((2 * shape - 1) * p + shape2) / shape2;
    const den = shape / shape2;
    return @log(num) / @log(den);
}

pub fn random(generator: std.Random, shape: f64) f64 {
    assert(0 < shape and shape < 1);
    const uni = generator.float(f64);
    if (shape == 0.5) {
        return uni;
    }
    const shape2 = 1 - shape;
    const num = ((2 * shape - 1) * uni + shape2) / shape2;
    const den = shape / shape2;
    return @log(num) / @log(den);
}

pub fn fill(buffer: []f64, generator: std.Random, shape: f64) []f64 {
    assert(0 < shape and shape < 1);
    if (shape == 0.5) {
        for (buffer) |*x| {
            x.* = generator.float(f64);
        }
        return buffer;
    }
    const shape2 = 1 - shape;
    const mc = (2 * shape - 1) / shape2;
    const log_den = @log(shape / shape2);
    for (buffer) |*x| {
        const uni = generator.float(f64);
        x.* = @log(1 + mc * uni) / log_den;
    }
    return buffer;
}

const expectEqual = std.testing.expectEqual;
const expectApproxEqRel = std.testing.expectApproxEqRel;
const eps = 10 * std.math.floatEps(f64); // 2.22 × 10^-15

// zig fmt: off
test density {
    try expectEqual(0, density(-inf, 0.2));
    try expectEqual(0, density( inf, 0.2));

    try expectApproxEqRel(1, density(0  , 0.5), eps);
    try expectApproxEqRel(1, density(0.5, 0.5), eps);
    try expectApproxEqRel(1, density(1  , 0.5), eps);

    try expectApproxEqRel(1.848392481493187, density(0  , 0.2), eps);
    try expectApproxEqRel(1.400819552806244, density(0.2, 0.2), eps);
    try expectApproxEqRel(0.609742125385850, density(0.8, 0.2), eps);
    try expectApproxEqRel(0.462098120373296, density(1  , 0.2), eps);
}

test probability {
    try expectEqual(0, probability(-inf, 0.2));
    try expectEqual(1, probability( inf, 0.2));

    try expectApproxEqRel(0  , probability(0  , 0.5), eps);
    try expectApproxEqRel(0.5, probability(0.5, 0.5), eps);
    try expectApproxEqRel(1  , probability(1  , 0.5), eps);

    try expectApproxEqRel(0                 , probability(0  , 0.2), eps);
    try expectApproxEqRel(0.3228556223264012, probability(0.2, 0.2), eps);
    try expectApproxEqRel(0.8934973630757019, probability(0.8, 0.2), eps);
    try expectApproxEqRel(1                 , probability(1  , 0.2), eps);
}

test quantile {
    try expectApproxEqRel(0  , quantile(0  , 0.5), eps);
    try expectApproxEqRel(0.5, quantile(0.5, 0.5), eps);
    try expectApproxEqRel(1  , quantile(1  , 0.5), eps);

    try expectApproxEqRel(0                 , quantile(0  , 0.2), eps);
    try expectApproxEqRel(0.1172326268185114, quantile(0.2, 0.2), eps);
    try expectApproxEqRel(0.2572865864148791, quantile(0.4, 0.2), eps);
    try expectApproxEqRel(0.4312482381250325, quantile(0.6, 0.2), eps);
    try expectApproxEqRel(0.6609640474436811, quantile(0.8, 0.2), eps);
    try expectApproxEqRel(1                 , quantile(1  , 0.2), eps);
}
