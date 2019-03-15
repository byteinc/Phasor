#version 330
#ifdef GL_ARB_shading_language_420pack
#extension GL_ARB_shading_language_420pack : require
#endif

uniform sampler2D blendTex;
uniform sampler2D colorTex;
uniform sampler2D sveloc;
uniform vec2 screenSizeInv;

in vec2 texCoord;
out vec4 fragColor;
in vec4 offset;

vec4 textureLodA(sampler2D tex, vec2 coords, float lod)
{
    return textureLod(tex, coords, lod);
}

vec4 SMAANeighborhoodBlendingPS(vec2 texcoord, vec4 offset_1)
{
    vec4 a;
    a.x = textureLod(blendTex, offset_1.xy, 0.0).w;
    a.y = textureLod(blendTex, offset_1.zw, 0.0).y;
    vec2 _54 = textureLod(blendTex, texcoord, 0.0).xz;
    a = vec4(a.x, a.y, _54.y, _54.x);
    if (dot(a, vec4(1.0)) < 9.9999997473787516355514526367188e-06)
    {
        vec4 color = textureLod(colorTex, texcoord, 0.0);
        vec2 velocity = textureLod(sveloc, texCoord, 0.0).xy;
        color.w = sqrt(5.0 * length(velocity));
        return color;
    }
    else
    {
        bool h = max(a.x, a.z) > max(a.y, a.w);
        vec4 blendingOffset = vec4(0.0, a.y, 0.0, a.w);
        vec2 blendingWeight = a.yw;
        if (h)
        {
            blendingOffset.x = a.x;
            blendingOffset.y = 0.0;
            blendingOffset.z = a.z;
            blendingOffset.w = 0.0;
            blendingWeight.x = a.x;
            blendingWeight.y = a.z;
        }
        blendingWeight /= vec2(dot(blendingWeight, vec2(1.0)));
        vec2 tc = texcoord;
        vec4 blendingCoord = (blendingOffset * vec4(screenSizeInv, -screenSizeInv)) + tc.xyxy;
        vec2 param = blendingCoord.xy;
        float param_1 = 0.0;
        vec4 color_1 = textureLodA(colorTex, param, param_1) * blendingWeight.x;
        vec2 param_2 = blendingCoord.zw;
        float param_3 = 0.0;
        color_1 += (textureLodA(colorTex, param_2, param_3) * blendingWeight.y);
        vec2 param_4 = blendingCoord.xy;
        float param_5 = 0.0;
        vec2 velocity_1 = textureLodA(sveloc, param_4, param_5).xy * blendingWeight.x;
        vec2 param_6 = blendingCoord.zw;
        float param_7 = 0.0;
        velocity_1 += (textureLodA(sveloc, param_6, param_7).xy * blendingWeight.y);
        color_1.w = sqrt(5.0 * length(velocity_1));
        return color_1;
    }
    return vec4(0.0);
}

void main()
{
    vec2 param = texCoord;
    vec4 param_1 = offset;
    fragColor = SMAANeighborhoodBlendingPS(param, param_1);
}

