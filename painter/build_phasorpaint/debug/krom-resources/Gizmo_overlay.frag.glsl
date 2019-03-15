#version 330
#ifdef GL_ARB_shading_language_420pack
#extension GL_ARB_shading_language_420pack : require
#endif

in vec3 wnormal;
in vec3 vcolor;
out vec4 fragColor;

void main()
{
    vec3 n = normalize(wnormal);
    vec3 Attribute_Color_res = vcolor;
    vec3 basecol = Attribute_Color_res;
    float roughness = 0.0;
    float metallic = 0.0;
    float occlusion = 1.0;
    float specular = 0.0;
    fragColor = vec4(basecol, 1.0);
    vec3 _38 = pow(fragColor.xyz, vec3(0.4545454680919647216796875));
    fragColor = vec4(_38.x, _38.y, _38.z, fragColor.w);
}

