shader_type canvas_item;

// Procedural weapon slash trail ribbon
uniform vec4 trail_color : source_color = vec4(0.9, 0.85, 0.5, 0.85);
uniform vec4 core_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float fade_sharpness : hint_range(0.5, 5.0) = 2.0;

void fragment() {
	// UV.x represents progress along the slash arc (0.0 = tip, 1.0 = tail)
	// UV.y represents blade width (0.0 to 1.0)
	float fade = pow(1.0 - UV.x, fade_sharpness);
	float edge_dist = abs(UV.y - 0.5) * 2.0;
	float core = 1.0 - smoothstep(0.0, 0.4, edge_dist);
	
	vec4 col = mix(trail_color, core_color, core);
	col.a *= fade * (1.0 - edge_dist);
	COLOR = col;
}
