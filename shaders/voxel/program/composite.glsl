#if STAGE == STAGE_VERTEX

	in vec3 at_midBlock;

	out vec2 texcoord;
	out vec3 midBlock;

	void main() {
		texcoord    = gl_Vertex.xy;
		gl_Position.xy = gl_Vertex.xy * 2.0 - 1.0;
		gl_Position.zw = vec2(1.0);
		midBlock = (at_midBlock / 64.0);
	}

#elif STAGE == STAGE_FRAGMENT

	in vec2 texcoord;
	in vec3 midBlock;

	/* RENDERTARGETS: 0 */
	layout (location = 0) out vec3 outColor;

	uniform sampler2D colortex0;
	uniform sampler2D colortex1;
	uniform sampler2D depthtex0;
	uniform sampler2D depthtex1;
	uniform sampler2D depthtex2;
	uniform usampler2D shadowcolor0;
	uniform usampler2D shadowcolor1;
	uniform sampler2D shadowtex0; // Needed to enable shadow maps
    uniform float frameTime;
    uniform vec2 viewResolution;

	uniform vec3 cameraPosition;

	uniform mat4 gbufferProjectionInverse;
	uniform mat4 gbufferModelViewInverse;

	#include "/voxel/lib/voxelization.glsl"
	#include "/voxel/lib/raytracer.glsl"

	struct Material {
		vec3   albedo;       // Scattering albedo
		float  opacity;
		vec3   normal;       // Normal
	};

	Material getMaterial(vec4 albedo, vec4 specular, vec4 normal, int voxelID) {
		Material material;
		
		material.albedo      = albedo.rgb;
		material.opacity     = albedo.a;

		material.normal      = normal.rgb;

		return material;
	}

	Material getMaterial(vec3 position, vec3 normal, vec4[2] voxel) {
		int id = ExtractVoxelId(voxel);

		// Figure out texture coordinates
		int   tileSize = ExtractVoxelTileSize(voxel);
		ivec2 tileOffs = ExtractVoxelTileIndex(voxel) * tileSize;

		ivec2 tileTexel;
		mat3 tbn;

		if (abs(normal.y) > abs(normal.x) && abs(normal.y) > abs(normal.z)) {
			tileTexel = ivec2(fract(position.x) * tileSize, fract(position.z * sign(normal.y)) * tileSize);
			tbn = mat3(vec3(1.0, 0.0, 0.0), vec3(0.0, 0.0, sign(normal.y)), normal);
		} else {
			tileTexel = ivec2(fract(position.x * sign(normal.z) - position.z * sign(normal.x)) * tileSize, fract(-position.y) * tileSize);
			tbn = mat3(vec3(sign(normal.z), 0.0, -sign(normal.x)), vec3(0.0, -1.0, 0.0), normal);
		}

		ivec2 texelIndex = tileOffs + tileTexel;

		// Read textures
		vec4 baseTex     = texelFetch(depthtex0, texelIndex, 0);
		vec4 specularTex = texelFetch(depthtex1, texelIndex, 0);
		vec4 normalTex   = texelFetch(depthtex2, texelIndex, 0);

		normalTex.xyz = normalTex.xyz * 2.0 - 1.0;
		normalTex.xyz = normalize(tbn * normalTex.xyz);

		baseTex.rgb *= ExtractVoxelTint(voxel);

		return getMaterial(baseTex, specularTex, normalTex, id);
	}

	void rayTrace(out vec3 hitPos, out vec3 hitNormal, out vec4[2] voxel) {
		vec4 p   = vec4(texcoord * 2.0 - 1.0, 0.0, 1.0);
		vec3 dir = (gbufferProjectionInverse * p).xyz / (gbufferProjectionInverse * p).w;
		     dir = normalize(mat3(gbufferModelViewInverse) * dir);

		vec3 startVoxelPosition = SceneSpaceToVoxelSpace(gbufferModelViewInverse[3].xyz);

		ivec3 hitIdx;
		bool hit = RaytraceVoxel(startVoxelPosition, ivec3(floor(startVoxelPosition)), dir, true, 4096, voxel, hitPos, hitIdx, hitNormal);
	}

