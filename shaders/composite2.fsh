#version 450 compatibility

uniform sampler2D colortex5;
uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;

#include "/lib/voxel.glsl"

float minOf2(vec2 val) {return min(val.x, val.y);}

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

/* DRAWBUFFERS:5 */
void main() {

	// ivec2 deltaCameraPos = ivec2(cameraPosition.xz) - ivec2(previousCameraPosition.xz);

	ivec2 storagePos = ivec2(gl_FragCoord.xy);

	// vec4 currentBlock = texelFetch(shadowcolor0, storagePos, 0);

	// storagePos -= deltaCameraPos * 16;

	// uvec2 data = texelFetch(shadowcolor0, storagePos, 0).xy;
	vec4 light = texelFetch(colortex5, storagePos, 0);

	// vec4[2] voxel = vec4[2](unpackUnorm4x8(data.x), unpackUnorm4x8(data.y));

	// int id = ExtractVoxelId(voxel);

	// if(id > 44 && id < 71)
	// 	gl_FragData[1] = vec4(1.0, 0.0, 0.0, 1.0);
	// else
	// 	gl_FragData[1] = vec4(0.0, 0.0, 1.0, 1.0);

	// if(length(light.rgb) > 0.95) {
	// 	// if(length(deltaCameraPos) > 0.1)
	// 	// 	light = vec4(1.0);

	// 	gl_FragData[1] = light;
	// }
	// else {

	// if(currentBlock.a < 0.4)
		light.rgb = getLightColor(storagePos, colortex5);
	// else
	// 	light = currentBlock;


	// light.rgb *= minOf2(smoothstep(1.0, 0.9, abs(texcoord * 2.0 - 1.0)));

	gl_FragData[0] = light;
	// }

	// gl_FragData[1] = vec4(currentBlock.a);

}
