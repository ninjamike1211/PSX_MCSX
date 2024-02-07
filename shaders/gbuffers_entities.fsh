#version 150 compatibility
/* DRAWBUFFERS:01 */
#extension GL_EXT_gpu_shader4 : enable
#extension GL_ARB_shader_texture_lod : enable

#define saturation 1.0					//Post-processing saturation value [0.10 0.20 0.30 0.40 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.0 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.60 1.70 1.80 1.90 2.00]
#define contrast 1.0					//Post-processing contrast value [0.10 0.20 0.30 0.40 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.0 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.60 1.70 1.80 1.90 2.00]

#define gbuffers_solid
#define gbuffers_entities
#include "/shaders.settings"
#include "/lib/psx_util.glsl"
#include "/lib/voxel.glsl"

varying vec2 texcoord;
varying vec3 texcoordAffine;
varying vec2 lmcoord;
varying vec4 color;

uniform float viewWidth;
uniform float viewHeight;
uniform sampler2D texture;
uniform sampler2D lightmap;
uniform vec4 entityColor;
uniform vec3 skyColor;
uniform float frameTimeCounter;
uniform int entityId;

#ifdef Floodfill_Enable
	varying vec3 voxelLightColor;
#endif

void main() {
	#ifdef affine_mapping
	#ifdef affine_clamp_enabled
	vec2 texelSize = vec2(1.0/viewWidth, 1.0/viewHeight);
	vec2 affine = AffineMapping(texcoordAffine, texcoord, texelSize, affine_clamp * 4.0);
	#else
	vec2 affine = texcoordAffine.xy / texcoordAffine.z;
	#endif
	#else 
	vec2 affine = texcoord.xy;
	#endif

	if(entityId == 10001) {
		gl_FragData[0] = vec4(1.0);
	}
	else {
		vec4 col = texture2D(texture, affine) * color;
		col.rgb = mix(col.rgb, entityColor.rgb, entityColor.a);
		
		#ifdef Floodfill_Enable
			vec4 lighting = vec4(voxelLightColor, 0.0);
			lighting += (texture2D(lightmap, vec2(1.0/32.0, lmcoord.y)) * 0.8 + 0.2);
		#else
			vec4 lighting = texture2D(lightmap, lmcoord.xy) * 0.8 + 0.2;
		#endif

		if(entityId == 10003) {
			lighting.rgb += mix(vec3(item_darkColor), vec3(item_lightColor), sin(frameTimeCounter * item_speed) * 0.5 + 0.5);
		}

		col *= lighting;

		#ifdef Player_Ignore_Post
			if(entityId == 10002) {
				vec3 hsv = rgb2hsv(col.rgb);
				hsv.y /= saturation;
				col.rgb = hsv2rgb(hsv);

				col.rgb = (col.rgb - 0.5) * (1.0/contrast) + 0.5;
			}
		#endif
		
		gl_FragData[0] = col;
	}

	gl_FragData[1] = vec4(0.0);
}
