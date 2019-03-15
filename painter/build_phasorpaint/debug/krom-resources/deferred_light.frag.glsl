#version 330
#ifdef GL_ARB_shading_language_420pack
#extension GL_ARB_shading_language_420pack : require
#endif

uniform sampler2D sltcMat;
uniform vec3 lightArea0;
uniform vec3 lightArea1;
uniform vec3 lightArea2;
uniform vec3 lightArea3;
uniform sampler2D sltcMag;
uniform vec4 shirr[7];
uniform sampler2D gbuffer0;
uniform sampler2D gbuffer1;
uniform sampler2D gbufferD;
uniform vec3 eye;
uniform vec3 eyeLook;
uniform vec2 cameraProj;
uniform sampler2D senvmapBrdf;
uniform int envmapNumMipmaps;
uniform sampler2D senvmapRadiance;
uniform float envmapStrength;
uniform sampler2D ssaotex;
uniform vec3 pointPos;
uniform vec3 pointCol;

in vec2 texCoord;
in vec3 viewRay;
out vec4 fragColor;
vec3 L0;
vec3 L1;
vec3 L2;
vec3 L3;
vec3 L4;

vec2 octahedronWrap(vec2 v)
{
    return (vec2(1.0) - abs(v.yx)) * vec2((v.x >= 0.0) ? 1.0 : (-1.0), (v.y >= 0.0) ? 1.0 : (-1.0));
}

vec2 unpackFloat(float f)
{
    return vec2(floor(f) / 100.0, fract(f));
}

vec2 unpackFloat2(float f)
{
    return vec2(floor(f) / 255.0, fract(f));
}

vec3 surfaceAlbedo(vec3 baseColor, float metalness)
{
    return mix(baseColor, vec3(0.0), vec3(metalness));
}

vec3 surfaceF0(vec3 baseColor, float metalness)
{
    return mix(vec3(0.039999999105930328369140625), baseColor, vec3(metalness));
}

vec3 getPos(vec3 eye_1, vec3 eyeLook_1, vec3 viewRay_1, float depth, vec2 cameraProj_1)
{
    float linearDepth = cameraProj_1.y / (((depth * 0.5) + 0.5) - cameraProj_1.x);
    float viewZDist = dot(eyeLook_1, viewRay_1);
    vec3 wposition = eye_1 + (viewRay_1 * (linearDepth / viewZDist));
    return wposition;
}

vec3 shIrradiance(vec3 nor)
{
    vec3 cl00 = vec3(shirr[0].x, shirr[0].y, shirr[0].z);
    vec3 cl1m1 = vec3(shirr[0].w, shirr[1].x, shirr[1].y);
    vec3 cl10 = vec3(shirr[1].z, shirr[1].w, shirr[2].x);
    vec3 cl11 = vec3(shirr[2].y, shirr[2].z, shirr[2].w);
    vec3 cl2m2 = vec3(shirr[3].x, shirr[3].y, shirr[3].z);
    vec3 cl2m1 = vec3(shirr[3].w, shirr[4].x, shirr[4].y);
    vec3 cl20 = vec3(shirr[4].z, shirr[4].w, shirr[5].x);
    vec3 cl21 = vec3(shirr[5].y, shirr[5].z, shirr[5].w);
    vec3 cl22 = vec3(shirr[6].x, shirr[6].y, shirr[6].z);
    return ((((((((((cl22 * 0.429042994976043701171875) * ((nor.y * nor.y) - ((-nor.z) * (-nor.z)))) + (((cl20 * 0.743125021457672119140625) * nor.x) * nor.x)) + (cl00 * 0.88622701168060302734375)) - (cl20 * 0.2477079927921295166015625)) + (((cl2m2 * 0.85808598995208740234375) * nor.y) * (-nor.z))) + (((cl21 * 0.85808598995208740234375) * nor.y) * nor.x)) + (((cl2m1 * 0.85808598995208740234375) * (-nor.z)) * nor.x)) + ((cl11 * 1.02332794666290283203125) * nor.y)) + ((cl1m1 * 1.02332794666290283203125) * (-nor.z))) + ((cl10 * 1.02332794666290283203125) * nor.x);
}

float getMipFromRoughness(float roughness, float numMipmaps)
{
    return roughness * numMipmaps;
}

vec2 envMapEquirect(vec3 normal)
{
    float phi = acos(normal.z);
    float theta = atan(-normal.y, normal.x) + 3.1415927410125732421875;
    return vec2(theta / 6.283185482025146484375, phi / 3.1415927410125732421875);
}

