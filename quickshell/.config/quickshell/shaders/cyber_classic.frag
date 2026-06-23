#version 440
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(binding = 0) uniform sampler2D qt_Texture0;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float time;
};
void main() {
    vec2 uv = qt_TexCoord0;
    float scanline = abs(sin(uv.y * 480.0 * 3.14159));
    scanline = smoothstep(0.88, 0.98, scanline);
    float edge = pow(abs(uv.x - 0.5) * 2.0, 3.0);
    vec3 color = vec3(0.0);
    color.r += edge * 0.1;
    color.b += edge * 0.1;
    float alpha = (scanline * 0.10 + edge * 0.05) * qt_Opacity;
    fragColor = vec4(color * alpha, alpha);
}
