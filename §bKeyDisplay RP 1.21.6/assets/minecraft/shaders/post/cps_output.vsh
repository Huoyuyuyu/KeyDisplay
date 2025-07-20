#version 150

#moj_import <minecraft:projection.glsl>

in vec4 Position;

layout(std140) uniform SamplerInfo {
    vec2 OutSize;
    vec2 InSize;
};

out vec2 texCoord;

uniform sampler2D CpsDataSampler;
uniform sampler2D CpsKeySampler;

int in_int(int x, int y){
    ivec3 c = ivec3(texelFetch(CpsDataSampler, ivec2(x,y), 0).rgb*255);
    int i = c.r*65536 + c.g*256 + c.b;
    return i;
}
int in_key(int x){
    return int(texelFetch(CpsKeySampler, ivec2(x,0), 0).r);
}

out float lmb_cps;
out float rmb_cps;
out float lmb;
out float rmb;
out float w;
out float a;
out float s;
out float d;
out float space;

void main(){
    vec4 outPos = ProjMat * vec4(Position.xy * OutSize, 0.0, 1.0);
    gl_Position = vec4(outPos.xy, 0.2, 1.0);

    texCoord = Position.xy;

    lmb_cps = float(in_int(1, 1));
    rmb_cps = float(in_int(1, 3));

    lmb = in_key(0);
    rmb = in_key(1);
    w = in_key(2);
    a = in_key(3);
    s = in_key(4);
    d = in_key(5);
    space = in_key(6);
}
