#version 330
#ifdef GL_ARB_shading_language_420pack
#extension GL_ARB_shading_language_420pack : require
#endif

uniform vec2 screenSizeInv;
uniform sampler2D edgesTex;
uniform sampler2D areaTex;
uniform sampler2D searchTex;
uniform vec2 screenSize;

in vec4 offset0;
in vec4 offset2;
in vec4 offset1;
out vec4 fragColor;
in vec2 texCoord;
in vec2 pixcoord;
vec2 cdw_end;

vec4 textureLodA(sampler2D tex, vec2 coord, float lod)
{
    return textureLod(tex, coord, lod);
}

vec2 SMAASearchDiag1(vec2 texcoord, vec2 dir)
{
    vec4 coord = vec4(texcoord, -1.0, 1.0);
    vec3 t = vec3(screenSizeInv, 1.0);
    float cw = coord.w;
    while ((coord.z < 7.0) && (cw > 0.89999997615814208984375))
    {
        vec3 _181 = (t * vec3(dir, 1.0)) + coord.xyz;
        coord = vec4(_181.x, _181.y, _181.z, coord.w);
        vec2 param = coord.xy;
        float param_1 = 0.0;
        cdw_end = textureLodA(edgesTex, param, param_1).xy;
        cw = dot(cdw_end, vec2(0.5));
    }
    coord.w = cw;
    return coord.zw;
}

vec4 SMAADecodeDiagBilinearAccess(inout vec4 e)
{
    vec2 _129 = e.xz * abs((e.xz * 5.0) - vec2(3.75));
    e = vec4(_129.x, e.y, _129.y, e.w);
    return floor(e + vec4(0.5));
}

vec2 SMAAAreaDiag(vec2 dist, vec2 e, float offset)
{
    vec2 texcoord = (vec2(20.0) * e) + dist;
    texcoord = (vec2(0.0062500000931322574615478515625, 0.001785714295692741870880126953125) * texcoord) + vec2(0.00312500004656612873077392578125, 0.0008928571478463709354400634765625);
    texcoord.x += 0.5;
    texcoord.y += (0.14285714924335479736328125 * offset);
    return textureLod(areaTex, texcoord, 0.0).xy;
}

vec2 SMAADecodeDiagBilinearAccess(inout vec2 e)
{
    e.x *= abs((5.0 * e.x) - 3.75);
    return floor(e + vec2(0.5));
}

vec2 SMAASearchDiag2(vec2 texcoord, vec2 dir)
{
    vec4 coord = vec4(texcoord, -1.0, 1.0);
    coord.x += (0.25 * screenSizeInv.x);
    vec3 t = vec3(screenSizeInv, 1.0);
    float cw = coord.w;
    while ((coord.z < 7.0) && (cw > 0.89999997615814208984375))
    {
        vec3 _244 = (t * vec3(dir, 1.0)) + coord.xyz;
        coord = vec4(_244.x, _244.y, _244.z, coord.w);
        vec2 param = coord.xy;
        float param_1 = 0.0;
        cdw_end = textureLodA(edgesTex, param, param_1).xy;
        vec2 param_2 = cdw_end;
        vec2 _255 = SMAADecodeDiagBilinearAccess(param_2);
        cdw_end = _255;
        cw = dot(cdw_end, vec2(0.5));
    }
    coord.w = cw;
    return coord.zw;
}

