#version 330
#ifdef GL_ARB_shading_language_420pack
#extension GL_ARB_shading_language_420pack : require
#endif

uniform sampler2D tex;
uniform sampler2D sveloc;
uniform sampler2D tex2;

in vec2 texCoord;
out vec4 fragColor;

void main()
{
    vec4 current = textureLod(tex, texCoord, 0.0);
    vec2 velocity = -textureLod(sveloc, texCoord, 0.0).xy;
    vec4 previous = textureLod(tex2, texCoord + velocity, 0.0);
    float delta = abs((current.w * current.w) - (previous.w * previous.w)) / 5.0;
    float weight = 0.5 * clamp(1.0 - (sqrt(delta) * 30.0), 0.0, 1.0);
    fragColor = vec4(mix(current.xyz, previous.xyz, vec3(weight)), 1.0);
}

