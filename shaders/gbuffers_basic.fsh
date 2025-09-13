#version 420 compatibility

varying vec4 color;

/* RENDERTARGETS: 10,1 */
void main() {
	
	gl_FragData[0] = color;
	gl_FragData[1] = vec4(0.0);
}
