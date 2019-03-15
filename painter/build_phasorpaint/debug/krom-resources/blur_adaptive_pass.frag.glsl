#version 330
#ifdef GL_ARB_shading_language_420pack
#extension GL_ARB_shading_language_420pack : require
#endif

uniform sampler2D gbuffer0;
uniform sampler2D tex;
uniform vec2 dirInv;

in vec2 texCoord;
out vec4 fragColor;

vec2 unpackFloat(float f)
{
    return vec2(floor(f) / 100.0, fract(f));
}

void main()
{
    float roughness = unpackFloat(textureLod(gbuffer0, texCoord, 0.0).z).y;
    if (roughness >= 0.800000011920928955078125)
    {
        vec3 _51 = textureLod(tex, texCoord, 0.0).xyz;
        fragColor = vec4(_51.x, _51.y, _51.z, fragColor.w);
        return;
    }
    vec3 _64 = textureLod(tex, texCoord + (dirInv * 2.5), 0.0).xyz;
    fragColor = vec4(_64.x, _64.y, _64.z, fragColor.w);
    vec3 _77 = fragColor.xyz + textureLod(tex, texCoord + (dirInv * 1.5), 0.0).xyz;
    fragColor = vec4(_77.x, _77.y, _77.z, fragColor.w);
    vec3 _86 = fragColor.xyz + textureLod(tex, texCoord, 0.0).xyz;
    fragColor = vec4(_86.x, _86.y, _86.z, fragColor.w);
    vec3 _98 = fragColor.xyz + textureLod(tex, texCoord - (dirInv * 1.5), 0.0).xyz;
    fragColor = vec4(_98.x, _98.y, _98.z, fragColor.w);
    vec3 _110 = fragColor.xyz + textureLod(tex, texCoord - (dirInv * 2.5), 0.0).xyz;
    fragColor = vec4(_110.x, _110.y, _110.z, fragColor.w);
    vec3 _117 = fragColor.xyz / vec3(5.0);
    fragColor = vec4(_117.x, _117.y, _117.z, fragColor.w);
}

