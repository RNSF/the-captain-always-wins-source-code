shader_type canvas_item;

uniform float width = 0.0;
uniform float offset_x = 0.0;

uniform vec4 text_color : source_color = vec4(1);
uniform vec4 text_color_2 : source_color = vec4(1);
uniform float charge_percent : hint_range(0.0, 1.0) = 1.0;
uniform vec4 line_color : source_color = vec4(1);
uniform float line_thickness : hint_range(0, 10) = 1.0;


varying vec2 full_uv;
void vertex () {
	full_uv = VERTEX.xy;
}


void fragment() {
	vec2 outline_size = TEXTURE_PIXEL_SIZE * line_thickness;

	float outline = texture(TEXTURE, UV + vec2(-outline_size.x, 0)).a;
	outline += texture(TEXTURE, UV + vec2(0, outline_size.y)).a;
	outline += texture(TEXTURE, UV + vec2(outline_size.x, 0)).a;
	outline += texture(TEXTURE, UV + vec2(0, -outline_size.y)).a;
	outline += texture(TEXTURE, UV + vec2(-outline_size.x, outline_size.y)).a;
	outline += texture(TEXTURE, UV + vec2(outline_size.x, outline_size.y)).a;
	outline += texture(TEXTURE, UV + vec2(-outline_size.x, -outline_size.y)).a;
	outline += texture(TEXTURE, UV + vec2(outline_size.x, -outline_size.y)).a;
	outline = min(outline, 1.0);

	vec4 color = texture(TEXTURE, UV);

	if (full_uv.x < round(charge_percent * width + offset_x))
		color.rgb = text_color_2.rgb;
	else
		color.rgb = text_color.rgb;
	color.a *= text_color.a;
	COLOR = mix(color, line_color, outline - color.a);
}