#version 330 compatibility
// Skybox and rain shader code from Sildurs Vibrant Shaders

/*
const int  colortex1Format  = RG8;
const vec4 colortex1ClearColor = vec4(0.0, 0.0, 0.0, 0.0);
const bool colortex5Clear  = false;
const int  colortex12Format = RGBA8_SNORM;
const bool colortex12Clear  = false;
*/

#define composite
#include "/shaders.settings"

varying vec2 texcoord;

varying vec3 lightColor;
varying vec3 sunVec;
varying vec3 upVec;
varying vec3 sky1;
varying vec3 sky2;

varying float tr;

varying vec3 sunlight;
varying vec3 nsunlight;

varying vec3 rawAvg;

varying float SdotU;
varying float sunVisibility;
varying float moonVisibility;

varying vec3 avgAmbient2;

uniform vec3 skyColor;
uniform vec3 fogColor;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
uniform sampler2D colortex8;
uniform sampler2D colortex7;
uniform sampler2D colortex12;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D depthtex2;
uniform vec2 texelSize;
uniform float viewWidth;
uniform float viewHeight;
uniform float near;
uniform float far;
uniform float rainStrength;
uniform int worldTime;
uniform int isEyeInWater;
uniform float playerMood;
uniform float eyeAltitude;
uniform ivec2 eyeBrightnessSmooth;

uniform bool inEnd;
uniform bool inNether;

float linearizeDepthFast(float depth) {
	return (near * far) / (depth * (near - far) + far);
}

float luminance(vec3 v) {
    return dot(v, vec3(0.2126f, 0.7152f, 0.0722f));
}


vec3 getOverworldSkyColor(vec3 viewPos, vec3 sunmoon) {
	vec3 viewDir = normalize(viewPos);
	float upDot = max(dot(viewDir, upVec), 0.0);
	float mixFactor = smoothstep(0.0, 0.7, upDot);

	float worldTimeAdjusted = ((worldTime + 785) % 24000) / 24000.0;
	vec3 sunFix = luminance(sunmoon) > 0.3 ? vec3(0.3, 0.2, -0.4) : vec3(0.0);

	vec3 horizonSkyColor;
	vec3 upperSkyColor;

	if(worldTimeAdjusted < 0.1) {
		horizonSkyColor = mix(vec3(0.7, 0.6, 0.6), vec3(0.4, 0.5, 1.0) + sunFix, worldTimeAdjusted / 0.1);
		upperSkyColor = mix(vec3(0.4, 0.35, 0.75), vec3(0, 0.27, 0.95) + sunFix, worldTimeAdjusted / 0.1);
	}
	else if(worldTimeAdjusted >= 0.1 && worldTimeAdjusted < 0.465) {
		horizonSkyColor = vec3(0.4, 0.5, 1.0) + sunFix;
		upperSkyColor = vec3(0, 0.27, 0.95) + sunFix;
	}
	else if(worldTimeAdjusted >= 0.465 && worldTimeAdjusted < 0.565) {
		horizonSkyColor = mix(vec3(0.4, 0.5, 1.0) + sunFix, vec3(0.7, 0.6, 0.6), (worldTimeAdjusted - 0.465) / 0.1);
		upperSkyColor = mix(vec3(0, 0.27, 0.95) + sunFix, vec3(0.4, 0.35, 0.75), (worldTimeAdjusted - 0.465) / 0.1);
	}
	else if(worldTimeAdjusted >= 0.565 && worldTimeAdjusted < 0.605) {
		horizonSkyColor = mix(vec3(0.7, 0.6, 0.6), vec3(0.2, 0.2, 0.3), (worldTimeAdjusted - 0.565) / 0.04);
		upperSkyColor = mix(vec3(0.4, 0.35, 0.75), vec3(0.13, 0.13, 0.2), (worldTimeAdjusted - 0.565) / 0.04);
	}
	else if(worldTimeAdjusted >= 0.605 && worldTimeAdjusted < 0.97) {
		horizonSkyColor = vec3(0.2, 0.2, 0.3);
		upperSkyColor = vec3(0.13, 0.13, 0.2);
	}
	else {
		horizonSkyColor = mix(vec3(0.2, 0.2, 0.3), vec3(0.7, 0.6, 0.6), (worldTimeAdjusted - 0.97) / 0.03);
		upperSkyColor = mix(vec3(0.13, 0.13, 0.2), vec3(0.4, 0.35, 0.75), (worldTimeAdjusted - 0.97) / 0.03);
	}

	horizonSkyColor = mix(horizonSkyColor, fogColor, rainStrength);
	upperSkyColor = mix(upperSkyColor, skyColor, rainStrength);

	return mix(horizonSkyColor, upperSkyColor, mixFactor);
}

