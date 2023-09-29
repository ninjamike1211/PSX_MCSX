#version 450 compatibility

varying vec2 texcoord;

void main() {

	gl_Position = ftransform();
	texcoord = gl_MultiTexCoord0.xy;
}
