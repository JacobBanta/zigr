// translated from https://raw.githubusercontent.com/erkkah/tigr/f7bf2abbf6b26e649ced5691003e87b61c03762e/examples/hello/hello.c
const zigr = @import("zigr");

pub fn main() void {
    const screen: *zigr.Window = .init(320, 240, "Hello", .{});
    defer screen.free();

    while (!screen.closed() and !(screen.keyDown(.ESCAPE))) {
        screen.clear(.initRGB(0x80, 0x90, 0xa0));
        screen.print(null, 120, 110, .initRGB(0xff, 0xff, 0xff), "Hello, world.");
        screen.update();
    }
}
