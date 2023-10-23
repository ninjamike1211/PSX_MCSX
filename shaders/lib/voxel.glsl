#define voxelMapResolution 2048 // [1024 2048 4096]
const int xzRadiusBlocks = voxelMapResolution / 32;

bool IsInVoxelizationVolume(ivec3 voxelIndex) {
	const ivec3 lo = ivec3(-xzRadiusBlocks    ,   0,-xzRadiusBlocks    );
	const ivec3 hi = ivec3( xzRadiusBlocks - 1, 255, xzRadiusBlocks - 1);

	return clamp(voxelIndex, lo, hi) == voxelIndex;
}

vec3 SceneSpaceToVoxelSpace(vec3 scenePosition, vec3 cameraPosition) {
	scenePosition.xz += fract(cameraPosition.xz);
	scenePosition.y  += fract(cameraPosition.y) + 128;
	return scenePosition;
}
vec3 WorldSpaceToVoxelSpace(vec3 worldPosition, vec3 cameraPosition) {
	worldPosition.xz -= floor(cameraPosition.xz);
	worldPosition.y  -= floor(cameraPosition.y) - 128;
	return worldPosition;
}

vec3 VoxelSpaceToSceneSpace(vec3 voxelPosition, vec3 cameraPosition) {
	voxelPosition.xz -= fract(cameraPosition.xz);
	voxelPosition.y  -= fract(cameraPosition.y) + 128;
	return voxelPosition;
}
vec3 VoxelSpaceToWorldSpace(vec3 voxelPosition, vec3 cameraPosition) {
	voxelPosition.xz += floor(cameraPosition.xz);
	voxelPosition.y  += floor(cameraPosition.y) - 128;
	return voxelPosition;
}

ivec2 GetVoxelStoragePos(ivec3 voxelIndex) {
	return (voxelIndex.xz + xzRadiusBlocks) * 16 + ivec2(voxelIndex.y % 16, voxelIndex.y / 16);
}

ivec3 GetVoxelIndex(ivec2 storagePos) {
	ivec3 voxelIndex;
    voxelIndex.xz = storagePos / 16 - xzRadiusBlocks;
    voxelIndex.y = (storagePos.x % 16) + 16 * (storagePos.y % 16);
    return voxelIndex;
}


const vec3[] custLightColors = vec3[](
    vec3(0.0, 0.0, 0.0),
    vec3(1.0, 0.85, 0.6),
    vec3(1.0, 0.7, 0.2),
    vec3(1.0, 0.3, 0.1),
    vec3(0.8, 0.2, 1.0),
    vec3(0.2, 0.7, 1.0),
    vec3(0.9, 0.9, 1.0),
    vec3(1.0, 1.0, 1.0),
    vec3(1.0, 0.7, 0.0),
    vec3(1.0, 0.0, 0.5),
    vec3(0.3, 0.7, 1.0),
    vec3(1.0, 1.0, 0.0),
    vec3(0.7, 1.0, 0.0),
    vec3(1.0, 0.5, 0.5),
    vec3(0.6, 0.6, 0.6),
    vec3(0.85, 0.85, 0.85),
    vec3(0.0, 1.0, 0.9),
    vec3(0.7, 0.0, 1.0),
    vec3(0.5, 0.5, 1.0),
    vec3(0.7, 0.5, 0.1),
    vec3(0.3, 1.0, 0.2),
    vec3(1.0, 0.3, 0.3),
    vec3(0.4, 0.4, 0.4),
    vec3(0.8, 0.3, 0.6),
    vec3(0.7, 1.0, 1.0),
    vec3(0.5, 0.6, 0.3),
    vec3(0.3, 0.3, 0.3),
    vec3(0.7, 1.0, 0.8),
    vec3(1.0, 0.7, 0.9),
    vec3(0.3, 0.53, 0.49),
    vec3(1.0, 0.7, 0.2)
);