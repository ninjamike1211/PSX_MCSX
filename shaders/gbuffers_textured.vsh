#version 420 compatibility
#extension GL_EXT_gpu_shader4 : enable

#define gbuffers_solid
#define gbuffers_terrain
#include "/shaders.settings"
#include "/lib/psx_util.glsl"
#include "/lib/voxel.glsl"

varying vec2 texcoord;
varying vec3 texcoordAffine;
varying vec2 lmcoord;
varying vec4 color;

attribute vec4 mc_Entity;

uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;
uniform mat4 gbufferModelViewInverse;
uniform sampler2D lightmap;

#define diagonal3(m) vec3((m)[0].x, (m)[1].y, m[2].z)
#define projMAD(m, v) (diagonal3(m) * (v) + (m)[3].xyz)
vec4 toClipSpace3(vec3 viewSpacePosition) {
    return vec4(projMAD(gl_ProjectionMatrix, viewSpacePosition),-viewSpacePosition.z);
}


#if defined Floodfill_Enable && defined Floodfill_Particles
	readonly layout (rgba8) uniform image2D colorimg5;
	varying vec3 voxelLightColor;
#endif

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	
	vec4 position4 = mat4(gl_ModelViewMatrix) * vec4(gl_Vertex) + gl_ModelViewMatrix[3].xyzw;
	vec3 position = PixelSnap(position4, vertex_inaccuracy_terrain).xyz;
	
	float wVal = (mat3(gl_ProjectionMatrix) * position).z;
	wVal = clamp(wVal, -10000.0, 0.0);
	texcoordAffine = vec3(texcoord.xy * wVal, wVal);

	color = gl_Color;
	
	gl_Position = toClipSpace3(position);

	// Voxelization
	#if defined Floodfill_Enable && defined Floodfill_Particles
		vec3 playerPos = (gbufferModelViewInverse * position4).xyz;
		ivec3 voxelPos = getPreviousVoxelIndex(playerPos, cameraPosition, previousCameraPosition);
		if(IsInVoxelizationVolume(voxelPos)) {
			float lightMult = getLightMult(lmcoord.y, lightmap);
			ivec2 voxelIndex = GetVoxelStoragePos(voxelPos);
			voxelLightColor = imageLoad(colorimg5, voxelIndex).rgb * lightMult;
		}
		else {
			voxelLightColor = vec3(0.0);
		}
	#endif
}
