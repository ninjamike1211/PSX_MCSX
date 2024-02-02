#version 150 compatibility
/* DRAWBUFFERS:01 */
#extension GL_EXT_gpu_shader4 : enable
#extension GL_ARB_shader_texture_lod : enable

#define gbuffers_solid
#include "/shaders.settings"
#include "/lib/psx_util.glsl"
#include "/lib/voxel.glsl"

uniform float viewWidth;
uniform float viewHeight;

uniform sampler2D texture;
uniform sampler2D lightmap;

varying vec2 texcoord;
varying vec3 texcoordAffine;
varying vec2 lmcoord;
varying vec4 color;

#ifdef Floodfill_Enable
	varying vec3 voxelLightColor;
#endif

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

	#ifdef Floodfill_Enable
		vec4 lighting = vec4(voxelLightColor, 0.0);
		lighting += (texture2D(lightmap, vec2(1.0/32.0, lmcoord.y)) * 0.8 + 0.2);
	#else
		vec4 lighting = texture2D(lightmap, lmcoord.xy);
	#endif

	vec4 col = texture2D(texture, affine) * color * lighting;
	
	gl_FragData[0] = col;
	gl_FragData[1] = vec4(0.0, 0.0, 0.0, 1.0);
}
