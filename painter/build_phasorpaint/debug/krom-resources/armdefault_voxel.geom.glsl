#version 330
#ifdef GL_ARB_shading_language_420pack
#extension GL_ARB_shading_language_420pack : require
#endif
layout(triangles) in;
layout(max_vertices = 3, triangle_strip) out;

in vec3 voxpositionGeom[3];
out vec3 voxposition;

void main()
{
    vec3 p1 = voxpositionGeom[1] - voxpositionGeom[0];
    vec3 p2 = voxpositionGeom[2] - voxpositionGeom[0];
    vec3 p = abs(cross(p1, p2));
    for (uint i = 0u; i < 3u; i++)
    {
        voxposition = voxpositionGeom[i];
        float _55 = p.z;
        float _57 = p.x;
        bool _58 = _55 > _57;
        bool _67;
        if (_58)
        {
            _67 = p.z > p.y;
        }
        else
        {
            _67 = _58;
        }
        if (_67)
        {
            gl_Position = vec4(voxposition.x, voxposition.y, 0.0, 1.0);
        }
        else
        {
            float _87 = p.x;
            float _89 = p.y;
            bool _90 = _87 > _89;
            bool _98;
            if (_90)
            {
                _98 = p.x > p.z;
            }
            else
            {
                _98 = _90;
            }
            if (_98)
            {
                gl_Position = vec4(voxposition.y, voxposition.z, 0.0, 1.0);
            }
            else
            {
                gl_Position = vec4(voxposition.x, voxposition.z, 0.0, 1.0);
            }
        }
        EmitVertex();
    }
    EndPrimitive();
}

