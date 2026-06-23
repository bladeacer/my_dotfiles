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
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}
void main() {
    vec2 uv = qt_TexCoord0;
    float n = hash(uv);
    float threshold = 1.0 - progress;
    float reveal = step(threshold, n);
    float alpha = 1.0 - reveal;
    fragColor = vec4(transBgColor.rgb * alpha, alpha);
}
