#version 420 compatibility

#define gbuffers_solid
#define gbuffers_terrain
#include "/shaders.settings"
#include "/lib/psx_util.glsl"

varying vec4 color;


void main() {
	
	vec4 ftrans = ftransform();
	float depth = clamp(ftrans.w, 0.001, 1000.0);
	float sqrtDepth = sqrt(depth);
	
	vec4 position4 = PixelSnap(ftrans, vertex_inaccuracy_terrain / sqrtDepth);

	gl_Position = position4;
	color = gl_Color;
}
