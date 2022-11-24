Shader "Reallusion/RL_CorneaShaderParallax_3D"
{
    Properties 
    {
        // Base Color
        [NoScaleOffset] _ScleraDiffuseMap("Sclera Diffuse Map", 2D) = "white" {}
        _ScleraScale("Sclera Scale", Range(0.25,2)) = 1
        _ScleraHue("Sclera Hue", Range(0,1)) = 0.5
        _ScleraSaturation("Sclera Saturation", Range(0,2)) = 1
        _ScleraBrightness("Sclera Brightness", Range(0,2)) = 0.75
        [NoScaleOffset]_CorneaDiffuseMap("Cornea Diffuse Map", 2D) = "white" {}
        _IrisScale("Iris Scale", Range(0.25,2)) = 1
        _IrisHue("Iris Hue", Range(0,1)) = 0.5
        _IrisSaturation("Iris Saturation", Range(0,2)) = 1
        _IrisBrightness("Iris Brightness", Range(0,2)) = 1        
        _IrisRadius("Iris Radius", Range(0.01,0.2)) = 0.15
        _IrisColor("Iris Color", Color) = (1,1,1,1)
        _IrisCloudyColor("Iris Cloudy Color", Color) = (0,0,0,0)
        _LimbusWidth("Limbus Width", Range(0.01,0.1)) = 0.055
        _LimbusDarkRadius("Limbus Dark Radius", Range(0.01,0.2)) = 0.1
        _LimbusDarkWidth("Limbus Dark Width", Range(0.01,0.2)) = 0.025
        _LimbusColor("Limbus Color", Color) = (0,0,0,0)
        _ShadowRadius("Shadow Radius", Range(0,0.5)) = 0.275
        _ShadowHardness("Shadow Hardness", Range(0.01,0.99)) = 0.5
        _CornerShadowColor("Corner Shadow Color", Color) = (1,0.7333333,0.6980392,1)
        // Mask
        [NoScaleOffset]_MaskMap("Mask Map", 2D) = "gray" {}
        _AOStrength("Ambient Occlusion Strength", Range(0,1)) = 0.2
        _ScleraSmoothness("Sclera Smoothness", Range(0,1)) = 0.8
        _CorneaSmoothness("Cornea Smoothness", Range(0,1)) = 1        
        // Blend Maps
        [NoScaleOffset]_ColorBlendMap("Color Blend Map", 2D) = "grey" {}
        _ColorBlendStrength("Color Blend Strength", Range(0,1)) = 0.2        
        // Normals
        [NoScaleOffset]_ScleraNormalMap("Sclera Normal Map", 2D) = "bump" {}
        _ScleraNormalStrength("Sclera Normal Strength", Range(0,1)) = 0.1
        _ScleraNormalTiling("Sclera Normal Tiling", Range(1,10)) = 2        
        // Emission
        [NoScaleOffset]_EmissionMap("Emission Map", 2D) = "white" {}
        [HDR]_EmissiveColor("Emissive Color", Color) = (0,0,0)       

        // Parallax        
        _PupilScale("Pupil Scale", Range(0.1,2)) = 0.8        
        _IrisDepth("Iris Depth", Range(0.1,1)) = 0.225        
        _IOR("IOR", Range(1,2)) = 1.4
        _PMod("Parallax Mod", Range(0,10)) = 6.2717
        _ParallaxRadius("Parallax Radius", Range(0,0.16)) = 0.1175
        _DepthRadius("Pupil Scale Radius", Range(0,1)) = 0.8

        // NOT YET IMPLEMENTED        
        [HideInInspector]_RefractionThickness("Refraction Thickness", Range(0,0.025)) = 0.01        

        // Keywords
        [ToggleUI]_IsLeftEye("Is Left Eye", Float) = 0
        [Toggle]BOOLEAN_ISCORNEA("IsCornea", Float) = 0

    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _ScleraDiffuseMap;
        sampler2D _CorneaDiffuseMap;
        sampler2D _ColorBlendMap;
        sampler2D _MaskMap;
        sampler2D _ScleraNormalMap;
        sampler2D _EmissionMap;

        struct Input
        {
            float2 uv_ScleraDiffuseMap;
            float3 viewDir;
        };
        
        half _AOStrength;
        half _ScleraNormalStrength;
        half _ScleraNormalTiling;
        half _ScleraScale;
        half _ScleraHue;
        half _ScleraSaturation;
        half _ScleraBrightness;
        half _IrisScale;
        half _IrisHue;
        half _IrisSaturation;
        half _IrisBrightness;        
        half _PupilScale;
        half _IrisRadius;
        fixed4 _IrisColor;
        fixed4 _IrisCloudyColor;
        half _LimbusWidth;
        half _LimbusDarkRadius;
        half _LimbusDarkWidth;
        fixed4 _LimbusColor;
        half _ShadowRadius;
        half _ShadowHardness;
        fixed4 _CornerShadowColor;
        half _ColorBlendStrength;
        half _ScleraSmoothness;
        half _CorneaSmoothness;
        half _IOR;
        half _ParallaxRadius;
        half _PMod;
        half _RefractionThickness;
        half _IrisDepth;
        half _DepthRadius;        
        half3 _EmissiveColor;
        half _IsLeftEye;        

        fixed4 HSV(fixed4 rgba, half hue, half saturation, half brightness)
        {
            // HUE
            half3 c = rgba.rgb;
            // this expects the h offset in normalized form i.e. 0.0 - 1.0, with 0.5 being no offset.
            hue = hue * 360.0 - 180.0;
            half4 K = half4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
            half4 P = lerp(half4(c.bg, K.wz), half4(c.gb, K.xy), step(c.b, c.g));
            half4 Q = lerp(half4(P.xyw, c.r), half4(c.r, P.yzx), step(P.x, c.r));
            half D = Q.x - min(Q.w, Q.y);
            half E = 1e-10;
            half3 hsv = half3(abs(Q.z + (Q.w - Q.y) / (6.0 * D + E)), D / (Q.x + E), Q.x);

            half h = hsv.x + hue / 360.0;
            hsv.x = (h < 0)
                ? h + 1
                : (h > 1)
                ? h - 1
                : h;

            half4 K2 = half4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
            half3 P2 = abs(frac(hsv.xxx + K2.xyz) * 6.0 - K2.www);
            c = hsv.z * lerp(K2.xxx, saturate(P2 - K2.xxx), hsv.y);

            // SATURATION
            half luma = dot(c, half3(0.2126729, 0.7151522, 0.0721750));
            c = luma.xxx + saturation.xxx * (c - luma.xxx);

            // LIGHTNESS
            rgba.rgb = c * brightness;
            return rgba;
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float2 uv = IN.uv_ScleraDiffuseMap;

            half4 mask = tex2D(_MaskMap, uv);
            half irisRadius = _IrisScale * _IrisRadius;
            half limbusWidth = _IrisScale * _LimbusWidth;
            half radial = length(uv.xy - half2(0.5, 0.5));
            half scleraMask = smoothstep(irisRadius - limbusWidth, irisRadius, radial);
            half irisMask = 1 - scleraMask;
            half depthRadius = irisRadius * _DepthRadius;
            half depthMask = saturate(1 - radial / depthRadius);
            
            // iris pupil scale mapping
            half pupilScale = _PupilScale * _IrisScale;
            half pupilTiling = 1.0 / lerp(_IrisScale, pupilScale, depthMask);
            half pupilOffset = 0.5 * (1.0 - pupilTiling);
            half2 pupilUV = uv * pupilTiling + pupilOffset;

            // parallax mapping            
            half3 Vr = normalize(o.Normal * (_IOR - 0.8) + IN.viewDir);
            half parallaxRadius = (_ParallaxRadius * _IrisScale);
            half parallaxHeightMask = pow(saturate((parallaxRadius - radial) / parallaxRadius), 0.25);            
            half parallaxTiling = 1.0 / (_IrisDepth * _PMod + 0.8711572);
            half parallaxOffset = 0.5 * (1.0 - parallaxTiling);
            half2 parallaxUV = (pupilUV - (half2(Vr.xy) * _IrisDepth)) * parallaxTiling + parallaxOffset;
            half2 corneaUV = lerp(pupilUV, parallaxUV, parallaxHeightMask);

            fixed4 cornea = HSV(tex2D(_CorneaDiffuseMap, corneaUV) * _IrisColor,
                                _IrisHue, _IrisSaturation, _IrisBrightness);

            half limbusDarkRadius = _LimbusDarkRadius * _IrisScale;
            half limbusDarkWidth = _LimbusDarkWidth * _IrisScale;
            half limbusMask = smoothstep(limbusDarkRadius, limbusDarkRadius + limbusDarkWidth, radial);

            cornea = cornea + (_IrisCloudyColor * 0.5);
            cornea = lerp(cornea, cornea * _LimbusColor, limbusMask);

            half scleraTiling = 1.0 / _ScleraScale;
            half2 scleraOffset = half2(0.5, 0.5) * (1 - scleraTiling);

            fixed4 sclera = HSV(tex2D(_ScleraDiffuseMap, uv * scleraTiling + scleraOffset),
                                _ScleraHue, _ScleraSaturation, _ScleraBrightness);

            half shadowRadius = _ShadowRadius * _ScleraScale;
            half shadowMask = smoothstep(shadowRadius * _ShadowHardness, shadowRadius, radial);

            sclera = lerp(sclera, _CornerShadowColor * sclera, shadowMask);

            fixed4 c = lerp(sclera, cornea, irisMask);

            half4 blend = tex2D(_ColorBlendMap, uv);
            c = lerp(c, c * blend, _ColorBlendStrength);
            
            // Smoothness
            half smoothness = lerp(_ScleraSmoothness, _CorneaSmoothness, irisMask);

            // remap AO
            half ao = lerp(1.0, mask.g, _AOStrength);

            // Sclera Normal
            half3 scleraNormal = UnpackNormal(tex2D(_ScleraNormalMap, uv * _ScleraNormalTiling));
            // apply micro normal strength
            half detailMask = _ScleraNormalStrength * scleraMask;
            scleraNormal = half3(scleraNormal.xy * detailMask, lerp(1, scleraNormal.z, saturate(detailMask)));            

            // emission
            half3 emission = tex2D(_EmissionMap, uv) * _EmissiveColor;

            // outputs
            o.Albedo = c.rgb;
            o.Metallic = mask.r;
            o.Smoothness = smoothness;
            o.Occlusion = ao;
            o.Normal = scleraNormal;
            o.Alpha = 1.0;
            o.Emission = emission;
        }        
        ENDCG
    }
    FallBack "Diffuse"
}
