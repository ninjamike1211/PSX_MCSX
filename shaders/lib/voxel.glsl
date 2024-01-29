// #define Floodfill_Enable // Enables floodfill colored lighting, significant performance impact

#define voxelMapResolution 2048 // [1024 2048 4096]
const int xzRadiusBlocks = voxelMapResolution / 32;

#define Floodfill_Brightness 1.0 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define Floodfill_SkyLightFactor 0.8 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define Floodfill_Instant
// #define Floodfill_Particles
// #define Floodfill_HeltItemLight

/*
#ifdef Floodfill_HeltItemLight
#endif
#ifdef Floodfill_Particles
#endif
*/

#ifdef Floodfill_Enable

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

    ivec3 getPreviousVoxelIndex(vec3 playerPos, vec3 cameraPosition, vec3 previousCameraPosition) {
        playerPos += cameraPosition - previousCameraPosition;
        return ivec3(floor(SceneSpaceToVoxelSpace(playerPos, previousCameraPosition)));
    }

    float getLightMult(float skyLmcoord, sampler2D lightmap) {
        vec3 skyLightVal = texture2D(lightmap, vec2(1.0/32.0, skyLmcoord)).rgb;
        vec3 fullLightVal = texture2D(lightmap, vec2(31.0/32.0, skyLmcoord)).rgb;
        return (fullLightVal.r - skyLightVal.r) * Floodfill_SkyLightFactor + (1.0 - Floodfill_SkyLightFactor) * Floodfill_Brightness;
    }


    const vec3[] custLightColors = vec3[](
        vec3(1.0, 0.85, 0.6),
        vec3(1.0, 0.7, 0.2),
        vec3(1.0, 0.5, 0.0),
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
        vec3(1.0, 0.7, 0.2),
        vec3(0.4, 0.3, 0.1),
        vec3(0.6, 1.0, 0.7),
        vec3(0.7, 0.05, 0.2),
        vec3(0.7, 0.48, 0.05),
        vec3(0.7, 0.6, 0.05),
        vec3(0.4, 0.7, 0.1),
        vec3(0.3, 0.5, 0.7),
        vec3(0.1, 0.3, 0.7),
        vec3(0.7, 0.05, 0.5),
        vec3(0.6, 0.6, 0.6),
        vec3(0.3, 0.3, 0.3),
        vec3(0.3, 0.3, 0.3),
        vec3(1.0, 0.9, 0.6),
        vec3(0.4, 0.7, 0.7)
    );

    vec3 getLightColor(ivec2 storagePos, sampler2D lightSampler) {
        vec3 maxLight = vec3(0.0);

        maxLight = max(maxLight, texelFetch(lightSampler, storagePos + ivec2( 0, 16), 0).rgb);
        maxLight = max(maxLight, texelFetch(lightSampler, storagePos + ivec2( 0,-16), 0).rgb);
        maxLight = max(maxLight, texelFetch(lightSampler, storagePos + ivec2( 16, 0), 0).rgb);
        maxLight = max(maxLight, texelFetch(lightSampler, storagePos + ivec2(-16, 0), 0).rgb);

        ivec2 rowStart = (storagePos / 16) * 16;
        int yIndex = storagePos.x - rowStart.x + 16 * (storagePos.y - rowStart.y);

        ivec2 storagePosY = rowStart + ivec2((yIndex + 1) % 16, (yIndex + 1) / 16);
        maxLight = max(maxLight, texelFetch(lightSampler, storagePosY, 0).rgb);

        storagePosY = rowStart + ivec2((yIndex - 1) % 16, (yIndex - 1) / 16);
        maxLight = max(maxLight, texelFetch(lightSampler, storagePosY, 0).rgb);

        // maxLight /= 4.0;
        maxLight = clamp(maxLight - 1.0/16.0, 0.0, 1.0);

        return maxLight;
    }

#endif