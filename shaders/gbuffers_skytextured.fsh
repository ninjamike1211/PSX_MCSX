#version 420 compatibility
/* RENDERTARGETS: 0,11 */

#define gbuffers_skytextured
#include "/shaders.settings"
#include "/lib/psx_util.glsl"

varying vec4 color;
varying vec2 texcoord;

uniform sampler2D gtexture;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform vec3 fogColor;
uniform vec3 skyColor;
uniform float sunAngle;
uniform float rainStrength;
uniform float viewWidth;
uniform float viewHeight;
uniform int isEyeInWater;
uniform bool inNether;
uniform bool inEnd;

#include "/lib/fog.glsl"

vec3 screenToView(vec3 screenPos) {
	vec4 ndcPos = vec4(screenPos, 1.0) * 2.0 - 1.0;
	vec4 tmp = gbufferProjectionInverse * ndcPos;
	return tmp.xyz / tmp.w;
}

void main() {
	if(inEnd) {
		vec3 skyColor = texture2D(gtexture,texcoord).rgb * end_sky_brightness + fogColor;
		gl_FragData[0] = vec4(skyColor, 1.0);
		gl_FragData[1] = vec4(skyColor, 1.0);
	}
	else {
		vec4 skyColor = texture2D(gtexture,texcoord) * color * fog_sunmoon;

		vec3 viewDir = normalize(screenToView(vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), 1.0)));
		float upDot = dot(viewDir, gbufferModelView[1].xyz);
		skyColor *= smoothstep(-0.2, 0.0, upDot);

		vec3 skyColorFog;
		applyFogColor(skyColorFog, 1.0, 1.0, skyColor.rgb, viewDir, isEyeInWater, sunAngle);
		gl_FragData[0] = vec4(skyColorFog, skyColor.a);
		gl_FragData[1] = skyColor;
	}
}
