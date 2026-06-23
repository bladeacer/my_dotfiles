#version 440
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(binding = 0) uniform sampler2D qt_Texture0;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float direction;
    float progress;
    vec4 transBgColor;
};
float hash(float p) {
    return fract(sin(p * 127.1) * 43758.5453);
}
void main() {
    vec2 uv = qt_TexCoord0;
    float alpha = 1.0;
    vec3 color = transBgColor.rgb;

    if (direction > 0.0) {
        float invProgress = 1.0 - progress;
        float lineNoise = hash(floor(uv.y * 80.0) + progress * 100.0);
        float jitter = sin(uv.y * 40.0 + progress * 50.0) * 0.08 * step(0.7, lineNoise);
        uv.x += jitter * invProgress;
        float interference = step(0.98, hash(uv.y + progress));
        color += vec3(0.2, 0.5, 1.0) * interference * invProgress * 0.4;
        alpha = invProgress;
    } else {
        float halfHeight = progress * 0.5;
        float distFromCenter = abs(uv.y - 0.5);
        if (distFromCenter > halfHeight) {
            discard;
        }
        float edgeGlow = exp(-abs(halfHeight - distFromCenter) * 150.0);
        color = mix(transBgColor.rgb, vec3(0.2, 0.6, 1.0), edgeGlow * 0.8);
        alpha = progress;
    }

    fragColor = vec4(color * alpha, alpha);
}
