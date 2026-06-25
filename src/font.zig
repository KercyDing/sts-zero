//! Embeds font assets with process lifetime.

const impeller = @import("impeller");

pub const Family = union(enum) {
    NotoSans,
};

pub fn loadFontBytes(family_name: Family) []const u8 {
    const path = "assets/fonts/" ++
        @as([]const u8, @tagName(family_name)) ++
        ".ttf";

    return @as([]const u8, @embedFile(path));
}
