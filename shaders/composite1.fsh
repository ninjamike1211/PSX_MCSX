#version 330

uniform usampler2D colortex4;
uniform sampler2D  colortex5;

uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;

#include "/lib/voxel.glsl"

/* DRAWBUFFERS:5 */
void main() {
    ivec2 storagePos = ivec2(gl_FragCoord.xy);
    int blockID = int(texelFetch(colortex4, storagePos, 0).r);

    vec4 lightColor = vec4(0.0);

    // Air (no block)
    if(blockID == 0) {
        ivec3 deltaCameraPos = ivec3(cameraPosition) - ivec3(previousCameraPosition);
        // ivec3 deltaCameraPos = ivec3(floor(SceneSpaceToVoxelSpace(vec3(0.0), cameraPosition)) - floor(SceneSpaceToVoxelSpace(vec3(0.0), previousCameraPosition)));
        // vec3 fractDiff = fract(cameraPosition) - fract(previousCameraPosition);
        // ivec3 deltaCameraPos = -ivec3(fractDiff + sign(fractDiff) * 0.5);
        storagePos += deltaCameraPos.xz * 16;

        ivec2 rowStart = (storagePos / 16) * 16;
        storagePos.x += deltaCameraPos.y;
        storagePos.y += (storagePos.x - rowStart.x) / 16;
        storagePos.x = rowStart.x + (storagePos.x - rowStart.x) % 16;

        // if(clamp(storagePos, 0, voxelMapResolution-1) == storagePos) {
            lightColor = vec4(texelFetch(colortex5, storagePos, 0).xyz, 1.0);
        // }

        // lightColor = vec4(vec3(lightColor.rgb == vec3(0.0)), 1.0);
    }
    // Block
    else {
        lightColor = vec4(custLightColors[blockID-1], 1.0);
    }

    gl_FragData[0] = lightColor;
}