#version 420 compatibility
/* DRAWBUFFERS:0 */
 
#define gbuffers_armor_glint
#include "/shaders.settings"
#include "/lib/psx_util.glsl"


varying vec4 color;
varying vec2 texcoord;

uniform sampler2D texture;
uniform float frameTimeCounter;


void main() {

	vec4 col = texture2D(texture, texcoord + vec2(frameTimeCounter/8.0)) * color * enchanted_strength;
	gl_FragData[0] = col;
}
