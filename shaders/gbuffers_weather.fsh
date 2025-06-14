#version 420 compatibility
/* RENDERTARGETS: 0,1 */

varying vec4 color;

varying vec2 texcoord;
varying vec2 lmcoord;

uniform sampler2D texture;
uniform sampler2D lightmap;

void main() {

	vec4 tex = texture2D(texture, texcoord)*color;
	tex *= texture2D(lightmap, lmcoord);

	gl_FragData[0] = tex;
	gl_FragData[1] = vec4(0.0);
}
