#version 120

varying vec4 color;

/* RENDERTARGETS: 10 */
void main() {

	vec4 col = color;
	gl_FragData[0] = col;
}
