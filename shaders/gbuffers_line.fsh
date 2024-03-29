#version 120
/* DRAWBUFFERS:0 */
#extension GL_EXT_gpu_shader4 : enable
#extension GL_ARB_shader_texture_lod : enable

varying vec4 color;

#include "/lib/psx_util.glsl"

uniform float viewWidth;
uniform float viewHeight;

void main() {

	vec4 col = color;
	
	gl_FragData[0] = col;
}
