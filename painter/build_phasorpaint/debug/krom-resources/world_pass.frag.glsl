#version 330
#ifdef GL_ARB_shading_language_420pack
#extension GL_ARB_shading_language_420pack : require
#endif

uniform sampler2D envmap;
uniform float envmapStrength;

in vec3 normal;
out vec4 fragColor;

vec2 envMapEquirect(vec3 normal_1)
{
    float phi = acos(normal_1.z);
    float theta = atan(-normal_1.y, normal_1.x) + 3.1415927410125732421875;
    return vec2(theta / 6.283185482025146484375, phi / 3.1415927410125732421875);
}

void main()
{
    vec3 n = normalize(normal);
    vec3 _57 = texture(envmap, envMapEquirect(n)).xyz * envmapStrength;
    fragColor = vec4(_57.x, _57.y, _57.z, fragColor.w);
}

