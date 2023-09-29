#version 450 compatibility

varying vec2 texcoord;

uniform sampler2D shadowcolor0;
uniform sampler2D shadowcolor1;
uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;

// #include "/voxel/lib/voxelization.glsl"
#include "/voxel/lib/floodfill.glsl"

float minOf2(vec2 val) {return min(val.x, val.y);}

void main() {

	// ivec2 deltaCameraPos = ivec2(cameraPosition.xz) - ivec2(previousCameraPosition.xz);

	ivec2 storagePos = ivec2(gl_FragCoord.xy);

	// vec4 currentBlock = texelFetch(shadowcolor0, storagePos, 0);

	// storagePos -= deltaCameraPos * 16;

	// uvec2 data = texelFetch(shadowcolor0, storagePos, 0).xy;
	vec4 light = texelFetch(shadowcolor1, storagePos, 0);

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
		light.rgb = getLightColor(storagePos, shadowcolor1);
	// else
	// 	light = currentBlock;


	light.rgb *= minOf2(smoothstep(1.0, 0.9, abs(texcoord * 2.0 - 1.0)));

	gl_FragData[1] = light;
	// }

	// gl_FragData[1] = vec4(currentBlock.a);

}
