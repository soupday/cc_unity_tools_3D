Shader "Reallusion/RL_TeethShader_3D"
{
    Properties
    {
        _DiffuseMap("Diffuse Map", 2D) = "white" {}
        _MaskMap("Mask Map", 2D) = "gray" {}
        _NormalMap("Normal Map", 2D) = "bump" {}
        _MicroNormalMap("Micro Normal Map", 2D) = "bump" {}
        _GumsMaskMap("Gums Mask Map", 2D) = "white" {}
        _GradientAOMap("Gradient AO Map", 2D) = "white" {}
        _NormalStrength("Normal Strength", Range(0,2)) = 1
        _MicroNormalStrength("Micro Normal Strength", Range(0,2)) = 0.5
        _MicroNormalTiling("Micro Normal Tiling", Range(0,10)) = 4
        _AOStrength("Ambient Occlusion Strength", Range(0,1)) = 1
        _SmoothnessPower("Smoothness Power", Range(0.5,2)) = 0.5
        _SmoothnessFront("Smoothness Front", Range(0,1)) = 0
        _SmoothnessRear("Smoothness Rear", Range(0,1)) = 0
        _SmoothnessMax("Smoothness Max", Range(0,1)) = 0.88
        _GumsSaturation("Gums Saturation", Range(0,2)) = 1
        _GumsBrightness("Gums Brightness", Range(0,2)) = 0.9
        _TeethSaturation("Teeth Saturation", Range(0,2)) = 0.9
        _TeethBrightness("Teeth Brightness", Range(0,2)) = 0.7
        _FrontAO("Front AO", Range(0,1.5)) = 1
        _RearAO("Rear AO", Range(0,1.5)) = 0
        _GumsSSS("Tongue Subsurface Scatter", Range(0,1)) = 1
        _GumsThickness("Tongue Thickness", Range(0,1)) = 0.85
        _TeethSSS("Tongue Subsurface Scatter", Range(0,1)) = 0.5
        _TeethThickness("Tongue Thickness", Range(0,1)) = 0.7
        _EmissionMap("Emission Map", 2D) = "black" {}
        _EmissiveColor("Emissive Color", Color) = (0,0,0,0)
        [ToggleUI]_IsUpperTeeth("Is Upper Teeth", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _DiffuseMap;
        sampler2D _MaskMap;
        sampler2D _NormalMap;
        sampler2D _MicroNormalMap;
        sampler2D _GumsMaskMap;
        sampler2D _GradientAOMap;
        sampler2D _EmissionMap;

        struct Input
        {
            float2 uv_MainTex;
        };
        
        half _NormalStrength;
        half _MicroNormalStrength;
        half _MicroNormalTiling;
        half _AOStrength;
        half _SmoothnessPower;
        half _SmoothnessFront;
        half _SmoothnessRear;
        half _SmoothnessMax;
        half _GumsSaturation;
        half _GumsBrightness;
        half _TeethSaturation;
        half _TeethBrightness;
        half _FrontAO;
        half _RearAO;
        half _GumsSSS;
        half _GumsThickness;
        half _TeethSSS;
        half _TeethThickness;
        fixed4 _EmissiveColor;
        half _IsUpperTeeth;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {            
            fixed4 diffuse = tex2D(_DiffuseMap, IN.uv_MainTex);
            half4 gradientAO = tex2D(_GradientAOMap, IN.uv_MainTex);
            half4 gumsMask = tex2D(_GumsMaskMap, IN.uv_MainTex);
            half4 mask = tex2D(_MaskMap, IN.uv_MainTex);            
            half cavityMask = lerp(gradientAO.r, gradientAO.g, _IsUpperTeeth);

            // saturation & brightness
            half luma = dot(diffuse, half3(0.2126729, 0.7151522, 0.0721750));
            half3 teeth = (luma.xxx + _TeethSaturation.xxx * (diffuse - luma.xxx)) * _TeethBrightness;
            half3 gums = (luma.xxx + _GumsSaturation.xxx * (diffuse - luma.xxx)) * _GumsBrightness;
            half3 teethGums = lerp(gums, teeth, gumsMask.g);
            half3 c = lerp(teethGums * _RearAO, teethGums * _FrontAO, cavityMask);

            // remap AO
            half ao = lerp(1.0, mask.g, _AOStrength);

            // remap smoothness
            half smoothness = smoothness = lerp(_SmoothnessFront, _SmoothnessMax, mask.a);
            smoothness = lerp(_SmoothnessRear, smoothness, cavityMask);
            smoothness = pow(saturate(smoothness), _SmoothnessPower);            

            // normal
            half3 normal = UnpackNormal(tex2D(_NormalMap, IN.uv_MainTex));
            // apply normal strength
            normal = half3(normal.xy * _NormalStrength, lerp(1, normal.z, saturate(_NormalStrength)));
            // micro normal
            half3 microNormal = UnpackNormal(tex2D(_MicroNormalMap, IN.uv_MainTex * _MicroNormalTiling));
            // apply micro normal strength
            half detailMask = _MicroNormalStrength * mask.b;
            microNormal = half3(microNormal.xy * detailMask, lerp(1, microNormal.z, saturate(detailMask)));
            // combine normals
            normal = normalize(half3(normal.xy + microNormal.xy, normal.z * microNormal.z));

            // outputs
            o.Albedo = c.rgb * ao;
            o.Metallic = mask.r;
            o.Smoothness = smoothness;
            o.Normal = normal;
            o.Alpha = 1.0;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
