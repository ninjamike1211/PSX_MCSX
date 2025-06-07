#define fog_enabled						//Toggles depth fog
#define fog_distance 20					//Adjusts fog starting distance in blocks [0 1 2 3 4 5 6 7 8 9 10 15 20 30 40 50 60 70 80 100 200 300 400 500 600 700 800 900 1000 1500 2000 2500 3000]
#define fog_slope 3.0					//Adjusts distance from 0 fog to full fog in blocks [0.025 0.05 0.1 0.15 0.2 0.25 0.5 0.75 1.0 1.5 2.0 2.5 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 15.0 20.0 25.0 30.0 40.0 50.0]
#define fog_rain_distance 10			//Adjusts rain fog starting distance in blocks [0 1 2 3 4 5 6 7 8 9 10 15 20 30 40 50 60 70 80 100 200 300 400 500 600 700 800 900 1000 1500 2000 2500 3000]
#define fog_rain_slope 15.0				//Adjusts rain distance from 0 fog to full fog in blocks [0.025 0.05 0.1 0.15 0.2 0.25 0.5 0.75 1.0 1.5 2.0 2.5 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 15.0 20.0 25.0 30.0 40.0 50.0]

#define fog_distance_water 7			//Adjusts underwater fog starting distance in blocks [0 1 2 3 4 5 6 7 8 9 10 15 20 30 40 50 60 70 80 100 200 300 400 500 600 700 800 900 1000 1500 2000 2500 3000]
#define fog_slope_water 3.0				//Adjusts underwater distance from 0 fog to full fog in blocks [0.025 0.05 0.1 0.15 0.2 0.25 0.5 0.75 1.0 1.5 2.0 2.5 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 15.0 20.0 25.0 30.0 40.0 50.0]
#define fog_distance_lava 60			//Adjusts lava fog starting distance in blocks [-10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 15 20 30 40 50 60 70 80 100 200 300 400 500 600 700 800 900 1000 1500 2000 2500 3000]
#define fog_slope_lava 3.0				//Adjusts lava distance from 0 fog to full fog in blocks [0.025 0.05 0.1 0.15 0.2 0.25 0.5 0.75 1.0 1.5 2.0 2.5 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 15.0 20.0 25.0 30.0 40.0 50.0]
#define fog_distance_snow 0 			//Adjusts powdered snow fog starting distance in blocks [-10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 15 20 30 40 50 60 70 80 100 200 300 400 500 600 700 800 900 1000 1500 2000 2500 3000]
#define fog_slope_snow 0.15				//Adjusts powdered snow distance from 0 fog to full fog in blocks [0.025 0.05 0.1 0.15 0.2 0.25 0.5 0.75 1.0 1.5 2.0 2.5 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 15.0 20.0 25.0 30.0 40.0 50.0]

#define fog_distance_nether 0			//Adjusts fog starting distance in blocks [0 1 2 3 4 5 6 7 8 9 10 15 20 30 40 50 60 70 80 100 200 300 400 500 600 700 800 900 1000 1500 2000 2500 3000]
#define fog_slope_nether 3.0			//Adjusts distance from 0 fog to full fog in blocks [0.025 0.05 0.1 0.15 0.2 0.25 0.5 0.75 1.0 1.5 2.0 2.5 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 15.0 20.0 25.0 30.0 40.0 50.0]
#define fog_distance_end 40				//Adjusts fog starting distance in blocks [0 1 2 3 4 5 6 7 8 9 10 15 20 30 40 50 60 70 80 100 200 300 400 500 600 700 800 900 1000 1500 2000 2500 3000]
#define fog_slope_end 3.0				//Adjusts distance from 0 fog to full fog in blocks [0.025 0.05 0.1 0.15 0.2 0.25 0.5 0.75 1.0 1.5 2.0 2.5 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 15.0 20.0 25.0 30.0 40.0 50.0]

#define fog_sunmoon 0.5					//Adjusts how much sun/moon appears in sky [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define fog_Darken_Mode 2				//Mode for darkening fog while in caves. 0 = off. 1 = altitude. 2 = player block brightness. 3 = player mood [0 1 2 3]
//#define fog_Cave_SkipSky				//Skips cave fog darkening on pixels containing only sky
#define fog_depth_type 0				//Method for determining fog depth. 0 = depth buffer. 1 = spherical distance. 2 = cylidrical distance

#ifdef fog_depth_type
#endif

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