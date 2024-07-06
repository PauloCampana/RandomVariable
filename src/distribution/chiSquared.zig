//! Support: [0,∞)
//!
//! Parameters:
//! - ν: `df` ∈ (0,∞)

const std = @import("std");
const gamma = @import("gamma.zig");
const inf = std.math.inf(f64);

/// f(x) = 0.5 / gamma(ν / 2) (x / 2)^(ν / 2 - 1) exp(-x / 2)
pub fn density(x: f64, df: f64) f64 {
    return gamma.density(x, 0.5 * df, 2);
}

/// No closed form
pub fn probability(q: f64, df: f64) f64 {
    return gamma.probability(q, 0.5 * df, 2);
}

/// No closed form
pub fn survival(t: f64, df: f64) f64 {
    return gamma.survival(t, 0.5 * df, 2);
}

/// No closed form
pub fn quantile(p: f64, df: f64) f64 {
    return gamma.quantile(p, 0.5 * df, 2);
}

pub fn random(generator: std.Random, df: f64) f64 {
    return gamma.random(generator, 0.5 * df, 2);
}

pub fn fill(buffer: []f64, generator: std.Random, df: f64) void {
    gamma.fill(buffer, generator, 0.5 * df, 2);
}

export fn rv_chi_squared_density(x: f64, df: f64) f64 {
    return density(x, df);
}
export fn rv_chi_squared_probability(q: f64, df: f64) f64 {
    return probability(q, df);
}
export fn rv_chi_squared_survival(t: f64, df: f64) f64 {
    return survival(t, df);
}
export fn rv_chi_squared_quantile(p: f64, df: f64) f64 {
    return quantile(p, df);
}

const expectEqual = std.testing.expectEqual;
const expectApproxEqRel = std.testing.expectApproxEqRel;
const eps = 10 * std.math.floatEps(f64); // 2.22 × 10^-15

// zig fmt: off
test density {
    try expectEqual(0, density(-inf, 3));
    try expectEqual(0, density( inf, 3));

    try expectEqual(inf, density(0, 1.8));
    try expectEqual(0.5, density(0, 2  ));
    try expectEqual(0  , density(0, 2.2));

    try expectApproxEqRel(0                 , density(0, 3), eps);
    try expectApproxEqRel(0.2419707245191434, density(1, 3), eps);
    try expectApproxEqRel(0.2075537487102973, density(2, 3), eps);
}

test probability {
    try expectEqual(0, probability(-inf, 3));
    try expectEqual(1, probability( inf, 3));

    try expectApproxEqRel(0                 , probability(0, 3), eps);
    try expectApproxEqRel(0.1987480430987992, probability(1, 3), eps);
    try expectApproxEqRel(0.4275932955291208, probability(2, 3), eps);
}

test survival {
    try expectEqual(1, survival(-inf, 3));
    try expectEqual(0, survival( inf, 3));

    try expectApproxEqRel(1                 , survival(0, 3), eps);
    try expectApproxEqRel(0.8012519569012008, survival(1, 3), eps);
    try expectApproxEqRel(0.5724067044708798, survival(2, 3), eps);
}

test quantile {
    try expectApproxEqRel(0                , quantile(0  , 3), eps);
    try expectApproxEqRel(1.005174013052349, quantile(0.2, 3), eps);
    try expectApproxEqRel(1.869168403388716, quantile(0.4, 3), eps);
    try expectApproxEqRel(2.946166073101952, quantile(0.6, 3), eps);
    try expectApproxEqRel(4.641627676087445, quantile(0.8, 3), eps);
    try expectEqual      (inf              , quantile(1  , 3)     );
}
