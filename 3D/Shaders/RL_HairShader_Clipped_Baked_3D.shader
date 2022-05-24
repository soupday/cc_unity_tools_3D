Shader "Reallusion/RL_HairShader_Clipped_Baked_3D"
{
    Properties 
    {
        // replicate standard shader inputs
        [NoScaleOffset]_MainTex("Albedo", 2D) = "white" {}
        _Color("Diffuse Color", Color) = (1,1,1)
        [NoScaleOffset]_MetallicGlossMap("Metallic", 2D) = "gray" {}                // metallic(rgb), smoothness(a)
        [NoScaleOffset]_BumpMap("Normal", 2D) = "bump" {}
        _BumpScale("Normal Scale", Range(0, 2)) = 1
        [NoScaleOffset]_OcclusionMap("Occlusion", 2D) = "white" {}
        _OcclusionStrength("Occlusion Strength", Range(0, 1)) = 1
        [NoScaleOffset]_EmissionMap("Emission Map", 2D) = "white" {}
        [HDR]_EmissiveColor("Emissive Color", Color) = (0,0,0)
        // custom shader
        _AlphaClip("Alpha Clip", Range(0, 1)) = 1
        _VertexBaseColor("Vertex Base Color", Color) = (0, 0, 0, 0)
        _VertexColorStrength("Vertex Color Strength", Range(0, 1)) = 0.5

        [KeywordEnum(Standard, Noise, Dither)]_ENUMCLIPQUALITY_ON("Clip Quality", Float) = 0
    }
    SubShader
    {
        Tags { "Queue" = "AlphaTest" "RenderType" = "TransparentCutout" }
        LOD 200

        Cull Off
        ZWrite On

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows addshadow  
        #pragma multi_compile _ENUMCLIPQUALITY_ON_STANDARD _ENUMCLIPQUALITY_ON_NOISE _ENUMCLIPQUALITY_ON_DITHER
        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _MetallicGlossMap;
        sampler2D _BumpMap;
        sampler2D _OcclusionMap;
        sampler2D _EmissionMap;

        struct Input
        {
            float2 uv_MainTex;    
            fixed4 vertColor : COLOR;
            float4 screenPos;
        };
        
         
        half _AlphaClip;
        half _BumpScale;
        half _OcclusionStrength;
        fixed4 _EmissiveColor;
        // custom
        fixed4 _VertexBaseColor;
        fixed4 _Color;
        half _VertexColorStrength;

        half Dither(half In, half2 ScreenPosition)
        {
            half2 uv = ScreenPosition.xy * _ScreenParams.xy;
            half DITHER_THRESHOLDS[16] =
            {
                1.0 / 17.0,  9.0 / 17.0,  3.0 / 17.0, 11.0 / 17.0,
                13.0 / 17.0,  5.0 / 17.0, 15.0 / 17.0,  7.0 / 17.0,
                4.0 / 17.0, 12.0 / 17.0,  2.0 / 17.0, 10.0 / 17.0,
                16.0 / 17.0,  8.0 / 17.0, 14.0 / 17.0,  6.0 / 17.0
            };
            uint index = (uint(uv.x) % 4) * 4 + uint(uv.y) % 4;
            return In - DITHER_THRESHOLDS[index];
        }

        inline float NoiseRandom(float2 uv)
        {
            return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
        }

        inline float NoiseInterpolate(float a, float b, float t)
        {
            return (1.0 - t) * a + (t * b);
        }

        inline float ValueNoise(float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);

            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = NoiseRandom(c0);
            float r1 = NoiseRandom(c1);
            float r2 = NoiseRandom(c2);
            float r3 = NoiseRandom(c3);

            float bottomOfGrid = NoiseInterpolate(r0, r1, f.x);
            float topOfGrid = NoiseInterpolate(r2, r3, f.x);
            float t = NoiseInterpolate(bottomOfGrid, topOfGrid, f.y);
            return t;
        }

        float Noise(float2 UV, float Scale)
        {
            float t = 0.0;

            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3 - 0));
            t += ValueNoise(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3 - 1));
            t += ValueNoise(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3 - 2));
            t += ValueNoise(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

            return t;
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float2 uv = IN.uv_MainTex;

            half4 metallicGloss = tex2D(_MetallicGlossMap, uv);            
            half4 ao = lerp(1.0, tex2D(_OcclusionMap, uv), _OcclusionStrength);
            half4 color = tex2D(_MainTex, uv);
            half alpha = color.a;

            // apply vertex color mask
            half vcf = (1 - (IN.vertColor.r + IN.vertColor.g + IN.vertColor.b) * 0.3333) * _VertexColorStrength;
            color = lerp(color, _VertexBaseColor, vcf) * _Color;

            // normal
            half3 normal = UnpackNormal(tex2D(_BumpMap, uv));
            // apply normal strength
            normal = half3(normal.xy * _BumpScale, lerp(1, normal.z, saturate(_BumpScale)));
            
            // emission
            half3 emission = tex2D(_EmissionMap, uv) * _EmissiveColor;

            // outputs
            o.Albedo = color.rgb;
            o.Metallic = metallicGloss.g;
            o.Smoothness = metallicGloss.a;
            o.Occlusion = ao.g;
            o.Normal = normal;
            o.Alpha = alpha;
            o.Emission = emission;        

#if _ENUMCLIPQUALITY_ON_NOISE
            clip(alpha - _AlphaClip * Noise(uv, 1000));
#elif _ENUMCLIPQUALITY_ON_DITHER
            clip(alpha - Dither(_AlphaClip + 0.5 - alpha, IN.screenPos.xy / IN.screenPos.w));
#else
            clip(alpha - _AlphaClip);
#endif
        }
        ENDCG

    }
    FallBack "Diffuse"
}
