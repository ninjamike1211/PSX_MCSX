#version 330 compatibility

uniform sampler2D colortex5;
uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;

#include "/lib/voxel.glsl"

/* DRAWBUFFERS:5 */
void main() {

	ivec2 storagePos = ivec2(gl_FragCoord.xy);

	vec4 light = texelFetch(colortex5, storagePos, 0);

	if(light.a < 0.4)
		light.rgb = getLightColor(storagePos, colortex5);

	gl_FragData[0] = light;

}
