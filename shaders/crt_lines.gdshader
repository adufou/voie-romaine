shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture;

// CRT vertical lines effect
// Uniforms
uniform float crt_line_width : hint_range(0.001, 0.1) = 0.02;
uniform float crt_line_intensity : hint_range(0.0, 1.0) = 0.3;
uniform float crt_line_speed : hint_range(-2.0, 2.0) = 0.1;
uniform float crt_line_sharpness : hint_range(0.1, 10.0) = 5.0;
uniform float time : hint_range(0.0, 1000.0) = 0.0;

void fragment() {
    float x = mod(SCREEN_UV.x + time * crt_line_speed, crt_line_width);
    float sharp = pow(abs(sin(3.14159 * x / crt_line_width)), crt_line_sharpness);
    float lines = 1.0 - crt_line_intensity * sharp;
    COLOR = texture(screen_texture, SCREEN_UV) * lines;
}
