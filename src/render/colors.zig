const impeller = @import("impeller");
const srgb = impeller.srgb;

pub const transparent = srgb(0.0, 0.0, 0.0, 0.0);

pub const white = srgb(1.0, 1.0, 1.0, 1.0);
pub const black = srgb(0.0, 0.0, 0.0, 1.0);

pub const gray = gray_400;
pub const gray_50 = srgb(0.95, 0.95, 0.95, 1.0);
pub const gray_100 = srgb(0.90, 0.90, 0.90, 1.0);
pub const gray_200 = srgb(0.80, 0.80, 0.80, 1.0);
pub const gray_300 = srgb(0.65, 0.65, 0.65, 1.0);
pub const gray_400 = srgb(0.50, 0.50, 0.50, 1.0);
pub const gray_500 = srgb(0.35, 0.35, 0.35, 1.0);
pub const gray_600 = srgb(0.25, 0.25, 0.25, 1.0);
pub const gray_700 = srgb(0.18, 0.18, 0.18, 1.0);
pub const gray_800 = srgb(0.12, 0.12, 0.12, 1.0);
pub const gray_900 = srgb(0.06, 0.06, 0.06, 1.0);

pub const red = srgb(1.0, 0.0, 0.0, 1.0);
pub const green = srgb(0.0, 1.0, 0.0, 1.0);
pub const blue = srgb(0.0, 0.0, 1.0, 1.0);

pub const yellow = srgb(1.0, 1.0, 0.0, 1.0);
pub const cyan = srgb(0.0, 1.0, 1.0, 1.0);
pub const magenta = srgb(1.0, 0.0, 1.0, 1.0);

pub const orange = srgb(1.0, 0.55, 0.0, 1.0);
pub const purple = srgb(0.55, 0.25, 0.95, 1.0);
pub const pink = srgb(1.0, 0.35, 0.65, 1.0);
pub const brown = srgb(0.45, 0.28, 0.16, 1.0);
pub const gold = srgb(0.95, 0.68, 0.25, 1.0);

pub const bg = srgb(0.07, 0.07, 0.09, 1.0);
pub const panel = srgb(0.14, 0.14, 0.18, 1.0);

pub const text = srgb(0.92, 0.90, 0.86, 1.0);

pub const accent = srgb(0.35, 0.55, 1.0, 1.0);
pub const success = srgb(0.25, 0.75, 0.35, 1.0);
pub const warning = srgb(0.95, 0.68, 0.25, 1.0);
pub const danger = srgb(0.85, 0.20, 0.18, 1.0);

pub const overlay = srgb(0.0, 0.0, 0.0, 0.55);
pub const shadow = srgb(0.0, 0.0, 0.0, 0.35);
