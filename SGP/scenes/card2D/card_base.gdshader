shader_type canvas_item;
render_mode blend_mix,unshaded;

uniform vec4 color = vec4(1.0, 1.0, 1.0, 1.0);

uniform float radius : hint_range(0.0, 1.0) = 0.0;
uniform vec2 size = vec2(1.0, 1.0);

void fragment() {
	vec4 texture_color = texture(TEXTURE, UV);
	COLOR = texture_color * color;
	
	vec2 size_ratio = vec2(max(1.0, size.x / size.y), max(1.0, size.y / size.x));
	float half_radius = 0.5 * radius;
	vec2 dist_max = half_radius / size_ratio;
	vec2 edge_pos = clamp(UV, dist_max, 1.0 - dist_max);
	float edge_dist = distance(UV * size_ratio, edge_pos * size_ratio);
	COLOR.a *= step(edge_dist, half_radius + 0.000001);
}