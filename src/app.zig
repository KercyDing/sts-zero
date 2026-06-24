const std = @import("std");
const sdl3 = @import("sdl3");
const events = sdl3.events;

/// The game's scene.
pub const Scene = enum {
    main_menu,
    map,
    combat,
};

pub const App = struct {
    quit: bool = false,
    scene: Scene = .main_menu,

    input: Input = .{},

    pub fn init() @This() {
        return .{};
    }

    pub fn beginFrame(self: *App) void {
        self.input.beginFrame();
    }

    pub fn update(self: *App, dt: f32) void {
        switch (self.scene) {
            .main_menu => self.updateMainMenu(dt),
            .map => self.updateMap(dt),
            .combat => self.updateCombat(dt),
        }
    }

    fn updateMainMenu(self: *App, dt: f32) void {
        _ = dt;

        if (self.input.mouse_pressed) {
            self.setScene(.map);
        }
    }

    fn updateMap(self: *App, dt: f32) void {
        _ = dt;

        if (self.input.mouse_pressed) {
            self.setScene(.combat);
        }
    }

    fn updateCombat(self: *App, dt: f32) void {
        _ = dt;

        if (self.input.esc_pressed) {
            self.setScene(.main_menu);
        }
    }

    pub fn setScene(self: *App, next: Scene) void {
        if (self.scene == next) return;

        std.log.debug("Scene: {s} -> {s}", .{
            @tagName(self.scene),
            @tagName(next),
        });

        self.scene = next;
    }

    pub fn handleEvent(self: *App, event: events.Event) void {
        switch (event) {
            .quit, .terminating => self.quit = true,

            .mouse_motion => |motion| {
                self.input.mouse_x = motion.x;
                self.input.mouse_y = motion.y;
            },

            .mouse_button_down => {
                self.input.mouse_down = true;
                self.input.mouse_pressed = true;
            },

            .mouse_button_up => {
                self.input.mouse_down = false;
                self.input.mouse_released = true;
            },

            .key_down => |key| {
                self.handleKeyDown(key);
            },

            else => {},
        }
    }

    pub fn handleKeyDown(self: *App, key: events.Keyboard) void {
        if (key.repeat) return;

        if (key.key) |kc| {
            switch (kc) {
                .escape => self.input.esc_pressed = true,
                else => {},
            }
        }
    }
};

/// Input event.
pub const Input = struct {
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
