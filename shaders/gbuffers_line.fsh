#version 120

varying vec4 color;

/* DRAWBUFFERS:0 */
void main() {

	vec4 col = color;
	gl_FragData[0] = col;
}
