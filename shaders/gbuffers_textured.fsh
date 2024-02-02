#version 150 compatibility
/* DRAWBUFFERS:01 */
#extension GL_EXT_gpu_shader4 : enable
#extension GL_ARB_shader_texture_lod : enable

varying vec2 texcoord;
varying vec3 texcoordAffine;
varying vec2 lmcoord;
varying vec4 color;

#include "/lib/psx_util.glsl"
#include "/lib/voxel.glsl"

uniform sampler2D texture;
uniform sampler2D lightmap;
uniform float viewWidth;
uniform float viewHeight;

#if defined Floodfill_Enable && defined Floodfill_Particles
	varying vec3 voxelLightColor;
#endif

void main() {
	vec2 texelSize = vec2(1.0/viewWidth, 1.0/viewHeight);
	vec2 affine = AffineMapping(texcoordAffine, texcoord, texelSize, 2);

	vec4 col = texture2D(texture, texcoord.xy) * color;

	#if defined Floodfill_Enable && defined Floodfill_Particles
		vec4 lighting = vec4(voxelLightColor, 0.0);
		lighting += (texture2D(lightmap, vec2(1.0/32.0, lmcoord.y)) * 0.8 + 0.2);
	#else
		vec4 lighting = texture2D(lightmap, lmcoord.xy) * 0.8 + 0.2;
	#endif
	
	col *= lighting;
	
	gl_FragData[0] = col;
	gl_FragData[1] = vec4(0.0, 1.0, 0.0, 1.0);
}
