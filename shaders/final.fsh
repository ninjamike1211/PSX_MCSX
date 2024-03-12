#version 420 compatibility
#extension GL_EXT_gpu_shader4 : enable

#define composite
#include "/shaders.settings"
#include "/lib/psx_util.glsl"
#include "/lib/voxel.glsl"

#define DITHER_COLORS 128
varying vec2 texcoord;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform vec2 texelSize;
uniform float viewWidth;
uniform float viewHeight;
uniform float aspectRatio;
uniform float frameTimeCounter;

// (This is put here to force Optifine to bind image textures, as it doesn't search in gbuffer vertex stage)

#ifdef Floodfill_Enable
	layout (rgba8) uniform image2D colorimg5;
#endif

vec2 screenDistort(vec2 uv)
{
	uv -= vec2(.5,.5);
	uv = uv*1.2*(1./1.2+2.*uv.x*uv.x*uv.y*uv.y);
	uv += vec2(.5,.5);
	return uv;
}

/* DRAWBUFFERS:0 */
void main() {
	vec2 baseRes = vec2(viewWidth, viewHeight);
	vec2 dsRes = baseRes * resolution_scale;
	float pixelSize = dsRes.x / baseRes.x;

	#ifdef CRT_Warp
		vec2 texcoordWarped = screenDistort(texcoord);
	#else
		vec2 texcoordWarped = texcoord;
	#endif

	vec2 downscale = floor(texcoordWarped * dsRes) / dsRes;


	#ifdef CRT_Blur
		float blurOffset = 0.5 / (viewWidth * resolution_scale.x);
		vec3 col = vec3(0.0);
		for(int i = -CRT_Blur_Samples/2; i <= CRT_Blur_Samples/2; i++) {
			col += texture2D(colortex0,texcoordWarped + vec2(blurOffset * i / (CRT_Blur_Samples/2), 0.0)).rgb;
		}
		col /= CRT_Blur_Samples;
	#else
		vec3 col = texture2D(colortex0, texcoordWarped).rgb;
	#endif

	col = (col - 0.5) * contrast + 0.5;
	
	vec3 hsv = rgb2hsv(col);
	hsv.y *= saturation;
	col = hsv2rgb(hsv);

	#ifdef CRT_Scanlines
		float scanlineDist = abs(((texcoordWarped.y - downscale.y) / (texelSize.y / resolution_scale)) * 2.0 - 1.0);
		float scanelineFactor = smoothstep(1.0, 0.4, scanlineDist);

		col *= mix(0.7, 1.0, scanelineFactor);
	#endif

	#ifdef CRT_Warp
		vec2 edgeDistances = abs(texcoordWarped * 2.0 - 1.0);
		col *= smoothstep(1.0, 0.98, max(edgeDistances.x, edgeDistances.y));
	#endif

	gl_FragData[0] = vec4(col, 1.0);
}
