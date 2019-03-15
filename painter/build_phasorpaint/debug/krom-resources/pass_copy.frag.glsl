#version 330
#ifdef GL_ARB_shading_language_420pack
#extension GL_ARB_shading_language_420pack : require
#endif

uniform sampler2D tex;

out vec4 fragColor;
in vec2 texCoord;

void main()
{
    fragColor = textureLod(tex, texCoord, 0.0);
}