/***********************************************************************/
	/* Text Rendering */
	const int
		_A    = 0x64bd29, _B    = 0x749d27, _C    = 0xe0842e, _D    = 0x74a527,
		_E    = 0xf09c2f, _F    = 0xf09c21, _G    = 0xe0b526, _H    = 0x94bd29,
		_I    = 0xf2108f, _J    = 0x842526, _K    = 0x9284a9, _L    = 0x10842f,
		_M    = 0x97a529, _N    = 0x95b529, _O    = 0x64a526, _P    = 0x74a4e1,
		_Q    = 0x64acaa, _R    = 0x749ca9, _S    = 0xe09907, _T    = 0xf21084,
		_U    = 0x94a526, _V    = 0x94a544, _W    = 0x94a5e9, _X    = 0x949929,
		_Y    = 0x94b90e, _Z    = 0xf4106f, _0    = 0x65b526, _1    = 0x431084,
		_2    = 0x64904f, _3    = 0x649126, _4    = 0x94bd08, _5    = 0xf09907,
		_6    = 0x609d26, _7    = 0xf41041, _8    = 0x649926, _9    = 0x64b904,
		_APST = 0x631000, _PI   = 0x07a949, _UNDS = 0x00000f, _HYPH = 0x001800,
		_TILD = 0x051400, _PLUS = 0x011c40, _EQUL = 0x0781e0, _SLSH = 0x041041,
		_EXCL = 0x318c03, _QUES = 0x649004, _COMM = 0x000062, _FSTP = 0x000002,
		_QUOT = 0x528000, _BLNK = 0x000000, _COLN = 0x000802, _LPAR = 0x410844,
		_RPAR = 0x221082;

	const ivec2 MAP_SIZE = ivec2(5, 5);

	int GetBit(int bitMap, int index) {
		return (bitMap >> index) & 1;
	}

	float DrawChar(int charBitMap, inout vec2 anchor, vec2 charSize, vec2 uv) {
		uv = (uv - anchor) / charSize;

		anchor.x += charSize.x;

		if (!all(lessThan(abs(uv - vec2(0.5)), vec2(0.5))))
			return 0.0;

		uv *= MAP_SIZE;

		int index = int(uv.x) % MAP_SIZE.x + int(uv.y)*MAP_SIZE.x;

		return GetBit(charBitMap, index);
	}

	const int STRING_LENGTH = 8;
	int[STRING_LENGTH] drawString;

	float DrawString(inout vec2 anchor, vec2 charSize, int stringLength, vec2 uv) {
		uv = (uv - anchor) / charSize;

		anchor.x += charSize.x * stringLength;

		if (!all(lessThan(abs(uv / vec2(stringLength, 1.0) - vec2(0.5)), vec2(0.5))))
			return 0.0;

		int charBitMap = drawString[int(uv.x)];

		uv *= MAP_SIZE;

		int index = int(uv.x) % MAP_SIZE.x + int(uv.y)*MAP_SIZE.x;

		return GetBit(charBitMap, index);
	}

	#define Log10(x) (log2(x) / 3.32192809488)

	float DrawInt(int val, inout vec2 anchor, vec2 charSize, vec2 uv) {
		if (val == 0) return DrawChar(_0, anchor, charSize, uv);

		const int _DIGITS[10] = int[10](_0,_1,_2,_3,_4,_5,_6,_7,_8,_9);

		bool isNegative = val < 0.0;

		if (isNegative) drawString[0] = _HYPH;

		val = abs(val);

		int posPlaces = int(ceil(Log10(abs(val) + 0.001)));
		int strIndex = posPlaces - int(!isNegative);

		while (val > 0) {
			drawString[strIndex--] = _DIGITS[val % 10];
			val /= 10;
		}

		return DrawString(anchor, charSize, posPlaces + int(isNegative), texcoord);
	}

	float DrawFloat(float val, inout vec2 anchor, vec2 charSize, int negPlaces, vec2 uv) {
		int whole = int(val);
		int part  = int(fract(abs(val)) * pow(10, negPlaces));

		int posPlaces = max(int(ceil(Log10(abs(val)))), 1);

		anchor.x -= charSize.x * (posPlaces + int(val < 0) + 0.25);
		float ret = 0.0;
		ret += DrawInt(whole, anchor, charSize, uv);
		ret += DrawChar(_FSTP, anchor, charSize, texcoord);
		anchor.x -= charSize.x * 0.3;
		ret += DrawInt(part, anchor, charSize, uv);

		return ret;
	}

	void DrawDebugText() {
		vec2 charSize = vec2(0.018) * viewResolution.yy / viewResolution;
		vec2 texPos = vec2(charSize.x * 2.75, 1.0 - charSize.y * 1.2);

		if ( texcoord.x > charSize.x * 18.0
		||   texcoord.y < 1 - charSize.y * 4.0)
		{ return; }

		vec3 color = vec3(0.0);

        texPos.y -= charSize.y * 2.0 - 0.0045;

		drawString = int[STRING_LENGTH](_F,_R,_M,_T,_I,_M,_E,_COLN);
		color += DrawString(texPos, charSize, 8, texcoord);
		texPos.x += charSize.x * 3.0;
		color += DrawFloat(frameTime * 1000, texPos, charSize, 5, texcoord);
		outColor = color;
	}    

    #define raytrace

	void main() {
        #ifdef raytrace
		vec4[2] voxel; vec3 hitPos, hitNormal;
		rayTrace(hitPos, hitNormal, voxel);
		outColor = getMaterial(hitPos, hitNormal, voxel).albedo;
        #endif
        DrawDebugText();
        //outColor = vec3(getTileSize(voxel) > 16 ? 1 : 0);

		// outColor.rgb = ExtractVoxelTint(voxel);
	}

#endif
