// Made with Amplify Shader Editor v1.9.1.8
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Reallusion/Amplify/RL_HairShader_Coverge_Baked_3D_Tessellation"
{
	Properties
	{
		_EdgeLength ( "Edge length", Range( 2, 50 ) ) = 15
		_TessPhongStrength( "Phong Tess Strength", Range( 0, 1 ) ) = 0.5
		_MainTex("Main Tex", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,0)
		_MetallicGlossMap("Metallic Gloss Map", 2D) = "white" {}
		_VertexBaseColor("Vertex Base Color", Color) = (0,0,0,0)
		_VertexColorStrength("Vertex Color Strength", Range( 0 , 1)) = 0.5
		_GlossMapScale("Gloss Map Scale", Range( 0 , 1)) = 1
		_BumpMap("Bump Map", 2D) = "bump" {}
		_BumpScale("Bump Scale", Range( 0 , 2)) = 1
		_OcclusionMap("Occlusion Map", 2D) = "white" {}
		_OcclusionStrength("Occlusion Strength", Range( 0 , 1)) = 1
		_EmissionMap("Emission Map", 2D) = "white" {}
		[HDR]_EmissionColor("Emission Color", Color) = (0,0,0,0)
		_AOOccludeAll("AO Occlude All", Range( 0 , 1)) = 0
		_IDMap("ID Map", 2D) = "gray" {}
		_FlowMap("Flow Map", 2D) = "gray" {}
		[Toggle]_FlowMapFlipGreen("Flow Map Flip Green", Float) = 0
		_RimPower("Rim Hardness", Range( 1 , 10)) = 4
		_RimTransmissionIntensity("Rim Transmission Intensity", Range( 0 , 75)) = 10
		_SpecularTint("Specular Tint", Color) = (1,1,1,0)
		_SpecularMultiplier("Specular Strength", Range( 0 , 2)) = 1
		_SpecularPowerScale("Specular Smoothness", Range( 0 , 10)) = 2
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
		Cull Off
		AlphaToMask On
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Tessellation.cginc"
		#include "Lighting.cginc"
		#pragma target 4.6
		#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
		#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
		#define ASE_USING_SAMPLING_MACROS 1
		#if defined(SHADER_API_D3D11) || defined(SHADER_API_XBOXONE) || defined(UNITY_COMPILER_HLSLCC) || defined(SHADER_API_PSSL) || (defined(SHADER_TARGET_SURFACE_ANALYSIS) && !defined(SHADER_TARGET_SURFACE_ANALYSIS_MOJOSHADER))//ASE Sampler Macros
		#define SAMPLE_TEXTURE2D(tex,samplerTex,coord) tex.Sample(samplerTex,coord)
		#else//ASE Sampling Macros
		#define SAMPLE_TEXTURE2D(tex,samplerTex,coord) tex2D(tex,coord)
		#endif//ASE Sampling Macros

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
			float2 uv_texcoord;
			half3 worldNormal;
			INTERNAL_DATA
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

		UNITY_DECLARE_TEX2D_NOSAMPLER(_MainTex);
		uniform half4 _MainTex_ST;
		SamplerState sampler_MainTex;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_FlowMap);
		uniform half4 _FlowMap_ST;
		uniform half _FlowMapFlipGreen;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_BumpMap);
		uniform half4 _BumpMap_ST;
		SamplerState sampler_BumpMap;
		uniform half _BumpScale;
		uniform half _SpecularShiftMin;
		uniform half _SpecularShiftMax;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_IDMap);
		uniform half4 _IDMap_ST;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_MetallicGlossMap);
		uniform half4 _MetallicGlossMap_ST;
		SamplerState sampler_MetallicGlossMap;
		uniform half _GlossMapScale;
		uniform half _SpecularPowerScale;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_OcclusionMap);
		uniform half4 _OcclusionMap_ST;
		SamplerState sampler_OcclusionMap;
		uniform half _SpecularMultiplier;
		uniform half _Translucency;
		uniform half4 _SpecularTint;
		uniform half4 _Color;
		uniform half4 _VertexBaseColor;
		uniform half _VertexColorStrength;
		uniform half _SpecularMix;
		uniform half _RimPower;
		uniform half _RimTransmissionIntensity;
		uniform half _OcclusionStrength;
		uniform half _AOOccludeAll;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_EmissionMap);
		uniform half4 _EmissionMap_ST;
		SamplerState sampler_EmissionMap;
		uniform half4 _EmissionColor;
		uniform float _EdgeLength;
		uniform float _TessPhongStrength;

		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			return UnityEdgeLengthBasedTess (v0.vertex, v1.vertex, v2.vertex, _EdgeLength);
		}

		void vertexDataFunc( inout appdata_full v )
		{
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			half4 tex2DNode19 = SAMPLE_TEXTURE2D( _MainTex, sampler_MainTex, uv_MainTex );
			half alpha518 = tex2DNode19.a;
			half temp_output_645_0 = alpha518;
			float2 uv_FlowMap = i.uv_texcoord * _FlowMap_ST.xy + _FlowMap_ST.zw;
			half4 break109_g857 = SAMPLE_TEXTURE2D( _FlowMap, sampler_MainTex, uv_FlowMap );
			half lerpResult123_g857 = lerp( break109_g857.g , ( 1.0 - break109_g857.g ) , _FlowMapFlipGreen);
			half3 appendResult98_g857 = (half3(break109_g857.r , lerpResult123_g857 , break109_g857.b));
			half3 flowTangent107_g857 = (WorldNormalVector( i , ( ( appendResult98_g857 * float3( 2,2,2 ) ) - float3( 1,1,1 ) ) ));
			float2 uv_BumpMap = i.uv_texcoord * _BumpMap_ST.xy + _BumpMap_ST.zw;
			half3 normal282 = UnpackScaleNormal( SAMPLE_TEXTURE2D( _BumpMap, sampler_BumpMap, uv_BumpMap ), _BumpScale );
			half3 worldNormal86_g857 = normalize( (WorldNormalVector( i , normal282 )) );
			float2 uv_IDMap = i.uv_texcoord * _IDMap_ST.xy + _IDMap_ST.zw;
			half idMap383 = SAMPLE_TEXTURE2D( _IDMap, sampler_MainTex, uv_IDMap ).r;
			half lerpResult81_g857 = lerp( _SpecularShiftMin , _SpecularShiftMax , idMap383);
			half3 normalizeResult10_g860 = normalize( ( flowTangent107_g857 + ( worldNormal86_g857 * lerpResult81_g857 ) ) );
			half3 shiftedTangent119_g857 = normalizeResult10_g860;
			float3 ase_worldPos = i.worldPos;
			half3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			half3 viewDIr52_g858 = ase_worldViewDir;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			half3 ase_worldlightDir = 0;
			#else //aseld
			half3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			half3 worldLight272_g857 = ase_worldlightDir;
			half3 lightDIr80_g858 = worldLight272_g857;
			half3 normalizeResult14_g859 = normalize( ( viewDIr52_g858 + lightDIr80_g858 ) );
			half dotResult16_g859 = dot( shiftedTangent119_g857 , normalizeResult14_g859 );
			half smoothstepResult22_g859 = smoothstep( -1.0 , 0.0 , dotResult16_g859);
			float2 uv_MetallicGlossMap = i.uv_texcoord * _MetallicGlossMap_ST.xy + _MetallicGlossMap_ST.zw;
			half smoothness643 = ( SAMPLE_TEXTURE2D( _MetallicGlossMap, sampler_MetallicGlossMap, uv_MetallicGlossMap ).a * _GlossMapScale );
			half temp_output_233_0_g857 = max( ( 1.0 - smoothness643 ) , 0.001 );
			half specularPower237_g857 = ( max( ( ( 2.0 / ( temp_output_233_0_g857 * temp_output_233_0_g857 ) ) - 2.0 ) , 0.001 ) * _SpecularPowerScale );
			float2 uv_OcclusionMap = i.uv_texcoord * _OcclusionMap_ST.xy + _OcclusionMap_ST.zw;
			half4 tex2DNode617 = SAMPLE_TEXTURE2D( _OcclusionMap, sampler_OcclusionMap, uv_OcclusionMap );
			half specularMask652 = tex2DNode617.a;
			half dotResult266_g857 = dot( normalize( (WorldNormalVector( i , normal282 )) ) , worldLight272_g857 );
			half translucencyWrap283_g857 = _Translucency;
			half lambertMask290_g857 = saturate( ( ( dotResult266_g857 * ( 1.0 - translucencyWrap283_g857 ) ) + translucencyWrap283_g857 ) );
			half temp_output_84_0_g858 = lambertMask290_g857;
			half4 temp_output_13_0_g858 = ( ( smoothstepResult22_g859 * pow( saturate( ( 1.0 - ( dotResult16_g859 * dotResult16_g859 ) ) ) , specularPower237_g857 ) ) * ( specularMask652 * _SpecularMultiplier ) * temp_output_84_0_g858 * _SpecularTint * alpha518 );
			half4 lerpResult112 = lerp( tex2DNode19 , _VertexBaseColor , ( ( 1.0 - i.vertexColor.r ) * _VertexColorStrength ));
			half4 baseColor331 = ( _Color * lerpResult112 );
			half4 temp_output_42_0_g857 = baseColor331;
			half4 temp_output_32_0_g858 = temp_output_42_0_g857;
			half4 lerpResult36_g858 = lerp( temp_output_13_0_g858 , ( temp_output_13_0_g858 * temp_output_32_0_g858 ) , _SpecularMix);
			half3 temp_output_24_0_g858 = worldNormal86_g857;
			half dotResult82_g858 = dot( lightDIr80_g858 , temp_output_24_0_g858 );
			half temp_output_40_0_g858 = translucencyWrap283_g857;
			half dotResult54_g858 = dot( temp_output_24_0_g858 , viewDIr52_g858 );
			half dotResult57_g858 = dot( viewDIr52_g858 , lightDIr80_g858 );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			half4 ase_lightColor = 0;
			#else //aselc
			half4 ase_lightColor = _LightColor0;
			#endif //aselc
			half lerpResult660 = lerp( 1.0 , tex2DNode617.g , _OcclusionStrength);
			half ambientOcclusion570 = lerpResult660;
			half temp_output_161_0_g857 = ambientOcclusion570;
			half lerpResult183_g857 = lerp( 1.0 , temp_output_161_0_g857 , _AOOccludeAll);
			half4 temp_output_182_0_g857 = ( ( ( lerpResult36_g858 + ( ( saturate( ( ( dotResult82_g858 * ( 1.0 - temp_output_40_0_g858 ) ) + temp_output_40_0_g858 ) ) + ( pow( ( max( ( 1.0 - abs( dotResult54_g858 ) ) , 0.0 ) * max( ( 0.0 - dotResult57_g858 ) , 0.0 ) ) , _RimPower ) * _RimTransmissionIntensity * temp_output_84_0_g858 ) ) * temp_output_32_0_g858 ) ) * ase_lightColor * ase_lightAtten ) * lerpResult183_g857 );
			UnityGI gi53_g857 = gi;
			float3 diffNorm53_g857 = worldNormal86_g857;
			gi53_g857 = UnityGI_Base( data, 1, diffNorm53_g857 );
			half3 indirectDiffuse53_g857 = gi53_g857.indirect.diffuse + diffNorm53_g857 * 0.0001;
			#ifdef UNITY_PASS_FORWARDBASE
				half4 staticSwitch250_g857 = ( temp_output_182_0_g857 + ( half4( indirectDiffuse53_g857 , 0.0 ) * temp_output_42_0_g857 * temp_output_161_0_g857 ) );
			#else
				half4 staticSwitch250_g857 = temp_output_182_0_g857;
			#endif
			float2 uv_EmissionMap = i.uv_texcoord * _EmissionMap_ST.xy + _EmissionMap_ST.zw;
			clip( alpha518 - 0.05);
			c.rgb = ( staticSwitch250_g857 + ( SAMPLE_TEXTURE2D( _EmissionMap, sampler_EmissionMap, uv_EmissionMap ) * _EmissionColor ) ).rgb;
			c.a = temp_output_645_0;
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
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows nometa vertex:vertexDataFunc tessellate:tessFunction tessphong:_TessPhongStrength 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			AlphaToMask Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.6
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
				vertexDataFunc( v );
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
}
/*ASEBEGIN
Version=19108
Node;AmplifyShaderEditor.CommentaryNode;121;-2209.837,-395.2434;Inherit;False;1295.191;809.48;;14;610;19;518;106;105;331;107;112;113;104;656;380;657;658;Final Color Blending;0.514151,1,0.6056049,1;0;0
Node;AmplifyShaderEditor.VertexColorNode;104;-2146.046,182.9718;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;106;-1944.258,290.4149;Inherit;False;Property;_VertexColorStrength;Vertex Color Strength;10;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;105;-1881.327,189.0002;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;19;-2148.696,-235.3144;Inherit;True;Property;_MainTex;Main Tex;6;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;621;-1707.991,1661.074;Inherit;False;797.2819;513.1732;Comment;4;638;632;630;643;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;113;-1661.103,22.41703;Inherit;False;Property;_VertexBaseColor;Vertex Base Color;9;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;610;-1597.214,-151.4336;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;613;-1879.579,493.4243;Inherit;False;961.1769;381.4063;Comment;3;620;629;282;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;612;-2173.329,2229.718;Inherit;False;1268.577;322.7186;Comment;5;570;623;617;652;660;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;107;-1625.77,230.7146;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;617;-2123.329,2308.437;Inherit;True;Property;_OcclusionMap;Occlusion Map;14;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;623;-1810.752,2279.718;Inherit;False;Property;_OcclusionStrength;Occlusion Strength;15;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;112;-1431.348,4.108437;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;512;-2387.855,1180.407;Inherit;False;680.6748;262.7862;;2;383;50;Maps;0.504717,0.9903985,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;632;-1657.992,1810.155;Inherit;True;Property;_MetallicGlossMap;Metallic Gloss Map;8;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;620;-1813.03,676.0306;Inherit;False;Property;_BumpScale;Bump Scale;13;0;Create;True;0;0;0;False;0;False;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;630;-1636.989,2023.247;Inherit;False;Property;_GlossMapScale;Gloss Map Scale;11;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;657;-1537.026,-297.6374;Inherit;False;Property;_Color;Color;7;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;638;-1277.709,1914.066;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;50;-2337.855,1230.407;Inherit;True;Property;_IDMap;ID Map;19;0;Create;True;0;0;0;False;0;False;19;None;None;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;658;-1272.026,-155.6374;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;660;-1445.443,2331.254;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;652;-1782.58,2456.9;Inherit;False;specularMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;624;-1531.789,1090.893;Inherit;False;622.4177;474.6811;Comment;3;635;634;633;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;629;-1490.091,623.4471;Inherit;True;Property;_BumpMap;Bump Map;12;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;282;-1137.676,647.9846;Inherit;False;normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;518;-1775.883,-67.44363;Inherit;False;alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;331;-1127.497,-1.164222;Inherit;False;baseColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;633;-1481.79,1140.893;Inherit;True;Property;_EmissionMap;Emission Map;16;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;380;-1204.927,315.3215;Inherit;False;Property;_SpecularMultiplier;Specular Strength;25;0;Create;False;0;0;0;False;0;False;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;570;-1137.698,2328.423;Inherit;False;ambientOcclusion;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;573;-759.7318,-401.0714;Inherit;False;1085.333;1589.565;;17;378;571;595;263;569;180;108;482;572;177;596;389;385;384;539;265;661;Specular Highlights;1,0.7932334,0.514151,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;656;-1122.026,233.8626;Inherit;False;652;specularMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;634;-1399.275,1353.574;Inherit;False;Property;_EmissionColor;Emission Color;17;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;643;-1107.433,1911.743;Inherit;False;smoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;383;-1915.727,1306.731;Inherit;False;idMap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;389;-681.8292,847.2004;Inherit;False;Property;_SpecularShiftMax;Specular Shift Max;29;0;Create;True;0;0;0;False;0;False;0.25;0.25;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;385;-684.1522,771.6683;Inherit;False;Property;_SpecularShiftMin;Specular Shift Min;28;0;Create;True;0;0;0;False;0;False;-0.25;-0.25;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;569;-590.8998,-125.8811;Inherit;False;282;normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;378;-628.2301,-49.07933;Inherit;False;Property;_SpecularTint;Specular Tint;24;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;635;-1071.372,1270.615;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;108;-694.5977,-200.0366;Inherit;False;Property;_AOOccludeAll;AO Occlude All;18;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;655;-557.0543,265.4722;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;571;-637.0811,-277.3754;Inherit;False;570;ambientOcclusion;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;263;-676.3562,1073.421;Inherit;False;Property;_RimPower;Rim Hardness;22;0;Create;False;0;0;0;False;0;False;4;4;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;596;-691.4732,356.8531;Inherit;False;Property;_SpecularPowerScale;Specular Smoothness;26;0;Create;False;0;0;0;False;0;False;2;2;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;572;-594.7292,-351.0714;Inherit;False;331;baseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;539;-679.4417,923.2449;Inherit;False;Property;_Translucency;Translucency;30;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;265;-678.6436,998.7183;Inherit;False;Property;_RimTransmissionIntensity;Rim Transmission Intensity;23;0;Create;True;0;0;0;False;0;False;10;10;0;75;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;177;-709.0319,429.8401;Inherit;True;Property;_FlowMap;Flow Map;20;0;Create;True;0;0;0;False;0;False;19;None;None;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;384;-582.3779,695.2554;Inherit;False;383;idMap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;482;-693.7015,194.9869;Inherit;False;Property;_SpecularMix;Specular Mix;27;0;Create;True;0;0;0;False;0;False;1;1;0.5;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;180;-626.6543,619.2548;Inherit;False;Property;_FlowMapFlipGreen;Flow Map Flip Green;21;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;595;-606.828,119.648;Inherit;False;643;smoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;661;-190.8415,715.3079;Inherit;False;518;alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;644;348.5175,1354.812;Inherit;False;312.7604;248.5646;;2;645;646;Alpha;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;662;-110.9783,9.531306;Inherit;False;RL_Amplify_Function_Hair_AnisotropicLighting_3D;-1;;857;1c2ce0d33e6d0364e94912a58b37cdd2;2,264,0,88,0;19;42;COLOR;1,1,1,0;False;161;FLOAT;1;False;178;FLOAT;1;False;84;FLOAT3;0,0,1;False;26;FLOAT3;0,0,1;False;131;COLOR;1,1,1,0;False;7;FLOAT;50;False;172;FLOAT;0;False;132;FLOAT;1;False;245;FLOAT;2;False;108;COLOR;0,0,0,0;False;112;FLOAT;0;False;71;FLOAT;0.5;False;75;FLOAT;-0.1;False;80;FLOAT;0.1;False;282;FLOAT;0;False;207;FLOAT;0;False;208;FLOAT;0;False;310;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;642;-742.063,1236.563;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;645;481.2044,1409.81;Inherit;False;518;alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;646;376.7883,1493.883;Inherit;False;Constant;_ConstAlphaClip;Const Alpha Clip;50;0;Create;True;0;0;0;False;0;False;0.05;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;574;638.7153,1173.22;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClipNode;651;830.4156,1281.184;Inherit;False;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;650;1118.693,1230.645;Half;False;True;-1;6;;0;0;CustomLighting;Reallusion/Amplify/RL_HairShader_Coverge_Baked_3D_Tessellation;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;False;False;False;False;Off;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;True;0;True;Opaque;;AlphaTest;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;2;15;10;25;True;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;5;-1;-1;0;0;True;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;True;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;105;0;104;1
WireConnection;610;0;19;0
WireConnection;107;0;105;0
WireConnection;107;1;106;0
WireConnection;112;0;610;0
WireConnection;112;1;113;0
WireConnection;112;2;107;0
WireConnection;638;0;632;4
WireConnection;638;1;630;0
WireConnection;658;0;657;0
WireConnection;658;1;112;0
WireConnection;660;1;617;2
WireConnection;660;2;623;0
WireConnection;652;0;617;4
WireConnection;629;5;620;0
WireConnection;282;0;629;0
WireConnection;518;0;19;4
WireConnection;331;0;658;0
WireConnection;570;0;660;0
WireConnection;643;0;638;0
WireConnection;383;0;50;1
WireConnection;635;0;633;0
WireConnection;635;1;634;0
WireConnection;655;0;656;0
WireConnection;655;1;380;0
WireConnection;662;42;572;0
WireConnection;662;161;571;0
WireConnection;662;178;108;0
WireConnection;662;84;569;0
WireConnection;662;131;378;0
WireConnection;662;7;595;0
WireConnection;662;172;482;0
WireConnection;662;132;655;0
WireConnection;662;245;596;0
WireConnection;662;108;177;0
WireConnection;662;112;180;0
WireConnection;662;71;384;0
WireConnection;662;75;385;0
WireConnection;662;80;389;0
WireConnection;662;282;539;0
WireConnection;662;207;265;0
WireConnection;662;208;263;0
WireConnection;662;310;661;0
WireConnection;642;0;635;0
WireConnection;574;0;662;0
WireConnection;574;1;642;0
WireConnection;651;0;574;0
WireConnection;651;1;645;0
WireConnection;651;2;646;0
WireConnection;650;9;645;0
WireConnection;650;13;651;0
ASEEND*/
//CHKSM=6711914C117E19B7509AB7EE9BB7D84AA3D4B469