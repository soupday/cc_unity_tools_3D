Shader "Reallusion/RL_EyeOcclusionShader_3D"
{
    Properties
    {
        _OcclusionColor("Occlusion Color", Color) = (0.3294118,0.09411765,0.05490196,1)
        _OcclusionStrength("Occlusion Strength", Range(0,2)) = 0.2
        _OcclusionPower("Occlusion Power", Range(0.1,4)) = 1.5
        _TopMin("Top Min", Range(0,1)) = 0.1
        _TopMax("Top Max", Range(0,1)) = 1
        _TopCurve("Top Curve", Range(0,2)) = 1.287
        _BottomMin("Bottom Min", Range(0,1)) = 0.05
        _BottomMax("Bottom Max", Range(0,1)) = 0.3
        _BottomCurve("Bottom Curve", Range(0,2)) = 2
        _InnerMin("Inner Min", Range(0,1)) = 0.25
        _InnerMax("Inner Max", Range(0,1)) = 0.5
        _OuterMin("Outer Min", Range(0,1)) = 0.2
        _OuterMax("Outer Max", Range(0,1)) = 0.5
        _OcclusionStrength2("Occlusion Strenth 2", Range(0,2)) = 0.45
        _Top2Min("Top 2 Min", Range(0,1)) = 0.15
        _Top2Max("Top 2 Max", Range(0,1)) = 1
        _TearDuctPosition("Tear Duct Position", Range(0,1)) = 0.8
        _TearDuctWidth("Tear Duct Width", Range(0,1)) = 0.5
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

            fixed4 _OcclusionColor;
            half  _OcclusionStrength;
            half _OcclusionPower;
            half _TopMin;
            half _TopMax;
            half _TopCurve;
            half _BottomMin;
            half _BottomMax;
            half _BottomCurve;
            half _InnerMin;
            half _InnerMax;
            half _OuterMin;
            half _OuterMax;
            half _OcclusionStrength2;
            half _Top2Min;
            half _Top2Max;
            half _TearDuctPosition;
            half _TearDuctWidth;
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

            half EyeOcclusionGradient(float2 uv)
            {
                half x = uv.x;
                half y = uv.y;
                half right = smoothstep(_InnerMin, _InnerMax, 1 - x);
                half left = smoothstep(_OuterMin, _OuterMax, x);
                half top = pow(smoothstep(_TopMin, _TopMax, 1 - y), _TopCurve);
                half bottom = pow(smoothstep(_BottomMin, _BottomMax, y), _BottomCurve);
                half alpha1 = saturate((1.0 - saturate(8.0 * right * left * top * bottom)) * _OcclusionStrength);
                half alpha2 = saturate(smoothstep(_Top2Min, _Top2Max, y) * _OcclusionStrength2);
                half edge2 = ((1.0 - _TearDuctPosition) * _TearDuctWidth) + _TearDuctPosition;
                half tearDuctMask = (1.0 - smoothstep(_TearDuctPosition, edge2, x));
                return pow(max(alpha1, alpha2) * tearDuctMask, _OcclusionPower);
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // sample the texture
                half a = EyeOcclusionGradient(i.uv);
                fixed4 col = _OcclusionColor * a;
                col.a = a;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
