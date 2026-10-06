// A small test program to exercise most of ZIGR's features.
// translated from https://raw.githubusercontent.com/erkkah/tigr/f7bf2abbf6b26e649ced5691003e87b61c03762e/examples/demo/demo.cpp

const std = @import("std");
const zigr = @import("zigr");

var playerx: f32 = 160;
var playery: f32 = 200;
var playerxs: f32 = 0;
var playerys: f32 = 0;
var standing: bool = true;
var remaining: f32 = 0;
var backdrop: *zigr.Window = undefined;
var screen: *zigr.Window = undefined;

// Some simple platformer-esque physics.
// I do not necessarily recommend this as a good way of implementing a platformer :)
fn update(dt: f32) void {
    if (remaining > 0)
        remaining -= dt;

    // Read the keyboard and move the player.
    if (standing and screen.keyDown(.SPACE))
        playerys -= 200;
    if (screen.keyHeld(.LEFT) or screen.keyHeld(.char('A')))
        playerxs -= 10;
    if (screen.keyHeld(.RIGHT) or screen.keyHeld(.char('D')))
        playerxs += 10;

    var oldx = playerx;
    var oldy = playery;

    // Apply simply physics.
    playerxs *= @exp(-10.0 * dt);
    playerys *= @exp(-2.0 * dt);
    playerys += dt * 200.0;
    playerx += dt * playerxs;
    playery += dt * playerys;

    // Apply collision.
    if (playerx < 8) {
        playerx = 8;
        playerxs = 0;
    }

    if (playerx > @as(f32, @floatFromInt(screen.w)) - 8) {
        playerx = @as(f32, @floatFromInt(screen.w)) - 8;
        playerxs = 0;
    }

    // Apply playfield collision and stepping.
    const dx = (playerx - oldx) / 10;
    var dy = (playery - oldy) / 10;
    standing = false;
    for (0..10) |_| {
        var p = backdrop.get(@intFromFloat(oldx), @intFromFloat(oldy - 1));
        if (p.r == 0 and p.g == 0 and p.b == 0)
            oldy -= 1;
        p = backdrop.get(@intFromFloat(oldx), @intFromFloat(oldy));
        if (p.r == 0 and p.g == 0 and p.b == 0 and playerys > 0) {
            playerys = 0;
            dy = 0;
            standing = true;
        }
        oldx += dx;
        oldy += dy;
    }

    playerx = oldx;
    playery = oldy;
}

pub fn main(init: std.process.Init) !void {
    // Load our sprite.
    const squinkle = zigr.loadImage("examples/squinkle.png") orelse {
        std.log.err("error loading `squinkle.png`", .{});
        return;
    };
    defer squinkle.free();

    // Load some UTF-8 text.
    const greetingFile = try std.Io.Dir.cwd().openFile(init.io, "examples/greeting.txt", .{});
    defer greetingFile.close(init.io);
    var greetingReader = greetingFile.reader(init.io, &.{});
    const greeting = try greetingReader.interface.allocRemaining(init.gpa, .unlimited);
    defer init.gpa.free(greeting);
    const greetingZ = try init.gpa.dupeSentinel(u8, greeting, 0);
    defer init.gpa.free(greetingZ);

    // Make a window and an off-screen backdrop.
    screen = zigr.initWindow(320, 240, greetingZ, .{ .scale = .x2 });
    defer screen.free();

    backdrop = zigr.initBitmap(screen.w, screen.h);
    defer backdrop.free();

    // Fill in the background.
    backdrop.clear(.initRGB(80, 180, 255));
    backdrop.fill(0, 200, 320, 40, .initRGB(60, 120, 60));
    backdrop.fill(0, 200, 320, 3, .initRGB(0, 0, 0));
    backdrop.line(0, 201, 320, 201, .initRGB(255, 255, 255));

    // Enable post fx
    screen.setPostFX(1, 1, 1, 2.0);

    var prevx: i32 = 0;
    var prevy: i32 = 0;
    var prev: bool = false;

    // Maintain a list of characters entered.
    var chars: [16]i32 = @splat('_');

    // Repeat till they close the window.
    while (!screen.closed() and !screen.keyDown(.ESCAPE)) {
        // Update the game.
        const dt = zigr.time();
        update(dt);

        // Read the mouse and draw lines when pressed.
        const m = screen.mouse();
        if (m.left) {
            if (prev)
                backdrop.line(prevx, prevy, m.x, m.y, .initRGB(0, 0, 0));
            prevx = m.x;
            prevy = m.y;
            prev = true;
        } else {
            prev = false;
        }

        // Composite the backdrop and sprite onto the screen.
        zigr.blit(screen, backdrop, 0, 0, 0, 0, backdrop.w, backdrop.h);
        zigr.blitAlpha(
            screen,
            squinkle,
            @as(i32, @intFromFloat(playerx)) - @divFloor(squinkle.w, 2),
            @as(i32, @intFromFloat(playery)) - squinkle.h,
            0,
            0,
            squinkle.w,
            squinkle.h,
            1.0,
        );

        screen.print(null, 10, 10, .initRGBA(0xc0, 0xd0, 0xff, 0xc0), greetingZ);
        screen.print(null, 10, 222, .initRGBA(0xff, 0xff, 0xff, 0xff), "A D + SPACE");

        // Grab any chars and add them to our buffer.
        while (true) {
            const c = screen.readChar();
            if (c == null) break;
            for (1..16) |n| {
                chars[n - 1] = chars[n];
            }
            chars[15] = @backingInt(c.?);
        }
        // Print out the character buffer too.
        var p: usize = 7;
        var out: [100]u8 = @splat(0);
        @memcpy(out[0..7], "Chars: ");
        for (chars) |char| {
            p += try std.unicode.utf8Encode(@intCast(char), out[p..]);
        }
        screen.print(null, 160, 222, .initRGB(255, 255, 255), out[0..p :0]);

        // Update the window.
        screen.update();
    }
}
