#version 330

uniform sampler2D InSampler;

layout(std140) uniform SamplerInfo {
    vec2 OutSize;
    vec2 InSize;
    vec2 CpsDataSize;
};
layout(std140) uniform BlitConfig {
    vec4 ColorModulate;
};
#moj_import <minecraft:globals.glsl>

in vec2 texCoord;

out vec4 fragColor;

uniform sampler2D CpsDataSampler;

in float lmb;
in float rmb;

ivec2 this_pos = ivec2(texCoord * CpsDataSize);
int px = this_pos.x;
int py = this_pos.y;

void out_int(int x, int y, int i){
    if(this_pos == ivec2(x,y)) {
        vec3 c;
        c.r = i / 65536;
        c.g = (i % 65536) / 256;
        c.b = i % 256;
        fragColor = vec4(c/255, 1);
    }
}
int in_int(int x, int y){
    ivec3 c = ivec3(texelFetch(CpsDataSampler, ivec2(x,y), 0).rgb*255);
    int i = c.r*65536 + c.g*256 + c.b;
    return i;
}

void main(){
    fragColor = texture(CpsDataSampler, texCoord);

    int time = int(32768*mod(GameTime*1200,1));

    if(py == 0 || py == 1){ // 左键
        int lmb_cps = in_int(1,1); // 上帧时的cps
        int lf_lmb = in_int(0,1); // 上帧是否点击
        int mark = in_int(2,1);// 获取“上帧是否点击”标记值
        int lf_time = in_int(3,1); // 获取“上帧时间”
        int fc_time = in_int(0,0); // 最远点击的时间
        if(fc_time != lf_time){
            mark = 1; // 若时间改变, 开始删除点击
            out_int(2,1, 1);
        }
        if(mark == 1) { // 选中左键点击区域
            int del_c = 0; // 初始化删除数量

            for(int i=0; i<lmb_cps; i++){ // 遍历上帧储存的所有点击
                int c_time = in_int(i,0); // 该点击的时间

                if(time >= lf_time){
                    if(lf_time <= c_time && c_time <= time){
                        del_c++;
                    }else break;
                }else{
                    if(c_time >= 0 && c_time <= 16384){
                        if(0 <= c_time && c_time <= time){
                            del_c++;
                        }else break;
                    }else{
                        if(lf_time <= c_time && c_time <= 32768){
                            del_c++;
                        }else break;
                    }
                }
            }
            if(px >= 0 && px < lmb_cps && py == 0) out_int(px,0, in_int(px+del_c,0));
            lmb_cps -= del_c;
        }
        if(lf_lmb==0 && lmb==1){
            out_int(2,1, 0); // 在下帧中的 mark = 0
            out_int(lmb_cps,0, time); // 在第“点击次数”格写入当前时间
            lmb_cps++;
        }
        out_int(0,1, int(lmb)); // 在下帧中的 lf_lmb
        out_int(3,1, time); // 在下帧中的 lf_time
        out_int(1,1, lmb_cps); // 在下帧中的 lmb_cps
    }
    
    if(py == 2 || py == 3){ // 右键
        int rmb_cps = in_int(1,3); // 上帧时的cps
        int lf_rmb = in_int(0,3); // 上帧是否点击
        int mark = in_int(2,3);// 获取“上帧是否点击”标记值
        int lf_time = in_int(3,3); // 获取“上帧时间”
        int fc_time = in_int(0,2); // 最远点击的时间
        if(fc_time != lf_time){
            mark = 1; // 若时间改变, 开始删除点击
            out_int(2,3, 1);
        }
        if(mark == 1) { // 选中左键点击区域
            int del_c = 0; // 初始化删除数量

            for(int i=0; i<rmb_cps; i++){ // 遍历上帧储存的所有点击
                int c_time = in_int(i,2); // 该点击的时间

                if(time >= lf_time){
                    if(lf_time <= c_time && c_time <= time){
                        del_c++;
                    }else break;
                }else{
                    if(c_time >= 0 && c_time <= 16384){
                        if(0 <= c_time && c_time <= time){
                            del_c++;
                        }else break;
                    }else{
                        if(lf_time <= c_time && c_time <= 32768){
                            del_c++;
                        }else break;
                    }
                }
            }
            if(px >= 0 && px < rmb_cps && py == 2) out_int(px,2, in_int(px+del_c,2));
            rmb_cps -= del_c;
        }
        if(lf_rmb==0 && rmb==1){
            out_int(2,3, 0); // 在下帧中的 mark = 0
            out_int(rmb_cps,2, time); // 在第“点击次数”格写入当前时间
            rmb_cps++;
        }
        out_int(0,3, int(rmb)); // 在下帧中的 lf_rmb
        out_int(3,3, time); // 在下帧中的 lf_time
        out_int(1,3, rmb_cps); // 在下帧中的 rmb_cps
    }
}


