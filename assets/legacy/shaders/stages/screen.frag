#pragma header

precision mediump float;

uniform float block;

vec4 screenColor = vec4(0.0, 198.0 / 255.0 * 0.75, 134.0 / 255.0 * 0.75, 0.75);

float intensity(vec4 color) {
	return max(max(color.r, color.g), color.b);
}

void main() {
	vec2 px = (openfl_TextureSize / block);
	vec2 coord = (floor(openfl_TextureCoordv * px) / px);
	vec4 color = vec4(1.0, 1.0, 1.0, 0.0);

	for (int x = -3; x < 3; x++)
	{
		for (int y = -3; y < 3; y++)
		{
<<<<<<< HEAD
			vec2 offset = vec2(float(x) / px.x / 6.0, float(y) / px.y / 6.0);
			vec4 p = texture2D(bitmap, coord + offset);
			
			color.rgb = (color.a == 0.0 ? p.rgb : mix(color.rgb, min(color.rgb, p.rgb), 0.1));
			color.a = min(color.a + p.a / pow(5.0, 2.0) * 3.0, 1.0);
=======
			// darkens 6*6 around to get like more "noticeable" outlines. its kinda butt but it wokrs
			vec4 p = texture2D(bitmap, coord + vec2(x / px.x / 6., y / px.y / 6.));
			color.rgb = (color.a == 0 ? p.rgb : mix(color.rgb, min(color.rgb, p.rgb), .05));
			color.a = min(color.a + p.a / pow(5., 2.) * 3., 1.);
>>>>>>> upstream/main
		}
	}
	
	color.rgb = max(color.rgb, 0.1 * color.a);
	color.rg *= 0.75;
	color.a *= 0.25;
	
	gl_FragColor = color;
}
