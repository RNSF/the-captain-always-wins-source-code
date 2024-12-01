shader_type canvas_item;
render_mode unshaded;

uniform sampler2D dissolve_texture : source_color;
uniform float dissolve_value : hint_range(0.0,1.0);

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment(){
	vec4 main_texture = texture(screen_texture, SCREEN_UV);
	vec4 noise_texture = texture(dissolve_texture, SCREEN_UV);
	main_texture.a *= floor(dissolve_value + min(1, noise_texture.x));
	COLOR = main_texture;

}