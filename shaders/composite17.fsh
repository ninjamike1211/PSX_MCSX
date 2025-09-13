#version 420 compatibility

/*
const int  colortex10Format  = RGBA8;
const vec4 colortex10ClearColor = vec4(0.0, 0.0, 0.0, 0.0);
const int  colortex1Format  = RG8;
const vec4 colortex1ClearColor = vec4(0.0, 0.0, 0.0, 0.0);
const int  colortex2Format  = RGBA8;
const int  colortex3Format  = RGBA8;
const bool colortex3Clear  = false;
const int  colortex4Format  = RGBA8;
const bool colortex4Clear  = false;
const int  colortex5Format  = RGBA8;
const bool colortex5Clear   = false;
const int  colortex7Format  = RGBA8;
const int  colortex8Format  = RGBA8;
const int  colortex11Format = RGBA8;
const int  colortex12Format = RGBA8_SNORM;
const bool colortex12Clear  = false;
*/

#define composite
#include "/shaders.settings"

#define DITHER_COLORS 128
varying vec2 texcoord;

uniform sampler2D colortex10;
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

/* RENDERTARGETS: 10 */
void main() {
	// ivec2 screenRes = ivec2(viewWidth, viewHeight) * resolution_scale

	vec2 dsRes = vec2(viewWidth, viewHeight) * resolution_scale;
	vec2 downscale = (floor(texcoord * dsRes) + 0.5) / dsRes;

	vec2 textCol     = texture2D(colortex1, texcoord).rg;
	vec2 textColDown = texture2D(colortex1, downscale).rg;
	if(textCol.r > 0.5 || textColDown.r > 0.5)
		downscale = texcoord;

    vec3 col = texture2D(colortex10,downscale).rgb;

	col = clamp(1.2 * (col - 0.5) + 0.5, 0, 1);
	col = GetDither(downscale * dsRes + 0.1, col, dither_amount);
	col = clamp(floor(col * color_depth) / color_depth, 0.0, 1.0);

	gl_FragData[0].rgb = col;
}
