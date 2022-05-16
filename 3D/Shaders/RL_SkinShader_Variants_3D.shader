Shader "Reallusion/RL_SkinShader_Variants_3D"
{
    Properties 
    {
        // Main Maps
        [NoScaleOffset] _DiffuseMap("Diffuse Map", 2D) = "white" {}
        _DiffuseColor("Diffuse Color", Color) = (1,1,1)
        [NoScaleOffset]_MaskMap("Mask Map", 2D) = "gray" {}
        _AOStrength("Ambient Occlusion Strength", Range(0,1)) = 1
        _SmoothnessPower("Smoothness Power", Range(0.5,2)) = 1
        _SmoothnessMin("Smoothness Min", Range(0,1)) = 0
        _SmoothnessMax("Smoothness Max", Range(0,1)) = 0.88        
        // Normals
        [NoScaleOffset]_NormalMap("Normal Map", 2D) = "bump" {}
        _NormalStrength("Normal Strength", Range(0,2)) = 1
        [NoScaleOffset]_MicroNormalMap("Micro Normal Map", 2D) = "bump" {}        
        _MicroNormalStrength("Micro Normal Strength", Range(0,2)) = 0.5
        _MicroNormalTiling("Micro Normal Tiling", Range(0,50)) = 25                              
        // Blend Maps
        [NoScaleOffset]_ColorBlendMap("Color Blend Map (Head)", 2D) = "grey" {}
        _ColorBlendStrength("Color Blend Strength (Head)", Range(0,1)) = 0.5
        [NoScaleOffset]_NormalBlendMap("Normal Blend Map (Head)", 2D) = "bump" {}
        _NormalBlendStrength("Normal Blend Strength (Head)", Range(0,1)) = 0.5
        // Cavity AO
        [NoScaleOffset]_MNAOMap("Cavity AO Map (Head)", 2D) = "white" {}
        _MouthCavityAO("Mouth Cavity AO", Range(0.1,5)) = 2.5
        _NostrilCavityAO("Nostril Cavity AO", Range(0.1,5)) = 2.5
        _LipsCavityAO("Lips Cavity AO", Range(0.1,5)) = 2.5        
        // Micro maps
        [NoScaleOffset]_RGBAMask("RGBA Map", 2D) = "black" {}        
        [NoScaleOffset]_CFULCMask("CFULC Mask", 2D) = "black" {}
        [NoScaleOffset]_EarNeckMask("Ear Neck Mask", 2D) = "black" {}
        _MicroSmoothnessMod("Micro Smoothness Mod", Range(-1.5,1.5)) = 0
        _RSmoothnessMod("Nose/R Smoothness Mod", Range(-1.5,1.5)) = 0
        _GSmoothnessMod("Mouth/G Smoothness Mod", Range(-1.5,1.5)) = 0
        _BSmoothnessMod("Upper Lid/B Smoothness Mod", Range(-1.5,1.5)) = 0
        _ASmoothnessMod("Inner Lid/A Smoothness Mod", Range(-1.5,1.5)) = 0
        _EarSmoothnessMod("Ear Smoothness Mod", Range(-1.5,1.5)) = 0
        _NeckSmoothnessMod("Neck Smoothness Mod", Range(-1.5,1.5)) = 0
        _CheekSmoothnessMod("Cheek Smoothness Mod", Range(-1.5,1.5)) = 0
        _ForeheadSmoothnessMod("Forehead Smoothness Mod", Range(-1.5,1.5)) = 0
        _UpperLipSmoothnessMod("Upper Lip Smoothness Mod", Range(-1.5,1.5)) = 0
        _ChinSmoothnessMod("Chin Smoothness Mod", Range(-1.5,1.5)) = 0
        _UnmaskedSmoothnessMod("Unmasked Smoothness Mod", Range(-1.5,1.5)) = 0        
        // Emission
        [NoScaleOffset]_EmissionMap("Emission Map", 2D) = "white" {}
        [HDR]_EmissiveColor("Emissive Color", Color) = (0,0,0)
        // Keywords
        [Toggle]BOOLEAN_IS_HEAD("Is Head", Float) = 1

        // NOT YET IMPLEMENTED
        [HideInInspector][NoScaleOffset]_SSSMap("Subsurface Map", 2D) = "white" {}
        [HideInInspector]_SubsurfaceScale("Subsurface Scale", Range(0,1)) = 1
        [HideInInspector][NoScaleOffset]_ThicknessMap("Thickness Map", 2D) = "black" {}
        [HideInInspector]_ThicknessScale("Thickness Scale", Range(0,1)) = 0.4
        [HideInInspector]_RScatterScale("Nose/R Scatter Scale", Range(0,2)) = 1
        [HideInInspector]_GScatterScale("Mouth/G Scatter Scale", Range(0,2)) = 1
        [HideInInspector]_BScatterScale("Upper Lid/B Scatter Scale", Range(0,2)) = 1
        [HideInInspector]_AScatterScale("Inner Lid/A Scatter Scale", Range(0,2)) = 1
        [HideInInspector]_EarScatterScale("Ear Scatter Scale", Range(0,2)) = 1
        [HideInInspector]_NeckScatterScale("Neck Scatter Scale", Range(0,2)) = 1
        [HideInInspector]_CheekScatterScale("Cheek Scatter Scale", Range(0,2)) = 1
        [HideInInspector]_ForeheadScatterScale("Forehead Scatter Scale", Range(0,2)) = 1
        [HideInInspector]_UpperLipScatterScale("Upper Lip Scatter Scale", Range(0,2)) = 1
        [HideInInspector]_ChinScatterScale("Chin Scatter Scale", Range(0,2)) = 1
        [HideInInspector]_UnmaskedScatterScale("Unmasked Scatter Scale", Range(0,2)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows
        #pragma multi_compile _ BOOLEAN_IS_HEAD_ON

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _DiffuseMap;        
        sampler2D _MaskMap;
        sampler2D _SSSMap;
        sampler2D _ThicknessMap;
        sampler2D _NormalMap;
        sampler2D _MicroNormalMap;
        sampler2D _ColorBlendMap;
        sampler2D _MNAOMap;
        sampler2D _NormalBlendMap;
        sampler2D _RGBAMask;
        sampler2D _CFULCMask;
        sampler2D _EarNeckMask;
        sampler2D _EmissionMap;
        
        struct Input
        {
            float2 uv_DiffuseMap;
        };

        half _NormalStrength;
        half _MicroNormalStrength;
        half _MicroNormalTiling;
        half _AOStrength;
        half _SmoothnessPower;
        half _SmoothnessMin;
        half _SmoothnessMax;
        half _SubsurfaceScale;
        half _ThicknessScale;
        half _MouthCavityAO;
        half _NostrilCavityAO;
        half _LipsCavityAO;
        half _ColorBlendStrength;
        half _NormalBlendStrength;
        half _MicroSmoothnessMod;
        half _RSmoothnessMod;
        half _GSmoothnessMod;
        half _BSmoothnessMod;
        half _ASmoothnessMod;
        half _EarSmoothnessMod;
        half _NeckSmoothnessMod;
        half _CheekSmoothnessMod;
        half _ForeheadSmoothnessMod;
        half _UpperLipSmoothnessMod;
        half _ChinSmoothnessMod;
        half _UnmaskedSmoothnessMod;
        half _RScatterScale;
        half _GScatterScale;
        half _BScatterScale;
        half _AScatterScale;
        half _EarScatterScale;
        half _NeckScatterScale;
        half _CheekScatterScale;
        half _ForeheadScatterScale;
        half _UpperLipScatterScale;
        half _ChinScatterScale;
        half _UnmaskedScatterScale;
        half3 _EmissiveColor;
        half3 _DiffuseColor;

#if BOOLEAN_IS_HEAD_ON
        void surf (Input IN, inout SurfaceOutputStandard o)
        {            
            float2 uv = IN.uv_DiffuseMap;

            fixed4 base = tex2D(_DiffuseMap, uv) * fixed4(_DiffuseColor, 1.0);
            half4 mask = tex2D(_MaskMap, uv);
            fixed4 bcb = tex2D(_ColorBlendMap, uv);

            // blend overlay the base color blend map over the diffuse
            fixed4 result1 = 1.0 - 2.0 * (1.0 - base) * (1.0 - bcb);
            fixed4 result2 = 2.0 * base * bcb;
            fixed4 zeroOrOne = step(base, 0.5);
            fixed4 result3 = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
            base = lerp(base, result3, _ColorBlendStrength);

            // cavity AO
            half4 cavityAO = tex2D(_MNAOMap, uv);
            half mouthAO = pow(cavityAO.g, _MouthCavityAO);
            half nostrilAO = pow(cavityAO.b, _NostrilCavityAO);
            half lipsAO = pow(cavityAO.a, _LipsCavityAO);
            half cao = saturate(mouthAO * nostrilAO * lipsAO);
            base *= cao;

            // remap AO
            half ao = lerp(1.0, mask.g, _AOStrength);
            
            // micro smoothness
            fixed4 mask1 = tex2D(_RGBAMask, uv);
            fixed4 mask2 = tex2D(_CFULCMask, uv);
            fixed4 mask3 = tex2D(_EarNeckMask, uv);
            fixed4 mod1 = fixed4(_RSmoothnessMod, _GSmoothnessMod, _BSmoothnessMod, _ASmoothnessMod);
            fixed4 mod2 = fixed4(_CheekSmoothnessMod, _ForeheadSmoothnessMod, _UpperLipSmoothnessMod, _ChinSmoothnessMod);
            fixed4 mod3 = fixed4(_NeckSmoothnessMod, _EarSmoothnessMod, 0.0, 0.0);
            fixed4 msum = mask1 + mask2 + mask3;            
            fixed unmask = 1.0 - saturate(msum.x + msum.y + msum.z + msum.w);
            fixed smoothnessMod = dot(mask1, mod1) + dot(mask2, mod2) + dot(mask3, mod3) + (unmask * _UnmaskedSmoothnessMod);

            // remap smoothness
            half smoothness = lerp(_SmoothnessMin, _SmoothnessMax, pow(mask.a, _SmoothnessPower));
            //smoothness = saturate(smoothness + smoothnessMod + _MicroSmoothnessMod);
            smoothness = saturate((1.0 + smoothnessMod + _MicroSmoothnessMod) * smoothness) * cao;

            // normal
            half3 normal = UnpackNormal(tex2D(_NormalMap, uv));
            // apply normal strength
            normal = half3(normal.xy * _NormalStrength, lerp(1, normal.z, saturate(_NormalStrength)));
            // blend normal
            half3 blendNormal = UnpackNormal(tex2D(_NormalBlendMap, uv));
            // apply blend normal strength
            blendNormal = half3(blendNormal.xy * _NormalBlendStrength, lerp(1, blendNormal.z, saturate(_NormalBlendStrength)));
            // micro normal
            half3 microNormal = UnpackNormal(tex2D(_MicroNormalMap, uv * _MicroNormalTiling));
            // apply micro normal strength
            half detailStrength = _MicroNormalStrength * mask.b;
            microNormal = half3(microNormal.xy * detailStrength, lerp(1, microNormal.z, saturate(detailStrength)));
            // combine normals
            normal = normalize(half3(normal.xy + blendNormal.xy + microNormal.xy, normal.z * blendNormal.z * microNormal.z));
            
            // emission
            half3 emission = tex2D(_EmissionMap, uv) * _EmissiveColor.rgb;

            // outputs
            o.Albedo = base.rgb;
            o.Metallic = mask.r;
            o.Smoothness = smoothness;
            o.Occlusion = ao;
            o.Normal = normal;            
            o.Alpha = 1.0; 
            o.Emission = emission;
        }
#else
        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            float2 uv = IN.uv_DiffuseMap;

            fixed4 base = tex2D(_DiffuseMap, uv) * fixed4(_DiffuseColor, 1.0);
            half4 mask = tex2D(_MaskMap, uv);
            fixed4 bcb = tex2D(_ColorBlendMap, uv);                        

            // remap AO
            half ao = lerp(1.0, mask.g, _AOStrength);

            // micro smoothness
            fixed4 mask1 = tex2D(_RGBAMask, uv);
            fixed4 mod1 = fixed4(_RSmoothnessMod, _GSmoothnessMod, _BSmoothnessMod, _ASmoothnessMod);            
            fixed unmask = 1.0 - saturate(mask1.x + mask1.y + mask1.z + mask1.w);
            fixed smoothnessMod = dot(mask1, mod1) + (unmask * _UnmaskedSmoothnessMod);

            // remap smoothness
            half smoothness = lerp(_SmoothnessMin, _SmoothnessMax, pow(mask.a, _SmoothnessPower));
            //smoothness = saturate(smoothness + smoothnessMod + _MicroSmoothnessMod);
            smoothness = saturate((1.0 + smoothnessMod + _MicroSmoothnessMod) * smoothness);

            // normal
            half3 normal = UnpackNormal(tex2D(_NormalMap, uv));
            // apply normal strength
            normal = half3(normal.xy * _NormalStrength, lerp(1, normal.z, saturate(_NormalStrength)));
            // micro normal
            half3 microNormal = UnpackNormal(tex2D(_MicroNormalMap, uv * _MicroNormalTiling));
            // apply micro normal strength
            half detailStrength = _MicroNormalStrength * mask.b;
            microNormal = half3(microNormal.xy * detailStrength, lerp(1, microNormal.z, saturate(detailStrength)));
            // combine normals
            normal = normalize(half3(normal.xy + microNormal.xy, normal.z * microNormal.z));
            
            // emission
            half3 emission = tex2D(_EmissionMap, uv) * _EmissiveColor.rgb;

            // outputs
            o.Albedo = base.rgb;
            o.Metallic = mask.r;
            o.Smoothness = smoothness;
            o.Occlusion = ao;
            o.Normal = normal;
            o.Alpha = 1.0;
            o.Emission = emission;
        }
#endif
        ENDCG
    }
    FallBack "Diffuse"
}
