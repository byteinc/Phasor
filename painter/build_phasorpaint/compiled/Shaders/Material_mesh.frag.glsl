#version 450
#include "compiled.inc"
#include "std/gbuffer.glsl"
in vec2 texCoord;
in vec3 wnormal;
in vec4 wvpposition;
in vec4 prevwvpposition;
out vec4 fragColor[3];
uniform sampler2D ImageTexture;
void main() {
vec3 n = normalize(wnormal);
	vec3 basecol;
	float roughness;
	float metallic;
	float occlusion;
	float specular;
	vec4 ImageTexture_store = texture(ImageTexture, texCoord.xy);
	ImageTexture_store.rgb = pow(ImageTexture_store.rgb, vec3(2.2));
	vec3 ImageTexture_Color_res = ImageTexture_store.rgb;
	basecol = ImageTexture_Color_res;
	roughness = 0.0;
	metallic = 0.0;
	occlusion = 1.0;
	specular = 0.0;
	n /= (abs(n.x) + abs(n.y) + abs(n.z));
	n.xy = n.z >= 0.0 ? n.xy : octahedronWrap(n.xy);
	const float matid = 0.0;
	fragColor[0] = vec4(n.xy, packFloat(metallic, roughness), matid);
	fragColor[1] = vec4(basecol.rgb, packFloat2(occlusion, specular));
	vec2 posa = (wvpposition.xy / wvpposition.w) * 0.5 + 0.5;
	vec2 posb = (prevwvpposition.xy / prevwvpposition.w) * 0.5 + 0.5;
	fragColor[2].rg = vec2(posa - posb);
}