/* DRAWBUFFERS:0 */
void main() {
	float isParticle = texture2D(colortex1, texcoord).g;
	float depth = texture2D(depthtex0, texcoord).r;
	float depth1 = texture2D(depthtex1, texcoord).r;

	if(isParticle > 0.5) {
		depth1 = depth;
	}
	
	vec4 fragpos = gbufferProjectionInverse * (vec4(texcoord, depth1, 1.0) * 2.0 - 1.0);
	fragpos /= fragpos.w;
	vec3 normalfragpos = normalize(fragpos.xyz);

	vec4 fragpos_water = gbufferProjectionInverse * (vec4(texcoord, depth, 1.0) * 2.0 - 1.0);
	fragpos_water /= fragpos_water.w;
	vec3 normalfragpos_water = normalize(fragpos_water.xyz);

	#if fog_depth_type == 0
		float linearDepth = linearizeDepthFast(depth1);
		float linearDepth_water = linearizeDepthFast(depth);
	#elif fog_depth_type == 1
		float linearDepth = length(fragpos.xyz);
		float linearDepth_water = length(fragpos_water.xyz);
	#elif fog_depth_type == 2
		float linearDepth = length((gbufferModelViewInverse * fragpos).xz);
		float linearDepth_water = length((gbufferModelViewInverse * fragpos_water).xz);
	#endif
	
	bool sky = depth >= 1.0;
	bool skyNoClouds = depth1 >= 1.0;
	
	#ifdef fog_enabled
		float fogDepth = -1.0;
		float fogDepth_water = -1.0;
		
		if(isEyeInWater == 0) {
			if(inNether) {
				fogDepth = (linearDepth - fog_distance_nether) / fog_slope_nether;
				fogDepth_water = (linearDepth_water - fog_distance_nether) / fog_slope_nether;
			}
			else if(inEnd) {
				fogDepth = (linearDepth - fog_distance_end) / fog_slope_end;
				fogDepth_water = (linearDepth_water - fog_distance_end) / fog_slope_end;
			}
			else {
				if(rainStrength == 0.0) {
					fogDepth = (linearDepth - fog_distance) / fog_slope;
					fogDepth_water = (linearDepth_water - fog_distance) / fog_slope;
				}
				else if(rainStrength == 1.0) {
					fogDepth = (linearDepth - fog_rain_distance) / fog_rain_slope;
					fogDepth_water = (linearDepth_water - fog_rain_distance) / fog_rain_slope;
				}
				else {
					fogDepth = (linearDepth - mix(fog_distance, fog_rain_distance, rainStrength)) / mix(fog_slope, fog_rain_slope, rainStrength);
					fogDepth_water = (linearDepth_water - mix(fog_distance, fog_rain_distance, rainStrength)) / mix(fog_slope, fog_rain_slope, rainStrength);
				}
			}
		}
		else if(isEyeInWater == 1) {
			fogDepth = (linearDepth - fog_distance_water) / fog_slope_water;
			fogDepth_water = (linearDepth_water - fog_distance_water) / fog_slope_water;
		}
		else if(isEyeInWater == 2) {
			fogDepth = (linearDepth - fog_distance_lava) / fog_slope_lava;
			fogDepth_water = (linearDepth_water - fog_distance_lava) / fog_slope_lava;
		}
		else if(isEyeInWater == 3) {
			fogDepth = (linearDepth - fog_distance_snow) / fog_slope_snow;
			fogDepth_water = (linearDepth_water - fog_distance_snow) / fog_slope_snow;
		}

		fogDepth = (sky) ? 1.0 : clamp(log2(fogDepth + 1.0), 0.0, 1.0);
		fogDepth_water = (sky) ? 1.0 : clamp(log2(fogDepth_water + 1.0), 0.0, 1.0);

		if(fogDepth_water >= 0.99)
			sky = true;
	#else
		float fogDepth = (sky) ? 1.0 : 0.0;
	#endif
	vec3 col = texture2D(colortex0, texcoord).rgb;
	vec4 col_water = texture2D(colortex2, texcoord);
	
	// vec3 skyCol = vec3(-1.0);
	// if (texcoord.x < 1.0 && texcoord.y < 1.0 && texcoord.x > 0.0 && texcoord.y > 0.0 && fogDepth > 0.0) {
	// 	skyCol = getSkyColor(fragpos.xyz);
	// }
	
	vec4 sunmoon = texture2D(colortex3, texcoord) * fog_sunmoon;
	vec4 clouds = texture2D(colortex8, texcoord);

	vec3 skyCol = getOverworldSkyColor(fragpos.xyz, sunmoon.rgb); 
	
	// sunmoon *= (1.0-rainStrength) * smoothstep(-0.2, -0.1, dot(normalfragpos, gbufferModelView[1].xyz));
	
	vec3 fogColorFinal = vec3(-1.0);

	if(inNether) {
		if(isEyeInWater == 0)
			fogColorFinal = normalize(fogColor) * 0.3 + 0.1;
		else if(isEyeInWater == 1)
			fogColorFinal = (fogColor + length(skyCol));
		else if(isEyeInWater == 2)
			fogColorFinal = vec3(2.0, 0.4, 0.1);
		else if(isEyeInWater == 3)
			fogColorFinal = vec3(1.0);
	}
	else if(inEnd) {
		if(isEyeInWater == 0)
			fogColorFinal = texture2D(colortex3, texcoord).xyz;
		else if(isEyeInWater == 1)
			fogColorFinal = (fogColor + length(skyCol));
		else if(isEyeInWater == 2)
			fogColorFinal = vec3(2.0, 0.4, 0.1);
		else if(isEyeInWater == 3)
			fogColorFinal = vec3(1.0);
	}
	else {
		if(isEyeInWater == 0) {

			// fogColorFinal = (mix(adjustSkyColor(skyColor), skyColor, rainStrength) + skyCol);
			fogColorFinal = skyCol;

			#ifdef fog_Cave_SkipSky
				if(!sky) {
			#endif
				#if fog_Darken_Mode == 1
					float caveFactor = smoothstep(54.0, 58.0, eyeAltitude);
				#elif fog_Darken_Mode == 2
					float caveFactor = eyeBrightnessSmooth.y / 240.0;
				#elif fog_Darken_Mode == 3
					float caveFactor = texelFetch(colortex12, ivec2(0), 0).a;
				#else
					float caveFactor = 1.0;
				#endif

				fogColorFinal *= mix(0.12, 1.0, caveFactor);
				sunmoon *= caveFactor;
			#ifdef fog_Cave_SkipSky
				}
			#endif
		}
		else if(isEyeInWater == 1)
			fogColorFinal = (fogColor * 0.7 * length(skyCol));
		else if(isEyeInWater == 2)
			fogColorFinal = vec3(2.0, 0.4, 0.1);
		else if(isEyeInWater == 3)
			fogColorFinal = vec3(1.0);
	}

	if(clouds.r > 0.0001) {
		clouds.rgb = mix(col*0.8, clouds.rgb, 0.75) + 0.1;
		float cloudsDepth = depth * 1000 - 999.2;
		cloudsDepth = clamp(cloudsDepth, 0.0, 1.0);
		col = mix(clouds.rgb, fogColorFinal, cloudsDepth);
		col += sunmoon.rgb/2 * vec3(skyNoClouds?1.0:0.0);
	} else {
		col_water.rgb /= col_water.a;
		col_water.rgb = mix(col_water.rgb, fogColorFinal, fogDepth_water);
		col = mix(col, fogColorFinal, fogDepth);
		if(col_water.a > 0.5/255.0)
			col = mix(col, col_water.rgb, col_water.a);
			
		if(!inEnd) {
			col += sunmoon.rgb * vec3(sky?1.0:0.0);
			// col = sky ? sunmoon.rgb : col;
		}
	}

	
	vec4 rain = texture2D(colortex7, texcoord);
	if (rain.r > 0.0001 && rainStrength > 0.01 && !(depth1 < texture2D(depthtex2, texcoord).x)){
		col.rgb = mix(col.rgb, rain.rgb, rain.a);
	}
	
	if(isEyeInWater > 0) {
		col *= vec3(0.5, 0.6902, 1.0);
	}

	gl_FragData[0] = vec4(col, 1.0);

	// gl_FragData[0] = texture2D(colortex1, texcoord);
	// gl_FragData[0] = sunmoon;
}
