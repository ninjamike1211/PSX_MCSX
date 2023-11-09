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
attribute vec4 at_tangent;

uniform ivec2 atlasSize;
uniform vec2 texelSize;
uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;
uniform int entityId;
uniform mat4 gbufferModelViewInverse;
uniform sampler2D gtexture;
uniform sampler2D lightmap;

writeonly layout (rgba8) uniform image2D colorimg4;
readonly layout (rgba8) uniform image2D colorimg5;

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
	float depth = clamp(ftrans.w, 0.001, 1000.0);
	float sqrtDepth = sqrt(depth);
	
	vec4 position4 = mat4(gl_ModelViewMatrix) * vec4(gl_Vertex) + gl_ModelViewMatrix[3].xyzw;
	vec3 position = PixelSnap(position4, vertex_inaccuracy_entities / sqrtDepth).xyz;
	
	float wVal = (mat3(gl_ProjectionMatrix) * position).z;
	wVal = clamp(wVal, 0.0, 10000.0);
	texcoordAffine = vec4(texcoord.xy * wVal, wVal, 0);
	
	color = gl_Color;
	gl_Position = toClipSpace3(position);



	// Voxelization
	vec2 centerDir = sign(mc_midTexCoord - texcoord.xy);
	vec3 viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
	vec3 normal = normalize(gl_NormalMatrix * gl_Normal);
	vec3 tangent = normalize(gl_NormalMatrix * at_tangent.xyz);
	vec3 bitangent = cross(normal, tangent) * sign(-at_tangent.w);

	vec3 playerPos = (gbufferModelViewInverse * vec4(viewPos + 0.125*centerDir.x*tangent + 0.125*centerDir.y*bitangent, 1.0)).xyz;
	ivec3 voxelPos = getPreviousVoxelIndex(playerPos, cameraPosition, previousCameraPosition);
	if(IsInVoxelizationVolume(voxelPos)) {
		float lightMult = getLightMult(lmcoord.y, lightmap);
		ivec2 voxelIndex = GetVoxelStoragePos(voxelPos);
		voxelLightColor = imageLoad(colorimg5, voxelIndex).rgb * lightMult;
	}
	else {
		voxelLightColor = vec3(0.0);
	}

	if(entityId == 10003) {
		voxelLightColor += item_glow;
	}

	playerPos = (gbufferModelViewInverse * vec4(viewPos + 0.5*centerDir.x*tangent + 0.5*centerDir.y*bitangent, 1.0)).xyz;
	voxelPos = ivec3(floor(SceneSpaceToVoxelSpace(playerPos, cameraPosition)));
	if(gl_VertexID % 4 == 0) {

		if(IsInVoxelizationVolume(voxelPos)) {
			ivec2 voxelIndex = GetVoxelStoragePos(voxelPos);

			if(entityId >= 11000) {
				imageStore(colorimg4, voxelIndex, vec4(custLightColors[entityId - 11000], 1.0));
			}
			else {
				vec2 halfTexSize = abs(texcoord.xy - mc_midTexCoord);
				vec4 cornerColor = texture2D(gtexture, mc_midTexCoord - halfTexSize + 0.5 / atlasSize);

				vec4 lightVal = vec4(0.0, 0.0, 0.0, 0.0);
				if(cornerColor == vec4(0.0, 1.0, 0.0, 25.0/255.0) && entityId != 10002 && entityId != 10003) {
					imageStore(colorimg4, voxelIndex, vec4(custLightColors[0], 1.0));
				}
				else if(cornerColor == vec4(1.0, 1.0, 0.0, 25.0/255.0) && entityId != 10002 && entityId != 10003) {
					imageStore(colorimg4, voxelIndex, vec4(custLightColors[1], 1.0));
					lmcoord.y = 31.0/32.0;
				}
				else if(cornerColor == vec4(1.0, 1.0, 1.0, 25.0/255.0)) {
					imageStore(colorimg4, voxelIndex, vec4(custLightColors[2], 1.0));
				}
				else if(cornerColor == vec4(1.0, 0.0, 0.0, 25.0/255.0) && entityId != 10002 && entityId != 10003) {
					imageStore(colorimg4, voxelIndex, vec4(custLightColors[3], 1.0));
				}
				else if(cornerColor == vec4(1.0, 0.0, 1.0, 25.0/255.0) && entityId != 10002 && entityId != 10003) {
					imageStore(colorimg4, voxelIndex, vec4(custLightColors[4] * lmcoord.x * 2.5, 1.0));
				}
				else if(cornerColor == vec4(0.0, 0.0, 1.0, 25.0/255.0) && entityId != 10002 && entityId != 10003) {
					imageStore(colorimg4, voxelIndex, vec4(custLightColors[5], 1.0));
				}
				else if(cornerColor == vec4(0.0, 1.0, 1.0, 25.0/255.0) && entityId != 10002 && entityId != 10003) {
					imageStore(colorimg4, voxelIndex, vec4(custLightColors[0] * 0.25, 1.0));
				}
			}
		}
	}
}
