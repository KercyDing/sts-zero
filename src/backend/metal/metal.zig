const impeller = @import("impeller");
const sdl3 = @import("sdl3");

pub fn configPlatform() !void {}

pub fn windowFlags() sdl3.video.Window.Flags {
    return .{
        .metal = true,
        .high_pixel_density = true,
    };
}

pub const Renderer = struct {
    impeller_context: impeller.Context,
    view: sdl3.MetalView,
    layer: *anyopaque,

    pub fn init(window: sdl3.video.Window) !Renderer {
        var impeller_context = try impeller.Context.initMetal();
        errdefer impeller_context.deinit();

        const view = sdl3.MetalView.init(window) orelse return error.CreateMetalViewFailed;
        errdefer view.deinit();

        const layer = view.getLayer() orelse return error.MetalLayerUnavailable;
        _ = macosSdl3ConfigureMetalLayer(layer) orelse return error.ConfigureMetalLayerFailed;

        return .{
            .impeller_context = impeller_context,
            .view = view,
            .layer = layer,
        };
    }

    pub fn deinit(self: *Renderer) void {
        self.view.deinit();
        self.impeller_context.deinit();
    }

    pub fn context(self: Renderer) impeller.Context {
        return self.impeller_context;
    }

    pub fn acquireSurface(self: Renderer, window: sdl3.video.Window) !FrameSurface {
        const size = try window.getSizeInPixels();
        const drawable = macosSdl3AcquireNextDrawable(
            self.layer,
            @floatFromInt(size[0]),
            @floatFromInt(size[1]),
        ) orelse return error.AcquireMetalDrawableFailed;
        errdefer macosSdl3ReleaseDrawable(drawable);

        return .{
            .surface = try impeller.Surface.wrapMetalDrawable(self.impeller_context, drawable),
            .drawable = drawable,
        };
    }
};

pub const FrameSurface = struct {
    surface: impeller.Surface,
    drawable: *anyopaque,

    pub fn deinit(self: *FrameSurface) void {
        self.surface.deinit();
        macosSdl3ReleaseDrawable(self.drawable);
    }

    pub fn draw(self: FrameSurface, display_list: impeller.DisplayList) !void {
        try self.surface.draw(display_list);
    }

    pub fn present(self: FrameSurface) !void {
        try self.surface.present();
    }
};

extern fn macosSdl3ConfigureMetalLayer(layer_ptr: *anyopaque) ?*anyopaque;
extern fn macosSdl3AcquireNextDrawable(
    layer_ptr: *anyopaque,
    width: f64,
    height: f64,
) ?*anyopaque;
extern fn macosSdl3ReleaseDrawable(drawable_ptr: *anyopaque) void;
