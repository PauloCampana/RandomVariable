//! Support: X ∈ [0,∞)
//!
//! Parameters:
//! - σ: `scale` ∈ (0,∞)

const std = @import("std");
const assert = std.debug.assert;
const isFinite = std.math.isFinite;
const isNan = std.math.isNan;
const inf = std.math.inf(f64);

/// f(x) = x / σ^2 exp(-x^2 / 2σ^2)).
pub fn density(x: f64, scale: f64) f64 {
    assert(isFinite(scale));
    assert(scale > 0);
    assert(!isNan(x));
    if (x < 0 or x == inf) {
        return 0;
    }
    const z = x / scale;
    return z / scale * @exp(-0.5 * z * z);
}

/// F(q) = 1 - exp(-q^2 / 2σ^2).
pub fn probability(q: f64, scale: f64) f64 {
    assert(isFinite(scale));
    assert(scale > 0);
    assert(!isNan(q));
    if (q <= 0) {
        return 0;
    }
    const z = q / scale;
    return -std.math.expm1(-0.5 * z * z);
}

/// Q(p) = σ sqrt(-2ln(1 - p)).
pub fn quantile(p: f64, scale: f64) f64 {
    assert(isFinite(scale));
    assert(scale > 0);
    assert(0 <= p and p <= 1);
    return scale * @sqrt(2 * -std.math.log1p(-p));
}

pub fn random(generator: std.Random, scale: f64) f64 {
    assert(isFinite(scale));
    assert(scale > 0);
    const exp = generator.floatExp(f64);
    return scale * @sqrt(2 * exp);
}

pub fn fill(buffer: []f64, generator: std.Random, scale: f64) []f64 {
    assert(isFinite(scale));
    assert(scale > 0);
    for (buffer) |*x| {
        const exp = generator.floatExp(f64);
        x.* = scale * @sqrt(2 * exp);
    }
    return buffer;
}

const expectEqual = std.testing.expectEqual;
const expectApproxEqRel = std.testing.expectApproxEqRel;
const eps = 10 * std.math.floatEps(f64); // 2.22 × 10^-15

// zig fmt: off
test density {
    try expectEqual(0, density(-inf, 3));
    try expectEqual(0, density( inf, 3));

    try expectApproxEqRel(0                 , density(0, 1), eps);
    try expectApproxEqRel(0.6065306597126334, density(1, 1), eps);
    try expectApproxEqRel(0.2706705664732253, density(2, 1), eps);
}

test probability {
    try expectEqual(0, probability(-inf, 3));
    try expectEqual(1, probability( inf, 3));

    try expectApproxEqRel(0                 , probability(0, 1), eps);
    try expectApproxEqRel(0.3934693402873665, probability(1, 1), eps);
    try expectApproxEqRel(0.8646647167633873, probability(2, 1), eps);
}

test quantile {
    try expectApproxEqRel(0                 , quantile(0  , 1), eps);
    try expectApproxEqRel(0.6680472308365775, quantile(0.2, 1), eps);
    try expectApproxEqRel(1.0107676525947896, quantile(0.4, 1), eps);
    try expectApproxEqRel(1.3537287260556710, quantile(0.6, 1), eps);
    try expectApproxEqRel(1.7941225779941014, quantile(0.8, 1), eps);
    try expectEqual      (inf               , quantile(1  , 1)     );
}
