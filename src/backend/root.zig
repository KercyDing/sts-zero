const builtin = @import("builtin");

const sdl3 = @import("sdl3");

pub const metal = @import("metal/metal.zig");
pub const vulkan = @import("vulkan/vulkan.zig");

const current = switch (builtin.target.os.tag) {
    .macos => metal,
    .linux, .windows => vulkan,
    else => @compileError("Unsupported platform"),
};

pub const Renderer = current.Renderer;
pub const FrameSurface = current.FrameSurface;

pub fn configPlatform() !void {
    try current.configPlatform();
}

pub fn windowFlags() sdl3.video.Window.Flags {
    return current.windowFlags();
}
