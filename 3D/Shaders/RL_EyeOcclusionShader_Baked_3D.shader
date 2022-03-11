Shader "Reallusion/RL_EyeOcclusionShader_Baked_3D"
{
    Properties 
    {
        // replicate standard shader inputs
        [NoScaleOffset] _MainTex("Albedo", 2D) = "white" {}        
        // vertex properties
        _ExpandOut("Expand Outward", Range(-0.001,0.001)) = 0 //0.0001
        _ExpandUpper("Expand Upper", Range(-0.001,0.001)) = 0
        _ExpandLower("Expand Lower", Range(-0.001,0.001)) = 0
        _ExpandInner("Expand Inner", Range(-0.001,0.001)) = 0
        _ExpandOuter("Expand Outer", Range(-0.001,0.001)) = 0
        _ExpandScale("Expand Scale", Range(1,100)) = 1.0
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
        LOD 100

        ZWrite Off
        Blend DstColor OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;            
            // vertex properties
            float _ExpandOut;
            float _ExpandUpper;
            float _ExpandLower;
            float _ExpandInner;
            float _ExpandOuter;
            float _ExpandScale;

            v2f vert (appdata v)
            {
                v2f o;
                float inner = v.uv.x * _ExpandInner;
                float outer = (1 - v.uv.x) * _ExpandOuter;
                float upper = v.uv.y * _ExpandUpper;
                float lower = (1 - v.uv.y) * _ExpandLower;
                float expand = (inner + outer + upper + lower + _ExpandOut) * _ExpandScale;

                o.vertex = UnityObjectToClipPos(v.vertex + (v.normal * expand));
                o.uv = v.uv;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
