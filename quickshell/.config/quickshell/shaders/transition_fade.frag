#version 440
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(binding = 0) uniform sampler2D qt_Texture0;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float progress;
    vec4 transBgColor;
};
void main() {
    float alpha = 1.0 - progress;
    fragColor = vec4(transBgColor.rgb * alpha, alpha);
}
