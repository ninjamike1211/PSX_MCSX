#version 420 compatibility

varying vec4 color;

/* DRAWBUFFERS:01 */
void main() {
	
	gl_FragData[0] = color;
	gl_FragData[1] = vec4(0.0);
}
