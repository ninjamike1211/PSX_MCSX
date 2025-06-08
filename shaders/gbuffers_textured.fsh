#version 420 compatibility
/* DRAWBUFFERS:01 */

varying vec2 texcoord;
varying vec3 texcoordAffine;
varying vec2 lmcoord;
varying vec4 color;
varying vec3 viewPos;

#include "/shaders.settings"
#include "/lib/psx_util.glsl"
#include "/lib/voxel.glsl"

uniform vec2 texelSize;
uniform sampler2D texture;
uniform sampler2D lightmap;

uniform sampler2D colortex12;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform vec3 fogColor;
uniform vec3 skyColor;
uniform float sunAngle;
uniform float rainStrength;
uniform float eyeAltitude;
uniform float near;
uniform float far;
uniform ivec2 eyeBrightnessSmooth;
uniform int isEyeInWater;
uniform bool inNether;
uniform bool inEnd;

#include "/lib/fog.glsl"

#if Floodfill > 0 && defined Floodfill_Particles
	varying vec3 voxelLightColor;
#endif

void main() {
	vec2 affine = AffineMapping(texcoordAffine, texcoord, texelSize, 2);
	vec4 col = texture2D(texture, texcoord) * color;

	#if Floodfill > 0 && defined Floodfill_Particles
		vec4 lighting = vec4(voxelLightColor, 0.0);
		lighting += (texture2D(lightmap, vec2(1.0/32.0, lmcoord.y)) * 0.8 + 0.2);
	#else
		vec4 lighting = texture2D(lightmap, lmcoord.xy) * 0.8 + 0.2;
	#endif
	
	col *= lighting;

	float fogDepth = clamp(getFogDepth(viewPos, gl_FragCoord.z, near, far), 0.0, 1.0);
	float caveFactor = fogCaveFactor(eyeAltitude, eyeBrightnessSmooth.y, colortex12);
	applyFogColor(col.rgb, fogDepth, caveFactor, normalize(viewPos), sunAngle);
	
	gl_FragData[0] = col;
	gl_FragData[1] = vec4(0.0, 1.0, 0.0, 1.0);
}
