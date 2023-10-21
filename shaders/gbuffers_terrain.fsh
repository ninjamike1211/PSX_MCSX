#version 120
/* DRAWBUFFERS:02 */
#extension GL_EXT_gpu_shader4 : enable
#extension GL_ARB_shader_texture_lod : enable

#define gbuffers_solid
#include "/shaders.settings"

uniform float viewWidth;
uniform float viewHeight;

uniform sampler2D texture;
uniform sampler2D lightmap;

varying vec4 texcoord;
varying vec4 texcoordAffine;
varying vec2 lmcoord;
varying vec4 color;
varying float isText;
varying vec3 lightColor;

#include "/lib/psx_util.glsl"

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

	if(isText > 0.5) {
		affine = texcoord.xy;
	}

	
	vec4 lighting = vec4(0.0, 0.0, 0.0, 1.0);
	vec2 finalLmcoord = lmcoord;
	if(any(greaterThan(lightColor, vec3(0.0)))) {
		lighting.xyz += lightColor;
		finalLmcoord.r = 1.0/32.0;
	}
	// else if(lmcoord.r > 1.0 / 32.0) {
	// 	lighting.xyz += lmcoord.x * vec3(1.0, 0.85, 0.6);
	// }
	lighting += (texture2D(lightmap, finalLmcoord) * 0.8 + 0.2);

	vec4 col = color * texture2D(texture, affine) * lighting;
	
	gl_FragData[0] = col;
	gl_FragData[1] = vec4(isText, isText, isText, 1.0);
}
