Shader "Reallusion/RL_HairShader_1st_Pass_Variants_3D"
{
    Properties 
    {
        // Main Maps
        [NoScaleOffset]_DiffuseMap("Diffuse Map", 2D) = "white" {}
        _DiffuseColor("Diffuse Color", Color) = (1,1,1)
        _DiffuseStrength("Diffuse Strength", Range(0, 2)) = 1
        _VertexBaseColor("Vertex Base Color", Color) = (0, 0, 0, 0)
        _VertexColorStrength("Vertex Color Strength", Range(0, 1)) = 0.5
        _BaseColorStrength("Base Color Strength", Range(0, 1)) = 1
        _AlphaPower("Alpha Power", Range(0.01, 2)) = 1
        _AlphaRemap("Alpha Remap", Range(0.5, 1)) = 1
        _AlphaClip("Alpha Clip", Range(0, 1)) = 1
        [NoScaleOffset]_MaskMap("Mask Map", 2D) = "white" {}
        _AOStrength("Ambient Occlusion Strength", Range(0, 1)) = 1
        _AOOccludeAll("AO Occlude All", Range(0, 1)) = 0
        _SmoothnessMin("Smoothness Min", Range(0, 1)) = 0
        _SmoothnessMax("Smoothness Max", Range(0, 1)) = 1
        _SmoothnessPower("Smoothness Power", Range(0.5, 2)) = 1
        // Normals
        [NoScaleOffset]_NormalMap("Normal Map", 2D) = "bump" {}        
        _NormalStrength("Normal Strength", Range(0, 2)) = 1
        // Blend Maps
        [NoScaleOffset]_BlendMap("Blend Map", 2D) = "white" {}
        _BlendStrength("Blend Strength", Range(0, 1)) = 1
        // Hair Root/End Colouring
        [NoScaleOffset]_RootMap("Root Map", 2D) = "grey" {}
        _GlobalStrength("Global Strength", Range(0, 1)) = 1
        _RootColorStrength("Root Color Strength", Range(0, 1)) = 1
        _EndColorStrength("End Color Strength", Range(0, 1)) = 1
        _InvertRootMap("Invert Root Map", Range(0, 1)) = 0
        _RootColor("Root Color", Color) = (0.3294118, 0.1411765, 0.05098039, 0)
        _EndColor("End Color", Color) = (0.6039216, 0.454902, 0.2862745, 0)
        // Hair ID Map Highlights
        [NoScaleOffset]_IDMap("ID Map", 2D) = "grey" {}
        _HighlightAStrength("Highlight A Strength", Range(0, 1)) = 1
        _HighlightAColor("Highlight A Color", Color) = (0.9137255, 0.7803922, 0.6352941, 0)
        _HighlightADistribution("Highlight A Distribution", Vector) = (0.1, 0.2, 0.3, 0)
        _HighlightAOverlapEnd("Highlight A Overlap End", Range(0, 1)) = 1
        _HighlightAOverlapInvert("Highlight A Overlap Invert", Range(0, 1)) = 1
        _HighlightBStrength("Highlight B Strength", Range(0, 1)) = 0
        _HighlightBColor("Highlight B Color", Color) = (1, 1, 1, 0)
        _HighlightBDistribution("Highlight B Distribution", Vector) = (0.6, 0.7, 0.8, 0)
        _HighlightBOverlapEnd("Highlight B Overlap End", Range(0, 1)) = 1
        _HighlightBOverlapInvert("Highlight B Overlap Invert", Range(0, 1)) = 1                       
        // Emission
        [NoScaleOffset]_EmissionMap("Emission Map", 2D) = "white" {}
        [HDR]_EmissiveColor("Emissive Color", Color) = (0, 0, 0)
        // Keywords            
        [Toggle]BOOLEAN_ENABLECOLOR("Enable Color", Float) = 0

        // NOT YET IMPLEMENTED
        [HideInInspector][NoScaleOffset]_SpecularMap("Specular Map", 2D) = "white" {}
        [HideInInspector][NoScaleOffset]_FlowMap("Flow Map", 2D) = "grey" {}
        [HideInInspector]_ShadowClip("Shadow Clip", Range(0, 1)) = 0.2
        [HideInInspector]_DepthPrepass("Depth Prepass", Range(0, 1)) = 0.95
        [HideInInspector]_DepthPostpass("Depth Postpass", Range(0, 1)) = 0.2
        [HideInInspector]_RimTransmissionIntensity("Rim Transmission Intensity", Range(0, 1)) = 0.05
        [HideInInspector]_SpecularTint("Specular Tint", Color) = (1, 1, 1, 1)
        [HideInInspector]_SpecularMultiplier("Specular Multiplier", Range(0, 1)) = 0.5
        [HideInInspector]_SpecularShift("Specular Shift", Range(-1, 1)) = 0.15
        [HideInInspector]_SecondarySpecularMultiplier("Secondary Specular Multiplier", Range(0, 1)) = 0.05
        [HideInInspector]_SecondarySpecularShift("Secondary Specular Shift", Range(-1, 1)) = 0.15
        [HideInInspector]_SecondarySmoothness("Secondary Smoothness", Range(0, 1)) = 0.625
        [HideInInspector][KeywordEnum(Standard, Noise, Dither)]_ENUMCLIPQUALITY_ON("Clip Quality", Float) = 0
    }
    SubShader
    {
        Tags { "Queue" = "AlphaTest" "RenderType" = "TransparentCutout" }
        LOD 200

        Cull Off
        ZWrite On

        // First pass: Render the hair as opaque alpha clipped. 
        // This should act as a depth prepass for the 2nd alpha blend pass.

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows alphatest:_AlphaClip addshadow
        #pragma multi_compile _ BOOLEAN_ENABLECOLOR_ON //_ENUMCLIPQUALITY_ON_STANDARD _ENUMCLIPQUALITY_ON_NOISE _ENUMCLIPQUALITY_ON_DITHER

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0                
        
        sampler2D _DiffuseMap;
        sampler2D _MaskMap;
        sampler2D _NormalMap;
        sampler2D _IDMap;
        sampler2D _BlendMap;
        sampler2D _RootMap;
        sampler2D _SpecularMap;
        sampler2D _FlowMap;
        sampler2D _EmissionMap;

        struct Input
        {
            float2 uv_DiffuseMap;
            fixed4 vertColor : COLOR;
        };        

        half _AOStrength;
        half _AOOccludeAll;
        half _DiffuseStrength;
        half _BlendStrength;
        fixed4 _VertexBaseColor;
        half _VertexColorStrength;
        half _BaseColorStrength;
        half _AlphaPower;
        half _AlphaRemap;
        half _ShadowClip;
        half _DepthPrepass;
        half _DepthPostpass;
        half _SmoothnessMin;
        half _SmoothnessMax;
        half _SmoothnessPower;
        half _GlobalStrength;
        half _RootColorStrength;
        half _EndColorStrength;
        half _InvertRootMap;
        fixed4 _RootColor;
        fixed4 _EndColor;
        half _HighlightAStrength;
        fixed4 _HighlightAColor;
        half4 _HighlightADistribution;
        half _HighlightAOverlapEnd;
        half _HighlightAOverlapInvert;
        half _HighlightBStrength;
        fixed4 _HighlightBColor;
        half4 _HighlightBDistribution;
        half _HighlightBOverlapEnd;
        half _HighlightBOverlapInvert;
        half _RimTransmissionIntensity;
        fixed4 _SpecularTint;
        half _SpecularMultiplier;
        half _SpecularShift;
        half _SecondarySpecularMultiplier;
        half _SecondarySpecularShift;
        half _SecondarySmoothness;
        half _NormalStrength;        
        fixed4 _EmissiveColor;
        fixed4 _DiffuseColor;
        half BOOLEAN_ENABLECOLOR;        

        float4 RootEndBlend(float4 color, float rootMask)
        {
            float globalMask = _GlobalStrength * (((1.0 - rootMask) * _RootColorStrength) + (rootMask * _EndColorStrength));
            rootMask = lerp(rootMask, 1.0 - rootMask, _InvertRootMap);
            float4 rootEnd = lerp(_RootColor, _EndColor, rootMask);
            return lerp(color, rootEnd, globalMask);
        }

        float4 HighlightBlend(float4 color, float idMap, float rootMask, float4 highlightColor,
                              float3 distribution, float strength, float overlap, float invert)
        {
            float lower = smoothstep(distribution.x, distribution.y, idMap);
            float upper = 1.0 - smoothstep(distribution.y, distribution.z, idMap);
            float highlightMask = strength * lerp(lower, upper, step(distribution.y, idMap));
            float invertedRootMask = lerp(rootMask, 1.0 - rootMask, 1.0 - invert);
            float overlappedInvertedRootMask = 1.0 - ((1.0 - invertedRootMask) * overlap);
            highlightMask = saturate(highlightMask * overlappedInvertedRootMask);
            return lerp(color, highlightColor, highlightMask);
        }

#if BOOLEAN_ENABLECOLOR_ON
        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            float2 uv = IN.uv_DiffuseMap;

            fixed4 diffuse = tex2D(_DiffuseMap, uv);
            half4 rootMap = tex2D(_RootMap, uv);
            half4 idMap = tex2D(_IDMap, uv);
            half4 depthBlend = tex2D(_BlendMap, uv);
            half4 mask = tex2D(_MaskMap, uv);

            // remap AO          
            half ao = lerp(1.0, mask.g, _AOStrength);
            half aoIndirect = lerp(1.0, ao, _AOOccludeAll * 0.5);
            half aoAll = lerp(1.0, ao, _AOOccludeAll);

            // remap Alpha
            half alpha = pow(saturate((diffuse.a / _AlphaRemap)), _AlphaPower);

            // remap smoothness
            half smoothness = lerp(_SmoothnessMin, _SmoothnessMax, pow(mask.a, _SmoothnessPower));

            fixed4 color = lerp(float4(1.0, 1.0, 1.0, 1.0), diffuse, _BaseColorStrength);
            color = RootEndBlend(color, rootMap.g);
            color = HighlightBlend(color, idMap.g, rootMap.g, _HighlightAColor, _HighlightADistribution,
                _HighlightAStrength, _HighlightAOverlapEnd, _HighlightAOverlapInvert);
            color = HighlightBlend(color, idMap.g, rootMap.g, _HighlightBColor, _HighlightBDistribution,
                _HighlightBStrength, _HighlightBOverlapEnd, _HighlightBOverlapInvert);

            color *= _DiffuseStrength;
            color = lerp(color, color * depthBlend, _BlendStrength);

            half vcf = (1 - (IN.vertColor.r + IN.vertColor.g + IN.vertColor.b) * 0.3333) * _VertexColorStrength;
            color = lerp(color, _VertexBaseColor, vcf) * _DiffuseColor;
            
            half3 normal = UnpackNormal(tex2D(_NormalMap, uv));
            // apply normal strength
            normal = half3(normal.xy * _NormalStrength, lerp(1, normal.z, saturate(_NormalStrength)));

            // emission
            half3 emission = tex2D(_EmissionMap, uv) * _EmissiveColor;

            o.Albedo = color.rgb * aoIndirect;
            o.Metallic = mask.r;
            o.Smoothness = smoothness * aoAll;
            o.Occlusion = ao;
            o.Normal = normal;            
            o.Alpha = alpha; 
            o.Emission = emission;
        }
#else
        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            float2 uv = IN.uv_DiffuseMap;

            fixed4 diffuse = tex2D(_DiffuseMap, uv);
            half4 depthBlend = tex2D(_BlendMap, uv);
            half4 mask = tex2D(_MaskMap, uv);

            // remap AO          
            half ao = lerp(1.0, mask.g, _AOStrength);
            half aoIndirect = lerp(1.0, ao, _AOOccludeAll * 0.5);
            half aoAll = lerp(1.0, ao, _AOOccludeAll);

            // remap Alpha
            half alpha = pow(saturate((diffuse.a / _AlphaRemap)), _AlphaPower);            

            // remap smoothness
            half smoothness = lerp(_SmoothnessMin, _SmoothnessMax, pow(mask.a, _SmoothnessPower));

            fixed4 color = diffuse * _DiffuseStrength;
            color = lerp(color, color * depthBlend, _BlendStrength);

            half vcf = (1 - (IN.vertColor.r + IN.vertColor.g + IN.vertColor.b) * 0.3333) * _VertexColorStrength;
            color = lerp(color, _VertexBaseColor, vcf) * _DiffuseColor;

            half3 normal = UnpackNormal(tex2D(_NormalMap, uv));
            // apply normal strength
            normal = half3(normal.xy * _NormalStrength, lerp(1, normal.z, saturate(_NormalStrength)));

            // emission
            half3 emission = tex2D(_EmissionMap, uv) * _EmissiveColor;

            o.Albedo = color.rgb * aoIndirect;
            o.Metallic = mask.r;
            o.Smoothness = smoothness * aoAll;
            o.Occlusion = ao;
            o.Normal = normal;
            o.Alpha = alpha;
            o.Emission = emission;
        }
#endif
        ENDCG        
    }
    FallBack "Diffuse"
}
