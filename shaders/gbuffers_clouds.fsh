#version 120
/* DRAWBUFFERS:8 */

#extension GL_EXT_gpu_shader4 : enable
#extension GL_ARB_shader_texture_lod : enable

varying vec4 texcoord;
varying vec4 color;

uniform sampler2D texture;
uniform sampler2D lightmap;

void main() {
	vec4 col = texture2D(texture, texcoord.xy) * color;

	if(col.a < 0.1)
		discard;
	
	gl_FragData[0] = vec4(1.0);
}
