#version 420 compatibility

varying vec4 color;
varying vec2 texcoord;
varying vec2 lmcoord;

uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferModelView;

void main() {

	vec4 position = gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex;
	gl_Position = gl_ProjectionMatrix * gbufferModelView * position;
	
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	color = gl_Color;

}
