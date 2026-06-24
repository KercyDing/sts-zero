const impeller = @import("impeller");

pub const Canvas = struct {
    builder: *impeller.display_list.Builder,
    paint: *impeller.paint.Paint,
};
