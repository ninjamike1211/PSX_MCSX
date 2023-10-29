#version 330 compatibility

uniform sampler2D colortex4;
uniform sampler2D colortex5;
uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;

// #include "/voxel/lib/voxelization.glsl"
#include "/lib/voxel.glsl"

/* DRAWBUFFERS:5 */
void main() {

	ivec2 storagePos = ivec2(gl_FragCoord.xy);
	ivec3 voxelIndex = GetVoxelIndex(storagePos);

	vec4 currentBlock = texelFetch(colortex4, storagePos, 0);

	#ifdef Floodfill_Instant
		gl_FragData[0] = currentBlock.a < 0.4 ? vec4(0.0) : currentBlock;
	#else
		ivec3 deltaCameraPos = ivec3(floor(cameraPosition.xyz) - floor(previousCameraPosition.xyz));
		voxelIndex += deltaCameraPos;
		storagePos = GetVoxelStoragePos(voxelIndex);

		vec4 light = vec4(texelFetch(colortex5, storagePos, 0).rgb, 0.0);
		gl_FragData[0] = currentBlock.a < 0.4 ? light : currentBlock;
	#endif

}
