#version 330

uniform sampler2D colortex5;

#include "/lib/voxel.glsl"

/* DRAWBUFFERS:5 */
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

void main() {
    ivec2 storagePos = ivec2(gl_FragCoord.xy);

    vec4 lightColor = texelFetch(colortex5, storagePos, 0);

    // if(lightColor.a < 0.9) {
        lightColor.rgb = getLightColor(storagePos, colortex5);
    // }

    gl_FragData[0] = lightColor;
}