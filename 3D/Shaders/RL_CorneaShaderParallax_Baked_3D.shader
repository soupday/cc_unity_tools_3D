Shader "Reallusion/RL_CorneaShaderParallax_Baked_3D"
{
    Properties 
    {
        // replicate standard shader inputs
        [NoScaleOffset]_MainTex("Albedo", 2D) = "white" {}
        [NoScaleOffset]_MetallicGlossMap("Metallic", 2D) = "gray" {}                // metallic(rgb), smoothness(a)
        [NoScaleOffset]_BumpMap("Normal", 2D) = "bunp" {}
        _BumpScale("Normal Scale", Range(0, 2)) = 1
        [NoScaleOffset]_OcclusionMap("Occlusion", 2D) = "white" {}
        _OcclusionStrength("Occlusion Strength", Range(0, 1)) = 1
        [NoScaleOffset]_DetailMask("Detail Mask (A)", 2D) = "gray" {}               // eye blend mask(r), pupil scale mask(g), parallax height mask(b), iris mask(a)
        _DetailAlbedoMap("Detail Albedo Map", 2D) = "grey" {}
        _DetailNormalMap("Detail Normal Map", 2D) = "bump" {}
        _DetailNormalMapScale("Detail Normal Scale", Range(0, 2)) = 0.5
        [NoScaleOffset]_EmissionMap("Emission Map", 2D) = "white" {}
        [HDR]_EmissiveColor("Emissive Color", Color) = (0,0,0)
        // custom shader
        _PupilScale("Pupil Scale", Range(0.1,2)) = 0.8
        _IrisDepth("Iris Depth", Range(0.1,1)) = 0.225
        _IOR("IOR", Range(1,2)) = 1.4        
        _PMod("Parallax Mod", Range(0,10)) = 6.2717        
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

        sampler2D _MainTex;
        sampler2D _MetallicGlossMap;
        sampler2D _BumpMap;
        sampler2D _OcclusionMap;
        sampler2D _DetailMask;
        sampler2D _DetailAlbedoMap;
        sampler2D _DetailNormalMap;
        sampler2D _EmissionMap;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_DetailNormalMap;
            float3 viewDir;
        };
        
         
        half _BumpScale;
        half _OcclusionStrength;
        half _DetailNormalMapScale;
        half3 _EmissiveColor;
        half _PupilScale;  
        half _IOR;
        half _PMod;        
        half _IrisDepth;

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float2 uv = IN.uv_MainTex;

            half4 metallicGloss = tex2D(_MetallicGlossMap, uv);
            half4 detail = tex2D(_DetailMask, uv); 
            half4 ao = lerp(1.0, tex2D(_OcclusionMap, uv), _OcclusionStrength);

            half tiling = 1.0 / lerp(1, _PupilScale, detail.g);
            half offset = half2(0.5, 0.5) * (1 - tiling);
            half2 pupilUV = uv * tiling + offset;

            // parallax mapping            
            half3 Vr = normalize(o.Normal * (_IOR - 0.6) + IN.viewDir);
            half parallaxTiling = 1.0 / ((_IrisDepth * _PMod) + 0.8711572);
            half parallaxOffset = 0.5 * (1.0 - parallaxTiling);
            half2 parallaxUV = (pupilUV - (half2(Vr.xy) * _IrisDepth)) * parallaxTiling + parallaxOffset;
            half2 corneaUV = lerp(pupilUV, parallaxUV, detail.b);

            half4 sclera = tex2D(_MainTex, uv);
            half4 cornea = tex2D(_MainTex, corneaUV);
            half4 color = lerp(sclera, cornea, detail.r);

            //half4 color = tex2D(_MainTex, lerp(uv, corneaUV, detail.r));

            // normal
            half3 normal = UnpackNormal(tex2D(_DetailNormalMap, IN.uv_DetailNormalMap));
            // apply normal strength
            half normalStrength = detail.a * _DetailNormalMapScale;
            normal = half3(normal.xy * normalStrength, lerp(1, normal.z, saturate(normalStrength)));
            
            // emission
            half3 emission = tex2D(_EmissionMap, uv) * _EmissiveColor;

            // outputs
            o.Albedo = color.rgb;
            o.Metallic = metallicGloss.g;
            o.Smoothness = metallicGloss.a;
            o.Occlusion = ao.g;
            o.Normal = normal;
            o.Alpha = color.a;
            o.Emission = emission;
        }        
        ENDCG
    }
    FallBack "Diffuse"
}
