#version 120
/* DRAWBUFFERS:012 */
#extension GL_EXT_gpu_shader4 : enable
#extension GL_ARB_shader_texture_lod : enable

#define gbuffers_solid
#include "/shaders.settings"

uniform float viewWidth;
uniform float viewHeight;
uniform ivec2 atlasSize;

uniform sampler2D texture;
uniform sampler2D lightmap;
uniform sampler2D normals;
uniform sampler2D colortex0;
uniform sampler2D colortex2;

varying vec4 texcoord;
varying vec4 texcoordAffine;
varying vec4 lmcoord;
varying vec4 color;
varying float isText;

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

	// // if(texture2D(normals, texcoord.xy).r, 1e-4) {
	// if(atlasSize.y == 0) {
	// 	affine = texcoord.xy;

	// 	gl_FragData[0] = vec4(1.0);
	// 	gl_FragData[1] = vec4(vec3(gl_FragCoord.z), 1.0);
	// 	return;
	// }

	vec4 lighting = color * (texture2D(lightmap, lmcoord.st) * 0.8 + 0.2);
	vec4 col = texture2D(texture, affine) * lighting;
	
	// if(isText > 0.5) {
	// // if(atlasSize.x == 0) {
	// 	gl_FragData[0] = col;
	// 	gl_FragData[1] = vec4(vec3(gl_FragCoord.z), 1.0);
	// 	gl_FragData[2] = vec4(col.rgb, 1.0);
	// }
	// else {
		gl_FragData[0] = col;
		gl_FragData[1] = vec4(vec3(gl_FragCoord.z), 1.0);
		// gl_FragData[2] = vec4(texture2D(colortex2, texcoord.xy).rgb, 0.0);
		// gl_FragData[2] = vec4(0.0);
		gl_FragData[2] = vec4(isText, isText, isText, 1.0);
	// }
}
