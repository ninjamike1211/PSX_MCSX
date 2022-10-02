#version 120
/* DRAWBUFFERS:5 */

varying vec4 color;
varying vec2 texcoord;

uniform sampler2D texture;
uniform float frameTimeCounter;

uniform bool inEnd;

void main() {
	if(inEnd) {
		vec3 color = mix(vec3(0.2, 0.2, 0.25), vec3(0.3, 0.1, 0.3), sin(frameTimeCounter) * 0.5 + 0.5);
		color = 0.5 * color + 0.1 * texture2D(texture,texcoord.xy).rgb;

		gl_FragData[0] = vec4(color, 1.0);
	}
	else {
		gl_FragData[0] = texture2D(texture,texcoord.xy) * color;
	}
}
