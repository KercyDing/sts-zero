const std = @import("std");

const backend = @import("backend");
const sdl3 = @import("sdl3");

const app_mod = @import("app.zig");
const config = @import("config");
const draw = @import("draw.zig");

const WindowSize = struct {
    width: usize,
    height: usize,
};

pub fn main() !void {
    defer sdl3.shutdown();

    try backend.configPlatform();

    const init_flag = sdl3.InitFlags{ .video = true };
    try sdl3.init(init_flag);
    defer sdl3.quit(init_flag);

    const window_size = try initialWindowSize();
    const window = try sdl3.video.Window.init(
        "STS-Zero",
        window_size.width,
        window_size.height,
        backend.windowFlags(),
    );
    defer window.deinit();

    var fps_capper = sdl3.extras.FramerateCapper(f32){
        .mode = .{ .limited = config.fps },
    };
    var app = app_mod.App.init();

    var renderer = try backend.Renderer.init(window);
    defer renderer.deinit();

    while (!app.quit) {
        app.beginFrame();

        const dt = @min(fps_capper.delay(), 1.0 / 15.0);

        while (sdl3.events.poll()) |event| {
            app.handleEvent(event);
        }

        app.update(dt);

        var frame_surface = try renderer.acquireSurface(window);
        defer frame_surface.deinit();

        const drawable_size = try window.getSizeInPixels();
        try frame_surface.draw(try draw.buildDisplayList(&app, renderer.context(), .{
            .width = drawable_size[0],
            .height = drawable_size[1],
        }));
        try frame_surface.present();
    }
}

fn initialWindowSize() !WindowSize {
    const primary_display = try sdl3.video.Display.getPrimaryDisplay();
    const content_scale = try primary_display.getContentScale();
    return scaledWindowSize(content_scale);
}

fn scaledWindowSize(display_scale: f32) WindowSize {
    const scale = if (display_scale > 1.0) display_scale else 1.0;

    return .{
        .width = @intFromFloat(@round(config.logical_width * scale)),
        .height = @intFromFloat(@round(config.logical_height * scale)),
    };
}
