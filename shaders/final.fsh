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

// HSV functions from Sam Hocevar (https://gamedev.stackexchange.com/a/59808/22302)

vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

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

	col = (col - 0.5) * contrast + 0.5;
	vec3 hsv = rgb2hsv(col);
	hsv.y *= saturation;

	gl_FragData[0].rgb = hsv2rgb(hsv);
}
