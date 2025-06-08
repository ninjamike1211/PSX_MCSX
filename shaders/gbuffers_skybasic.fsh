#version 420 compatibility

uniform mat4 gbufferModelView;
uniform mat4 gbufferProjectionInverse;
uniform vec3 fogColor;
uniform vec3 skyColor;
uniform float sunAngle;
uniform float rainStrength;
uniform float viewWidth;
uniform float viewHeight;

#define gbuffers_sky
#include "/shaders.settings"
#include "/lib/psx_util.glsl"
#include "/lib/fog.glsl"

vec3 screenToView(vec3 screenPos) {
	vec4 ndcPos = vec4(screenPos, 1.0) * 2.0 - 1.0;
	vec4 tmp = gbufferProjectionInverse * ndcPos;
	return tmp.xyz / tmp.w;
}

/* DRAWBUFFERS:0 */
void main() {
	vec3 viewPos = screenToView(vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), 1.0));
	gl_FragData[0] = vec4(getOverworldSkyColor(normalize(viewPos), sunAngle), 0.0);
}
