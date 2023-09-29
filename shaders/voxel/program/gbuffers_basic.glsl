
#if     STAGE == STAGE_VERTEX

out vec2 texcoord;
out vec3 normal;

void main() {
	gl_Position = gl_ProjectionMatrix * (gl_ModelViewMatrix * gl_Vertex);
	texcoord = gl_MultiTexCoord0.st;
	normal = gl_NormalMatrix * gl_Normal;
}

#elif STAGE == STAGE_FRAGMENT

in vec2 texcoord;
in vec3 normal;
in vec3 vid;

uniform sampler2D texture;
uniform mat4 gbufferModelViewInverse;
uniform float viewWidth;
uniform float viewHeight;

/* RENDERTARGETS: 0 */

layout (location = 0) out vec4 normals;
void main() {
    if(texture2D(texture, texcoord).a < 0.102) discard;
	normals = vec4(mat3(gbufferModelViewInverse) * normal, 1.0);
}

#endif
