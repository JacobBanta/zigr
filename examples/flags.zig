// translated from https://raw.githubusercontent.com/erkkah/tigr/f7bf2abbf6b26e649ced5691003e87b61c03762e/examples/flags/flags.c
const std = @import("std");
const zigr = @import("zigr");

const white = zigr.Pixel.initRGB(255, 255, 255);
const yellow = zigr.Pixel.initRGB(255, 255, 0);
const black = zigr.Pixel.initRGB(0, 0, 0);
const initialW = 400;
const initialH = 400;

fn makeDemoWindow(w: i32, h: i32, flags: zigr.WindowFlags) *zigr.Window {
    return zigr.initWindow(w, h, "Flag tester", flags);
}

fn drawDemoWindow(win: *zigr.Window, allocator: std.mem.Allocator) !void {
    const lineColor: zigr.Pixel = .initRGB(100, 100, 100);
    win.line(0, 0, win.w - 1, win.h - 1, lineColor);
    win.line(0, win.h - 1, win.w - 1, 0, lineColor);
    win.rect(0, 0, win.w, win.h, .initRGB(200, 10, 10));

    const text = try allocator.print("{d}x{d}\x00", .{ win.w, win.h });
    defer allocator.free(text);
    win.print(null, 5, 5, .initRGB(20, 200, 0), text[0 .. text.len - 1 :0]);
}

const Toggle = struct {
    text: [:0]const u8,
    checked: bool = false,
    value: zigr.WindowFlags,
    key: zigr.Key,
    color: zigr.Pixel,
};

fn drawToggle(bmp: *zigr.Window, toggle: *const Toggle, x: i32, y: i32, stride: i32) void {
    const height = zigr.textHeight(null, toggle.text);
    const width = zigr.textWidth(null, toggle.text);

    var yOffset = @divFloor(stride, 2);
    const xOffset = @divTrunc(width, -2);

    bmp.print(null, x + xOffset, y + yOffset, toggle.color, toggle.text);

    yOffset += if (toggle.checked) height else (@divFloor(height, 3));
    var lineColor: zigr.Pixel = toggle.color;
    lineColor.a = 240;
    bmp.line(x + xOffset, y + yOffset, x + xOffset + width, y + yOffset, lineColor);
}

pub fn main(init: std.process.Init) error{OutOfMemory}!void {
    var flags: zigr.WindowFlags = .{};

    var win = makeDemoWindow(initialW, initialH, flags);
    defer win.free();

    var toggles = [_]Toggle{
        .{ .text = "(A)UTO", .value = .{ .size = .auto }, .key = .char('A'), .color = white },
        .{ .text = "(R)ETINA", .value = .{ .retina = true }, .key = .char('R'), .color = white },
        .{ .text = "(F)ULLSCREEN", .value = .{ .fullscreen = true }, .key = .char('F'), .color = white },
        .{ .text = "(2)X", .value = .{ .scale = .x2 }, .key = .char('2'), .color = yellow },
        .{ .text = "(3)X", .value = .{ .scale = .x3 }, .key = .char('3'), .color = yellow },
        .{ .text = "(4)X", .value = .{ .scale = .x4 }, .key = .char('4'), .color = yellow },
        .{ .text = "(N)OCURSOR", .value = .{ .nocursor = true }, .key = .char('N'), .color = white },
    };

    while (!win.closed() and !(win.keyDown(.ESCAPE))) {
        win.clear(black);

        try drawDemoWindow(win, init.gpa);

        const stepY = @divFloor(win.h, @as(i32, @intCast(toggles.len)));
        var toggleY: i32 = 0;
        const toggleX = @divFloor(win.w, 2);
        var changed: bool = false;

        {
            var newFlags: zigr.WindowFlags = .{};
            for (&toggles) |*toggle| {
                if (win.keyDown(toggle.key)) {
                    toggle.checked = !toggle.checked;
                    changed = true;
                }
                if (toggle.checked) {
                    if (toggle.value.size == .auto)
                        newFlags.size = .auto;
                    if (toggle.value.fullscreen)
                        newFlags.fullscreen = true;
                    if (toggle.value.retina)
                        newFlags.retina = true;
                    if (toggle.value.scale != .x1)
                        newFlags.scale = toggle.value.scale;
                    if (toggle.value.nocursor)
                        newFlags.nocursor = true;
                }
                drawToggle(win, toggle, toggleX, toggleY, stepY);

                toggleY += stepY;
            }

            if (changed) {
                changed = false;
                const modeChange = (flags.size != newFlags.size) or (flags.retina != newFlags.retina);
                flags = newFlags;

                const w = if (modeChange) initialW else win.w;
                const h = if (modeChange) initialH else win.h;
                win.free();
                win = makeDemoWindow(w, h, flags);
            }
        }

        win.update();
    }
}
