const int shadowMapResolution = 2048; // [1024 2048 4096 8192 16384]

bool IsInVoxelizationVolume(ivec3 voxelIndex) {
	const int xzRadiusBlocks = shadowMapResolution / 32;
	const ivec3 lo = ivec3(-xzRadiusBlocks    ,   0,-xzRadiusBlocks    );
	const ivec3 hi = ivec3( xzRadiusBlocks - 1, 255, xzRadiusBlocks - 1);

	return clamp(voxelIndex, lo, hi) == voxelIndex;
}

vec3 SceneSpaceToVoxelSpace(vec3 scenePosition) {
	scenePosition.xz += fract(cameraPosition.xz);
	scenePosition.y  += fract(cameraPosition.y) + 128;
	return scenePosition;
}
vec3 WorldSpaceToVoxelSpace(vec3 worldPosition) {
	worldPosition.xz -= floor(cameraPosition.xz);
	worldPosition.y  -= floor(cameraPosition.y) - 128;
	return worldPosition;
}

vec3 VoxelSpaceToSceneSpace(vec3 voxelPosition) {
	voxelPosition.xz -= fract(cameraPosition.xz);
	voxelPosition.y  -= fract(cameraPosition.y) + 128;
	return voxelPosition;
}
vec3 VoxelSpaceToWorldSpace(vec3 voxelPosition) {
	voxelPosition.xz += floor(cameraPosition.xz);
	voxelPosition.y  += floor(cameraPosition.y) - 128;
	return voxelPosition;
}

ivec2 GetVoxelStoragePos(ivec3 voxelIndex) { // in pixels/texels
	return (voxelIndex.xz + (shadowMapResolution / 32)) * 16 + ivec2(voxelIndex.y % 16, voxelIndex.y / 16);
}

#if !defined VOXELIZATION_PASS
	vec4[2] ReadVoxel(ivec3 voxelPosition) {
		ivec2 storagePos = GetVoxelStoragePos(voxelPosition);

		uvec2 data = texelFetch(shadowcolor0, storagePos, 0).xy;

		return vec4[2](unpackUnorm4x8(data.x), unpackUnorm4x8(data.y));
	}
#endif

#define clamp01(x) clamp(x, 0.0, 1.0)

float PackUnorm2x4(vec2 xy) {
	return dot(floor(15.0 * xy + 0.5), vec2(1.0 / 255.0, 16.0 / 255.0));
}

vec2 UnpackUnorm2x4(float pack) {
	vec2 xy; xy.x = modf(pack * 255.0 / 16.0, xy.y);
	return xy * vec2(16.0 / 15.0, 1.0 / 15.0);
}

void SetVoxelTint(inout vec4[2] voxel, vec3 tint) {
	voxel[0].rgb = tint;
}
void SetVoxelId(inout vec4[2] voxel, int id) {
	voxel[0].a = id / 255.0;
}
void SetVoxelTileSize(inout vec4[2] voxel, int tileSize) {
	voxel[1].x = clamp01(log2(float(tileSize)) / 255.0);
}
void SetVoxelTileIndex(inout vec4[2] voxel, ivec2 tileIndex) {
	//voxel[1].zw = tileIndex / 255.0;
	voxel[1].yzw = vec3(PackUnorm2x4(floor(tileIndex / 256.0) / 15.0), fract(tileIndex / 256.0) * 256.0 / 255.0);
}

vec3 ExtractVoxelTint(vec4[2] voxel) {
	return voxel[0].rgb;
}
int ExtractVoxelId(vec4[2] voxel) {
	return int(0.5 + 255.0 * voxel[0].a);
}
int ExtractVoxelTileSize(vec4[2] voxel) {
	return int(exp2(floor(voxel[1].x * 255.0 + 0.5)));
}
ivec2 ExtractVoxelTileIndex(vec4[2] voxel) {
	//return ivec2(floor(voxel[1].zw * 255.0 + 0.5));
	return ivec2(256.0 * 15.0 * UnpackUnorm2x4(voxel[1].y) + 255.0 * voxel[1].zw);
}
