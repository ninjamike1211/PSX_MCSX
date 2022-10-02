#version 120
#extension GL_EXT_gpu_shader4 : enable
#include "/lib/psx_util.glsl"

#define gbuffers_solid
#define gbuffers_terrain
#include "/shaders.settings"

varying vec4 color;

attribute vec4 mc_Entity;
uniform vec2 texelSize;
uniform float frameTimeCounter;
uniform int renderStage;

#define diagonal3(m) vec3((m)[0].x, (m)[1].y, m[2].z)
#define projMAD(m, v) (diagonal3(m) * (v) + (m)[3].xyz)
vec4 toClipSpace3(vec3 viewSpacePosition) {
    return vec4(projMAD(gl_ProjectionMatrix, viewSpacePosition),-viewSpacePosition.z);
}

void main() {
	
	vec4 ftrans = ftransform();
	float depth = clamp(ftrans.w, 0.001, 1000.0);
	float sqrtDepth = sqrt(depth);
	
	// vec4 position4 = PixelSnap(ftrans, vertex_inaccuracy_terrain / sqrtDepth);

	// position4.z -= 0.01 * position4.w;

	gl_Position = ftrans;

	color = gl_Color;

	if(renderStage == MC_RENDER_STAGE_OUTLINE) {
		color.xyz = mix(vec3(outline_darkColor), vec3(outline_lightColor), sin(frameTimeCounter * outline_speed) * 0.5 + 0.5);
	}
	
	// gl_Position = toClipSpace3(gl_Position);
}