vec2 SMAACalculateDiagWeights(vec2 texcoord, vec2 e, vec4 subsampleIndices)
{
    vec2 weights = vec2(0.0);
    vec4 d;
    if (e.x > 0.0)
    {
        vec2 param = texcoord;
        vec2 param_1 = vec2(-1.0, 1.0);
        vec2 _311 = SMAASearchDiag1(param, param_1);
        d = vec4(_311.x, d.y, _311.y, d.w);
        float dadd = float(cdw_end.y > 0.89999997615814208984375);
        d.x += dadd;
    }
    else
    {
        d = vec4(vec2(0.0).x, d.y, vec2(0.0).y, d.w);
    }
    vec2 param_2 = texcoord;
    vec2 param_3 = vec2(1.0, -1.0);
    vec2 _332 = SMAASearchDiag1(param_2, param_3);
    d = vec4(d.x, _332.x, d.z, _332.y);
    if ((d.x + d.y) > 2.0)
    {
        vec4 coords = (vec4((-d.x) + 0.25, d.x, d.y, (-d.y) - 0.25) * screenSizeInv.xyxy) + texcoord.xyxy;
        vec2 param_4 = coords.xy + (vec2(-1.0, 0.0) * screenSizeInv);
        float param_5 = 0.0;
        vec2 _374 = textureLodA(edgesTex, param_4, param_5).xy;
        vec4 c;
        c = vec4(_374.x, _374.y, c.z, c.w);
        vec2 param_6 = coords.zw + (vec2(1.0, 0.0) * screenSizeInv);
        float param_7 = 0.0;
        vec2 _386 = textureLodA(edgesTex, param_6, param_7).xy;
        c = vec4(c.x, c.y, _386.x, _386.y);
        vec4 param_8 = c;
        vec4 _391 = SMAADecodeDiagBilinearAccess(param_8);
        c = vec4(_391.y, _391.x, _391.w, _391.z);
        vec2 cc = (vec2(2.0) * c.xz) + c.yw;
        float a1condx = step(0.89999997615814208984375, d.z);
        float a1condy = step(0.89999997615814208984375, d.w);
        if (a1condx == 1.0)
        {
            cc.x = 0.0;
        }
        if (a1condy == 1.0)
        {
            cc.y = 0.0;
        }
        vec2 param_9 = d.xy;
        vec2 param_10 = cc;
        float param_11 = subsampleIndices.z;
        weights += SMAAAreaDiag(param_9, param_10, param_11);
    }
    vec2 param_12 = texcoord;
    vec2 param_13 = vec2(-1.0);
    vec2 _435 = SMAASearchDiag2(param_12, param_13);
    d = vec4(_435.x, d.y, _435.y, d.w);
    vec2 param_14 = texcoord + (vec2(1.0, 0.0) * screenSizeInv);
    float param_15 = 0.0;
    if (textureLodA(edgesTex, param_14, param_15).x > 0.0)
    {
        vec2 param_16 = texcoord;
        vec2 param_17 = vec2(1.0);
        vec2 _453 = SMAASearchDiag2(param_16, param_17);
        d = vec4(d.x, _453.x, d.z, _453.y);
        float dadd_1 = float(cdw_end.y > 0.89999997615814208984375);
        d.y += dadd_1;
    }
    else
    {
        d = vec4(d.x, vec2(0.0).x, d.z, vec2(0.0).y);
    }
    if ((d.x + d.y) > 2.0)
    {
        vec4 coords_1 = (vec4(-d.x, -d.x, d.y, d.y) * screenSizeInv.xyxy) + texcoord.xyxy;
        vec2 param_18 = coords_1.xy + (vec2(-1.0, 0.0) * screenSizeInv);
        float param_19 = 0.0;
        vec4 c_1;
        c_1.x = textureLodA(edgesTex, param_18, param_19).y;
        vec2 param_20 = coords_1.xy + (vec2(0.0, -1.0) * screenSizeInv);
        float param_21 = 0.0;
        c_1.y = textureLodA(edgesTex, param_20, param_21).x;
        vec2 param_22 = coords_1.zw + (vec2(1.0, 0.0) * screenSizeInv);
        float param_23 = 0.0;
        vec2 _525 = textureLodA(edgesTex, param_22, param_23).yx;
        c_1 = vec4(c_1.x, c_1.y, _525.x, _525.y);
        vec2 cc_1 = (vec2(2.0) * c_1.xz) + c_1.yw;
        float a1condx_1 = step(0.89999997615814208984375, d.z);
        float a1condy_1 = step(0.89999997615814208984375, d.w);
        if (a1condx_1 == 1.0)
        {
            cc_1.x = 0.0;
        }
        if (a1condy_1 == 1.0)
        {
            cc_1.y = 0.0;
        }
        vec2 param_24 = d.xy;
        vec2 param_25 = cc_1;
        float param_26 = subsampleIndices.w;
        weights += SMAAAreaDiag(param_24, param_25, param_26).yx;
    }
    return weights;
}

