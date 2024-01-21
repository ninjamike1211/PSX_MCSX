#version 120
/* DRAWBUFFERS:3 */

#define gbuffers_skytextured
#include "/shaders.settings"

varying vec4 color;
varying vec2 texcoord;

uniform sampler2D texture;
uniform float frameTimeCounter;
uniform vec3 fogColor;

uniform bool inEnd;

void main() {
	if(inEnd) {
		// vec3 color = mix(vec3(0.0), vec3(0.3, 0.1, 0.3), pow(sin(frameTimeCounter * endsky_speed) * 0.5 + 0.5, 6.0));
		// color = 0.5 * color /* + 0.1 * texture2D(texture,texcoord.xy).rgb */;

		// vec3 color = vec3(26, 0, 41) / 200.0 + fogColor;
		// color += 1.0 * fogColor;

		vec3 color = texture2D(texture,texcoord.xy).rgb * end_sky_brightness + fogColor;
		// color = vec3(1.0);

		gl_FragData[0] = vec4(color, 1.0);
	}
	else {
		gl_FragData[0] = texture2D(texture,texcoord.xy) * color;
	}
}
