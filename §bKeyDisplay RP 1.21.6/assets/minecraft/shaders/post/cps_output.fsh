#version 330

    const vec2 Direction = vec2(0,1);
    // 基准点, 同时影响对齐方式, 单位: 1屏幕长宽

    const ivec2 Translation = ivec2(20,-20);
    // 相对偏移, 单位: 1屏幕像素

    const vec4 PressText = vec4(0,0,0,255) / 255;
    const vec4 ReleaseText = vec4(255,255,255,255) / 255;
    // 按下/松开按键时 文字的颜色 数字分别代表 rgba 值

    const vec4 PressBackground = vec4(72,72,72,54) / 255;
    const vec4 ReleaseBackground = vec4(65,65,145,54) / 255;
    // 按下/松开按键时 背景的颜色 数字分别代表 rgba 值

    const int psd_SettingScale = 4;
    // 正常情况的界面尺寸 (窗口大小太小时会自动减小)

// 上面这几个常量变量可以修改, 以此自定义ui样式




uniform sampler2D InSampler;

uniform sampler2D PsdAsciiSampler;
uniform sampler2D CpsDataSampler;

layout(std140) uniform SamplerInfo {
    vec2 OutSize;
    vec2 InSize;
};
layout(std140) uniform BlitConfig {
    vec4 ColorModulate;
};

in vec2 texCoord;

out vec4 fragColor;

// psd
    struct psd_image{
        ivec2 v0; ivec2 v1; ivec2 uv0; ivec2 uv1;
    };

    bool range2d(ivec2 v, ivec2 vmin, ivec2 vmax){
        return v.x >= vmin.x && v.y > vmin.y && v.x < vmax.x && v.y <= vmax.y;
    }

    void mixout(vec4 color){
        fragColor = vec4(mix(fragColor.rgb, color.rgb, color.a),1);
    }

    ivec2 this_pos = ivec2(texCoord*OutSize);
    int px = this_pos.x;
    int py = this_pos.y;

    void psd_drawImage(psd_image Image, sampler2D texMap, vec2 texSize, vec4 ImageColor){
        ivec2 tex = this_pos;
        if(range2d(tex, Image.v0, Image.v1)){
            tex.x = tex.x - Image.v0.x;
            tex.y = Image.v1.y - tex.y;
            tex *= (Image.uv1 - Image.uv0);
            tex /= (Image.v1 - Image.v0);
            vec4 color = texture(texMap, vec2(Image.uv0 + tex)/texSize) * ImageColor;
            mixout(color);
        }
    }

    int psd_GuiScale = min(psd_SettingScale, int(min( OutSize.x/320, OutSize.y/240 )));

    ivec2 gui(ivec2 screen){
        return screen*psd_GuiScale;
    }
    ivec2 gui(int x, int y){
        return ivec2(x,y)*psd_GuiScale;
    }

    void psd_drawAscii(ivec2 pos, int ascii, vec4 ImageColor){
        int x = ascii%16*8;
        int y = ascii/16*8;
        psd_image Image = psd_image(pos, pos+8*psd_GuiScale, ivec2(x,y), ivec2(x,y)+8);
        psd_drawImage(Image, PsdAsciiSampler, vec2(128), ImageColor);
    }

    void psd_drawNumber(ivec2 pos, int number, vec4 ImageColor){
        int n = number;
        if(n == 0){
            psd_drawAscii(pos, 48, ImageColor);
            return;
        }
        for(int i = 0; n > 0 ; i++){
            psd_drawAscii(pos-i*gui(6,0), 48+n%10, ImageColor);
            n /= 10;
        }
    }

// cps
    in float lmb_cps;
    in float rmb_cps;
    in float lmb;
    in float rmb;
    in float w;
    in float a;
    in float s;
    in float d;
    in float space;

    ivec2 UiSize = gui(77,98);
    ivec2 Origin = ivec2(Direction*(OutSize-vec2(UiSize))) + Translation;

