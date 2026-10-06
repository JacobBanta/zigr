// translated from https://raw.githubusercontent.com/erkkah/tigr/f7bf2abbf6b26e649ced5691003e87b61c03762e/examples/clip/clip.c
const zigr = @import("zigr");

pub fn main() void {
    const screen: *zigr.Window = .init(320, 240, "Clip", .{});
    defer screen.free();
    const c0 = zigr.Pixel.initRGB(55, 55, 55);
    const c1 = zigr.Pixel.initRGB(255, 255, 255);
    const c2 = zigr.Pixel.initRGB(100, 200, 100);
    const c3 = zigr.Pixel.initRGBA(100, 100, 200, 150);

    while (!screen.closed() and !(screen.keyDown(.ESCAPE))) {
        screen.clear(c0);

        const cx = @divFloor(screen.w, 2);
        const cy = @divFloor(screen.h, 2);
        const w = 100;
        const d = 50;

        screen.clip(cx - d, cy - d, w, w);
        screen.fill(cx - d, cy - d, w, w, c1);

        screen.rect(cx - w, cy - w, w, w, c2);
        screen.fillRect(cx - w, cy - w, w, w, c3);

        screen.circle(cx + d, cy - d, d, c2);
        screen.fillCircle(cx + d, cy - d, d, c3);

        const message = "Half a thought is also a thought";
        const tw = zigr.textWidth(null, message);
        const th = zigr.textHeight(null, message);
        screen.print(null, cx - @divFloor(tw, 2), cy + d - @divFloor(th, 2), c2, message);
        screen.update();
    }
}
