const impeller = @import("impeller");

const colors = @import("colors.zig");
const font = @import("font");

pub const TextOptions = struct {
    font_size: f32 = 18.0,
    width: f32 = 300.0,
    color: impeller.Color = colors.black,
    alignment: impeller.TextAlignment = .left,
    direction: impeller.TextDirection = .ltr,
    height: f32 = 1.0,
    weight: impeller.FontWeight = .normal,
    max_lines: ?u32 = null,
    ellipsis: ?[:0]const u8 = null,
};

pub const TextRenderer = struct {
    typo_context: impeller.TypographyContext,

    pub fn init(
        family_name: font.Family,
    ) !TextRenderer {
        var context = try impeller.TypographyContext.init();
        errdefer context.deinit();

        const font_bytes = font.loadFontBytes(family_name);

        try context.registerFontBorrowed(font_bytes, @tagName(family_name));

        return .{
            .typo_context = context,
        };
    }

    pub fn deinit(self: *TextRenderer) void {
        self.typo_context.deinit();
    }

    pub fn buildParagraph(
        self: *TextRenderer,
        content: []const u8,
        options: TextOptions,
    ) !impeller.Paragraph {
        var para_fg = try impeller.Paint.init(); // paragraphy foreground
        defer para_fg.deinit();
        para_fg.setColor(options.color);

        var para_style = try impeller.ParagraphStyle.init();
        defer para_style.deinit();
        para_style.setForeground(para_fg);
        para_style.setFontSize(options.font_size);
        para_style.setFontWeight(options.weight);
        para_style.setTextAlignment(options.alignment);
        para_style.setTextDirection(options.direction);
        para_style.setHeight(options.height);
        if (options.max_lines) |max_lines| {
            para_style.setMaxLines(max_lines);
        }
        if (options.ellipsis) |ellipsis| {
            para_style.setEllipsis(ellipsis);
        }

        var para_builder = try impeller.ParagraphBuilder.init(self.typo_context);
        defer para_builder.deinit();
        para_builder.pushStyle(para_style);
        para_builder.addText(content);
        para_builder.popStyle();

        const para = try para_builder.build(options.width);
        return para;
    }
};
