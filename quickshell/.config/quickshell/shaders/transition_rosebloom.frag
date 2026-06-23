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
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}
void main() {
    vec2 uv = qt_TexCoord0;
    float isOpening = max(0.0, direction);
    float isClosing = 1.0 - isOpening;

    float scale = 5.0;
    vec2 p = uv * scale;
    vec2 i = floor(p);
    vec2 f = fract(p) - 0.5;

    float minDist = 1.0;
    vec2 minId = vec2(0.0);
    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            vec2 n = vec2(float(x), float(y));
            vec2 cell = i + n;
            vec2 c = vec2(hash(cell), hash(cell + 100.0));
            vec2 d = n + c - f;
            float dist = dot(d, d);
            if (dist < minDist) {
                minDist = dist;
                minId = cell;
            }
        }
    }
    minDist = sqrt(minDist);

    float cellThreshold = hash(minId);
    float centerDist = length(uv - 0.5);
    float activation = progress * 1.3 - centerDist * 0.3;
    float reveal = smoothstep(cellThreshold - 0.05, cellThreshold + 0.05, activation);

    float edgeGlow = exp(-minDist * 8.0) * (1.0 - reveal) * 0.6;
    vec3 bloomColor = transBgColor.rgb + vec3(0.2, 0.5, 1.0) * edgeGlow;

    float openAlpha = 1.0 - reveal;
    float closeAlpha = 1.0 - progress;
    float alpha = openAlpha * isOpening + closeAlpha * isClosing;
    vec3 color = bloomColor * isOpening + transBgColor.rgb * isClosing;

    fragColor = vec4(color * alpha, alpha);
}