float SMAASearchLength(vec2 e, float offset)
{
    vec2 scale = vec2(33.0, -33.0);
    vec2 bias = vec2(66.0, 33.0) * vec2(offset, 1.0);
    scale += vec2(-1.0, 1.0);
    bias += vec2(0.5, -0.5);
    scale *= vec2(0.015625, 0.0625);
    bias *= vec2(0.015625, 0.0625);
    vec2 coord = (scale * e) + bias;
    return textureLod(searchTex, coord, 0.0).x;
}

float SMAASearchXLeft(inout vec2 texcoord, float end)
{
    vec2 e = vec2(0.0, 1.0);
    for (;;)
    {
        float _612 = texcoord.x;
        float _613 = end;
        bool _614 = _612 > _613;
        bool _621;
        if (_614)
        {
            _621 = e.y > 0.828100025653839111328125;
        }
        else
        {
            _621 = _614;
        }
        bool _627;
        if (_621)
        {
            _627 = e.x == 0.0;
        }
        else
        {
            _627 = _621;
        }
        if (_627)
        {
            vec2 param = texcoord;
            float param_1 = 0.0;
            e = textureLodA(edgesTex, param, param_1).xy;
            texcoord = (vec2(-2.0, -0.0) * screenSizeInv) + texcoord;
            continue;
        }
        else
        {
            break;
        }
    }
    vec2 param_2 = e;
    float param_3 = 0.0;
    float offset = ((-2.007874011993408203125) * SMAASearchLength(param_2, param_3)) + 3.25;
    return (screenSizeInv.x * offset) + texcoord.x;
}

float SMAASearchXRight(inout vec2 texcoord, float end)
{
    vec2 e = vec2(0.0, 1.0);
    for (;;)
    {
        float _665 = texcoord.x;
        float _666 = end;
        bool _667 = _665 < _666;
        bool _673;
        if (_667)
        {
            _673 = e.y > 0.828100025653839111328125;
        }
        else
        {
            _673 = _667;
        }
        bool _679;
        if (_673)
        {
            _679 = e.x == 0.0;
        }
        else
        {
            _679 = _673;
        }
        if (_679)
        {
            vec2 param = texcoord;
            float param_1 = 0.0;
            e = textureLodA(edgesTex, param, param_1).xy;
            texcoord = (vec2(2.0, 0.0) * screenSizeInv) + texcoord;
            continue;
        }
        else
        {
            break;
        }
    }
    vec2 param_2 = e;
    float param_3 = 0.5;
    float offset = ((-2.007874011993408203125) * SMAASearchLength(param_2, param_3)) + 3.25;
    return ((-screenSizeInv.x) * offset) + texcoord.x;
}

vec2 SMAAArea(vec2 dist, float e1, float e2, float offset)
{
    vec2 texcoord = (vec2(16.0) * floor((vec2(e1, e2) * 4.0) + vec2(0.5))) + dist;
    texcoord = (vec2(0.0062500000931322574615478515625, 0.001785714295692741870880126953125) * texcoord) + vec2(0.00312500004656612873077392578125, 0.0008928571478463709354400634765625);
    texcoord.y = (0.14285714924335479736328125 * offset) + texcoord.y;
    return textureLod(areaTex, texcoord, 0.0).xy;
}

vec2 SMAADetectHorizontalCornerPattern(inout vec2 weights, vec4 texcoord, vec2 d)
{
    vec2 leftRight = step(d, d.yx);
    vec2 rounding = leftRight * 0.75;
    rounding /= vec2(leftRight.x + leftRight.y);
    vec2 factor = vec2(1.0);
    vec2 param = texcoord.xy + (vec2(0.0, 1.0) * screenSizeInv);
    float param_1 = 0.0;
    factor.x -= (rounding.x * textureLodA(edgesTex, param, param_1).x);
    vec2 param_2 = texcoord.zw + (vec2(1.0) * screenSizeInv);
    float param_3 = 0.0;
    factor.x -= (rounding.y * textureLodA(edgesTex, param_2, param_3).x);
    vec2 param_4 = texcoord.xy + (vec2(0.0, -2.0) * screenSizeInv);
    float param_5 = 0.0;
    factor.y -= (rounding.x * textureLodA(edgesTex, param_4, param_5).x);
    vec2 param_6 = texcoord.zw + (vec2(1.0, -2.0) * screenSizeInv);
    float param_7 = 0.0;
    factor.y -= (rounding.y * textureLodA(edgesTex, param_6, param_7).x);
    weights *= clamp(factor, vec2(0.0), vec2(1.0));
    return weights;
}

