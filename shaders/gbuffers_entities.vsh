#version 420 compatibility
#extension GL_EXT_gpu_shader4 : enable
#include "/lib/psx_util.glsl"

#define gbuffers_solid
#define gbuffers_entities
#include "/shaders.settings"

varying vec4 texcoord;
varying vec4 texcoordAffine;
varying vec2 lmcoord;
varying vec4 color;
varying vec3 voxelLightColor;

attribute vec2 mc_midTexCoord;

uniform vec2 texelSize;
uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;
uniform int entityId;
uniform mat4 gbufferModelViewInverse;
uniform sampler2D gtexture;

layout (rgba8) uniform image2D colorimg4;
layout (rgba8) uniform image2D colorimg5;

#include "/lib/voxel.glsl"

#define diagonal3(m) vec3((m)[0].x, (m)[1].y, m[2].z)
#define  projMAD(m, v) (diagonal3(m) * (v) + (m)[3].xyz)
vec4 toClipSpace3(vec3 viewSpacePosition) {
  return vec4(projMAD(gl_ProjectionMatrix, viewSpacePosition),-viewSpacePosition.z);
}

void main() {
	texcoord.xy = (gl_MultiTexCoord0).xy;
	texcoord.zw = gl_MultiTexCoord1.xy/255.0;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	
	vec4 ftrans = ftransform();
	float depth = clamp(ftrans.w, 0.001, 1000);
	float sqrtDepth = sqrt(depth);
	
	vec4 position4 = mat4(gl_ModelViewMatrix) * vec4(gl_Vertex) + gl_ModelViewMatrix[3].xyzw;
	vec3 position = PixelSnap(position4, vertex_inaccuracy_entities / sqrtDepth).xyz;
	
	float wVal = (mat3(gl_ProjectionMatrix) * position).z;
	wVal = clamp(wVal, 0.0, 10000.0);
	texcoordAffine = vec4(texcoord.xy * wVal, wVal, 0);
	
	color = gl_Color;
	gl_Position = toClipSpace3(position);



	// Voxelization
	vec3 playerPos = (gbufferModelViewInverse * gl_Vertex).xyz;
	ivec3 voxelPos = ivec3(floor(SceneSpaceToVoxelSpace(playerPos - vec3(0.0, 0.5, 0.0), cameraPosition)));
	if(gl_VertexID % 4 == 0) {

		if(IsInVoxelizationVolume(voxelPos)) {
			ivec2 voxelIndex = GetVoxelStoragePos(voxelPos);

			vec4 lightVal = vec4(0.0, 0.0, 0.0, 0.0);
			vec4 cornerColor = texture2D(gtexture, 0.8 * ((gl_MultiTexCoord0).xy + 0.25 * mc_midTexCoord));
			if(cornerColor == vec4(0.0, 1.0, 0.0, 25.0/255.0)) {
				imageStore(colorimg4, voxelIndex, vec4(custLightColors[1], 1.0));
			}
			else if(cornerColor == vec4(1.0, 1.0, 0.0, 25.0/255.0)) {
				imageStore(colorimg4, voxelIndex, vec4(custLightColors[2], 1.0));
			}
			else if(cornerColor == vec4(1.0, 0.0, 0.0, 25.0/255.0)) {
				imageStore(colorimg4, voxelIndex, vec4(custLightColors[3], 1.0));
			}
			else if(cornerColor == vec4(1.0, 0.0, 1.0, 25.0/255.0)) {
				imageStore(colorimg4, voxelIndex, vec4(custLightColors[4] * lmcoord.x * 2.5, 1.0));
			}
			else if(cornerColor == vec4(0.0, 0.0, 1.0, 25.0/255.0)) {
				imageStore(colorimg4, voxelIndex, vec4(custLightColors[5], 1.0));
			}
			else if(cornerColor == vec4(0.0, 1.0, 1.0, 25.0/255.0)) {
				imageStore(colorimg4, voxelIndex, vec4(custLightColors[1] * 0.25, 1.0));
			}

			// imageStore(colorimg4, voxelIndex, lightVal);
		}
	}

	voxelPos = ivec3(floor(SceneSpaceToVoxelSpace(playerPos, previousCameraPosition)));
	// voxelPos += ivec3(gl_Normal.xyz);
	if(IsInVoxelizationVolume(voxelPos)) {
		ivec2 voxelIndex = GetVoxelStoragePos(voxelPos);
		// ivec3 deltaCameraPos = ivec3(floor(cameraPosition.xyz) - floor(previousCameraPosition.xyz));
		// voxelIndex += deltaCameraPos.xz * 16;

		// ivec2 rowStart = (voxelIndex / 16) * 16;
		// voxelIndex.x += deltaCameraPos.y;
		// voxelIndex.y += (voxelIndex.x - rowStart.x) / 16;
		// voxelIndex.x = rowStart.x + (voxelIndex.x - rowStart.x) % 16;

		voxelLightColor = imageLoad(colorimg5, voxelIndex).rgb;
	}
	else {
		voxelLightColor = vec3(0.0);
	}
}
