// #version 430 compatibility

#define viewBuffer 0 //[0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 -1 -2 -3 -4 -5 -6 -7 100 101 102 103 104 105 106]
#define viewBufferSweep 0.0 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]


// ------------------------ File Contents -----------------------
    // Final shader, allows displaying of various buffers


uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
uniform sampler2D colortex4;
uniform sampler2D colortex5;
uniform sampler2D colortex6;
uniform sampler2D colortex7;
uniform sampler2D colortex8;
uniform sampler2D colortex9;
uniform sampler2D colortex10;
uniform sampler2D colortex11;
uniform sampler2D colortex12;
uniform sampler2D colortex13;
uniform sampler2D colortex14;
uniform sampler2D colortex15;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D depthtex2;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;
uniform sampler2D shadowcolor1;

vec4 debugBufferView(vec2 texcoord) {
    #if viewBuffer != 0
    if(texcoord.x > viewBufferSweep) {
    #endif
        #if viewBuffer == 0
            return texture2D(colortex0, texcoord);
        #elif viewBuffer == 1
            return texture2D(colortex1, texcoord);
        #elif viewBuffer == 2
            return texture2D(colortex2, texcoord);
        #elif viewBuffer == 3
            return texture2D(colortex3, texcoord);
        #elif viewBuffer == 4
            return texture2D(colortex4, texcoord);
        #elif viewBuffer == 5
            return texture2D(colortex5, texcoord);
        #elif viewBuffer == 6
            return texture2D(colortex6, texcoord);
        #elif viewBuffer == 7
            return texture2D(colortex7, texcoord);
        #elif viewBuffer == 8
            return texture2D(colortex8, texcoord);
        #elif viewBuffer == 9
            return texture2D(colortex9, texcoord);
        #elif viewBuffer == 10
            return texture2D(colortex10, texcoord);
        #elif viewBuffer == 11
            return texture2D(colortex11, texcoord);
        #elif viewBuffer == 12
            return texture2D(colortex12, texcoord);
        #elif viewBuffer == 13
            return texture2D(colortex13, texcoord);
        #elif viewBuffer == 14
            return texture2D(colortex14, texcoord);
        #elif viewBuffer == 15
            return texture2D(colortex15, texcoord);
        #elif viewBuffer == -1
            return texture2D(depthtex0, texcoord);
        #elif viewBuffer == -2
            return texture2D(depthtex1, texcoord);
        #elif viewBuffer == -3
            return texture2D(depthtex1, texcoord);
        #elif viewBuffer == -4
            return texture2D(shadowtex0, texcoord);
        #elif viewBuffer == -5
            return texture2D(shadowtex1, texcoord);
        #elif viewBuffer == -6
            return texture2D(shadowcolor0, texcoord);
        #elif viewBuffer == -7
            return texture2D(shadowcolor1, texcoord);
        #endif
    #if viewBuffer != 0
    }
    else {
        return texture2D(colortex0, texcoord);
    }
    #endif

}