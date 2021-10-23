Shader "Reallusion/RL_TearlineShader_3D"
{
    Properties
    {                
        _Alpha ("Alpha", Range(0,1)) = 0
        _Smoothness ("Smoothness", Range(0,1)) = 0.88
        _Metallic("Metallic", Range(0,1)) = 0

        _DepthOffset("Depth Offset", Range(-0.001,0.001)) = 0
        _InnerOffset("Inner Offset", Range(-0.001,0.001)) = 0.0005
        _Color("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
        LOD 200

        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows alpha:premul vertex:vert

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Alpha;
        half _Smoothness;
        half _Metallic;

        half _DepthOffset;
        half _InnerOffset;
        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)        

        void vert(inout appdata_full v)
        {
            float inner = (1 - smoothstep(0, 0.05, abs(v.texcoord.x - 0.5))) * _InnerOffset;
            float offset = inner + _DepthOffset;
            float4 vpos = float4(0, 0, 1, 0) * offset;
            v.vertex += vpos;
        }        

        void surf (Input IN, inout SurfaceOutputStandard o)
        {            
            fixed4 c = _Color * _Alpha;
            o.Albedo = c.rgb;            
            o.Metallic = _Metallic;
            o.Smoothness = _Smoothness;
            o.Alpha = _Alpha;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
