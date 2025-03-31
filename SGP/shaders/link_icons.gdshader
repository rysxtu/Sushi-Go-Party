shader_type canvas_item;
uniform float onoff;
uniform vec4 line_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float line_thickness : hint_range(0, 10) = 4.0;

// 'uniform' exposes variable so it can be changed externally (for example, in a script)
uniform bool is_grey = false;


// These constants represent how a human eye perceives "brightness" of different colors
// Since shaders only work with RGB color space, we'll need these to find "brightness" of every pixel
const float RED_LUMINANCE = 0.2126;
const float GREEN_LUMINANCE = 0.7152;
const float BLUE_LUMINANCE = 0.0722;

const vec2 OFFSETS[8] = {
	vec2(-1, -1), vec2(-1, 0), vec2(-1, 1), vec2(0, -1), vec2(0, 1), 
	vec2(1, -1), vec2(1, 0), vec2(1, 1)
};

void fragment() {
	vec2 size = TEXTURE_PIXEL_SIZE * line_thickness;
	float outline = 1.0;
	
	for (int i = 0; i < OFFSETS.length(); i++) {
		outline *= texture(TEXTURE, UV + size * OFFSETS[i]).a;
	}
	outline = 1.0 - outline;
	
	vec4 color = texture(TEXTURE, UV);
	vec4 outlined_result = mix(color, line_color, outline * color.a);
	COLOR = mix(color, outlined_result, outlined_result.a * onoff);
	
	// We get the RGBA value of current pixel
    vec4 col = COLOR;

    if(is_grey)
    {
	// This variable will tell how bright current pixel is when observed by a human eye
	float luminance = (col.r*RED_LUMINANCE + col.g*GREEN_LUMINANCE + col.b*BLUE_LUMINANCE);
	// We simply multiply the value of every color channel (red, green and blue) by their respective "brightness"

	// Here we set R,G,B channels' values to 'luminance' and keep the alpha (transparency) of the pixel the same
	col = vec4(vec3(luminance), col.a);
	// This code is equivalent to 'col = vec4(luminance, luminance, luminance, col.a)'
    }

    // Finally, we set the color of current pixel to a new value
    COLOR = col;

}