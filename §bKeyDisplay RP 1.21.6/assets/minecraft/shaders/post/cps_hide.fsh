#version 150

uniform sampler2D InSampler;

layout(std140) uniform BlitConfig {
    vec4 ColorModulate;
};
layout(std140) uniform SamplerInfo {
    vec2 OutSize;
    vec2 InSize;
};

in vec2 texCoord;

out vec4 fragColor;

ivec2 this_pos = ivec2(texCoord * OutSize);

void main(){
    fragColor = texture(InSampler, texCoord) * ColorModulate;
    if(this_pos.y == 0 && this_pos.x < 7) fragColor = texelFetch(InSampler, ivec2(this_pos.x, this_pos.y+1), 0);
}
