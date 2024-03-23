//! Support: X ∈ (-∞,∞)
//!
//! Parameters:
//! - μ: `location` ∈ (-∞,∞)
//! - σ: `scale`    ∈ ( 0,∞)

const std = @import("std");
const assert = std.debug.assert;
const isFinite = std.math.isFinite;
const isNan = std.math.isNan;
const inf = std.math.inf(f64);

pub const discrete = false;

/// f(x) = exp(-|x - μ| / σ) / 2σ.
pub fn density(x: f64, location: f64, scale: f64) f64 {
    assert(isFinite(location) and isFinite(scale));
    assert(scale > 0);
    assert(!isNan(x));
    const z = @abs(x - location) / scale;
    return @exp(-z) / (2 * scale);
}

/// F(q) =     exp(+(q - μ) / σ)) / 2, x < μ.
///
/// F(q) = 1 - exp(-(q - μ) / σ)) / 2, x > μ.
pub fn probability(q: f64, location: f64, scale: f64) f64 {
    assert(isFinite(location) and isFinite(scale));
    assert(scale > 0);
    assert(!isNan(q));
    const z = (q - location) / scale;
    if (q < location) {
        return 0.5 * @exp(z);
    } else {
        return 1 - 0.5 * @exp(-z);
    }
}

/// Q(p) = μ + σ ln(2p),       0.0 < p < 0.5.
///
/// Q(p) = μ - σ ln(2(1 - p)), 0.5 < p < 1.0.
pub fn quantile(p: f64, location: f64, scale: f64) f64 {
    assert(isFinite(location) and isFinite(scale));
    assert(scale > 0);
    assert(0 <= p and p <= 1);
    const q = if (p <= 0.5) @log(2 * p) else -@log(2 * (1 - p));
    return location + scale * q;
}

pub fn random(generator: std.Random, location: f64, scale: f64) f64 {
    assert(isFinite(location) and isFinite(scale));
    assert(scale > 0);
    const exp = generator.floatExp(f64);
    const uni = generator.float(f64);
    return location + scale * if (uni < 0.5) exp else -exp;
}

pub fn fill(buffer: []f64, generator: std.Random, location: f64, scale: f64) []f64 {
    assert(isFinite(location) and isFinite(scale));
    assert(scale > 0);
    for (buffer) |*x| {
        const exp = generator.floatExp(f64);
        const uni = generator.float(f64);
        x.* = location + scale * if (uni < 0.5) exp else -exp;
    }
    return buffer;
}

const expectEqual = std.testing.expectEqual;
const expectApproxEqRel = std.testing.expectApproxEqRel;
const eps = 10 * std.math.floatEps(f64); // 2.22 × 10^-15

// zig fmt: off
test "laplace.density" {
    try expectEqual(0, density(-inf, 0, 1));
    try expectEqual(0, density( inf, 0, 1));

    try expectApproxEqRel(0.5               , density(0, 0, 1), eps);
    try expectApproxEqRel(0.1839397205857211, density(1, 0, 1), eps);
    try expectApproxEqRel(0.0676676416183063, density(2, 0, 1), eps);
}

test "laplace.probability" {
    try expectEqual(0, probability(-inf, 0, 1));
    try expectEqual(1, probability( inf, 0, 1));

    try expectApproxEqRel(0.5               , probability(0, 0, 1), eps);
    try expectApproxEqRel(0.8160602794142788, probability(1, 0, 1), eps);
    try expectApproxEqRel(0.9323323583816936, probability(2, 0, 1), eps);
}

test "laplace.quantile" {
    try expectEqual      (-inf               , quantile(0  , 0, 1)     );
    try expectApproxEqRel(-0.9162907318741550, quantile(0.2, 0, 1), eps);
    try expectApproxEqRel(-0.2231435513142097, quantile(0.4, 0, 1), eps);
    try expectApproxEqRel( 0.2231435513142097, quantile(0.6, 0, 1), eps);
    try expectApproxEqRel( 0.9162907318741550, quantile(0.8, 0, 1), eps);
    try expectEqual      ( inf               , quantile(1  , 0, 1)     );
}
