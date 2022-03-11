Shader "Reallusion/RL_TearlineShader_3D"
{
    Properties 
    {                
        // Occlusion alpha
        _Color("Color", Color) = (1,1,1,1)
        _Alpha ("Alpha", Range(0,1)) = 0
        _Smoothness ("Smoothness", Range(0,1)) = 0.88
        _Metallic("Metallic", Range(0,1)) = 0
        // Vertex Adjust
        _DepthOffset("Depth Offset", Range(-0.001,0.001)) = 0
        _InnerOffset("Inner Offset", Range(-0.001,0.001)) = 0.0005
        // Keywords            
        [Toggle]BOOLEAN_ZUP("Z Up", Float) = 0
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
        LOD 200

        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard alpha:premul vertex:vert finalcolor:NoFogColor
        #pragma multi_compile _ BOOLEAN_ZUP_ON
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
        half BOOLEAN_ZUP;

        void vert(inout appdata_full v)
        {
            float inner = (1 - smoothstep(0, 0.05, abs(v.texcoord.x - 0.5))) * _InnerOffset;
            float offset = (inner + _DepthOffset);            
#if BOOLEAN_ZUP_ON
            v.vertex.y -= offset;
#else
            v.vertex.z += offset;
#endif
        }    

        void NoFogColor(Input IN, SurfaceOutputStandard o, inout fixed4 color)
        {
            // Prevent fog from adding colour to the entirely transparent tearline material:
            // (otherwise the tearline becomes very visible through fog.)
            // by doing nothing here...
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
