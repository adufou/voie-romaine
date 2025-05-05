shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture;

// Uniforms pour contrôler l'aberration
uniform float abberation_start : hint_range(0.0, 1.0) = 0.2;
uniform float abberation_max_offset : hint_range(0.0, 8) = 4.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
    vec2 center = vec2(0.5, 0.5);
    float dist = distance(SCREEN_UV, center);

    // Calcul du facteur d'aberration (0 si proche du centre, max au bord)
    float t = clamp((dist - abberation_start) / (0.5 - abberation_start), 0.0, 1.0);
    float abberation = abberation_max_offset * t;

    // Décalage des canaux R et B
    vec4 red_channel = texture(screen_texture, vec2(SCREEN_UV.x + (abberation * SCREEN_PIXEL_SIZE.x), SCREEN_UV.y));
    vec4 green_channel = texture(screen_texture, SCREEN_UV);
    vec4 blue_channel = texture(screen_texture, vec2(SCREEN_UV.x - (abberation * SCREEN_PIXEL_SIZE.x), SCREEN_UV.y));

    COLOR = vec4(red_channel.r, green_channel.g, blue_channel.b, 1.0);
}


//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
