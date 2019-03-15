#version 330
#ifdef GL_ARB_shading_language_420pack
#extension GL_ARB_shading_language_420pack : require
#endif

uniform sampler2D tex;

in vec2 texCoord;
out vec4 fragColor;

float vignette()
{
    return 0.60000002384185791015625 + (0.4000000059604644775390625 * pow((((16.0 * texCoord.x) * texCoord.y) * (1.0 - texCoord.x)) * (1.0 - texCoord.y), 0.20000000298023223876953125));
}

vec3 tonemapFilmic(vec3 color)
{
    vec3 x = max(vec3(0.0), color - vec3(0.0040000001899898052215576171875));
    return (x * ((x * 6.19999980926513671875) + vec3(0.5))) / ((x * ((x * 6.19999980926513671875) + vec3(1.7000000476837158203125))) + vec3(0.0599999986588954925537109375));
}

void main()
{
    vec2 texCo = texCoord;
    vec3 _88 = textureLod(tex, texCo, 0.0).xyz;
    fragColor = vec4(_88.x, _88.y, _88.z, fragColor.w);
    float x = ((texCo.x + 4.0) * (texCo.y + 4.0)) * 10.0;
    vec3 _121 = fragColor.xyz + (vec3(mod((mod(x, 13.0) + 1.0) * (mod(x, 123.0) + 1.0), 0.00999999977648258209228515625) - 0.004999999888241291046142578125) * 0.0900000035762786865234375);
    fragColor = vec4(_121.x, _121.y, _121.z, fragColor.w);
    vec3 _127 = fragColor.xyz * vignette();
    fragColor = vec4(_127.x, _127.y, _127.z, fragColor.w);
    vec3 _132 = tonemapFilmic(fragColor.xyz);
    fragColor = vec4(_132.x, _132.y, _132.z, fragColor.w);
}

