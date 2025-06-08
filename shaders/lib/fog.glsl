
const vec3 NoonHorizonColor = vec3(0.4, 0.5, 1.0);
const vec3 NoonSkyColor = vec3(0, 0.27, 0.95);
const vec3 SunriseHorizonColor = vec3(0.7, 0.6, 0.6);
const vec3 SunriseSkyColor = vec3(0.4, 0.35, 0.75);
const vec3 NightHorizonColor = vec3(0.15);
const vec3 NightSkyColor = vec3(0.0);

vec3 getOverworldSkyColor(in vec3 viewDir, float sunAngle) {
	float upDot = max(dot(viewDir, gbufferModelView[1].xyz), 0.0);
	float mixFactor = smoothstep(0.0, 0.7, upDot);

	vec3 horizonSkyColor;
	vec3 upperSkyColor;

    if(rainStrength < 1.0) {
        if(sunAngle < 0.1) {
            horizonSkyColor = mix(SunriseHorizonColor, NoonHorizonColor, sunAngle / 0.1);
            upperSkyColor   = mix(SunriseSkyColor, NoonSkyColor, sunAngle / 0.1);
        }
        else if(sunAngle >= 0.1 && sunAngle < 0.465) {
            horizonSkyColor = NoonHorizonColor;
            upperSkyColor   = NoonSkyColor;
        }
        else if(sunAngle >= 0.465 && sunAngle < 0.565) {
            horizonSkyColor = mix(NoonHorizonColor, SunriseHorizonColor, (sunAngle - 0.465) / 0.1);
            upperSkyColor   = mix(NoonSkyColor, SunriseSkyColor, (sunAngle - 0.465) / 0.1);
        }
        else if(sunAngle >= 0.565 && sunAngle < 0.605) {
            horizonSkyColor = mix(SunriseHorizonColor, NightHorizonColor, (sunAngle - 0.565) / 0.04);
            upperSkyColor   = mix(SunriseSkyColor, NightSkyColor, (sunAngle - 0.565) / 0.04);
        }
        else if(sunAngle >= 0.605 && sunAngle < 0.97) {
            horizonSkyColor = NightHorizonColor;
            upperSkyColor   = NightSkyColor;
        }
        else {
            horizonSkyColor = mix(NightHorizonColor, SunriseHorizonColor, (sunAngle - 0.97) / 0.03);
            upperSkyColor   = mix(NightSkyColor, SunriseSkyColor, (sunAngle - 0.97) / 0.03);
        }

        horizonSkyColor = mix(horizonSkyColor, fogColor, rainStrength);
        upperSkyColor   = mix(upperSkyColor, skyColor, rainStrength);
    }
    else {
        horizonSkyColor = fogColor;
        upperSkyColor   = skyColor;
    }

	return mix(horizonSkyColor, upperSkyColor, mixFactor);
}

#ifndef gbuffers_sky

float getFogDepth(in vec3 viewPos, in float depth1, float near, float far) {
    #if fog_depth_type == 0
		float depth = linearizeDepthFast(depth1, near, far);
	#elif fog_depth_type == 1
		float depth = length(viewPos);
	#elif fog_depth_type == 2
		float depth = length((gbufferModelViewInverse * vec4(viewPos, 1.0)).xz);
	#endif
        
    if(isEyeInWater == 0) {
        if(inNether) {
            return (depth - fog_distance_nether) / fog_slope_nether;
        }
        else if(inEnd) {
            return (depth - fog_distance_end) / fog_slope_end;
        }
        else {
            if(rainStrength == 0.0) {
                return (depth - fog_distance) / fog_slope;
            }
            else if(rainStrength == 1.0) {
                return (depth - fog_rain_distance) / fog_rain_slope;
            }
            else {
                return (depth - mix(fog_distance, fog_rain_distance, rainStrength)) / mix(fog_slope, fog_rain_slope, rainStrength);
            }
        }
    }
    else if(isEyeInWater == 1) {
        return (depth - fog_distance_water) / fog_slope_water;
    }
    else if(isEyeInWater == 2) {
        return (depth - fog_distance_lava) / fog_slope_lava;
    }
    else if(isEyeInWater == 3) {
        return (depth - fog_distance_snow) / fog_slope_snow;
    }
}

float fogCaveFactor(float eyeAltitude, float eyeBrightness, sampler2D moodTex) {
    #if fog_Darken_Mode == 1
        return smoothstep(54.0, 58.0, eyeAltitude);
    #elif fog_Darken_Mode == 2
        return eyeBrightness / 240.0;
    #elif fog_Darken_Mode == 3
        return texelFetch(moodTex, ivec2(0), 0).a;
    #else
        return 1.0;
    #endif
}

void applyFogColor(inout vec3 sceneColor, in float fogDepth, in float caveFactor, in vec3 viewDir, float sunAngle) {
    vec3 fogTint;

    if(isEyeInWater == 0) {
        if(inNether) {
            fogTint = normalize(fogColor) * 0.3 + 0.1;
        }
        else if(inEnd) {
            fogTint = vec3(0.5);
        }
        else {
			fogTint = getOverworldSkyColor(viewDir, sunAngle); 
            fogTint *= mix(0.12, 1.0, caveFactor);
        }
    }
    else if(isEyeInWater == 1) {
        fogTint = fogColor;
    }
    else if(isEyeInWater == 2) {
        fogTint = vec3(2.0, 0.4, 0.1);
    }
    else if(isEyeInWater == 3) {
        fogTint = vec3(1.0);
    }

    sceneColor = mix(sceneColor, fogTint, fogDepth);
}

#endif