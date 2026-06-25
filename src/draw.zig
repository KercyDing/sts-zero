const impeller = @import("impeller");

const config = @import("config");

const App = @import("app.zig").App;
const canvas_mod = @import("render/canvas.zig");
const Canvas = canvas_mod.Canvas;
const colors = @import("render/colors.zig");

pub const SurfaceSize = struct {
    width: usize,
    height: usize,
};

pub fn buildDisplayList(app: *const App, surface_size: SurfaceSize) !impeller.DisplayList {
    var builder = try impeller.DisplayListBuilder.init(null);
    defer builder.deinit();

    var paint = try impeller.Paint.init();
    defer paint.deinit();

    var canvas = Canvas{
        .builder = &builder,
        .paint = &paint,
    };

    applyViewportScale(&canvas, surface_size);
    try drawApp(&canvas, app);

    return builder.build();
}

fn applyViewportScale(canvas: *Canvas, surface_size: SurfaceSize) void {
    const scale_x = @as(f32, @floatFromInt(surface_size.width)) / config.logical_width;
    const scale_y = @as(f32, @floatFromInt(surface_size.height)) / config.logical_height;

    canvas.builder.scale(scale_x, scale_y);
}

fn drawApp(canvas: *Canvas, app: *const App) !void {
    // Root background.
    canvas.clear(colors.bg);

    // Draw scene.
    switch (app.scene) {
        .main_menu => {
            try drawMainMenu(canvas, app);
        },
        .map => {
            try drawMap(canvas, app);
        },
        .combat => {
            try drawCombat(canvas, app);
        },
    }
}

fn drawMainMenu(canvas: *Canvas, app: *const App) !void {
    _ = app;

    canvas.roundedRect(
        160.0,
        90.0,
        960.0,
        540.0,
        24.0,
        colors.panel,
    );

    try canvas.text("STS-Zero", .NotoSans, .{
        .font_size = 36.0,
        .width = 960.0,
        .alignment = .center,
        .color = colors.text,
    }, 160.0, 180.0);

    canvas.roundedRect(
        520.0,
        340.0,
        240.0,
        64.0,
        14.0,
        colors.gray,
    );

    try canvas.text("Start Game", .NotoSans, .{
        .font_size = 24.0,
        .width = 240.0,
        .alignment = .center,
        .color = colors.white,
    }, 520.0, 360.0);
}

// Map scene of the game.
fn drawMap(canvas: *Canvas, app: *const App) !void {
    _ = app;

    canvas.roundedRect(
        160.0,
        90.0,
        960.0,
        540.0,
        24.0,
        colors.panel,
    );

    try canvas.text("Map", .NotoSans, .{
        .font_size = 36.0,
        .width = 960.0,
        .alignment = .center,
        .color = colors.text,
    }, 160.0, 180.0);

    canvas.roundedRect(
        520.0,
        340.0,
        240.0,
        64.0,
        14.0,
        colors.gray,
    );

    try canvas.text("Map here", .NotoSans, .{
        .font_size = 24.0,
        .width = 240.0,
        .alignment = .center,
        .color = colors.white,
    }, 520.0, 360.0);
}

// Combat scene of the game.
fn drawCombat(canvas: *Canvas, app: *const App) !void {
    _ = app;

    canvas.roundedRect(
        160.0,
        90.0,
        960.0,
        540.0,
        24.0,
        colors.panel,
    );

    try canvas.text("Combat", .NotoSans, .{
        .font_size = 36.0,
        .width = 960.0,
        .alignment = .center,
        .color = colors.text,
    }, 160.0, 180.0);

    canvas.roundedRect(
        520.0,
        340.0,
        240.0,
        64.0,
        14.0,
        colors.gray,
    );

    try canvas.text("Esc to back", .NotoSans, .{
        .font_size = 24.0,
        .width = 240.0,
        .alignment = .center,
        .color = colors.white,
    }, 520.0, 360.0);
}
