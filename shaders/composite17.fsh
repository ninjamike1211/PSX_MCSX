#version 420 compatibility

#define composite
#include "/shaders.settings"

#define DITHER_COLORS 128
varying vec2 texcoord;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform float viewWidth;
uniform float viewHeight;

vec3 GetDither(vec2 pos, vec3 c, float intensity) {
	int DITHER_THRESHOLDS[16] = int[]( -4, 0, -3, 1, 2, -2, 3, -1, -3, 1, -4, 0, 3, -1, 2, -2 );
	int index = (int(pos.x) & 3) * 4 + (int(pos.y) & 3);

	c.xyz = clamp(c.xyz * (DITHER_COLORS-1) + DITHER_THRESHOLDS[index] * (intensity * 100), vec3(0), vec3(DITHER_COLORS-1));

	c /= DITHER_COLORS;
	return c;
}

/* DRAWBUFFERS:0 */
void main() {
	vec2 dsRes = vec2(viewWidth, viewHeight) * resolution_scale;
	vec2 downscale = floor(texcoord * dsRes) / dsRes;

	vec2 textCol     = texture2D(colortex1, texcoord).rg;
	vec2 textColDown = texture2D(colortex1, downscale).rg;
	if(textCol.r > 0.5 || textColDown.r > 0.5)
		downscale = texcoord;

    vec3 col = texture2D(colortex0,downscale).rgb;

	col = clamp(1.2 * (col - 0.5) + 0.5, 0, 1);
	col = GetDither(downscale * dsRes + 0.1, col, dither_amount);
	col = clamp(floor(col * color_depth) / color_depth, 0.0, 1.0);

	gl_FragData[0].rgb = col;
}
