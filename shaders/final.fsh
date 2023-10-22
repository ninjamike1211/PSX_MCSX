#version 420 compatibility
#extension GL_EXT_gpu_shader4 : enable

#define composite
#include "/shaders.settings"
#include "/lib/voxel.glsl"

#define DITHER_COLORS 128
varying vec2 texcoord;

uniform sampler2D colortex0;
uniform sampler2D colortex4;
uniform sampler2D colortex5;
uniform sampler2D colortex7;
uniform sampler2D colortex1;
uniform vec2 texelSize;
uniform float viewWidth;
uniform float viewHeight;
uniform float aspectRatio;

layout (rgba8) uniform image2D colorimg5;

vec3 GetDither(vec2 pos, vec3 c, float intensity) {
	int DITHER_THRESHOLDS[16] = int[]( -4, 0, -3, 1, 2, -2, 3, -1, -3, 1, -4, 0, 3, -1, 2, -2 );
	int index = (int(pos.x) & 3) * 4 + (int(pos.y) & 3);

	c.xyz = clamp(c.xyz * (DITHER_COLORS-1) + DITHER_THRESHOLDS[index] * (intensity * 100), vec3(0), vec3(DITHER_COLORS-1));

	c /= DITHER_COLORS;
	return c;
}

/* DRAWBUFFERS:0 */
void main() {
	vec2 baseRes = vec2(viewWidth, viewHeight);
	vec2 dsRes = baseRes * resolution_scale;
	float pixelSize = dsRes.x / baseRes.x;
	vec2 downscale = floor(texcoord * (dsRes - 1) + 0.5) / (dsRes - 1);

	vec2 textCol     = texture2D(colortex1, texcoord).rg;
	vec2 textColDown = texture2D(colortex1, downscale).rg;
	if(textCol.r > 0.5 || textColDown.r > 0.5)
		downscale = texcoord;

    vec3 col = texture2D(colortex0,downscale).rgb;

	col = clamp(1.2 * (col - 0.5) + 0.5, 0, 1);
	col = GetDither(vec2(downscale.x, downscale.y / aspectRatio) * dsRes.x, col, dither_amount);
	col = clamp(floor(col * color_depth) / color_depth, 0.0, 1.0);

	ivec2 pixelCoords = ivec2(gl_FragCoord.xy);
	if(clamp(pixelCoords, 0, voxelMapResolution) == pixelCoords) {
		col += texelFetch(colortex4, pixelCoords, 0).rgb;
		col *= 0.5;

		if(pixelCoords == ivec2(voxelMapResolution / 2))
			col = vec3(1.0);
	}

	gl_FragData[0].rgb = col;
}
