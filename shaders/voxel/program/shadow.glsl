//--// Settings

#define VOXELIZATION_PASS

//--// Uniforms

uniform vec3 cameraPosition;

uniform mat4 shadowModelViewInverse;

uniform int renderStage; 

uniform sampler2D tex;
uniform sampler2D normals;

#if   STAGE == STAGE_VERTEX
	//--// Vertex Inputs

	#define attribute in
	attribute vec3 at_midBlock;
	attribute vec2 mc_Entity;
	attribute vec2 mc_midTexCoord;

	uniform int blockEntityId;
	uniform int entityId;

	//--// Vertex Outputs

	out vec4 tint;
	out vec3 scenePosition;
	out vec3 worldNormal;
	out vec3 midBlock;
	out vec2 texCoord;
	out vec2 midCoord;
	out vec2 lmcoord;
	flat out int blockId;
	out float isNotOpaque;

	//--// Vertex Functions

	void main() {
		gl_Position = gl_ModelViewMatrix * gl_Vertex;

		tint = gl_Color;
		scenePosition = (shadowModelViewInverse * gl_Position).xyz;
		worldNormal = normalize(mat3(shadowModelViewInverse) * gl_NormalMatrix * gl_Normal);
		texCoord = gl_MultiTexCoord0.st;
		midBlock = (at_midBlock / 64.0);
		midCoord = mc_midTexCoord;
		lmcoord = gl_MultiTexCoord1.xy / 240.0;

		// if(renderStage == 8)
		// 	blockId = int(mc_Entity.x);

		// if(renderStage == 10)
		// 	blockId = entityId;
		// else if(renderStage == 12)
		// 	blockId = blockEntityId;
		// else
		// 	blockId = int(mc_Entity.x);

		if(entityId > 10000)
			blockId = entityId;
		else if(blockEntityId > 10000)
			blockId = blockEntityId;
		else
			blockId = int(mc_Entity.x);

		if (renderStage == 8 || blockId > 10000) {
			isNotOpaque = 0.0;
		} else {
			isNotOpaque = 1.0;
			// blockId = max(blockId, 1);
		}
	}
