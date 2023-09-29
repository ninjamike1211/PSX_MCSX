vec3 getLightColor(ivec2 storagePos, sampler2D lightSampler) {
    vec3 maxLight = vec3(0.0);

    maxLight = max(maxLight, texelFetch(lightSampler, storagePos + ivec2(0, 16), 0).rgb);
    maxLight = max(maxLight, texelFetch(lightSampler, storagePos + ivec2(0,-16), 0).rgb);
    maxLight = max(maxLight, texelFetch(lightSampler, storagePos + ivec2(16, 0), 0).rgb);
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