#version 420 compatibility
/* DRAWBUFFERS:3 */

#define gbuffers_skytextured
#include "/shaders.settings"

varying vec4 color;
varying vec2 texcoord;

uniform sampler2D texture;
uniform vec3 fogColor;

uniform bool inEnd;

void main() {
	if(inEnd) {
		vec3 color = texture2D(texture,texcoord).rgb * end_sky_brightness + fogColor;
		gl_FragData[0] = vec4(color, 1.0);
	}
	else {
		gl_FragData[0] = texture2D(texture,texcoord) * color;
	}
}
