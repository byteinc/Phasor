#version 330
#ifdef GL_ARB_shading_language_420pack
#extension GL_ARB_shading_language_420pack : require
#endif

uniform sampler2D tex;
uniform vec2 screenSizeInv;

out vec4 fragColor;
in vec2 texCoord;

vec3 textureSS(sampler2D tex_1, vec2 tc, vec2 texStep)
{
    vec3 col = texture(tex_1, tc).xyz;
    col += texture(tex_1, tc + (vec2(1.5, 0.0) * texStep)).xyz;
    col += texture(tex_1, tc + (vec2(-1.5, 0.0) * texStep)).xyz;
    col += texture(tex_1, tc + (vec2(0.0, 1.5) * texStep)).xyz;
    col += texture(tex_1, tc + (vec2(0.0, -1.5) * texStep)).xyz;
    col += texture(tex_1, tc + (vec2(1.5) * texStep)).xyz;
    col += texture(tex_1, tc + (vec2(-1.5) * texStep)).xyz;
    col += texture(tex_1, tc + (vec2(1.5, -1.5) * texStep)).xyz;
    col += texture(tex_1, tc + (vec2(-1.5, 1.5) * texStep)).xyz;
    return col / vec3(9.0);
}

void main()
{
    vec2 param = texCoord;
    vec2 param_1 = screenSizeInv / vec2(4.0);
    vec3 _129 = textureSS(tex, param, param_1);
    fragColor = vec4(_129.x, _129.y, _129.z, fragColor.w);
}

