const impeller = @import("impeller");

const App = @import("app.zig").App;
const Canvas = @import("render/canvas.zig").Canvas;
const config = @import("config");

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
    // Root background in white.
    canvas.paint.setColor(impeller.srgb(1.0, 1.0, 1.0, 1.0));
    canvas.builder.drawPaint(canvas.paint.*);

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

// Main menu of the game.
fn drawMainMenu(canvas: *Canvas, app: *const App) !void {
    _ = app;

    canvas.paint.setColor(impeller.srgb(1.0, 0.0, 0.0, 1.0));
    canvas.builder.drawRect(
        impeller.rect(160.0, 90.0, 960.0, 540.0),
        canvas.paint.*,
    );
}

// Map scene of the game.
fn drawMap(canvas: *Canvas, app: *const App) !void {
    _ = app;

    canvas.paint.setColor(impeller.srgb(0.0, 1.0, 0.0, 1.0));
    canvas.builder.drawRect(
        impeller.rect(160.0, 90.0, 960.0, 540.0),
        canvas.paint.*,
    );
}

// Combat scene of the game.
fn drawCombat(canvas: *Canvas, app: *const App) !void {
    _ = app;

    canvas.paint.setColor(impeller.srgb(0.0, 0.0, 1.0, 1.0));
    canvas.builder.drawRect(
        impeller.rect(160.0, 90.0, 960.0, 540.0),
        canvas.paint.*,
    );
}
