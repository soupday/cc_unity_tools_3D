Shader "Reallusion/RL_TongueShader_3D"
{
    Properties
    {
        [NoScaleOffset] _DiffuseMap("Diffuse Map", 2D) = "white" {}
        [NoScaleOffset]_MaskMap("Mask Map", 2D) = "gray" {}
        [NoScaleOffset]_NormalMap("Normal Map", 2D) = "bump" {}
        [NoScaleOffset]_MicroNormalMap("Micro Normal Map", 2D) = "bump" {}
        [NoScaleOffset]_GradientAOMap("Gradient AO Map", 2D) = "white" {}
        _NormalStrength("Normal Strength", Range(0,2)) = 1
        _MicroNormalStrength("Micro Normal Strength", Range(0,2)) = 0.5
        _MicroNormalTiling("Micro Normal Tiling", Range(0,10)) = 4
        _AOStrength("Ambient Occlusion Strength", Range(0,1)) = 1
        _SmoothnessPower("Smoothness Power", Range(0.5,2)) = 0.5
        _SmoothnessFront("Smoothness Front", Range(0,1)) = 0
        _SmoothnessRear("Smoothness Rear", Range(0,1)) = 0
        _SmoothnessMax("Smoothness Max", Range(0,1)) = 0.88
        _TongueSaturation("Tongue Saturation", Range(0,2)) = 0.95
        _TongueBrightness("Tongue Brightness", Range(0,2)) = 1
        _FrontAO("Front AO", Range(0,1.5)) = 1
        _RearAO("Rear AO", Range(0,1.5)) = 0
        _TongueSSS("Tongue Subsurface Scatter", Range(0,1)) = 1
        _TongueThickness("Tongue Thickness", Range(0,1)) = 0.75
        [NoScaleOffset]_EmissionMap("Emission Map", 2D) = "black" {}
        _EmissiveColor("Emissive Color", Color) = (0,0,0,0)
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
        sampler2D _GradientAOMap;
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
        half _SmoothnessFront;
        half _SmoothnessRear;
        half _SmoothnessMax;
        half _TongueSaturation;
        half _TongueBrightness;
        half _FrontAO;
        half _RearAO;
        half _TongueSSS;
        half _TongueThickness;
        fixed4 _EmissiveColor;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {        
            float2 uv = IN.uv_DiffuseMap;

            fixed4 diffuse = tex2D(_DiffuseMap, uv);
            half4 gradientAO = tex2D(_GradientAOMap, uv);
            half4 mask = tex2D(_MaskMap, uv);            
            half cavityMask = gradientAO.b;

            // saturation & brightness
            half luma = dot(diffuse, half3(0.2126729, 0.7151522, 0.0721750));
            half3 sat = (luma.xxx + _TongueSaturation.xxx * (diffuse - luma.xxx)) * _TongueBrightness;
            half3 c = lerp(sat * _RearAO, sat * _FrontAO, cavityMask);

            // remap AO
            half ao = lerp(1.0, mask.g, _AOStrength);

            // remap smoothness
            half smoothness = smoothness = lerp(_SmoothnessFront, _SmoothnessMax, mask.a);
            smoothness = lerp(_SmoothnessRear, smoothness, cavityMask);
            smoothness = pow(saturate(smoothness), _SmoothnessPower);            

            // normal
            half3 normal = UnpackNormal(tex2D(_NormalMap, uv));
            // apply normal strength
            normal = half3(normal.xy * _NormalStrength, lerp(1, normal.z, saturate(_NormalStrength)));
            // micro normal
            half3 microNormal = UnpackNormal(tex2D(_MicroNormalMap, uv * _MicroNormalTiling));
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
