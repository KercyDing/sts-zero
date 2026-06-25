const impeller = @import("impeller");

const font = @import("font");

const colors = @import("colors.zig");
const text_mod = @import("text.zig");

pub const Canvas = struct {
    builder: *impeller.display_list.Builder,
    paint: *impeller.paint.Paint,

    /// Clear with the given color.
    pub fn clear(self: *Canvas, color: impeller.Color) void {
        self.paint.setColor(color);
        self.builder.drawPaint(self.paint.*);
    }

    /// Draw a rectangle at position.
    pub fn rect(
        self: *Canvas,
        x: f32,
        y: f32,
        width: f32,
        height: f32,
        color: impeller.Color,
    ) void {
        self.paint.setColor(color);
        self.builder.drawRect(
            impeller.rect(x, y, width, height),
            self.paint.*,
        );
    }

    /// Draw a rounded rectangle at position.
    pub fn roundedRect(
        self: *Canvas,
        x: f32,
        y: f32,
        width: f32,
        height: f32,
        radius: f32,
        color: impeller.Color,
    ) void {
        self.paint.setColor(color);
        self.builder.drawRoundedRect(
            impeller.rect(x, y, width, height),
            impeller.RoundingRadii{
                .top_left = impeller.point(radius, radius),
                .top_right = impeller.point(radius, radius),
                .bottom_right = impeller.point(radius, radius),
                .bottom_left = impeller.point(radius, radius),
            },
            self.paint.*,
        );
    }

    /// Draw a raw texture at position.
    pub fn texture(
        self: *Canvas,
        tex: impeller.Texture,
        x: f32,
        y: f32,
        sampling: impeller.TextureSampling,
    ) void {
        self.textureTinted(
            tex,
            x,
            y,
            sampling,
            colors.white,
        );
    }

    /// Draw a tinted texture at position.
    pub fn textureTinted(
        self: *Canvas,
        tex: impeller.Texture,
        x: f32,
        y: f32,
        sampling: impeller.TextureSampling,
        tint: impeller.Color,
    ) void {
        self.paint.setColor(tint);
        self.builder.drawTexture(
            tex,
            impeller.point(x, y),
            sampling,
            self.paint.*,
        );
    }

    /// Draw a text at position.
    ///
    /// This is a high-level helper.
    /// The underlying logic is in "text.zig".
    pub fn text(
        self: *Canvas,
        content: []const u8,
        family_name: font.Family,
        options: text_mod.TextOptions,
        x: f32,
        y: f32,
    ) !void {
        var text_renderer = try text_mod.TextRenderer.init(family_name);
        defer text_renderer.deinit();

        const paragraph = try text_renderer.buildParagraph(content, options);

        self.builder.drawParagraph(
            paragraph,
            impeller.point(x, y),
        );
    }
};
