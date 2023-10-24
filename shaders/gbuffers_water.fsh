#version 120
/* DRAWBUFFERS:01 */
#extension GL_EXT_gpu_shader4 : enable
#extension GL_ARB_shader_texture_lod : enable

#define gbuffers_solid
#include "/shaders.settings"

uniform float viewWidth;
uniform float viewHeight;

varying vec4 texcoord;
varying vec4 texcoordAffine;
varying vec4 lmcoord;
varying vec4 color;
varying vec3 voxelLightColor;

#include "/lib/psx_util.glsl"

uniform sampler2D texture;
uniform sampler2D lightmap;

void main() {
	#ifdef affine_mapping
	#ifdef affine_clamp_enabled
	vec2 texelSize = vec2(1.0/viewWidth, 1.0/viewHeight);
	vec2 affine = AffineMapping(texcoordAffine, texcoord, texelSize, affine_clamp);
	#else
	vec2 affine = texcoordAffine.xy / texcoordAffine.z;
	#endif
	#else 
	vec2 affine = texcoord.xy;
	#endif


	vec2 lmcoordAdjusted = lmcoord.st;
	vec4 lighting = vec4(0.0);
	// if(any(greaterThan(voxelLightColor, vec3(0.0)))) {
		lighting.rgb += voxelLightColor;
		lmcoordAdjusted.s = 1.0/32.0;
	// }
	lighting += (texture2D(lightmap, lmcoordAdjusted.st) * 0.8 + 0.2);
	vec4 col = texture2D(texture, affine) * color * lighting;
	
	gl_FragData[0] = col;
	gl_FragData[1] = vec4(0.0);
}
