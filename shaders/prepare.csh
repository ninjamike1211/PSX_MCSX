#version 430

#include "/lib/voxel.glsl"

layout (local_size_x = 8, local_size_y = 8, local_size_z = 1) in;
const ivec3 workGroups = ivec3(256, 256, 1);

uniform int frameCounter;

layout (rgba8) uniform image2D colorimg3;
layout (rgba8) uniform image2D colorimg4;

void main() {
    ivec2 coords = ivec2(gl_GlobalInvocationID.xy);
    if (frameCounter % 2 == 0)
        imageStore(colorimg4, coords, vec4(0.0));
    else
        imageStore(colorimg3, coords, vec4(0.0));
}