#elif STAGE == STAGE_GEOMETRY
	//--// Geometry Inputs

	const vec3[] custLightColors = vec3[](
		vec3(1.0, 1.0, 1.0),
		vec3(1.0, 0.7, 0.0),
		vec3(1.0, 0.0, 0.5),
		vec3(0.3, 0.7, 1.0),
		vec3(1.0, 1.0, 0.0),
		vec3(0.7, 1.0, 0.0),
		vec3(1.0, 0.5, 0.5),
		vec3(1.0, 1.0, 1.0),
		vec3(1.0, 1.0, 1.0),
		vec3(0.0, 1.0, 0.9),
		vec3(0.7, 0.0, 1.0),
		vec3(0.5, 0.5, 1.0),
		vec3(1.0, 0.7, 0.15),
		vec3(0.3, 1.0, 0.2),
		vec3(1.0, 0.3, 0.3),
		vec3(1.0, 1.0, 1.0),
		vec3(1.0, 0.4, 0.8),
		vec3(0.7, 1.0, 1.0),
		vec3(0.8, 1.0, 0.5),
		vec3(1.0, 1.0, 1.0),
		vec3(0.7, 1.0, 0.8),
		vec3(1.0, 0.7, 0.9),
		vec3(0.57, 1.0, 0.92)
	);

	layout (triangles) in;

	in vec4[3] tint;
	in vec3[3] scenePosition;
	in vec3[3] worldNormal;
	in vec3[3] midBlock;
	in vec2[3] texCoord;
	in vec2[3] midCoord;
	in vec2[3] lmcoord;
	flat in int[3] blockId;
	in float[3] isNotOpaque;

	//--// Geometry Outputs

	layout (points, max_vertices = 1) out;

	// out vec4 fData0;
	// out vec4 fData1;
	out vec4 fData2;

	//--// Geometry Libraries

	#include "/voxel/lib/voxelization.glsl"

	//--// Geometry Functionss

	float maxof(vec2 x) { return max(x.x, x.y); }
	float maxof(vec3 x) { return max(x.x, max(x.y, x.z)); }
	float minof(vec3 x) { return min(x.x, min(x.y, x.z)); }

	void main() {
		if (isNotOpaque[0] > 0.5) { return; }

		vec3 triCentroid = (scenePosition[0] + scenePosition[1] + scenePosition[2]) / 3.0;
		vec3 midCentroid = (midBlock[0] + midBlock[1] + midBlock[2]) / 3.0;

		// voxel position in the 2d map
		vec3 voxelSpacePosition = SceneSpaceToVoxelSpace(triCentroid + midCentroid);
		ivec3 voxelIndex = ivec3(floor(voxelSpacePosition));
		if (!IsInVoxelizationVolume(voxelIndex)) { return; }
		vec4 p2d = vec4(((GetVoxelStoragePos(voxelIndex) + 0.5) / float(shadowMapResolution)) * 2.0 - 1.0, worldNormal[0].y * -0.25 + 0.5, 1.0);

		// // fill out data
		// ivec2 atlasResolution = textureSize(tex, 0);
		// vec2 atlasAspectCorrect = vec2(1.0, float(atlasResolution.x) / float(atlasResolution.y));
		// float tileSize   = maxof(abs(texCoord[0] - midCoord[0]) / atlasAspectCorrect) / maxof(abs(scenePosition[0] - scenePosition[1]));
		// vec2  tileOffset = round((midCoord[0] - tileSize * atlasAspectCorrect) * atlasResolution);
		//       tileSize   = round(2.0 * tileSize * atlasResolution.x);
		//       tileOffset = round(tileOffset / tileSize);

		// vec4[2] voxel = vec4[2](vec4(0.0), vec4(0.0));
		// SetVoxelTint(voxel, tint[0].rgb);
		// SetVoxelId(voxel, blockId[0]);
		// SetVoxelTileSize(voxel, int(tileSize));
		// SetVoxelTileIndex(voxel, ivec2(tileOffset));

		// // Create the primitive
		// fData0 = voxel[0];
		// fData1 = voxel[1];

		if(blockId[0] == 10001) {
			fData2 = vec4(1.0, 0.85, 0.6, 1.0);	
		}
		else if(blockId[0] == 10002) {
			fData2 = vec4(1.0, 0.7, 0.2, 1.0);	
		}
		else if(blockId[0] == 10003) {
			fData2 = vec4(1.0, 0.3, 0.1, 1.0);	
		}
		else if(blockId[0] == 10004) {
			fData2 = vec4(0.8, 0.2, 1.0, 1.0);	
		}
		else if(blockId[0] == 10005) {
			fData2 = vec4(0.2, 0.7, 1.0, 1.0);	
		}
		else if(blockId[0] == 10006) {
			fData2 = vec4(0.9, 0.9, 1.0, 1.0);	
		}
		else if(blockId[0] > 10009) {
			fData2 = vec4(custLightColors[blockId[0] - 10010], 1.0);
		}
		else {
			fData2 = vec4(0.0, 0.0, 0.0, 0.5);
		}

		fData2 *= lmcoord[0].r;

		gl_Position  = p2d;
		gl_PointSize = 1.0;

		EmitVertex();
		EndPrimitive();
	}
#elif STAGE == STAGE_FRAGMENT
	//--// Fragment Inputs

	// in vec4 fData0;
	// in vec4 fData1;
	in vec4 fData2;

	//--// Fragment Functionss

	/* RENDERTARGETS: 0,1 */
	// layout(location = 0) out uvec2 voxelData;
	layout(location = 0) out vec4 lightData;
	// layout(location = 1) out vec4 nullData;

	void main() {
		// voxelData = uvec2(packUnorm4x8(fData0), packUnorm4x8(fData1));
		lightData = fData2;
		// nullData = vec4(0.0);
	}
#endif
