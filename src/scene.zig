const impeller = @import("impeller");

pub const Scene = struct {
    display_list: impeller.DisplayList,

    pub fn deinit(self: *Scene) void {
        self.display_list.deinit();
    }
};

pub fn createScene(context: impeller.Context) !Scene {
    _ = context;

    const display_list = try createDisplayList();
    errdefer display_list.deinit();

    return .{
        .display_list = display_list,
    };
}

fn createDisplayList() !impeller.DisplayList {
    var builder = try impeller.DisplayListBuilder.init(null);
    defer builder.deinit();

    var paint = try impeller.Paint.init();
    defer paint.deinit();

    paint.setColor(impeller.srgb(1.0, 1.0, 1.0, 1.0));
    builder.drawPaint(paint);

    paint.setColor(impeller.srgb(0.2, 0.4, 1.0, 1.0));
    builder.drawRect(impeller.rect(120.0, 100.0, 240.0, 160.0), paint);

    return builder.build();
}