float SMAASearchYUp(inout vec2 texcoord, float end)
{
    vec2 e = vec2(1.0, 0.0);
    for (;;)
    {
        float _714 = texcoord.y;
        float _715 = end;
        bool _716 = _714 > _715;
        bool _722;
        if (_716)
        {
            _722 = e.x > 0.828100025653839111328125;
        }
        else
        {
            _722 = _716;
        }
        bool _728;
        if (_722)
        {
            _728 = e.y == 0.0;
        }
        else
        {
            _728 = _722;
        }
        if (_728)
        {
            vec2 param = texcoord;
            float param_1 = 0.0;
            e = textureLodA(edgesTex, param, param_1).xy;
            texcoord = (vec2(-0.0, -2.0) * screenSizeInv) + texcoord;
            continue;
        }
        else
        {
            break;
        }
    }
    vec2 param_2 = e.yx;
    float param_3 = 0.0;
    float offset = ((-2.007874011993408203125) * SMAASearchLength(param_2, param_3)) + 3.25;
    return (screenSizeInv.y * offset) + texcoord.y;
}

float SMAASearchYDown(inout vec2 texcoord, float end)
{
    vec2 e = vec2(1.0, 0.0);
    for (;;)
    {
        float _763 = texcoord.y;
        float _764 = end;
        bool _765 = _763 < _764;
        bool _771;
        if (_765)
        {
            _771 = e.x > 0.828100025653839111328125;
        }
        else
        {
            _771 = _765;
        }
        bool _777;
        if (_771)
        {
            _777 = e.y == 0.0;
        }
        else
        {
            _777 = _771;
        }
        if (_777)
        {
            vec2 param = texcoord;
            float param_1 = 0.0;
            e = textureLodA(edgesTex, param, param_1).xy;
            texcoord = (vec2(0.0, 2.0) * screenSizeInv) + texcoord;
            continue;
        }
        else
        {
            break;
        }
    }
    vec2 param_2 = e.yx;
    float param_3 = 0.5;
    float offset = ((-2.007874011993408203125) * SMAASearchLength(param_2, param_3)) + 3.25;
    return ((-screenSizeInv.y) * offset) + texcoord.y;
}

vec2 SMAADetectVerticalCornerPattern(inout vec2 weights, vec4 texcoord, vec2 d)
{
    vec2 leftRight = step(d, d.yx);
    vec2 rounding = leftRight * 0.75;
    rounding /= vec2(leftRight.x + leftRight.y);
    vec2 factor = vec2(1.0);
    vec2 param = texcoord.xy + (vec2(1.0, 0.0) * screenSizeInv);
    float param_1 = 0.0;
    factor.x -= (rounding.x * textureLodA(edgesTex, param, param_1).y);
    vec2 param_2 = texcoord.zw + (vec2(1.0) * screenSizeInv);
    float param_3 = 0.0;
    factor.x -= (rounding.y * textureLodA(edgesTex, param_2, param_3).y);
    vec2 param_4 = texcoord.xy + (vec2(-2.0, 0.0) * screenSizeInv);
    float param_5 = 0.0;
    factor.y -= (rounding.x * textureLodA(edgesTex, param_4, param_5).y);
    vec2 param_6 = texcoord.zw + (vec2(-2.0, 1.0) * screenSizeInv);
    float param_7 = 0.0;
    factor.y -= (rounding.y * textureLodA(edgesTex, param_6, param_7).y);
    weights *= clamp(factor, vec2(0.0), vec2(1.0));
    return weights;
}

