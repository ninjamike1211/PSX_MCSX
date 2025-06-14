#version 420 compatibility

uniform sampler2D colortex4;
uniform sampler2D colortex5;
uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;
uniform int heldItemId;
uniform int heldItemId2;

#include "/lib/voxel.glsl"

/* RENDERTARGETS: 5 */
void main() {

	ivec2 storagePos = ivec2(gl_FragCoord.xy);
	ivec3 voxelIndex = GetVoxelIndex(storagePos);

	vec4 currentBlock = texelFetch(colortex4, storagePos, 0);

	#if Floodfill == 2
		gl_FragData[0] = currentBlock.a < 0.4 ? vec4(0.0) : currentBlock;
	#else
		ivec3 deltaCameraPos = ivec3(floor(cameraPosition.xyz) - floor(previousCameraPosition.xyz));
		storagePos = GetVoxelStoragePos(voxelIndex + deltaCameraPos);

		vec4 light = vec4(texelFetch(colortex5, storagePos, 0).rgb, 0.0);
		gl_FragData[0] = currentBlock.a < 0.4 ? light : currentBlock;
	#endif

	#ifdef Floodfill_HeltItemLight
		if(all(equal(voxelIndex, ivec3(0, 128, 0)))) {
			if(heldItemId >= 11000 && heldItemId < 12000) {
				gl_FragData[0] = vec4(max(gl_FragData[0].rgb, lightColors[heldItemId-11000]), 1.0);
			}
			if(heldItemId2 >= 11000 && heldItemId < 12000) {
				gl_FragData[0] = vec4(max(gl_FragData[0].rgb, lightColors[heldItemId2-11000]), 1.0);
			}
		}
	#endif
}
