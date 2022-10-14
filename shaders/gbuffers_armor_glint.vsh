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
	
	// vec4 position4 = mat4(gl_ModelViewMatrix) * vec4(gl_Vertex) + gl_ModelViewMatrix[3].xyzw;
	// vec3 position = PixelSnap(position4, vertex_inaccuracy_entities).xyz;
	
	// float wVal = (mat3(gl_ProjectionMatrix) * position).z;
	// wVal = clamp(wVal, -10000.0, 0.0);
	// texcoordAffine = vec4(texcoord.xy * wVal, wVal, 0);
	
	// gl_Position = toClipSpace3(position);

	// gl_Position = ftransform();

	if(renderStage == MC_RENDER_STAGE_HAND_SOLID) {
		vec4 position4 = mat4(gl_ModelViewMatrix) * vec4(gl_Vertex) + gl_ModelViewMatrix[3].xyzw;

		#ifdef aspectRatio_fix
			if(!(heldItemId == 10001 && heldItemId2 != heldItemId) && abs(position4.x) > 0.2)
				position4.x -= sign(position4.x) * 0.13 * clamp((aspectRatio - 1.7) / (1.0 - 1.7), 0.0, 1.0) * position4.w;
		#endif

		vec3 position = position4.xyz;

		if(heldItemId != 10001 && heldItemId2 != 10001)
			position = PixelSnap(position4, vertex_inaccuracy_hand).xyz;
		
		gl_Position = toClipSpace3(position);
	}
	else
		gl_Position = ftransform();
}