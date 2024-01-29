#version 150 compatibility
/* DRAWBUFFERS:21 */
#extension GL_EXT_gpu_shader4 : enable
#extension GL_ARB_shader_texture_lod : enable

#define gbuffers_solid
#include "/shaders.settings"
#include "/lib/psx_util.glsl"
#include "/lib/voxel.glsl"

varying vec4 texcoord;
varying vec4 lmcoord;
varying vec4 color;
varying vec4 blockColor;

#ifdef Floodfill_Enable
	varying vec3 voxelLightColor;
#endif

uniform sampler2D texture;
uniform sampler2D lightmap;

void main() {
	vec4 colorVal = texture2D(texture, texcoord.xy) * color;

	#ifdef Floodfill_Enable
		vec4 lighting = vec4(voxelLightColor, 0.0);
		lighting += (texture2D(lightmap, vec2(1.0/32.0, lmcoord.y)) * 0.8 + 0.2);
	#else
		vec4 lighting = texture2D(lightmap, lmcoord.xy) * 0.8 + 0.2;
	#endif

	vec4 data0 = colorVal * lighting;
	
	gl_FragData[0] = data0;

	gl_FragData[1] = vec4(0.0);
}
