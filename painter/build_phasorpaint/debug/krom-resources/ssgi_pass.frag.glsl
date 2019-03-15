#version 330
#ifdef GL_ARB_shading_language_420pack
#extension GL_ARB_shading_language_420pack : require
#endif

uniform mat4 P;
uniform sampler2D gbufferD;
uniform vec2 cameraProj;
uniform sampler2D gbuffer0;
uniform mat3 V3;

in vec3 viewRay;
out float fragColor;
in vec2 texCoord;
vec2 coord;
float depth;
vec3 hitCoord;
vec3 vpos;

vec3 _204;

vec2 octahedronWrap(vec2 v)
{
    return (vec2(1.0) - abs(v.yx)) * vec2((v.x >= 0.0) ? 1.0 : (-1.0), (v.y >= 0.0) ? 1.0 : (-1.0));
}

vec3 getPosView(vec3 viewRay_1, float depth_1, vec2 cameraProj_1)
{
    float linearDepth = cameraProj_1.y / (cameraProj_1.x - depth_1);
    return viewRay_1 * linearDepth;
}

vec2 getProjectedCoord(vec3 hitCoord_1)
{
    vec4 projectedCoord = P * vec4(hitCoord_1, 1.0);
    vec2 _86 = projectedCoord.xy / vec2(projectedCoord.w);
    projectedCoord = vec4(_86.x, _86.y, projectedCoord.z, projectedCoord.w);
    vec2 _94 = (projectedCoord.xy * 0.5) + vec2(0.5);
    projectedCoord = vec4(_94.x, _94.y, projectedCoord.z, projectedCoord.w);
    return projectedCoord.xy;
}

float getDeltaDepth(vec3 hitCoord_1)
{
    vec3 param = hitCoord_1;
    coord = getProjectedCoord(param);
    depth = (textureLod(gbufferD, coord, 0.0).x * 2.0) - 1.0;
    vec3 p = getPosView(viewRay, depth, cameraProj);
    return p.z - hitCoord_1.z;
}

void rayCast(inout vec3 dir)
{
    hitCoord = vpos;
    dir *= 0.0199999995529651641845703125;
    float dist = 0.1500000059604644775390625;
    for (int i = 0; i < 8; i++)
    {
        hitCoord += dir;
        vec3 param = hitCoord;
        float _163 = getDeltaDepth(param);
        float delta = _163;
        if ((delta > 0.0) && (delta < 0.20000000298023223876953125))
        {
            dist = distance(vpos, hitCoord);
            break;
        }
    }
    fragColor += dist;
}

vec3 tangent(vec3 n)
{
    vec3 t1 = cross(n, vec3(0.0, 0.0, 1.0));
    vec3 t2 = cross(n, vec3(0.0, 1.0, 0.0));
    if (length(t1) > length(t2))
    {
        return normalize(t1);
    }
    else
    {
        return normalize(t2);
    }
}

void main()
{
    fragColor = 0.0;
    vec4 g0 = textureLod(gbuffer0, texCoord, 0.0);
    float d = (textureLod(gbufferD, texCoord, 0.0).x * 2.0) - 1.0;
    vec2 enc = g0.xy;
    vec3 n;
    n.z = (1.0 - abs(enc.x)) - abs(enc.y);
    vec2 _236;
    if (n.z >= 0.0)
    {
        _236 = enc;
    }
    else
    {
        _236 = octahedronWrap(enc);
    }
    n = vec3(_236.x, _236.y, n.z);
    n = normalize(V3 * n);
    vpos = getPosView(viewRay, d, cameraProj);
    vec3 param = n;
    rayCast(param);
    vec3 o1 = normalize(tangent(n));
    vec3 o2 = cross(o1, n);
    vec3 c1 = (o1 + o2) * 0.5;
    vec3 c2 = (o1 - o2) * 0.5;
    vec3 param_1 = mix(n, o1, vec3(0.5));
    rayCast(param_1);
    vec3 param_2 = mix(n, o2, vec3(0.5));
    rayCast(param_2);
    vec3 param_3 = mix(n, -c1, vec3(0.5));
    rayCast(param_3);
    vec3 param_4 = mix(n, -c2, vec3(0.5));
    rayCast(param_4);
}

