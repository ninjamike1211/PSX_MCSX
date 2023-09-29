#version 450 compatibility

varying vec2 texcoord;

uniform sampler2D shadowcolor0;
uniform sampler2D shadowcolor1;
uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;

// #include "/voxel/lib/voxelization.glsl"
#include "/voxel/lib/floodfill.glsl"

void main() {

	ivec2 storagePos = ivec2(gl_FragCoord.xy);

	vec4 currentBlock = texelFetch(shadowcolor0, storagePos, 0);

	ivec3 deltaCameraPos = ivec3(cameraPosition.xyz) - ivec3(previousCameraPosition.xyz);
	storagePos += deltaCameraPos.xz * 16;

	ivec2 rowStart = (storagePos / 16) * 16;
	storagePos.x += deltaCameraPos.y;
	storagePos.y += (storagePos.x - rowStart.x) / 16;
	storagePos.x = rowStart.x + (storagePos.x - rowStart.x) % 16;

	// uvec2 data = texelFetch(shadowcolor0, storagePos, 0).xy;
	vec4 light = texelFetch(shadowcolor1, storagePos, 0);

	// vec4[2] voxel = vec4[2](unpackUnorm4x8(data.x), unpackUnorm4x8(data.y));

	// int id = ExtractVoxelId(voxel);

	gl_FragData[1] = currentBlock.a < 0.4 ? light : currentBlock;

}
