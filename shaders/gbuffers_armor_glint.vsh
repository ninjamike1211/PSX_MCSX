#version 120
#include "/lib/psx_util.glsl"

#define gbuffers_solid
#define gbuffers_entities
#define gbuffers_hand
#include "/shaders.settings"

varying vec4 color;
varying vec2 texcoord;
varying vec3 texcoordAffine;

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
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	color = gl_Color;

	vec4 position4 = gl_ModelViewMatrix * gl_Vertex + gl_ModelViewMatrix[3].xyzw;
	vec3 position = position4.xyz;
	
	if(renderStage == MC_RENDER_STAGE_HAND_SOLID) {
		if(gl_VertexID < 4 || gl_VertexID > 8) {
			gl_Position = vec4(-10.0);
			return;
		}

		#ifdef aspectRatio_fix
		if(!(heldItemId == 10001 && heldItemId2 != heldItemId) && abs(position4.x) > 0.2)
			position4.x -= sign(position4.x) * 0.13 * clamp((aspectRatio - 1.7) / (1.0 - 1.7), 0.0, 1.0) * position4.w;
		#endif
		
		position = PixelSnap(position4, vertex_inaccuracy_hand).xyz;
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
	texcoordAffine = vec3(texcoord.xy * wVal, wVal);
}