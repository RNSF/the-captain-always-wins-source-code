
shader_type canvas_item;

uniform sampler2D u_color_tex;

void fragment() {
	COLOR = texture(TEXTURE, UV);
	vec3 col = texture(u_color_tex, round(vec2(COLOR.r, 0) * 4.0) / 4.0).rgb;
	COLOR.rgb = col;
}
