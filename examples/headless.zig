// translated from https://raw.githubusercontent.com/erkkah/tigr/f7bf2abbf6b26e649ced5691003e87b61c03762e/examples/headless/headless.c
const std = @import("std");
const zigr = @import("zigr");

pub fn main() void {
    const bmp = zigr.initBitmap(320, 240);
    defer bmp.free();
    bmp.clear(.initRGB(0x80, 0x90, 0xa0));
    bmp.print(null, 120, 110, .initRGB(0xff, 0xff, 0xff), "Hello, world.");
    if (bmp.saveImage("headless.png") == 0) {
        std.log.err("something went wrong saving the file", .{});
    }
}
