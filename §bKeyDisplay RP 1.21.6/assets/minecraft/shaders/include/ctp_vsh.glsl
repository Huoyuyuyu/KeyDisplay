
out vec2 part_pos;

float pixel_l = 2/ScreenSize.x;
float pixel_h = 2/ScreenSize.y;

float[] cornerX = float[](
    0, 0, 1, 1
);
float[] cornerY = float[](
    1, 0, 0, 1
);
// 不同的顶点

void Unit(int start, int end){
    int len = end-start;
    vec2 pos = vec2( (start+len*cornerX[gl_VertexID%4]) * pixel_l ,  cornerY[gl_VertexID%4] * pixel_h );
    gl_Position = vec4(pos-vec2(1),0,1);
    // 输出顶点坐标
    part_pos = vec2( len*cornerX[gl_VertexID%4] ,  cornerY[gl_VertexID%4] );
    // 输出局部坐标
}
