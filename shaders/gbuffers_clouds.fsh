#version 420 compatibility
/* RENDERTARGETS: 10 */

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 color;

uniform sampler2D texture;
uniform sampler2D lightmap;

void main() {
	vec4 col = texture2D(texture, texcoord);

	if(col.a < 0.1)
		discard;

	col *= texture2D(lightmap, lmcoord) * color;
	
	gl_FragData[0] = col;
}
