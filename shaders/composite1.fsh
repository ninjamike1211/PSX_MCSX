#version 450 compatibility

uniform sampler2D colortex4;
uniform sampler2D colortex5;
uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;

// #include "/voxel/lib/voxelization.glsl"
#include "/lib/voxel.glsl"

/* DRAWBUFFERS:5 */
void main() {

	ivec2 storagePos = ivec2(gl_FragCoord.xy);

	vec4 currentBlock = texelFetch(colortex4, storagePos, 0);

	ivec3 deltaCameraPos = ivec3(floor(cameraPosition.xyz) - floor(previousCameraPosition.xyz));
	storagePos += deltaCameraPos.xz * 16;

	ivec2 rowStart = (storagePos / 16) * 16;
	storagePos.x += deltaCameraPos.y;
	storagePos.y += (storagePos.x - rowStart.x) / 16;
	storagePos.x = rowStart.x + (storagePos.x - rowStart.x) % 16;

	vec4 light = texelFetch(colortex5, storagePos, 0);

	gl_FragData[0] = currentBlock.a < 0.4 ? light : currentBlock;

}
