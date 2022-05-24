Shader "Reallusion/RL_HairShader_2nd_Pass_Baked_3D"
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
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "ForceNoShadowCasting" = "True" }
        LOD 200

        // 2nd Pass, render remaining alpha blended hair (fade) around the first opaque pass
        // ZTest set to Less than, so that the opaque parts of each hair card will never be overdrawn. 
        // (Should be better performance)
        Blend SrcAlpha OneMinusSrcAlpha
        ZTest Less
        Cull Off
        ZWrite Off

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows alpha:fade
        #pragma multi_compile _ BOOLEAN_ENABLECOLOR_ON //_ENUMCLIPQUALITY_ON_STANDARD _ENUMCLIPQUALITY_ON_NOISE _ENUMCLIPQUALITY_ON_DITHER

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
        };


        half _BumpScale;
        fixed4 _EmissiveColor;
        // custom
        fixed4 _VertexBaseColor;
        fixed4 _Color;
        half _VertexColorStrength;        

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            float2 uv = IN.uv_MainTex;

            half4 metallicGloss = tex2D(_MetallicGlossMap, uv);
            half4 ao = tex2D(_OcclusionMap, uv);
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
        }
        ENDCG

    }
    FallBack "Diffuse"
}
