shader_type canvas_item;

// Silhouette shader for Shadow Ronin fighters
// Forces the character to a deep silhouette tone with customizable rim lighting

uniform vec4 silhouette_color : source_color = vec4(0.04, 0.05, 0.07, 1.0);
uniform vec4 rim_color : source_color = vec4(0.9, 0.25, 0.25, 0.8);
uniform float rim_thickness : hint_range(0.0, 4.0) = 1.2;
uniform float rim_intensity : hint_range(0.0, 2.0) = 0.6;

void fragment() {
	vec4 base_col = texture(TEXTURE, UV);
	if (base_col.a < 0.1) {
		discard;
	}
	
	// Sample neighborhood for edge detection (Rim lighting)
	vec2 pixel_size = TEXTURE_PIXEL_SIZE * rim_thickness;
	float a_up = texture(TEXTURE, UV + vec2(0.0, -pixel_size.y)).a;
	float a_down = texture(TEXTURE, UV + vec2(0.0, pixel_size.y)).a;
	float a_left = texture(TEXTURE, UV + vec2(-pixel_size.x, 0.0)).a;
	float a_right = texture(TEXTURE, UV + vec2(pixel_size.x, 0.0)).a;
	
	float edge = 4.0 * base_col.a - (a_up + a_down + a_left + a_right);
	edge = clamp(edge, 0.0, 1.0);
	
	vec4 final_color = mix(silhouette_color, rim_color, edge * rim_intensity);
	final_color.a = base_col.a;
	COLOR = final_color;
}
