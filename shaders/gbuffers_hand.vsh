#version 420 compatibility
#extension GL_EXT_gpu_shader4 : enable

#define gbuffers_solid
#define gbuffers_hand
#include "/shaders.settings"
#include "/lib/psx_util.glsl"
#include "/lib/voxel.glsl"

varying vec4 texcoord;
varying vec4 lmcoord;
varying vec4 color;
varying vec4 lightLevels;

attribute vec4 mc_Entity;
uniform vec2 texelSize;
uniform float aspectRatio;
uniform int heldItemId;
uniform int heldItemId2;
uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;
uniform sampler2D lightmap;

#ifdef Floodfill_Enable
	varying vec3 voxelLightColor;
	readonly layout (rgba8) uniform image2D colorimg5;
#endif

#define diagonal3(m) vec3((m)[0].x, (m)[1].y, m[2].z)
#define projMAD(m, v) (diagonal3(m) * (v) + (m)[3].xyz)
vec4 toClipSpace3(vec3 viewSpacePosition) {
    return vec4(projMAD(gl_ProjectionMatrix, viewSpacePosition),-viewSpacePosition.z);
}


void main() {
	texcoord.xy = (gl_MultiTexCoord0).xy;
	texcoord.zw = gl_MultiTexCoord1.xy/255.0;
	lmcoord = gl_TextureMatrix[1] * gl_MultiTexCoord1;
	
	vec4 position4 = mat4(gl_ModelViewMatrix) * vec4(gl_Vertex) + gl_ModelViewMatrix[3].xyzw;

	#ifdef aspectRatio_fix
		if(!(heldItemId == 10001 && heldItemId2 != heldItemId) && abs(position4.x) > 0.2)
			position4.x -= sign(position4.x) * 0.13 * clamp((aspectRatio - 1.7) / (1.0 - 1.7), 0.0, 1.0) * position4.w;
	#endif

	vec3 position = position4.xyz;

	if(heldItemId != 10001 && heldItemId2 != 10001)
		position = PixelSnap(position4, vertex_inaccuracy_hand).xyz;

	color = gl_Color;
	
	gl_Position = toClipSpace3(position);

	// Voxelization
	#ifdef Floodfill_Enable
		ivec3 voxelPos = getPreviousVoxelIndex(vec3(0.0), cameraPosition, previousCameraPosition);
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
