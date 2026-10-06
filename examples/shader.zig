// translated from https://raw.githubusercontent.com/erkkah/tigr/f7bf2abbf6b26e649ced5691003e87b61c03762e/examples/shader/shader.c
const zigr = @import("zigr");

const fxShader =
    \\void fxShader(out vec4 color, in vec2 uv) {
    \\  vec2 tex_size = vec2(textureSize(image, 0));
    \\  vec4 c = texture(image, (floor(uv * tex_size) 
    \\           + 0.5 * sin(parameters.x)) / tex_size);
    \\  color = c;
    \\}
;

pub fn main() void {
    const screen: *zigr.Window = .init(320, 240, "Shady", .{});
    defer screen.free();

    screen.setPostShader(fxShader);

    const duration = 1;
    var phase: f32 = 0;

    while (!screen.closed() and !(screen.keyDown(.ESCAPE))) {
        phase += zigr.time();
        while (phase > duration) {
            phase -= duration;
        }
        const p: f32 = 6.28 * phase / duration;
        screen.setPostFX(p, 0, 0, 0);
        screen.clear(.initRGB(0x80, 0x90, 0xa0));
        screen.print(null, 120, 110, .initRGB(0xff, 0xff, 0xff), "Shady business");
        screen.update();
    }
}
