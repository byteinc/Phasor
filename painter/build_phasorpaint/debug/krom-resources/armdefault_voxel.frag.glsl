#version 330
#ifdef GL_ARB_shading_language_420pack
#extension GL_ARB_shading_language_420pack : require
#endif
#extension GL_ARB_shader_image_load_store : require

layout(r8) uniform writeonly image3D voxels;

in vec3 voxposition;

void main()
{
    bool _18 = abs(voxposition.z) > 1.0;
    bool _27;
    if (!_18)
    {
        _27 = abs(voxposition.x) > 1.0;
    }
    else
    {
        _27 = _18;
    }
    bool _36;
    if (!_27)
    {
        _36 = abs(voxposition.y) > 1.0;
    }
    else
    {
        _36 = _27;
    }
    if (_36)
    {
        return;
    }
    imageStore(voxels, ivec3(vec3(256.0) * ((voxposition * 0.5) + vec3(0.5))), vec4(1.0));
}

