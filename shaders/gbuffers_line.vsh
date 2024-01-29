#version 120
#extension GL_EXT_gpu_shader4 : enable

#define gbuffers_solid
#define gbuffers_terrain
#define gbuffers_line
#include "/shaders.settings"
#include "/lib/psx_util.glsl"

varying vec4 color;

attribute vec4 mc_Entity;
uniform vec2 texelSize;
uniform float frameTimeCounter;
uniform float viewWidth;
uniform float viewHeight;
uniform int renderStage;

#define diagonal3(m) vec3((m)[0].x, (m)[1].y, m[2].z)
#define projMAD(m, v) (diagonal3(m) * (v) + (m)[3].xyz)
vec4 toClipSpace3(vec3 viewSpacePosition) {
    return vec4(projMAD(gl_ProjectionMatrix, viewSpacePosition),-viewSpacePosition.z);
}

const float VIEW_SHRINK = 1.0 - (1.0 / 256.0);
const mat4 VIEW_SCALE   = mat4(
	VIEW_SHRINK, 0.0, 0.0, 0.0,
	0.0, VIEW_SHRINK, 0.0, 0.0,
	0.0, 0.0, VIEW_SHRINK, 0.0,
	0.0, 0.0, 0.0, 1.0
);

void main() {
	
	// vec4 ftrans = ftransform();\

	vec2 resolution   = vec2(viewWidth, viewHeight);
	vec4 linePosStart = gl_ProjectionMatrix * (VIEW_SCALE * (gl_ModelViewMatrix * gl_Vertex));
	vec4 linePosEnd   = gl_ProjectionMatrix * (VIEW_SCALE * (gl_ModelViewMatrix * vec4(gl_Vertex.xyz + gl_Normal, 1.0)));

	linePosStart = PixelSnap(linePosStart, vertex_inaccuracy_terrain / sqrt(clamp(linePosStart.w, 0.001, 1000.0)));
	linePosEnd = PixelSnap(linePosEnd, vertex_inaccuracy_terrain / sqrt(clamp(linePosEnd.w, 0.001, 1000.0)));

	vec3 ndc1 = linePosStart.xyz / linePosStart.w;
	vec3 ndc2 = linePosEnd.xyz   / linePosEnd.w;

	vec2 lineScreenDirection = normalize((ndc2.xy - ndc1.xy) * resolution);
	vec2 lineOffset = vec2(-lineScreenDirection.y, lineScreenDirection.x) * LINE_WIDTH / resolution;

	if (lineOffset.x < 0.0) lineOffset = -lineOffset;
	if (gl_VertexID % 2 != 0) lineOffset = -lineOffset;
	vec4 ftrans = vec4((ndc1 + vec3(lineOffset, 0.0)) * linePosStart.w, linePosStart.w);


	float depth = clamp(ftrans.w, 0.001, 1000.0);
	float sqrtDepth = sqrt(depth);
	
	// vec4 position4 = PixelSnap(ftrans, vertex_inaccuracy_terrain / sqrtDepth);

	ftrans.z -= 0.0001 * ftrans.w;

	gl_Position = ftrans;
	// gl_Position = position4;

	color = gl_Color;

	if(renderStage == MC_RENDER_STAGE_OUTLINE) {
		color.xyz = mix(vec3(outline_darkColor), vec3(outline_lightColor), sin(frameTimeCounter * outline_speed) * 0.5 + 0.5);
		color.a = 1.0;
	}
	
	// gl_Position = toClipSpace3(gl_Position);
}