void main(){
    fragColor = texture(InSampler, texCoord) * ColorModulate;

    ivec2 Pos = Origin;
    if(range2d(this_pos, Pos, Pos+UiSize)){
        if(range2d(this_pos, Pos, Pos+gui(77,20))) mixout((space == 1) ? PressBackground : ReleaseBackground);
        if(range2d(this_pos, Pos+gui(16,10), Pos+gui(62,11))) mixout((space == 1) ? PressText : ReleaseText);

        Pos = Origin + gui(0,21);
        if(range2d(this_pos, Pos, Pos+gui(38,25))) mixout((lmb == 1) ? PressBackground : ReleaseBackground);
        psd_drawAscii(Pos+gui(10,14), 76, (lmb == 1) ? PressText : ReleaseText);
        psd_drawAscii(Pos+gui(16,14), 77, (lmb == 1) ? PressText : ReleaseText);
        psd_drawAscii(Pos+gui(22,14), 66, (lmb == 1) ? PressText : ReleaseText);
        psd_drawNumber(Pos+gui(5,5)+((lmb_cps>9) ? gui(3,0):ivec2(0)), int(lmb_cps), (lmb == 1) ? PressText : ReleaseText);
        psd_drawAscii(Pos+gui(15,5)+((lmb_cps>9) ? gui(3,0):ivec2(0)), 67, (lmb == 1) ? PressText : ReleaseText);
        psd_drawAscii(Pos+gui(21,5)+((lmb_cps>9) ? gui(3,0):ivec2(0)), 80, (lmb == 1) ? PressText : ReleaseText);
        psd_drawAscii(Pos+gui(27,5)+((lmb_cps>9) ? gui(3,0):ivec2(0)), 83, (lmb == 1) ? PressText : ReleaseText);

        Pos = Origin + gui(39,21);
        if(range2d(this_pos, Pos, Pos+gui(38,25))) mixout((rmb == 1) ? PressBackground : ReleaseBackground);
        psd_drawAscii(Pos+gui(10,14), 82, (rmb == 1) ? PressText : ReleaseText);
        psd_drawAscii(Pos+gui(16,14), 77, (rmb == 1) ? PressText : ReleaseText);
        psd_drawAscii(Pos+gui(22,14), 66, (rmb == 1) ? PressText : ReleaseText);
        psd_drawNumber(Pos+gui(5,5)+((rmb_cps>9) ? gui(3,0):ivec2(0)), int(rmb_cps), (rmb == 1) ? PressText : ReleaseText);
        psd_drawAscii(Pos+gui(15,5)+((rmb_cps>9) ? gui(3,0):ivec2(0)), 67, (rmb == 1) ? PressText : ReleaseText);
        psd_drawAscii(Pos+gui(21,5)+((rmb_cps>9) ? gui(3,0):ivec2(0)), 80, (rmb == 1) ? PressText : ReleaseText);
        psd_drawAscii(Pos+gui(27,5)+((rmb_cps>9) ? gui(3,0):ivec2(0)), 83, (rmb == 1) ? PressText : ReleaseText);

        Pos = Origin + gui(0,47);
        if(range2d(this_pos, Pos, Pos+gui(25,25))) mixout((a == 1) ? PressBackground : ReleaseBackground);
        psd_drawAscii(Pos+gui(10,8), 65, (a == 1) ? PressText : ReleaseText);

        Pos = Origin + gui(26,47);
        if(range2d(this_pos, Pos, Pos+gui(25,25))) mixout((s == 1) ? PressBackground : ReleaseBackground);
        psd_drawAscii(Pos+gui(10,8), 83, (s == 1) ? PressText : ReleaseText);

        Pos = Origin + gui(52,47);
        if(range2d(this_pos, Pos, Pos+gui(25,25))) mixout((d == 1) ? PressBackground : ReleaseBackground);
        psd_drawAscii(Pos+gui(10,8), 68, (d == 1) ? PressText : ReleaseText);

        Pos = Origin + gui(26,73);
        if(range2d(this_pos, Pos, Pos+gui(25,25))) mixout((w == 1) ? PressBackground : ReleaseBackground);
        psd_drawAscii(Pos+gui(10,8), 87, (w == 1) ? PressText : ReleaseText);
    }
}