vec4 SMAABlendingWeightCalculationPS(vec2 texcoord, vec2 pixcoord_1, vec4 subsampleIndices)
{
    vec4 weights = vec4(0.0);
    vec2 param = texcoord;
    float param_1 = 0.0;
    vec2 e = textureLodA(edgesTex, param, param_1).xy;
    if (e.y > 0.0)
    {
        vec2 param_2 = texcoord;
        vec2 param_3 = e;
        vec4 param_4 = subsampleIndices;
        vec2 _1039 = SMAACalculateDiagWeights(param_2, param_3, param_4);
        weights = vec4(_1039.x, _1039.y, weights.z, weights.w);
        if (weights.x == (-weights.y))
        {
            vec2 param_5 = offset0.xy;
            float param_6 = offset2.x;
            float _1061 = SMAASearchXLeft(param_5, param_6);
            vec3 coords;
            coords.x = _1061;
            coords.y = offset1.y;
            vec2 d;
            d.x = coords.x;
            vec2 param_7 = coords.xy;
            float param_8 = 0.0;
            float e1 = textureLodA(edgesTex, param_7, param_8).x;
            vec2 param_9 = offset0.zw;
            float param_10 = offset2.y;
            float _1084 = SMAASearchXRight(param_9, param_10);
            coords.z = _1084;
            d.y = coords.z;
            d = abs(floor(((screenSize.xx * d) + (-pixcoord_1.xx)) + vec2(0.5)));
            vec2 sqrt_d = sqrt(d);
            vec2 param_11 = coords.zy + (vec2(1.0, 0.0) * screenSizeInv);
            float param_12 = 0.0;
            float e2 = textureLodA(edgesTex, param_11, param_12).x;
            vec2 param_13 = sqrt_d;
            float param_14 = e1;
            float param_15 = e2;
            float param_16 = subsampleIndices.y;
            vec2 _1124 = SMAAArea(param_13, param_14, param_15, param_16);
            weights = vec4(_1124.x, _1124.y, weights.z, weights.w);
            coords.y = texcoord.y;
            vec2 param_17 = weights.xy;
            vec4 param_18 = coords.xyzy;
            vec2 param_19 = d;
            vec2 _1138 = SMAADetectHorizontalCornerPattern(param_17, param_18, param_19);
            weights = vec4(_1138.x, _1138.y, weights.z, weights.w);
        }
        else
        {
            e.x = 0.0;
        }
    }
    if (e.x > 0.0)
    {
        vec2 param_20 = offset1.xy;
        float param_21 = offset2.z;
        float _1155 = SMAASearchYUp(param_20, param_21);
        vec3 coords_1;
        coords_1.y = _1155;
        coords_1.x = offset0.x;
        vec2 d_1;
        d_1.x = coords_1.y;
        vec2 param_22 = coords_1.xy;
        float param_23 = 0.0;
        float e1_1 = textureLodA(edgesTex, param_22, param_23).y;
        vec2 param_24 = offset1.zw;
        float param_25 = offset2.w;
        float _1177 = SMAASearchYDown(param_24, param_25);
        coords_1.z = _1177;
        d_1.y = coords_1.z;
        d_1 = abs(floor(((screenSize.yy * d_1) + (-pixcoord_1.yy)) + vec2(0.5)));
        vec2 sqrt_d_1 = sqrt(d_1);
        vec2 param_26 = coords_1.xz + (vec2(0.0, 1.0) * screenSizeInv);
        float param_27 = 0.0;
        float e2_1 = textureLodA(edgesTex, param_26, param_27).y;
        vec2 param_28 = sqrt_d_1;
        float param_29 = e1_1;
        float param_30 = e2_1;
        float param_31 = subsampleIndices.x;
        vec2 _1216 = SMAAArea(param_28, param_29, param_30, param_31);
        weights = vec4(weights.x, weights.y, _1216.x, _1216.y);
        coords_1.x = texcoord.x;
        vec2 param_32 = weights.zw;
        vec4 param_33 = coords_1.xyxz;
        vec2 param_34 = d_1;
        vec2 _1230 = SMAADetectVerticalCornerPattern(param_32, param_33, param_34);
        weights = vec4(weights.x, weights.y, _1230.x, _1230.y);
    }
    return weights;
}

void main()
{
    vec2 param = texCoord;
    vec2 param_1 = pixcoord;
    vec4 param_2 = vec4(0.0);
    vec4 _1246 = SMAABlendingWeightCalculationPS(param, param_1, param_2);
    fragColor = _1246;
}

