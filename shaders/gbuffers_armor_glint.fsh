#version 420 compatibility
/* RENDERTARGETS: 10 */
 
#define gbuffers_armor_glint
#include "/shaders.settings"
#include "/lib/psx_util.glsl"


varying vec4 color;
varying vec2 texcoord;
varying vec3 viewPos;

uniform sampler2D texture;
uniform float rainStrength;
uniform float frameTimeCounter;
uniform float near;
uniform float far;
uniform int isEyeInWater;
uniform bool inNether;
uniform bool inEnd;

#include "/lib/fog.glsl"


void main() {
	vec4 col = texture2D(texture, texcoord + vec2(frameTimeCounter/8.0)) * color * enchanted_strength;

	float fogDepth = clamp(getFogDepth(viewPos, gl_FragCoord.z, isEyeInWater, near, far), 0.0, 1.0);
	col *= 1.0-fogDepth;

	gl_FragData[0] = col;
}
