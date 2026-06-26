const impeller = @import("impeller");

const config = @import("config");

const App = @import("app.zig").App;
const canvas_mod = @import("render/canvas.zig");
const colors = @import("render/colors.zig");
const Canvas = canvas_mod.Canvas;
const FragInfo = canvas_mod.FragInfo;

const mainmenu_shader = @embedFile("assets/shaders/mainmenu.iplr");
const map_shader = @embedFile("assets/shaders/map.iplr");
const compat_shader = @embedFile("assets/shaders/compat.iplr");

pub const SurfaceSize = struct {
    width: usize,
    height: usize,
};

pub fn buildDisplayList(
    app: *const App,
    context: impeller.Context,
    surface_size: SurfaceSize,
) !impeller.DisplayList {
    var builder = try impeller.DisplayListBuilder.init(null);
    defer builder.deinit();

    var paint = try impeller.Paint.init();
    defer paint.deinit();

    var canvas = Canvas{
        .builder = &builder,
        .paint = &paint,
        .context = context,
    };

    applyViewportScale(&canvas, surface_size);
    try drawApp(&canvas, app, surface_size);

    return builder.build();
}

fn applyViewportScale(canvas: *Canvas, surface_size: SurfaceSize) void {
    const scale_x = @as(f32, @floatFromInt(surface_size.width)) / config.logical_width;
    const scale_y = @as(f32, @floatFromInt(surface_size.height)) / config.logical_height;

    canvas.builder.scale(scale_x, scale_y);
}

fn drawApp(canvas: *Canvas, app: *const App, surface_size: SurfaceSize) !void {
    // Root background.
    canvas.clear(colors.bg);

    // Draw scene.
    switch (app.scene) {
        .main_menu => {
            try drawMainMenu(canvas, app, surface_size);
        },
        .map => {
            try drawMap(canvas, app, surface_size);
        },
        .combat => {
            try drawCombat(canvas, app, surface_size);
        },
    }
}

fn shaderInfo(
    surface_size: SurfaceSize,
    x: f32,
    y: f32,
    width: f32,
    height: f32,
    time: f32,
) FragInfo {
    const scale_x = @as(f32, @floatFromInt(surface_size.width)) / config.logical_width;
    const scale_y = @as(f32, @floatFromInt(surface_size.height)) / config.logical_height;

    return .{
        .resolution = .{
            @floatFromInt(surface_size.width),
            @floatFromInt(surface_size.height),
        },
        .rect_origin = .{ x * scale_x, y * scale_y },
        .rect_size = .{ width * scale_x, height * scale_y },
        .time = time,
    };
}

fn drawMainMenu(canvas: *Canvas, app: *const App, surface_size: SurfaceSize) !void {
    const panel_x = 160.0;
    const panel_y = 90.0;
    const panel_w = 960.0;
    const panel_h = 540.0;
    const frag_info = shaderInfo(surface_size, panel_x, panel_y, panel_w, panel_h, app.time);

    canvas.roundedRect(
        panel_x + 18.0,
        panel_y + 18.0,
        panel_w,
        panel_h,
        24.0,
        colors.shadow,
    );

    try canvas.shaderRoundedRect(
        mainmenu_shader,
        frag_info,
        panel_x,
        panel_y,
        panel_w,
        panel_h,
        24.0,
    );

    try canvas.text("STS-Zero", .NotoSans, .{
        .font_size = 46.0,
        .width = panel_w,
        .alignment = .center,
        .color = colors.white,
    }, panel_x, 170.0);

    canvas.roundedRect(
        520.0,
        340.0,
        240.0,
        64.0,
        14.0,
        colors.gold,
    );

    try canvas.text("Start Game", .NotoSans, .{
        .font_size = 24.0,
        .width = 240.0,
        .alignment = .center,
        .color = colors.white,
    }, 520.0, 360.0);
}

// Map scene of the game.
fn drawMap(canvas: *Canvas, app: *const App, surface_size: SurfaceSize) !void {
    const panel_x = 130.0;
    const panel_y = 92.0;
    const panel_w = 1020.0;
    const panel_h = 520.0;
    const frag_info = shaderInfo(surface_size, panel_x, panel_y, panel_w, panel_h, app.time);

    canvas.roundedRect(
        panel_x + 16.0,
        panel_y + 18.0,
        panel_w,
        panel_h,
        22.0,
        colors.shadow,
    );

    try canvas.shaderRoundedRect(
        map_shader,
        frag_info,
        panel_x,
        panel_y,
        panel_w,
        panel_h,
        22.0,
    );

    try canvas.text("Map", .NotoSans, .{
        .font_size = 42.0,
        .width = panel_w,
        .color = colors.white,
        .alignment = .center,
    }, panel_x, 124.0);
}

// Combat scene of the game.
fn drawCombat(canvas: *Canvas, app: *const App, surface_size: SurfaceSize) !void {
    const panel_x = 160.0;
    const panel_y = 90.0;
    const panel_w = 960.0;
    const panel_h = 540.0;
    const frag_info = shaderInfo(surface_size, panel_x, panel_y, panel_w, panel_h, app.time);

    canvas.roundedRect(
        panel_x + 18.0,
        panel_y + 18.0,
        panel_w,
        panel_h,
        24.0,
        colors.shadow,
    );

    try canvas.shaderRoundedRect(
        compat_shader,
        frag_info,
        panel_x,
        panel_y,
        panel_w,
        panel_h,
        24.0,
    );

    try canvas.text("Combat", .NotoSans, .{
        .font_size = 42.0,
        .width = panel_w,
        .alignment = .center,
        .color = colors.white,
    }, panel_x, 164.0);

    canvas.roundedRect(
        520.0,
        340.0,
        240.0,
        64.0,
        14.0,
        colors.danger,
    );

    try canvas.text("Esc to back", .NotoSans, .{
        .font_size = 24.0,
        .width = 240.0,
        .alignment = .center,
        .color = colors.white,
    }, 520.0, 360.0);
}
