#version 330
#ifdef GL_ARB_shading_language_420pack
#extension GL_ARB_shading_language_420pack : require
#endif

uniform mat4 invP;

out vec2 texCoord;
in vec2 pos;
out vec3 viewRay;

void main()
{
    texCoord = (pos * vec2(0.5)) + vec2(0.5);
    gl_Position = vec4(pos, 0.0, 1.0);
    vec4 v = vec4(pos.x, pos.y, 1.0, 1.0);
    v = vec4(invP * v);
    viewRay = vec3(v.xy / vec2(v.z), 1.0);
}

