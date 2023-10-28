#version 420 compatibility
#extension GL_EXT_gpu_shader4 : enable
#include "/lib/psx_util.glsl"

#define gbuffers_solid
#define gbuffers_terrain
#include "/shaders.settings"
#include "/lib/voxel.glsl"

varying vec4 texcoord;
varying vec4 texcoordAffine;
varying vec4 lmcoord;
varying vec4 color;
varying vec3 voxelLightColor;

attribute vec4 mc_Entity;
attribute vec3 at_midBlock;

uniform vec2 texelSize;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferModelView;
uniform float frameTimeCounter;
uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;
uniform sampler2D lightmap;

layout (rgba8) uniform image2D colorimg4;
layout (rgba8) uniform image2D colorimg5;

#define diagonal3(m) vec3((m)[0].x, (m)[1].y, m[2].z)
#define projMAD(m, v) (diagonal3(m) * (v) + (m)[3].xyz)
vec4 toClipSpace3(vec3 viewSpacePosition) {
    return vec4(projMAD(gl_ProjectionMatrix, viewSpacePosition),-viewSpacePosition.z);
}

void main() {
	texcoord = gl_MultiTexCoord0;
	lmcoord = gl_TextureMatrix[1] * gl_MultiTexCoord1;
	int blockID = int(mc_Entity.x + 0.5);

	vec4 vertexPos = gl_Vertex;

	if(blockID == 10001) {
		vertexPos.y += water_wave_height * sin(water_wave_speed * frameTimeCounter + water_wave_length * (cos(water_wave_angle) * (vertexPos.x + cameraPosition.x) + sin(water_wave_angle) * (vertexPos.z + cameraPosition.z)));
	}
	else if(blockID == 11030) {
		vertexPos.y += lava_wave_height * sin(lava_wave_speed * frameTimeCounter + lava_wave_length * (cos(lava_wave_angle) * (vertexPos.x + cameraPosition.x) + sin(lava_wave_angle) * (vertexPos.z + cameraPosition.z)));
	}
	
	// vec4 ftrans = ftransform();
	vec4 ftrans = gl_ModelViewProjectionMatrix * vertexPos;
	float depth = clamp(ftrans.w, 0.001, 1000.0);
	float sqrtDepth = sqrt(depth);
	
	vec4 position4 = PixelSnap(ftrans, vertex_inaccuracy_terrain / sqrtDepth);
	vec3 position = position4.xyz;
	
	float wVal = (mat3(gl_ProjectionMatrix) * position).z;
	wVal = clamp(wVal, -10000.0, 0.0);
	texcoordAffine = vec4(texcoord.xy * wVal, wVal, 0);

	color = gl_Color;
	
	// "Fixes" z fighting with waterlogged blocks
	vec4 normal;
	normal.a = 4.0 / sqrtDepth;
	normal.xyz = normalize(gl_NormalMatrix * gl_Normal);
	
	position4 += normal * -0.001;
	
	gl_Position = position4;

	// Voxelization
	vec3 centerPos = gl_Vertex.xyz + at_midBlock/64.0;
	if(gl_VertexID % 4 == 0 && blockID > 11000) {
		ivec3 voxelPos = ivec3(floor(SceneSpaceToVoxelSpace(centerPos, cameraPosition)));
		if(IsInVoxelizationVolume(voxelPos)) {
			ivec2 voxelIndex = GetVoxelStoragePos(voxelPos);
			imageStore(colorimg4, voxelIndex, vec4(custLightColors[blockID - 11000], 1.0));
		}
	}

	ivec3 voxelPos = ivec3(floor(SceneSpaceToVoxelSpace(centerPos, previousCameraPosition)));
	voxelPos += ivec3(gl_Normal.xyz);
	if(IsInVoxelizationVolume(voxelPos)) {
		float lightMult = getLightMult(lmcoord.y, lightmap);
		ivec2 voxelIndex = GetVoxelStoragePos(voxelPos);
		voxelLightColor = imageLoad(colorimg5, voxelIndex).rgb * lightMult;
	}
	else {
		voxelLightColor = vec3(0.0);
	}
}
