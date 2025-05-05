shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture;

// Circular outward distortion
// Uniforms
uniform float distortion_strength : hint_range(0.0, 0.2) = 0.05;
uniform float distortion_radius : hint_range(0.0, 1.0) = 0.7;
uniform float distortion_exponent : hint_range(0.1, 8.0) = 2.0;

void fragment() {
    vec2 center = vec2(0.5, 0.5);
    vec2 uv = SCREEN_UV;
    vec2 delta = uv - center;
    float dist = length(delta);
    float strength = distortion_strength * pow(clamp(dist / distortion_radius, 0.0, 1.0), distortion_exponent);
    vec2 distorted_uv = center + delta * (1.0 + strength);
    COLOR = texture(screen_texture, distorted_uv);
}
