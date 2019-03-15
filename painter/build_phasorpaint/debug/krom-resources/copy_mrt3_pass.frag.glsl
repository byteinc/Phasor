#version 330
#ifdef GL_ARB_shading_language_420pack
#extension GL_ARB_shading_language_420pack : require
#endif

uniform sampler2D tex0;
uniform sampler2D tex1;
uniform sampler2D tex2;

out vec4 fragColor[3];
in vec2 texCoord;

void main()
{
    fragColor[0] = textureLod(tex0, texCoord, 0.0);
    fragColor[1] = textureLod(tex1, texCoord, 0.0);
    fragColor[2] = textureLod(tex2, texCoord, 0.0);
}

