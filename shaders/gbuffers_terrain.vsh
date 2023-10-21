#version 450 compatibility
#extension GL_EXT_gpu_shader4 : enable
#include "/lib/psx_util.glsl"

#define gbuffers_solid
#define gbuffers_terrain
#include "/shaders.settings"

varying vec4 texcoord;
varying vec4 texcoordAffine;
varying vec2 lmcoord;
varying vec4 color;
varying float isText;
varying vec3 lightColor;

attribute vec4 mc_Entity;
attribute vec3 at_midBlock;

uniform sampler2D depthtex1;
uniform usampler2D shadowcolor0;
uniform sampler2D shadowcolor1;

uniform bool inNether;
uniform int blockEntityId;
uniform ivec2 atlasSize;
uniform float frameTimeCounter;
uniform vec3 cameraPosition;

#include "/voxel/lib/voxelization.glsl"

#define diagonal3(m) vec3((m)[0].x, (m)[1].y, m[2].z)
#define projMAD(m, v) (diagonal3(m) * (v) + (m)[3].xyz)
vec4 toClipSpace3(vec3 viewSpacePosition) {
    return vec4(projMAD(gl_ProjectionMatrix, viewSpacePosition),-viewSpacePosition.z);
}

void main() {
	texcoord = gl_MultiTexCoord0;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	// lmcoord = gl_MultiTexCoord1.xy / 240.0;

	isText = float(blockEntityId == 10003 && atlasSize.x == 0);

	if(inNether)
		lmcoord.r = lmcoord.r * 0.5 + 0.5;
	
	color = gl_Color;

	vec4 vertexPos = gl_Vertex;

	if(abs(mc_Entity.x - 10002) < 0.1) {
		vertexPos.y += lava_wave_height * sin(lava_wave_speed * frameTimeCounter + lava_wave_length * (cos(lava_wave_angle) * (vertexPos.x + cameraPosition.x) + sin(lava_wave_angle) * (vertexPos.z + cameraPosition.z)));
	}
	
	// vec4 ftrans = ftransform();
	vec4 ftrans = gl_ModelViewProjectionMatrix * vertexPos;
	float depth = clamp(ftrans.w, 0.001, 1000.0);
	float sqrtDepth = sqrt(depth);


	vec4 position4 = ftrans;

	position4 = PixelSnap(ftrans, vertex_inaccuracy_terrain / sqrtDepth);
	vec3 position = position4.xyz;
	
	float wVal = (mat3(gl_ProjectionMatrix) * position).z;
	wVal = clamp(wVal, -10000.0, 0.0);
	texcoordAffine = vec4(texcoord.xy * wVal, wVal, 0);

	if(isText > 0.5) {
		texcoordAffine = texcoord;
		position4 = ftrans;

		vec3 ndcPos = position4.xyz / position4.w;
		float depth = texture2D(depthtex1, ndcPos.xy * 0.5 + 0.5).r - 0.01;

		position4.z = (depth * 2.0 - 1.0) * position4.w;
	}

	gl_Position = position4;

	vec3 voxelPos = SceneSpaceToVoxelSpace(vertexPos.xyz + at_midBlock / 64.0);
	ivec3 voxelIndex = ivec3(floor(voxelPos));

	ivec2 storagePos = GetVoxelStoragePos(voxelIndex);

	lightColor = texelFetch(shadowcolor1, storagePos, 0).rgb;
}
