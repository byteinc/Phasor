#version 330
#ifdef GL_ARB_shading_language_420pack
#extension GL_ARB_shading_language_420pack : require
#endif

uniform vec2 dir;
uniform vec2 screenSize;
uniform sampler2D tex;

out vec4 fragColor;
in vec2 texCoord;

void main()
{
    vec2 _step = (dir / screenSize) * 3.0;
    vec3 _34 = textureLod(tex, texCoord, 0.0).xyz * 0.132571995258331298828125;
    fragColor = vec4(_34.x, _34.y, _34.z, fragColor.w);
    for (int i = 1; i < 10; i++)
    {
        vec2 s = _step * (float(i) + 0.5);
        float indexable[10] = float[](0.132571995258331298828125, 0.12547199428081512451171875, 0.10637299716472625732421875, 0.0807799994945526123046875, 0.0549499988555908203125, 0.03348200023174285888671875, 0.018275000154972076416015625, 0.008933999575674533843994140625, 0.00391199998557567596435546875, 0.00153500004671514034271240234375);
        vec3 _85 = fragColor.xyz + (textureLod(tex, texCoord + s, 0.0).xyz * indexable[i]);
        fragColor = vec4(_85.x, _85.y, _85.z, fragColor.w);
        float indexable_1[10] = float[](0.132571995258331298828125, 0.12547199428081512451171875, 0.10637299716472625732421875, 0.0807799994945526123046875, 0.0549499988555908203125, 0.03348200023174285888671875, 0.018275000154972076416015625, 0.008933999575674533843994140625, 0.00391199998557567596435546875, 0.00153500004671514034271240234375);
        vec3 _101 = fragColor.xyz + (textureLod(tex, texCoord - s, 0.0).xyz * indexable_1[i]);
        fragColor = vec4(_101.x, _101.y, _101.z, fragColor.w);
    }
    vec3 _109 = fragColor.xyz * 0.699999988079071044921875;
    fragColor = vec4(_109.x, _109.y, _109.z, fragColor.w);
    vec3 _116 = min(fragColor.xyz, vec3(64.0));
    fragColor = vec4(_116.x, _116.y, _116.z, fragColor.w);
}

