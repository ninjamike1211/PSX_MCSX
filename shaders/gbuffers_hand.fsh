#version 150 compatibility
/* DRAWBUFFERS:01 */
#extension GL_EXT_gpu_shader4 : enable
#extension GL_ARB_shader_texture_lod : enable

#define gbuffers_solid
#include "/shaders.settings"
#include "/lib/psx_util.glsl"
#include "/lib/voxel.glsl"

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 color;

#if Floodfill > 0
	varying vec3 voxelLightColor;
#endif

uniform sampler2D texture;
uniform sampler2D lightmap;
uniform int heldItemId;
uniform int heldItemId2;
uniform ivec2 atlasSize;

void main() {
	vec4 colorVal = texture2D(texture, texcoord.xy) * color;

	if(colorVal.a < 0.1)
		discard;

	#if Floodfill > 0
		vec4 lighting = vec4(voxelLightColor, 0.0);
		lighting += (texture2D(lightmap, vec2(1.0/32.0, lmcoord.y)) * 0.8 + 0.2);
	#else
		vec4 lighting = texture2D(lightmap, lmcoord.xy) * 0.8 + 0.2;
	#endif

	vec4 col = colorVal * lighting;

	#ifdef Player_Ignore_Post
		if(heldItemId == 10002 || heldItemId2 == 10002 && atlasSize.x == 0) {
			vec3 hsv = rgb2hsv(col.rgb);
			hsv.y /= saturation;
			col.rgb = hsv2rgb(hsv);

			col.rgb = (col.rgb - 0.5) * (1.0/contrast) + 0.5;
		}
	#endif
	
	gl_FragData[0] = col;

	gl_FragData[1] = vec4(0.0);
}
