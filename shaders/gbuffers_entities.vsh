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

uniform vec2 texelSize;
uniform vec3 cameraPosition;
uniform int entityId;
uniform mat4 gbufferModelViewInverse;

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

	// // Voxelization
	// if(entityId > 11000) {
	// 	vec3 centerPos = (gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex)).xyz;
	// 	ivec3 voxelPos = ivec3(SceneSpaceToVoxelSpace(centerPos));
	// 	if(IsInVoxelizationVolume(voxelPos)) {
	// 		ivec2 voxelIndex = GetVoxelStoragePos(voxelPos);
	// 		imageStore(colorimg4, voxelIndex, uvec4(entityId - 11000) + 1);
	// 	}
	// }
}
