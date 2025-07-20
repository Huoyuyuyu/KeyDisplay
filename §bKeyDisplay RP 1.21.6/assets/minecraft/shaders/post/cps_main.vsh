#version 150

#moj_import <minecraft:projection.glsl>

uniform sampler2D InSampler;

in vec4 Position;

layout(std140) uniform SamplerInfo {
    vec2 OutSize;
    vec2 InSize;
    vec2 CpsDataSize;
};
layout(std140) uniform BlitConfig {
    vec4 ColorModulate;
};

out vec2 texCoord;

    out float lmb;
    out float rmb;

void main(){
    vec4 outPos = ProjMat * vec4(Position.xy * OutSize, 0.0, 1.0);
    gl_Position = vec4(outPos.xy, 0.2, 1.0);

    texCoord = Position.xy;
    
    lmb = texelFetch(InSampler, ivec2(0, 0), 0).r;
    rmb = texelFetch(InSampler, ivec2(1, 0), 0).r;
}
