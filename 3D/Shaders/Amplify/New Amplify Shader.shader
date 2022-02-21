// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "New Amplify Shader"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_BaseMap("Base Map", 2D) = "white" {}
		_MetallicGlossMap("Metallic Gloss Map", 2D) = "white" {}
		_VertexBaseColor("Vertex Base Color", Color) = (0,0,0,0)
		_VertexColorStrength("Vertex Color Strength", Range( 0 , 1)) = 0.5
		_GlossMapScale("Gloss Map Scale", Range( 0 , 1)) = 1
		_BumpMap("Bump Map", 2D) = "bump" {}
		_BumpScale("Bump Scale", Range( 0 , 2)) = 1
		_OcclusionMap("Occlusion Map", 2D) = "white" {}
		_AlphaClip2("Alpha Clip", Range( 0 , 1)) = 0.15
		_OcclusionStrength("Occlusion Strength", Range( 0 , 1)) = 1
		_EmissionMap("Emission Map", 2D) = "white" {}
		[HDR]_EmissiveColor("Emissive Color", Color) = (0,0,0,0)
		_AOOccludeAll("AO Occlude All", Range( 0 , 1)) = 0
		_IDMap("ID Map", 2D) = "gray" {}
		_FlowMap("Flow Map", 2D) = "gray" {}
		[Toggle]_FlowMapFlipGreen("Flow Map Flip Green", Float) = 0
		_RimPower("Rim Hardness", Range( 1 , 10)) = 4
		_RimTransmissionIntensity("Rim Transmission Intensity", Range( 0 , 20)) = 10
		_SpecularTint("Specular Tint", Color) = (1,1,1,0)
		_SpecularMultiplier("Specular Strength", Range( 0 , 2)) = 1
		_SpecularPowerScale("Specular Smoothness", Range( 0 , 5)) = 2
		_SpecularMix("Specular Mix", Range( 0.5 , 1)) = 1
		_SpecularShiftMin("Specular Shift Min", Range( -1 , 1)) = -0.25
		_SpecularShiftMax("Specular Shift Max", Range( -1 , 1)) = 0.25
		_Translucency("Translucency", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
		#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
			float3 worldPos;
			float4 vertexColor : COLOR;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform sampler2D _FlowMap;
		uniform float4 _FlowMap_ST;
		uniform float _FlowMapFlipGreen;
		uniform sampler2D _BumpMap;
		uniform float4 _BumpMap_ST;
		uniform float _BumpScale;
		uniform float _SpecularShiftMin;
		uniform float _SpecularShiftMax;
		uniform sampler2D _IDMap;
		uniform float4 _IDMap_ST;
		uniform sampler2D _MetallicGlossMap;
		uniform float4 _MetallicGlossMap_ST;
		uniform float _GlossMapScale;
		uniform float _SpecularPowerScale;
		uniform float _SpecularMultiplier;
		uniform float _Translucency;
		uniform float4 _SpecularTint;
		uniform sampler2D _BaseMap;
		uniform float4 _BaseMap_ST;
		uniform float4 _VertexBaseColor;
		uniform float _VertexColorStrength;
		uniform float _SpecularMix;
		uniform float _RimPower;
		uniform float _RimTransmissionIntensity;
		uniform float _OcclusionStrength;
		uniform sampler2D _OcclusionMap;
		uniform float4 _OcclusionMap_ST;
		uniform float _AOOccludeAll;
		uniform sampler2D _EmissionMap;
		uniform float4 _EmissionMap_ST;
		uniform float4 _EmissiveColor;
		uniform float _AlphaClip2;
		uniform float _Cutoff = 0.5;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float2 uv_BaseMap = i.uv_texcoord * _BaseMap_ST.xy + _BaseMap_ST.zw;
			float4 tex2DNode11 = tex2D( _BaseMap, uv_BaseMap );
			float alpha53 = tex2DNode11.a;
			c.rgb = 0;
			c.a = alpha53;
			clip( _AlphaClip2 - _Cutoff );
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
			float2 uv_FlowMap = i.uv_texcoord * _FlowMap_ST.xy + _FlowMap_ST.zw;
			float4 break109_g849 = tex2D( _FlowMap, uv_FlowMap );
			float lerpResult123_g849 = lerp( break109_g849.g , ( 1.0 - break109_g849.g ) , _FlowMapFlipGreen);
			float3 appendResult98_g849 = (float3(break109_g849.r , lerpResult123_g849 , break109_g849.b));
			float3 flowTangent107_g849 = (WorldNormalVector( i , ( ( appendResult98_g849 * float3( 2,2,2 ) ) - float3( 1,1,1 ) ) ));
			float2 uv_BumpMap = i.uv_texcoord * _BumpMap_ST.xy + _BumpMap_ST.zw;
			float3 normal32 = UnpackScaleNormal( tex2D( _BumpMap, uv_BumpMap ), _BumpScale );
			float3 worldNormal86_g849 = normalize( (WorldNormalVector( i , normal32 )) );
			float2 uv_IDMap = i.uv_texcoord * _IDMap_ST.xy + _IDMap_ST.zw;
			float idMap28 = tex2D( _IDMap, uv_IDMap ).r;
			float lerpResult81_g849 = lerp( _SpecularShiftMin , _SpecularShiftMax , idMap28);
			float3 normalizeResult10_g850 = normalize( ( flowTangent107_g849 + ( worldNormal86_g849 * lerpResult81_g849 ) ) );
			float3 shiftedTangent119_g849 = normalizeResult10_g850;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 viewDIr52_g851 = ase_worldViewDir;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 lightDir55_g851 = ase_worldlightDir;
			float3 normalizeResult14_g852 = normalize( ( viewDIr52_g851 + lightDir55_g851 ) );
			float dotResult16_g852 = dot( shiftedTangent119_g849 , normalizeResult14_g852 );
			float smoothstepResult22_g852 = smoothstep( -1.0 , 0.0 , dotResult16_g852);
			float2 uv_MetallicGlossMap = i.uv_texcoord * _MetallicGlossMap_ST.xy + _MetallicGlossMap_ST.zw;
			float smoothness27 = ( tex2D( _MetallicGlossMap, uv_MetallicGlossMap ).a * _GlossMapScale );
			float temp_output_233_0_g849 = max( ( 1.0 - smoothness27 ) , 0.001 );
			float specularPower237_g849 = ( max( ( ( 2.0 / ( temp_output_233_0_g849 * temp_output_233_0_g849 ) ) - 2.0 ) , 0.001 ) * _SpecularPowerScale );
			float3 temp_output_24_0_g851 = worldNormal86_g849;
			float dotResult15_g851 = dot( lightDir55_g851 , temp_output_24_0_g851 );
			float temp_output_40_0_g851 = _Translucency;
			float temp_output_6_0_g851 = saturate( ( ( dotResult15_g851 * ( 1.0 - temp_output_40_0_g851 ) ) + temp_output_40_0_g851 ) );
			float wrappedLambert74_g851 = temp_output_6_0_g851;
			float4 temp_output_13_0_g851 = ( ( smoothstepResult22_g852 * pow( saturate( ( 1.0 - ( dotResult16_g852 * dotResult16_g852 ) ) ) , specularPower237_g849 ) ) * _SpecularMultiplier * wrappedLambert74_g851 * _SpecularTint );
			float2 uv_BaseMap = i.uv_texcoord * _BaseMap_ST.xy + _BaseMap_ST.zw;
			float4 tex2DNode11 = tex2D( _BaseMap, uv_BaseMap );
			float4 lerpResult21 = lerp( tex2DNode11 , _VertexBaseColor , ( ( 1.0 - i.vertexColor.r ) * _VertexColorStrength ));
			float4 baseColor31 = lerpResult21;
			float4 temp_output_42_0_g849 = baseColor31;
			float4 temp_output_32_0_g851 = temp_output_42_0_g849;
			float4 lerpResult36_g851 = lerp( temp_output_13_0_g851 , ( temp_output_13_0_g851 * temp_output_32_0_g851 ) , _SpecularMix);
			float dotResult54_g851 = dot( temp_output_24_0_g851 , viewDIr52_g851 );
			float dotResult57_g851 = dot( viewDIr52_g851 , lightDir55_g851 );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 temp_output_262_0_g849 = ( 1 * ( ( lerpResult36_g851 + ( ( temp_output_6_0_g851 + ( pow( ( max( ( 1.0 - abs( dotResult54_g851 ) ) , 0.0 ) * max( ( 0.0 - dotResult57_g851 ) , 0.0 ) ) , _RimPower ) * _RimTransmissionIntensity * wrappedLambert74_g851 ) ) * temp_output_32_0_g851 ) ) * ase_lightColor ) );
			float2 uv_OcclusionMap = i.uv_texcoord * _OcclusionMap_ST.xy + _OcclusionMap_ST.zw;
			float ambientOcclusion33 = ( 1.0 - ( _OcclusionStrength * ( 1.0 - tex2D( _OcclusionMap, uv_OcclusionMap ).g ) ) );
			float temp_output_161_0_g849 = ambientOcclusion33;
			float temp_output_178_0_g849 = _AOOccludeAll;
			float lerpResult180_g849 = lerp( temp_output_161_0_g849 , 1.0 , temp_output_178_0_g849);
			#ifdef UNITY_PASS_FORWARDBASE
				float4 staticSwitch250_g849 = ( temp_output_262_0_g849 + ( float4( float3(0,0,0) , 0.0 ) * temp_output_42_0_g849 * lerpResult180_g849 ) );
			#else
				float4 staticSwitch250_g849 = temp_output_262_0_g849;
			#endif
			float lerpResult183_g849 = lerp( 1.0 , temp_output_161_0_g849 , temp_output_178_0_g849);
			float2 uv_EmissionMap = i.uv_texcoord * _EmissionMap_ST.xy + _EmissionMap_ST.zw;
			o.Albedo = ( ( staticSwitch250_g849 * lerpResult183_g849 ) + ( tex2D( _EmissionMap, uv_EmissionMap ) * _EmissiveColor ) ).rgb;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				half4 color : COLOR0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.color = v.color;
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				surfIN.vertexColor = IN.color;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT( UnityGI, gi );
				o.Alpha = LightingStandardCustomLighting( o, worldViewDir, gi ).a;
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
1920;0;1920;1029;1105.353;179.2701;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;1;-3047.901,-1576.299;Inherit;False;1295.191;809.48;;10;53;31;21;19;18;13;11;8;7;4;Final Color Blending;0.514151,1,0.6056049,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;2;-3011.393,1048.663;Inherit;False;1268.577;322.7186;Comment;6;33;20;17;6;5;3;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;3;-2961.393,1127.382;Inherit;True;Property;_OcclusionMap;Occlusion Map;8;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;4;-2984.11,-998.0835;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;5;-2575.817,1245.663;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-2648.816,1098.663;Inherit;False;Property;_OcclusionStrength;Occlusion Strength;10;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;7;-2719.391,-992.0551;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-2782.322,-890.6404;Inherit;False;Property;_VertexColorStrength;Vertex Color Strength;4;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;9;-2717.643,-687.631;Inherit;False;961.1769;381.4063;Comment;3;32;22;12;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;10;-2546.055,480.0186;Inherit;False;797.2819;513.1732;Comment;4;27;24;16;15;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;11;-2986.76,-1416.37;Inherit;True;Property;_BaseMap;Base Map;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;14;-3225.919,-0.648391;Inherit;False;680.6748;262.7862;;2;28;23;Maps;0.504717,0.9903985,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;19;-2499.167,-1158.638;Inherit;False;Property;_VertexBaseColor;Vertex Base Color;3;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-2463.834,-950.3407;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-2345.817,1145.663;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;16;-2496.056,629.0997;Inherit;True;Property;_MetallicGlossMap;Metallic Gloss Map;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;12;-2651.094,-505.0248;Inherit;False;Property;_BumpScale;Bump Scale;7;0;Create;True;0;0;0;False;0;False;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;13;-2435.278,-1332.489;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-2475.053,842.1918;Inherit;False;Property;_GlossMapScale;Gloss Map Scale;5;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-2115.773,733.0107;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;20;-2181.817,1148.663;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;21;-2172.412,-1176.947;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;22;-2328.155,-557.6083;Inherit;True;Property;_BumpMap;Bump Map;6;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;23;-3175.919,49.35156;Inherit;True;Property;_IDMap;ID Map;14;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;25;-2369.853,-90.16242;Inherit;False;622.4177;474.6811;Comment;3;37;30;29;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;32;-1975.74,-533.0707;Inherit;False;normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;29;-2237.339,172.5185;Inherit;False;Property;_EmissiveColor;Emissive Color;12;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;31;-1965.561,-1182.22;Inherit;False;baseColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;33;-1975.762,1147.368;Inherit;False;ambientOcclusion;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;30;-2319.854,-40.16243;Inherit;True;Property;_EmissionMap;Emission Map;11;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;27;-1945.497,730.6877;Inherit;False;smoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;28;-2753.791,125.6755;Inherit;False;idMap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;26;-1597.796,-1582.127;Inherit;False;1085.333;1589.565;;18;55;51;50;49;48;47;46;45;44;43;42;41;40;39;38;36;35;34;Specular Highlights;1,0.7932334,0.514151,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-1519.894,-333.8549;Inherit;False;Property;_SpecularShiftMax;Specular Shift Max;24;0;Create;True;0;0;0;False;0;False;0.25;0.25;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;50;-1432.794,-1532.127;Inherit;False;31;baseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-1522.217,-409.387;Inherit;False;Property;_SpecularShiftMin;Specular Shift Min;23;0;Create;True;0;0;0;False;0;False;-0.25;-0.25;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;48;-1517.506,-257.8105;Inherit;False;Property;_Translucency;Translucency;25;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-1529.766,-981.0684;Inherit;False;Property;_SpecularMix;Specular Mix;22;0;Create;True;0;0;0;False;0;False;1;1;0.5;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-1464.719,-561.8005;Inherit;False;Property;_FlowMapFlipGreen;Flow Map Flip Green;16;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;45;-1440.892,-1056.407;Inherit;False;27;smoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-1516.708,-182.3371;Inherit;False;Property;_RimTransmissionIntensity;Rim Transmission Intensity;18;0;Create;True;0;0;0;False;0;False;10;10;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;42;-1420.442,-485.8;Inherit;False;28;idMap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-1514.421,-107.6343;Inherit;False;Property;_RimPower;Rim Hardness;17;0;Create;False;0;0;0;False;0;False;4;4;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-1527.991,-903.7338;Inherit;False;Property;_SpecularMultiplier;Specular Strength;20;0;Create;False;0;0;0;False;0;False;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;39;-1428.964,-1306.937;Inherit;False;32;normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;38;-1475.145,-1458.431;Inherit;False;33;ambientOcclusion;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-1909.436,89.55952;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;36;-1527.537,-826.2022;Inherit;False;Property;_SpecularPowerScale;Specular Smoothness;21;0;Create;False;0;0;0;False;0;False;2;2;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-1532.662,-1381.092;Inherit;False;Property;_AOOccludeAll;AO Occlude All;13;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;34;-1466.294,-1230.135;Inherit;False;Property;_SpecularTint;Specular Tint;19;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;41;-1547.096,-751.2152;Inherit;True;Property;_FlowMap;Flow Map;15;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;54;-475.7498,179.9536;Inherit;False;350.3223;276.6241;;2;57;56;Alpha;1,1,1,1;0;0
Node;AmplifyShaderEditor.WireNode;52;-1580.127,55.50757;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;53;-2613.947,-1248.499;Inherit;False;alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;55;-949.0427,-1171.524;Inherit;False;RL_Amplify_Function_Hair_AnisotropicLighting;-1;;849;1c2ce0d33e6d0364e94912a58b37cdd2;1,88,0;18;42;COLOR;1,1,1,0;False;161;FLOAT;1;False;178;FLOAT;1;False;84;FLOAT3;0,0,1;False;26;FLOAT3;0,0,1;False;131;COLOR;1,1,1,0;False;7;FLOAT;50;False;172;FLOAT;0;False;132;FLOAT;1;False;245;FLOAT;2;False;108;COLOR;0,0,0,0;False;112;FLOAT;0;False;71;FLOAT;0.5;False;75;FLOAT;-0.1;False;80;FLOAT;0.1;False;200;FLOAT;0;False;207;FLOAT;0;False;208;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-421.2682,344.5627;Inherit;False;Property;_AlphaClip2;Alpha Clip;9;0;Create;False;0;0;0;False;0;False;0.15;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;58;-199.3492,-7.835402;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;57;-313.9048,257.9516;Inherit;False;53;alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;New Amplify Shader;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;False;Opaque;;AlphaTest;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;5;0;3;2
WireConnection;7;0;4;1
WireConnection;18;0;7;0
WireConnection;18;1;8;0
WireConnection;17;0;6;0
WireConnection;17;1;5;0
WireConnection;13;0;11;0
WireConnection;24;0;16;4
WireConnection;24;1;15;0
WireConnection;20;0;17;0
WireConnection;21;0;13;0
WireConnection;21;1;19;0
WireConnection;21;2;18;0
WireConnection;22;5;12;0
WireConnection;32;0;22;0
WireConnection;31;0;21;0
WireConnection;33;0;20;0
WireConnection;27;0;24;0
WireConnection;28;0;23;1
WireConnection;37;0;30;0
WireConnection;37;1;29;0
WireConnection;52;0;37;0
WireConnection;53;0;11;4
WireConnection;55;42;50;0
WireConnection;55;161;38;0
WireConnection;55;178;35;0
WireConnection;55;84;39;0
WireConnection;55;131;34;0
WireConnection;55;7;45;0
WireConnection;55;172;47;0
WireConnection;55;132;40;0
WireConnection;55;245;36;0
WireConnection;55;108;41;0
WireConnection;55;112;46;0
WireConnection;55;71;42;0
WireConnection;55;75;49;0
WireConnection;55;80;51;0
WireConnection;55;200;48;0
WireConnection;55;207;44;0
WireConnection;55;208;43;0
WireConnection;58;0;55;0
WireConnection;58;1;52;0
WireConnection;0;0;58;0
WireConnection;0;9;57;0
WireConnection;0;10;56;0
ASEEND*/
//CHKSM=13110C7B526ADB5604674E2C87CD800661E41393