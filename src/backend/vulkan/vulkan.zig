const builtin = @import("builtin");

const impeller = @import("impeller");
const sdl3 = @import("sdl3");

pub fn configPlatform() !void {
    switch (builtin.target.os.tag) {
        // Keep the current Linux path on X11 here.
        // Wayland doesn't have good support for impeller.
        .linux => try sdl3.hints.setWithPriority(.video_driver, "x11", .override),
        .windows => {},
        else => unreachable,
    }
}

pub fn windowFlags() sdl3.video.Window.Flags {
    return .{
        .vulkan = true,
        .high_pixel_density = true,
    };
}

pub const Renderer = struct {
    impeller_context: impeller.Context,
    swapchain: impeller.VulkanSwapchain,

    pub fn init(window: sdl3.video.Window) !Renderer {
        var impeller_context = try impeller.Context.initVulkan(.{
            .user_data = null,
            .proc_address_callback = VulkanProcResolver.resolve,
            .enable_vulkan_validation = true,
        });
        errdefer impeller_context.deinit();

        const vulkan_info = impeller_context.vulkanInfo() orelse return error.VulkanInfoUnavailable;

        if (!sdl3.vulkan.getPresentationSupport(
            @ptrCast(vulkan_info.vk_instance),
            @ptrCast(vulkan_info.vk_physical_device),
            vulkan_info.graphics_queue_family_index,
        )) {
            return error.PresentationUnsupported;
        }

        const vulkan_surface = try sdl3.vulkan.Surface.init(
            window,
            @ptrCast(vulkan_info.vk_instance),
            null,
        );

        var swapchain = try impeller.VulkanSwapchain.init(
            impeller_context,
            @ptrCast(vulkan_surface.surface),
        );
        errdefer swapchain.deinit();

        return .{
            .impeller_context = impeller_context,
            .swapchain = swapchain,
        };
    }

    pub fn deinit(self: *Renderer) void {
        self.swapchain.deinit();
        self.impeller_context.deinit();
    }

    pub fn context(self: Renderer) impeller.Context {
        return self.impeller_context;
    }

    pub fn acquireSurface(self: Renderer, window: sdl3.video.Window) !FrameSurface {
        _ = window;
        return .{ .surface = try self.swapchain.acquireNextSurface() };
    }
};

pub const FrameSurface = struct {
    surface: impeller.Surface,

    pub fn deinit(self: *FrameSurface) void {
        self.surface.deinit();
    }

    pub fn draw(self: FrameSurface, display_list: impeller.DisplayList) !void {
        try self.surface.draw(display_list);
    }

    pub fn present(self: FrameSurface) !void {
        try self.surface.present();
    }
};

const VulkanProcResolver = struct {
    fn resolve(
        instance: ?*anyopaque,
        proc_name: [*c]const u8,
        user_data: ?*anyopaque,
    ) callconv(.c) ?*anyopaque {
        _ = user_data;
        const GetProcAddr = *const fn (?*anyopaque, [*c]const u8) callconv(.c) ?*anyopaque;
        const get_proc_addr: GetProcAddr =
            @ptrCast(sdl3.vulkan.getVkGetInstanceProcAddr() catch return null);
        return get_proc_addr(instance, proc_name);
    }
};