int clipQuadToHorizon()
{
    int n = 0;
    int config = 0;
    if (L0.z > 0.0)
    {
        config++;
    }
    if (L1.z > 0.0)
    {
        config += 2;
    }
    if (L2.z > 0.0)
    {
        config += 4;
    }
    if (L3.z > 0.0)
    {
        config += 8;
    }
    if (config == 0)
    {
    }
    else
    {
        if (config == 1)
        {
            n = 3;
            L1 = (L0 * (-L1.z)) + (L1 * L0.z);
            L2 = (L0 * (-L3.z)) + (L3 * L0.z);
        }
        else
        {
            if (config == 2)
            {
                n = 3;
                L0 = (L1 * (-L0.z)) + (L0 * L1.z);
                L2 = (L1 * (-L2.z)) + (L2 * L1.z);
            }
            else
            {
                if (config == 3)
                {
                    n = 4;
                    L2 = (L1 * (-L2.z)) + (L2 * L1.z);
                    L3 = (L0 * (-L3.z)) + (L3 * L0.z);
                }
                else
                {
                    if (config == 4)
                    {
                        n = 3;
                        L0 = (L2 * (-L3.z)) + (L3 * L2.z);
                        L1 = (L2 * (-L1.z)) + (L1 * L2.z);
                    }
                    else
                    {
                        if (config == 5)
                        {
                            n = 0;
                        }
                        else
                        {
                            if (config == 6)
                            {
                                n = 4;
                                L0 = (L1 * (-L0.z)) + (L0 * L1.z);
                                L3 = (L2 * (-L3.z)) + (L3 * L2.z);
                            }
                            else
                            {
                                if (config == 7)
                                {
                                    n = 5;
                                    L4 = (L0 * (-L3.z)) + (L3 * L0.z);
                                    L3 = (L2 * (-L3.z)) + (L3 * L2.z);
                                }
                                else
                                {
                                    if (config == 8)
                                    {
                                        n = 3;
                                        L0 = (L3 * (-L0.z)) + (L0 * L3.z);
                                        L1 = (L3 * (-L2.z)) + (L2 * L3.z);
                                        L2 = L3;
                                    }
                                    else
                                    {
                                        if (config == 9)
                                        {
                                            n = 4;
                                            L1 = (L0 * (-L1.z)) + (L1 * L0.z);
                                            L2 = (L3 * (-L2.z)) + (L2 * L3.z);
                                        }
                                        else
                                        {
                                            if (config == 10)
                                            {
                                                n = 0;
                                            }
                                            else
                                            {
                                                if (config == 11)
                                                {
                                                    n = 5;
                                                    L4 = L3;
                                                    L3 = (L3 * (-L2.z)) + (L2 * L3.z);
                                                    L2 = (L1 * (-L2.z)) + (L2 * L1.z);
                                                }
                                                else
                                                {
                                                    if (config == 12)
                                                    {
                                                        n = 4;
                                                        L1 = (L2 * (-L1.z)) + (L1 * L2.z);
                                                        L0 = (L3 * (-L0.z)) + (L0 * L3.z);
                                                    }
                                                    else
                                                    {
                                                        if (config == 13)
                                                        {
                                                            n = 5;
                                                            L4 = L3;
                                                            L3 = L2;
                                                            L2 = (L2 * (-L1.z)) + (L1 * L2.z);
                                                            L1 = (L0 * (-L1.z)) + (L1 * L0.z);
                                                        }
                                                        else
                                                        {
                                                            if (config == 14)
                                                            {
                                                                n = 5;
                                                                L4 = (L3 * (-L0.z)) + (L0 * L3.z);
                                                                L0 = (L1 * (-L0.z)) + (L0 * L1.z);
                                                            }
                                                            else
                                                            {
                                                                if (config == 15)
                                                                {
                                                                    n = 4;
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    if (n == 3)
    {
        L3 = L0;
    }
    if (n == 4)
    {
        L4 = L0;
    }
    return n;
}

float integrateEdge(vec3 v1, vec3 v2)
{
    float cosTheta = dot(v1, v2);
    float theta = acos(cosTheta);
    vec3 _191 = v1;
    vec3 _192 = v2;
    float _198;
    if (theta > 0.001000000047497451305389404296875)
    {
        _198 = theta / sin(theta);
    }
    else
    {
        _198 = 1.0;
    }
    float res = cross(_191, _192).z * _198;
    return res;
}

float ltcEvaluate(vec3 N, vec3 V, float dotNV, vec3 P, inout mat3 Minv, vec3 points0, vec3 points1, vec3 points2, vec3 points3)
{
    vec3 T1 = normalize(V - (N * dotNV));
    vec3 T2 = cross(N, T1);
    Minv *= transpose(mat3(vec3(T1), vec3(T2), vec3(N)));
    L0 = Minv * (points0 - P);
    L1 = Minv * (points1 - P);
    L2 = Minv * (points2 - P);
    L3 = Minv * (points3 - P);
    L4 = vec3(0.0);
    int _652 = clipQuadToHorizon();
    int n = _652;
    if (n == 0)
    {
        return 0.0;
    }
    L0 = normalize(L0);
    L1 = normalize(L1);
    L2 = normalize(L2);
    L3 = normalize(L3);
    L4 = normalize(L4);
    float sum = 0.0;
    vec3 param = L0;
    vec3 param_1 = L1;
    sum += integrateEdge(param, param_1);
    vec3 param_2 = L1;
    vec3 param_3 = L2;
    sum += integrateEdge(param_2, param_3);
    vec3 param_4 = L2;
    vec3 param_5 = L3;
    sum += integrateEdge(param_4, param_5);
    if (n >= 4)
    {
        vec3 param_6 = L3;
        vec3 param_7 = L4;
        sum += integrateEdge(param_6, param_7);
    }
    if (n == 5)
    {
        vec3 param_8 = L4;
        vec3 param_9 = L0;
        sum += integrateEdge(param_8, param_9);
    }
    return max(0.0, -sum);
}

float attenuate(float dist)
{
    return 1.0 / (dist * dist);
}

vec3 sampleLight(vec3 p, vec3 n, vec3 v, float dotNV, vec3 lp, vec3 lightCol, vec3 albedo, float rough, float spec, vec3 f0)
{
    vec3 ld = lp - p;
    vec3 l = normalize(ld);
    vec3 h = normalize(v + l);
    float dotNH = dot(n, h);
    float dotVH = dot(v, h);
    float dotNL = dot(n, l);
    float theta = acos(dotNV);
    vec2 tuv = vec2(rough, theta / 1.57079637050628662109375);
    tuv = (tuv * 0.984375) + vec2(0.0078125);
    vec4 t = textureLod(sltcMat, tuv, 0.0);
    mat3 invM = mat3(vec3(vec3(1.0, 0.0, t.y)), vec3(vec3(0.0, t.z, 0.0)), vec3(vec3(t.w, 0.0, t.x)));
    vec3 param = n;
    vec3 param_1 = v;
    float param_2 = dotNV;
    vec3 param_3 = p;
    mat3 param_4 = invM;
    vec3 param_5 = lightArea0;
    vec3 param_6 = lightArea1;
    vec3 param_7 = lightArea2;
    vec3 param_8 = lightArea3;
    float _805 = ltcEvaluate(param, param_1, param_2, param_3, param_4, param_5, param_6, param_7, param_8);
    float ltcspec = _805;
    ltcspec *= textureLod(sltcMag, tuv, 0.0).w;
    vec3 param_9 = n;
    vec3 param_10 = v;
    float param_11 = dotNV;
    vec3 param_12 = p;
    mat3 param_13 = mat3(vec3(1.0, 0.0, 0.0), vec3(0.0, 1.0, 0.0), vec3(0.0, 0.0, 1.0));
    vec3 param_14 = lightArea0;
    vec3 param_15 = lightArea1;
    vec3 param_16 = lightArea2;
    vec3 param_17 = lightArea3;
    float _831 = ltcEvaluate(param_9, param_10, param_11, param_12, param_13, param_14, param_15, param_16, param_17);
    float ltcdiff = _831;
    vec3 direct = (albedo * ltcdiff) + vec3((ltcspec * spec) * 0.0500000007450580596923828125);
    direct *= attenuate(distance(p, lp));
    direct *= lightCol;
    return direct;
}

void main()
{
    vec4 g0 = textureLod(gbuffer0, texCoord, 0.0);
    vec3 n;
    n.z = (1.0 - abs(g0.x)) - abs(g0.y);
    vec2 _1021;
    if (n.z >= 0.0)
    {
        _1021 = g0.xy;
    }
    else
    {
        _1021 = octahedronWrap(g0.xy);
    }
    n = vec3(_1021.x, _1021.y, n.z);
    n = normalize(n);
    vec2 metrough = unpackFloat(g0.z);
    vec4 g1 = textureLod(gbuffer1, texCoord, 0.0);
    vec2 occspec = unpackFloat2(g1.w);
    vec3 albedo = surfaceAlbedo(g1.xyz, metrough.x);
    vec3 f0 = surfaceF0(g1.xyz, metrough.x);
    float depth = (textureLod(gbufferD, texCoord, 0.0).x * 2.0) - 1.0;
    vec3 p = getPos(eye, eyeLook, normalize(viewRay), depth, cameraProj);
    vec3 v = normalize(eye - p);
    float dotNV = max(dot(n, v), 0.0);
    vec2 envBRDF = textureLod(senvmapBrdf, vec2(metrough.y, 1.0 - dotNV), 0.0).xy;
    vec3 envl = shIrradiance(n);
    envl /= vec3(3.1415927410125732421875);
    vec3 reflectionWorld = reflect(-v, n);
    float lod = getMipFromRoughness(metrough.y, float(envmapNumMipmaps));
    vec3 prefilteredColor = textureLod(senvmapRadiance, envMapEquirect(reflectionWorld), lod).xyz;
    envl *= albedo;
    envl += (((prefilteredColor * ((f0 * envBRDF.x) + vec3(envBRDF.y))) * 1.5) * occspec.y);
    envl *= (envmapStrength * occspec.x);
    fragColor = vec4(envl.x, envl.y, envl.z, fragColor.w);
    vec3 _1169 = fragColor.xyz * textureLod(ssaotex, texCoord, 0.0).x;
    fragColor = vec4(_1169.x, _1169.y, _1169.z, fragColor.w);
    vec3 _1186 = sampleLight(p, n, v, dotNV, pointPos, pointCol, albedo, metrough.y, occspec.y, f0);
    vec3 _1189 = fragColor.xyz + _1186;
    fragColor = vec4(_1189.x, _1189.y, _1189.z, fragColor.w);
}

