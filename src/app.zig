const sdl3 = @import("sdl3");
const events = sdl3.events;

pub const App = struct {
    quit: bool = false,
    input: Input = .{},

    pub fn init() @This() {
        return .{
            .quit = false,
        };
    }

    pub fn beginFrame(self: *App) void {
        self.input.beginFrame();
    }

    pub fn update(self: *App, dt: f32) void {
        _ = self;
        _ = dt;
    }

    pub fn handleEvent(self: *App, event: events.Event) void {
        switch (event) {
            .quit, .terminating => {
                self.quit = true;
            },
            .key_down => |key| {
                self.handleKeyDown(key);
            },
            .key_up => |key| {
                self.handleKeyUp(key);
            },
            .mouse_motion => |motion| {
                self.handleMouseMotion(motion);
            },
            .mouse_button_down => |button| {
                self.handleMouseButtonDown(button);
            },
            .mouse_button_up => |button| {
                self.handleMouseButtonUp(button);
            },
            .mouse_wheel => |wheel| {
                self.handleMouseWheel(wheel);
            },
            else => {},
        }
    }

    pub fn handleKeyDown(self: *App, key: events.Keyboard) void {
        _ = self;
        _ = key;
    }

    pub fn handleKeyUp(self: *App, key: events.Keyboard) void {
        _ = self;
        _ = key;
    }

    pub fn handleMouseMotion(self: *App, motion: events.MouseMotion) void {
        _ = self;
        _ = motion;
    }

    pub fn handleMouseButtonDown(self: *App, button: events.MouseButton) void {
        _ = self;
        _ = button;
    }

    pub fn handleMouseButtonUp(self: *App, button: events.MouseButton) void {
        _ = self;
        _ = button;
    }

    pub fn handleMouseWheel(self: *App, wheel: events.MouseWheel) void {
        _ = self;
        _ = wheel;
    }
};

const Input = struct {
    mouse_x: f32 = 0,
    mouse_y: f32 = 0,

    mouse_down: bool = false,
    mouse_pressed: bool = false,
    mouse_released: bool = false,

    esc_pressed: bool = false,

    pub fn beginFrame(self: *Input) void {
        self.mouse_pressed = false;
        self.mouse_released = false;
        self.esc_pressed = false;
    }
};
