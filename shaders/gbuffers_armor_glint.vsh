#version 120
#include "/lib/psx_util.glsl"

#define gbuffers_solid
#define gbuffers_entities
#define gbuffers_hand
#include "/shaders.settings"

varying vec4 color;
varying vec4 texcoord;
varying vec4 texcoordAffine;

uniform int heldItemId;
uniform int heldItemId2;
uniform float aspectRatio;
uniform int renderStage;

#define diagonal3(m) vec3((m)[0].x, (m)[1].y, m[2].z)
#define  projMAD(m, v) (diagonal3(m) * (v) + (m)[3].xyz)
vec4 toClipSpace3(vec3 viewSpacePosition) {
  return vec4(projMAD(gl_ProjectionMatrix, viewSpacePosition),-viewSpacePosition.z);
}

void main() {
	texcoord.xy = (gl_MultiTexCoord0).xy;
	texcoord.zw = gl_MultiTexCoord1.xy/255.0;
	color = gl_Color;

	vec4 position4 = gl_ModelViewMatrix * gl_Vertex + gl_ModelViewMatrix[3].xyzw;
	vec3 position = position4.xyz;
	
	if(renderStage == MC_RENDER_STAGE_HAND_SOLID) {
		// if(gl_VertexID < 4 || gl_VertexID > 8) {
		// 	gl_Position = vec4(-10.0);
		// 	return;
		// }
		
		// position = PixelSnap(position4, vertex_inaccuracy_hand).xyz;
	}
	else {
		vec4 ftrans = ftransform();
		float depth = clamp(ftrans.w, 0.001, 1000.0);
		float sqrtDepth = sqrt(depth);

		position = PixelSnap(position4, vertex_inaccuracy_entities / sqrtDepth).xyz;
	}
	
	gl_Position = toClipSpace3(position);

	float wVal = (mat3(gl_ProjectionMatrix) * position).z;
	wVal = clamp(wVal, 0.0, 10000.0);
	texcoordAffine = vec4(texcoord.xy * wVal, wVal, 0);
}