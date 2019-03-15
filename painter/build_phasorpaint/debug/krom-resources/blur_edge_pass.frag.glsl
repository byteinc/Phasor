#version 330
#ifdef GL_ARB_shading_language_420pack
#extension GL_ARB_shading_language_420pack : require
#endif

uniform sampler2D gbuffer0;
uniform sampler2D tex;
uniform vec2 dirInv;

in vec2 texCoord;
out float fragColor;

vec2 octahedronWrap(vec2 v)
{
    return (vec2(1.0) - abs(v.yx)) * vec2((v.x >= 0.0) ? 1.0 : (-1.0), (v.y >= 0.0) ? 1.0 : (-1.0));
}

vec3 getNor(vec2 enc)
{
    vec3 n;
    n.z = (1.0 - abs(enc.x)) - abs(enc.y);
    vec2 _53;
    if (n.z >= 0.0)
    {
        _53 = enc;
    }
    else
    {
        _53 = octahedronWrap(enc);
    }
    n = vec3(_53.x, _53.y, n.z);
    n = normalize(n);
    return n;
}

void main()
{
    vec3 nor = getNor(textureLod(gbuffer0, texCoord, 0.0).xy);
    fragColor = textureLod(tex, texCoord, 0.0).x * 0.132571995258331298828125;
    float weight = 0.132571995258331298828125;
    for (int i = 1; i < 8; i++)
    {
        float posadd = float(i);
        vec3 nor2 = getNor(textureLod(gbuffer0, texCoord + (dirInv * float(i)), 0.0).xy);
        float influenceFactor = step(0.949999988079071044921875, dot(nor2, nor));
        float col = textureLod(tex, texCoord + (dirInv * posadd), 0.0).x;
        float indexable[10] = float[](0.132571995258331298828125, 0.12547199428081512451171875, 0.10637299716472625732421875, 0.0807799994945526123046875, 0.0549499988555908203125, 0.03348200023174285888671875, 0.018275000154972076416015625, 0.008933999575674533843994140625, 0.00391199998557567596435546875, 0.00153500004671514034271240234375);
        float w = indexable[i] * influenceFactor;
        fragColor += (col * w);
        weight += w;
        nor2 = getNor(textureLod(gbuffer0, texCoord - (dirInv * float(i)), 0.0).xy);
        influenceFactor = step(0.949999988079071044921875, dot(nor2, nor));
        col = textureLod(tex, texCoord - (dirInv * posadd), 0.0).x;
        float indexable_1[10] = float[](0.132571995258331298828125, 0.12547199428081512451171875, 0.10637299716472625732421875, 0.0807799994945526123046875, 0.0549499988555908203125, 0.03348200023174285888671875, 0.018275000154972076416015625, 0.008933999575674533843994140625, 0.00391199998557567596435546875, 0.00153500004671514034271240234375);
        w = indexable_1[i] * influenceFactor;
        fragColor += (col * w);
        weight += w;
    }
    fragColor /= weight;
}

