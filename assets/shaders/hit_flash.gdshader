shader_type canvas_item;

// Hit-flash shader for impact freeze frames
uniform float flash_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	if (tex_color.a < 0.05) {
		discard;
	}
	vec3 blended = mix(tex_color.rgb, flash_color.rgb, flash_amount);
	COLOR = vec4(blended, tex_color.a);
}
