#version 420 compatibility

#define gbuffers_solid
#define gbuffers_terrain
#include "/shaders.settings"
#include "/lib/psx_util.glsl"
#include "/lib/voxel.glsl"

varying vec2 texcoord;
varying vec3 texcoordAffine;
varying vec2 lmcoord;
varying vec4 color;
varying vec3 viewPos;
varying float testOut;

attribute vec4 mc_Entity;
attribute vec3 at_midBlock;
attribute vec4 at_tangent;

uniform float frameTimeCounter;
uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;
uniform sampler2D lightmap;
uniform int isEyeInWater;
uniform mat4 gbufferModelViewInverse;

#if Floodfill > 0
	varying vec3 voxelLightColor;
	layout (rgba8) uniform image2D colorimg4;
	readonly layout (rgba8) uniform image2D colorimg5;
#endif


// vec3 screenToView(vec3 screenPos) {
// 	vec4 ndcPos = vec4(screenPos, 1.0) * 2.0 - 1.0;
// 	vec4 tmp = gbufferProjectionInverse * ndcPos;
// 	return tmp.xyz / tmp.w;
// }


void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	color = gl_Color;
	int blockID = int(mc_Entity.x + 0.5);

	vec4 vertexPos = gl_Vertex;


	if(blockID == 10001) {
		vec4 viewPos = gl_ModelViewMatrix * vertexPos;
		vec3 worldPos = fract(cameraPosition) + (gbufferModelViewInverse * viewPos).xyz;

		// if(abs(gl_Vertex.x - int(gl_Vertex.x+0.5)) => 0.000) {
		vec3 fractPos = 0.5 - abs(0.5 - fract(worldPos.xyz));
		if (fract(gl_Normal.xyz) == vec3(0.0) &&
			((fractPos.x > 0.0009 && fractPos.x < 0.002) ||
			(fractPos.z > 0.0009 && fractPos.z < 0.002))) {
			gl_Position = vec4(vec3(-10.0), 1.0);
			return;
			// color = vec4(vec3(0.0), 1.0);
		}

		// vertexPos.y += water_wave_height * sin(water_wave_speed * frameTimeCounter + water_wave_length * (cos(water_wave_angle) * (vertexPos.x + cameraPosition.x) + sin(water_wave_angle) * (vertexPos.z + cameraPosition.z)));
	}
	else if(blockID == 11030) {
		vertexPos.y += lava_wave_height * sin(lava_wave_speed * frameTimeCounter + lava_wave_length * (cos(lava_wave_angle) * (vertexPos.x + cameraPosition.x) + sin(lava_wave_angle) * (vertexPos.z + cameraPosition.z)));
	}
	
	viewPos = (gl_ModelViewMatrix * vertexPos).xyz;
	vec4 ftrans = gl_ProjectionMatrix * vec4(viewPos, 1.0);
	float depth = clamp(ftrans.w, 0.001, 1000.0);
	float sqrtDepth = sqrt(depth);
	
	vec4 position4 = PixelSnap(ftrans, vertex_inaccuracy_terrain / sqrtDepth);
	vec3 position = position4.xyz;
	
	float wVal = (mat3(gl_ProjectionMatrix) * position).z;
	wVal = clamp(wVal, -10000.0, 0.0);
	texcoordAffine = vec3(texcoord * wVal, wVal);
	
	// "Fixes" z fighting with waterlogged blocks
	vec4 normal;
	normal.a = 4.0 / sqrtDepth;
	normal.xyz = normalize(gl_NormalMatrix * gl_Normal);
	
	position4 += normal * -0.001;
	
	// gl_Position = position4;
	gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;


	// Voxelization
	#if Floodfill > 0
		vec3 centerPos = gl_Vertex.xyz + at_midBlock/64.0;

		ivec3 voxelPos = getPreviousVoxelIndex(centerPos, cameraPosition, previousCameraPosition);
		if(all(greaterThan(abs(at_midBlock), vec3(27.0))) && any(equal(gl_Normal * sign(at_midBlock), vec3(-1.0)))) {
			voxelPos += ivec3(gl_Normal.xyz);
		}

		if(IsInVoxelizationVolume(voxelPos)) {
			float lightMult = getLightMult(lmcoord.y, lightmap);
			ivec2 voxelIndex = GetVoxelStoragePos(voxelPos);
			vec4 voxel_raw = imageLoad(colorimg5, voxelIndex);
			voxelLightColor = voxel_raw.rgb * lightMult;
		}
		else {
			voxelLightColor = vec3(0.0);
		}


		if(gl_VertexID % 4 == 0 && ((blockID < 10000 || blockID > 10902) || (blockID >= 11000 && blockID < 12000))) {
			voxelPos = ivec3(floor(SceneSpaceToVoxelSpace(centerPos, cameraPosition)));
			if(IsInVoxelizationVolume(voxelPos)) {
				ivec2 voxelIndex = GetVoxelStoragePos(voxelPos);

				vec4 lightVal = vec4(0.0, 0.0, 0.0, 0.75);
				if(blockID >= 11000) {
					lightVal = vec4(lightColors[blockID - 11000], 1.0);
				}

				imageStore(colorimg4, voxelIndex, vec4(lightVal));
			}
		}

		testOut = -1.0;
		// if(blockID == 10001) {

		// 	vec3 worldNormal = mat3(gbufferModelViewInverse) * normal.xyz;
		// 	// vec3 tangent = mat3(gbufferModelViewInverse) * normalize(gl_NormalMatrix * at_tangent.xyz);
		// 	// vec3 bitangent = cross(worldNormal, tangent) * sign(-at_tangent.w);

		// 	// ivec3 samplePos = voxelPos + ivec3(worldNormal);
		// 	ivec3 samplePos = ivec3(floor(SceneSpaceToVoxelSpace(centerPos + worldNormal, cameraPosition)));
		// 	ivec2 voxelIndex = GetVoxelStoragePos(samplePos);
		// 	vec4 voxelData = imageLoad(colorimg4, voxelIndex);

		// 	testOut = voxelData.r;
		// 	// testOut = 1.0;
		// 	if(voxelData.a > 0.6) {
		// 		color.a = 0.0;
		// 		testOut = 0.0;
		// 	}

		// 	// vec3 screenPos = position4.xyz / position4.w;
		// 	// vec3 viewDir = normalize(screenToView(screenPos));
		// 	// // normal = normalize((gl_NormalMatrix * gl_Normal).xyz);
		// 	// float viewDot = dot(normal.xyz, viewDir);
		// 	// // float viewDot = dot(normal, gbufferModelViewInverse[2].xyz);
		// 	// // normal = vec3(viewDot);


		// 	// if(viewDot < 0.0) {
		// 	// if(abs(fract(gl_Vertex.x)) > 0.5 || abs(fract(gl_Vertex.z)) > 0.5) {
		// 	// if(abs(worldNormal.y) < 0.1) {
		// 	// 	// gl_Position = vec4(vec3(-10.0), 1.0);
		// 	// 	// return;
		// 	// 	color.a = 0.0;
		// 	// }

		// }
	#endif

}
