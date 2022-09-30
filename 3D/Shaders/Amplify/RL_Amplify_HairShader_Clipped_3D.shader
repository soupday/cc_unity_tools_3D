// Made with Amplify Shader Editor v1.9.0.1
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Reallusion/Amplify/RL_HairShader_Clipped_3D"
{
	Properties
	{
		_DiffuseMap("Diffuse Map", 2D) = "white" {}
		_DiffuseColor("Diffuse Color", Color) = (1,1,1,0)
		_DiffuseStrength("Diffuse Strength", Range( 0 , 2)) = 1
		_VertexBaseColor("Vertex Base Color", Color) = (0,0,0,0)
		_VertexColorStrength("Vertex Color Strength", Range( 0 , 1)) = 0.5
		_BaseColorStrength("Base Color Strength", Range( 0 , 1)) = 1
		_AlphaPower("Alpha Power", Range( 0.01 , 2)) = 1
		_AlphaRemap("Alpha Remap", Range( 0.5 , 1)) = 0.5
		[KeywordEnum(Standard,Dithered)] _ClipQuality("Clip Quality", Float) = 0
		_AlphaClip("Alpha Clip", Range( 0 , 1)) = 0.15
		_MaskMap("Mask Map", 2D) = "white" {}
		_AOStrength("Ambient Occlusion Strength", Range( 0 , 1)) = 1
		_AOOccludeAll("AO Occlude All", Range( 0 , 1)) = 0
		_SmoothnessPower("Smoothness Power", Range( 0.5 , 2)) = 1.25
		_SmoothnessMin("Smoothness Min", Range( 0 , 1)) = 0
		_SmoothnessMax("Smoothness Max", Range( 0 , 1)) = 1
		_BlendMap("Blend Map", 2D) = "white" {}
		_BlendStrength("Blend Strength", Range( 0 , 1)) = 1
		[Toggle(BOOLEAN_ENABLECOLOR_ON)] BOOLEAN_ENABLECOLOR("Enable Color", Float) = 0
		_RootMap("Root Map", 2D) = "gray" {}
		_GlobalStrength("Global Strength", Range( 0 , 1)) = 1
		_RootColorStrength("Root Color Strength", Range( 0 , 1)) = 1
		_EndColorStrength("End Color Strength", Range( 0 , 1)) = 1
		_InvertRootMap("Invert Root Map", Range( 0 , 1)) = 0
		_RootColor("Root Color", Color) = (0.3294118,0.1411765,0.05098039,0)
		_EndColor("End Color", Color) = (0.6039216,0.454902,0.2862745,0)
		_IDMap("ID Map", 2D) = "gray" {}
		_HighlightBlend("Highlight Blend", Range( 0 , 1)) = 1
		_HighlightAStrength("Highlight A Strength", Range( 0 , 1)) = 1
		_HighlightAColor("Highlight A Color", Color) = (0.9137255,0.7803922,0.6352941,0)
		_HighlightADistribution("Highlight A Distribution", Vector) = (0.1,0.2,0.3,0)
		_HighlightAOverlapEnd("Highlight A Overlap End", Range( 0 , 1)) = 1
		_HighlightAOverlapInvert("Highlight A Overlap Invert", Range( 0 , 1)) = 1
		_HighlightBStrength("Highlight B Strength", Range( 0 , 1)) = 1
		_HighlightBColor("Highlight B Color", Color) = (1,1,1,0)
		_HighlightBDistribution("Highlight B Distribution", Vector) = (0.1,0.2,0.3,0)
		_HighlightBOverlapEnd("Highlight B Overlap End", Range( 0 , 1)) = 1
		_HighlightBOverlapInvert("Highlight B Overlap Invert", Range( 0 , 1)) = 1
		_EmissionMap("Emission Map", 2D) = "white" {}
		_EmissiveColor("Emissive Color", Color) = (0,0,0,0)
		_SpecularMap("Specular  Map", 2D) = "white" {}
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
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 4.6
		#pragma shader_feature_local BOOLEAN_ENABLECOLOR_ON
		#pragma shader_feature_local _CLIPQUALITY_STANDARD _CLIPQUALITY_DITHERED
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
			float2 uv_texcoord;
			half3 worldNormal;
			INTERNAL_DATA
			float3 worldPos;
			float4 vertexColor : COLOR;
			float4 screenPos;
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

		uniform sampler2D _DiffuseMap;
		uniform half4 _DiffuseMap_ST;
		uniform half _AlphaRemap;
		uniform half _AlphaPower;
		uniform sampler2D _FlowMap;
		uniform half4 _FlowMap_ST;
		uniform half _FlowMapFlipGreen;
		uniform half _SpecularShiftMin;
		uniform half _SpecularShiftMax;
		uniform sampler2D _IDMap;
		uniform half4 _IDMap_ST;
		uniform half _SmoothnessMin;
		uniform half _SmoothnessMax;
		uniform sampler2D _MaskMap;
		uniform half4 _MaskMap_ST;
		uniform half _SmoothnessPower;
		uniform half _SpecularPowerScale;
		uniform sampler2D _SpecularMap;
		uniform half4 _SpecularMap_ST;
		uniform half _SpecularMultiplier;
		uniform half _Translucency;
		uniform half4 _SpecularTint;
		uniform half4 _DiffuseColor;
		uniform sampler2D _BlendMap;
		uniform half4 _BlendMap_ST;
		uniform half _DiffuseStrength;
		uniform half _BaseColorStrength;
		uniform half4 _RootColor;
		uniform half4 _EndColor;
		uniform sampler2D _RootMap;
		uniform half4 _RootMap_ST;
		uniform half _InvertRootMap;
		uniform half _RootColorStrength;
		uniform half _EndColorStrength;
		uniform half _GlobalStrength;
		uniform half4 _HighlightAColor;
		uniform half3 _HighlightADistribution;
		uniform half _HighlightAStrength;
		uniform half _HighlightAOverlapEnd;
		uniform half _HighlightAOverlapInvert;
		uniform half _HighlightBlend;
		uniform half4 _HighlightBColor;
		uniform half3 _HighlightBDistribution;
		uniform half _HighlightBStrength;
		uniform half _HighlightBOverlapEnd;
		uniform half _HighlightBOverlapInvert;
		uniform half _BlendStrength;
		uniform half4 _VertexBaseColor;
		uniform half _VertexColorStrength;
		uniform half _SpecularMix;
		uniform half _RimPower;
		uniform half _RimTransmissionIntensity;
		uniform half _AOStrength;
		uniform half _AOOccludeAll;
		uniform sampler2D _EmissionMap;
		uniform half4 _EmissionMap_ST;
		uniform half4 _EmissiveColor;
		uniform half _AlphaClip;


		half ThreePointDistribution( half3 From, half ID, half Fac )
		{
			float lower = smoothstep(From.x, From.y, ID);
			float upper = 1.0 - smoothstep(From.y, From.z, ID);
			return Fac * lerp(lower, upper, step(From.y, ID));
		}


		half UnityHDRPDither175( half In, half2 ScreenPosition )
		{
			half2 uv = ScreenPosition.xy * _ScreenParams.xy;
			half DITHER_THRESHOLDS[16] =
			{
			                1.0 / 17.0,  9.0 / 17.0,  3.0 / 17.0, 11.0 / 17.0,
			                13.0 / 17.0,  5.0 / 17.0, 15.0 / 17.0,  7.0 / 17.0,
			                4.0 / 17.0, 12.0 / 17.0,  2.0 / 17.0, 10.0 / 17.0,
			                16.0 / 17.0,  8.0 / 17.0, 14.0 / 17.0,  6.0 / 17.0
			};
			uint index = (uint(uv.x) % 4) * 4 + uint(uv.y) % 4;
			return In - DITHER_THRESHOLDS[index];
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
			float2 uv_DiffuseMap = i.uv_texcoord * _DiffuseMap_ST.xy + _DiffuseMap_ST.zw;
			half4 tex2DNode19 = tex2D( _DiffuseMap, uv_DiffuseMap );
			half saferPower23 = abs( saturate( ( tex2DNode19.a / _AlphaRemap ) ) );
			half alpha518 = pow( saferPower23 , _AlphaPower );
			float2 uv_FlowMap = i.uv_texcoord * _FlowMap_ST.xy + _FlowMap_ST.zw;
			half4 break109_g1030 = tex2D( _FlowMap, uv_FlowMap );
			half lerpResult123_g1030 = lerp( break109_g1030.g , ( 1.0 - break109_g1030.g ) , _FlowMapFlipGreen);
			half3 appendResult98_g1030 = (half3(break109_g1030.r , lerpResult123_g1030 , break109_g1030.b));
			half3 flowTangent107_g1030 = (WorldNormalVector( i , ( ( appendResult98_g1030 * float3( 2,2,2 ) ) - float3( 1,1,1 ) ) ));
			half3 worldNormal86_g1030 = normalize( (WorldNormalVector( i , float3( 0,0,1 ) )) );
			float2 uv_IDMap = i.uv_texcoord * _IDMap_ST.xy + _IDMap_ST.zw;
			half idMap383 = tex2D( _IDMap, uv_IDMap ).r;
			half lerpResult81_g1030 = lerp( _SpecularShiftMin , _SpecularShiftMax , idMap383);
			half3 normalizeResult10_g1033 = normalize( ( flowTangent107_g1030 + ( worldNormal86_g1030 * lerpResult81_g1030 ) ) );
			half3 shiftedTangent119_g1030 = normalizeResult10_g1033;
			float3 ase_worldPos = i.worldPos;
			half3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			half3 viewDIr52_g1031 = ase_worldViewDir;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			half3 ase_worldlightDir = 0;
			#else //aseld
			half3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			half3 worldLight272_g1030 = ase_worldlightDir;
			half3 lightDIr80_g1031 = worldLight272_g1030;
			half3 normalizeResult14_g1032 = normalize( ( viewDIr52_g1031 + lightDIr80_g1031 ) );
			half dotResult16_g1032 = dot( shiftedTangent119_g1030 , normalizeResult14_g1032 );
			half smoothstepResult22_g1032 = smoothstep( -1.0 , 0.0 , dotResult16_g1032);
			float2 uv_MaskMap = i.uv_texcoord * _MaskMap_ST.xy + _MaskMap_ST.zw;
			half4 tex2DNode115 = tex2D( _MaskMap, uv_MaskMap );
			half saferPower126 = abs( tex2DNode115.a );
			half lerpResult128 = lerp( _SmoothnessMin , _SmoothnessMax , pow( saferPower126 , _SmoothnessPower ));
			half smoothness594 = lerpResult128;
			half temp_output_233_0_g1030 = max( ( 1.0 - smoothness594 ) , 0.001 );
			half specularPower237_g1030 = ( max( ( ( 2.0 / ( temp_output_233_0_g1030 * temp_output_233_0_g1030 ) ) - 2.0 ) , 0.001 ) * _SpecularPowerScale );
			float2 uv_SpecularMap = i.uv_texcoord * _SpecularMap_ST.xy + _SpecularMap_ST.zw;
			half dotResult266_g1030 = dot( normalize( (WorldNormalVector( i , float3( 0,0,1 ) )) ) , worldLight272_g1030 );
			half translucencyWrap283_g1030 = _Translucency;
			half lambertMask290_g1030 = saturate( ( ( dotResult266_g1030 * ( 1.0 - translucencyWrap283_g1030 ) ) + translucencyWrap283_g1030 ) );
			half temp_output_84_0_g1031 = lambertMask290_g1030;
			half4 temp_output_13_0_g1031 = ( ( smoothstepResult22_g1032 * pow( saturate( ( 1.0 - ( dotResult16_g1032 * dotResult16_g1032 ) ) ) , specularPower237_g1030 ) ) * ( tex2D( _SpecularMap, uv_SpecularMap ).g * _SpecularMultiplier ) * temp_output_84_0_g1031 * _SpecularTint * alpha518 );
			float2 uv_BlendMap = i.uv_texcoord * _BlendMap_ST.xy + _BlendMap_ST.zw;
			half4 diffuseMap517 = tex2DNode19;
			half4 lerpResult41_g786 = lerp( float4( 1,1,1,0 ) , diffuseMap517 , _BaseColorStrength);
			float2 uv_RootMap = i.uv_texcoord * _RootMap_ST.xy + _RootMap_ST.zw;
			half root58 = tex2D( _RootMap, uv_RootMap ).r;
			half temp_output_55_0_g786 = root58;
			half lerpResult50_g786 = lerp( temp_output_55_0_g786 , ( 1.0 - temp_output_55_0_g786 ) , _InvertRootMap);
			half4 lerpResult44_g786 = lerp( _RootColor , _EndColor , lerpResult50_g786);
			half lerpResult43_g786 = lerp( _RootColorStrength , _EndColorStrength , lerpResult50_g786);
			half4 lerpResult53_g786 = lerp( lerpResult41_g786 , lerpResult44_g786 , ( lerpResult43_g786 * _GlobalStrength ));
			half3 From8_g788 = _HighlightADistribution;
			half ID8_g788 = idMap383;
			half Fac8_g788 = _HighlightAStrength;
			half localThreePointDistribution8_g788 = ThreePointDistribution( From8_g788 , ID8_g788 , Fac8_g788 );
			half temp_output_24_0_g788 = root58;
			half lerpResult16_g788 = lerp( temp_output_24_0_g788 , ( 1.0 - temp_output_24_0_g788 ) , _HighlightAOverlapInvert);
			half4 lerpResult18_g788 = lerp( lerpResult53_g786 , _HighlightAColor , saturate( ( localThreePointDistribution8_g788 * ( 1.0 - ( _HighlightAOverlapEnd * lerpResult16_g788 ) ) * _HighlightBlend ) ));
			half3 From8_g789 = _HighlightBDistribution;
			half ID8_g789 = idMap383;
			half Fac8_g789 = _HighlightBStrength;
			half localThreePointDistribution8_g789 = ThreePointDistribution( From8_g789 , ID8_g789 , Fac8_g789 );
			half temp_output_24_0_g789 = root58;
			half lerpResult16_g789 = lerp( temp_output_24_0_g789 , ( 1.0 - temp_output_24_0_g789 ) , _HighlightBOverlapInvert);
			half4 lerpResult18_g789 = lerp( lerpResult18_g788 , _HighlightBColor , saturate( ( localThreePointDistribution8_g789 * ( 1.0 - ( _HighlightBOverlapEnd * lerpResult16_g789 ) ) * _HighlightBlend ) ));
			#ifdef BOOLEAN_ENABLECOLOR_ON
				half4 staticSwitch95 = lerpResult18_g789;
			#else
				half4 staticSwitch95 = diffuseMap517;
			#endif
			half4 blendOpSrc101 = tex2D( _BlendMap, uv_BlendMap );
			half4 blendOpDest101 = ( _DiffuseStrength * staticSwitch95 );
			half4 lerpBlendMode101 = lerp(blendOpDest101,( blendOpSrc101 * blendOpDest101 ),_BlendStrength);
			half4 lerpResult112 = lerp( ( saturate( lerpBlendMode101 )) , _VertexBaseColor , ( ( 1.0 - i.vertexColor.r ) * _VertexColorStrength ));
			half4 baseColor331 = ( _DiffuseColor * lerpResult112 );
			half4 temp_output_42_0_g1030 = baseColor331;
			half4 temp_output_32_0_g1031 = temp_output_42_0_g1030;
			half4 lerpResult36_g1031 = lerp( temp_output_13_0_g1031 , ( temp_output_13_0_g1031 * temp_output_32_0_g1031 ) , _SpecularMix);
			half3 temp_output_24_0_g1031 = worldNormal86_g1030;
			half dotResult82_g1031 = dot( lightDIr80_g1031 , temp_output_24_0_g1031 );
			half temp_output_40_0_g1031 = translucencyWrap283_g1030;
			half dotResult54_g1031 = dot( temp_output_24_0_g1031 , viewDIr52_g1031 );
			half dotResult57_g1031 = dot( viewDIr52_g1031 , lightDIr80_g1031 );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			half4 ase_lightColor = 0;
			#else //aselc
			half4 ase_lightColor = _LightColor0;
			#endif //aselc
			half lerpResult638 = lerp( 1.0 , tex2DNode115.g , _AOStrength);
			half ambientOcclusion570 = lerpResult638;
			half temp_output_161_0_g1030 = ambientOcclusion570;
			half lerpResult183_g1030 = lerp( 1.0 , temp_output_161_0_g1030 , _AOOccludeAll);
			half4 temp_output_182_0_g1030 = ( ( ( lerpResult36_g1031 + ( ( saturate( ( ( dotResult82_g1031 * ( 1.0 - temp_output_40_0_g1031 ) ) + temp_output_40_0_g1031 ) ) + ( pow( ( max( ( 1.0 - abs( dotResult54_g1031 ) ) , 0.0 ) * max( ( 0.0 - dotResult57_g1031 ) , 0.0 ) ) , _RimPower ) * _RimTransmissionIntensity * temp_output_84_0_g1031 ) ) * temp_output_32_0_g1031 ) ) * ase_lightColor * ase_lightAtten ) * lerpResult183_g1030 );
			UnityGI gi53_g1030 = gi;
			float3 diffNorm53_g1030 = worldNormal86_g1030;
			gi53_g1030 = UnityGI_Base( data, 1, diffNorm53_g1030 );
			half3 indirectDiffuse53_g1030 = gi53_g1030.indirect.diffuse + diffNorm53_g1030 * 0.0001;
			#ifdef UNITY_PASS_FORWARDBASE
				half4 staticSwitch250_g1030 = ( temp_output_182_0_g1030 + ( half4( indirectDiffuse53_g1030 , 0.0 ) * temp_output_42_0_g1030 * temp_output_161_0_g1030 ) );
			#else
				half4 staticSwitch250_g1030 = temp_output_182_0_g1030;
			#endif
			float2 uv_EmissionMap = i.uv_texcoord * _EmissionMap_ST.xy + _EmissionMap_ST.zw;
			half In175 = _AlphaClip;
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			half2 ScreenPosition175 = ase_screenPosNorm.xy;
			half localUnityHDRPDither175 = UnityHDRPDither175( In175 , ScreenPosition175 );
			#if defined(_CLIPQUALITY_STANDARD)
				half staticSwitch528 = _AlphaClip;
			#elif defined(_CLIPQUALITY_DITHERED)
				half staticSwitch528 = localUnityHDRPDither175;
			#else
				half staticSwitch528 = _AlphaClip;
			#endif
			clip( alpha518 - staticSwitch528);
			c.rgb = ( staticSwitch250_g1030 + ( tex2D( _EmissionMap, uv_EmissionMap ) * _EmissiveColor ) ).rgb;
			c.a = alpha518;
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
				float4 screenPos : TEXCOORD2;
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
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
				o.screenPos = ComputeScreenPos( o.pos );
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
				surfIN.screenPos = IN.screenPos;
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
	CustomEditor "Reallusion.Import.CustomHairShaderGUI"
}
/*ASEBEGIN
Version=19001
1913;48;1920;981;978.469;38.90891;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;25;-5721.536,873.5989;Inherit;False;1176.518;561.6434;;8;518;517;23;22;24;21;20;19;Diffuse & Alpha;0.5235849,1,0.631946,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;512;-5718.366,1661.348;Inherit;False;696.6748;494.7862;;4;26;58;383;50;Maps;0.504717,0.9903985,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;19;-5671.535,923.5991;Inherit;True;Property;_DiffuseMap;Diffuse Map;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;26;-5664.931,1926.134;Inherit;True;Property;_RootMap;Root Map;23;0;Create;True;0;0;0;False;0;False;19;None;None;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;517;-5312.597,999.702;Inherit;False;diffuseMap;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;516;-5730.066,-1036.8;Inherit;False;2272.674;1645.196;;29;91;88;92;87;84;508;69;53;52;54;55;503;519;504;27;31;32;33;29;30;28;59;510;509;502;524;523;522;637;Hair Color Blending;0.5330188,1,0.6022252,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;58;-5245.691,1959.615;Inherit;False;root;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-5671.595,-237.5661;Inherit;False;Property;_RootColorStrength;Root Color Strength;25;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;504;-5567.181,-781.3913;Inherit;False;58;root;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-5669.347,-147.4745;Inherit;False;Property;_EndColorStrength;End Color Strength;26;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-5668.135,-688.8041;Inherit;False;Property;_GlobalStrength;Global Strength;24;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;519;-5581.311,-960.5982;Inherit;False;517;diffuseMap;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;32;-5612.805,-421.4388;Inherit;False;Property;_EndColor;End Color;29;0;Create;True;0;0;0;False;0;False;0.6039216,0.454902,0.2862745,0;0.6039216,0.454902,0.2862744,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;33;-5674.055,-876.1475;Inherit;False;Property;_BaseColorStrength;Base Color Strength;6;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;31;-5612.955,-600.91;Inherit;False;Property;_RootColor;Root Color;28;0;Create;True;0;0;0;False;0;False;0.3294118,0.1411765,0.05098039,0;0.3294117,0.1411764,0.05098034,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;29;-5666.166,-64.65891;Inherit;False;Property;_InvertRootMap;Invert Root Map;27;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;50;-5668.366,1711.348;Inherit;True;Property;_IDMap;ID Map;30;0;Create;True;0;0;0;False;0;False;19;None;None;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;383;-5246.238,1787.672;Inherit;False;idMap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;523;-5087.463,-880.7275;Inherit;False;RL_Amplify_Function_Hair_RootBlend;-1;;786;3304ef6ee2139bd4cab5d899498bc3dd;0;9;52;COLOR;0,0,0,0;False;46;FLOAT;1;False;55;FLOAT;0;False;51;FLOAT;1;False;45;COLOR;0.3294118,0.1411765,0.05098039,0;False;40;COLOR;0.6039216,0.454902,0.2862745,0;False;49;FLOAT;1;False;47;FLOAT;1;False;48;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;637;-4949.334,252.3765;Inherit;False;Property;_HighlightBlend;Highlight Blend;31;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-5014.418,58.35992;Inherit;False;Property;_HighlightAOverlapInvert;Highlight A Overlap Invert;36;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-5017.905,-259.2123;Inherit;False;Property;_HighlightAStrength;Highlight A Strength;32;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-5017.305,-22.45101;Inherit;False;Property;_HighlightAOverlapEnd;Highlight A Overlap End;35;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;502;-4641.802,-723.1288;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;503;-4915.507,-514.9556;Inherit;False;383;idMap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;52;-4972.563,-178.1671;Inherit;False;Property;_HighlightADistribution;Highlight A Distribution;34;0;Create;True;0;0;0;False;0;False;0.1,0.2,0.3;0.1,0.2,0.3;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;59;-4915.522,-589.2163;Inherit;False;58;root;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;69;-4960.777,-437.1049;Inherit;False;Property;_HighlightAColor;Highlight A Color;33;0;Create;True;0;0;0;False;0;False;0.9137255,0.7803922,0.6352941,0;0.9137255,0.7803922,0.635294,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;522;-4431.044,-426.122;Inherit;False;RL_Amplify_Function_Hair_IDBlend;-1;;788;6afb608343a58854589726462adfdb8b;0;9;26;COLOR;1,1,1,0;False;24;FLOAT;0.5;False;27;FLOAT;0.5;False;25;COLOR;0.9137256,0.7803922,0.6352941,0;False;21;FLOAT;1;False;20;FLOAT3;0.1,0.2,0.3;False;22;FLOAT;1;False;23;FLOAT;1;False;28;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;525;-3245.436,-222.8687;Inherit;False;622.7622;286.4321;Enable Color;2;95;520;Keyword;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;88;-4359.578,513.0045;Inherit;False;Property;_HighlightBOverlapInvert;Highlight B Overlap Invert;41;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;87;-4315.965,276.4831;Inherit;False;Property;_HighlightBDistribution;Highlight B Distribution;39;0;Create;True;0;0;0;False;0;False;0.1,0.2,0.3;0.6,0.7,0.8;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;508;-4260.21,-59.08698;Inherit;False;383;idMap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;510;-3968.615,-191.6566;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;92;-4296.681,19.90401;Inherit;False;Property;_HighlightBColor;Highlight B Color;38;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;91;-4364.522,197.3449;Inherit;False;Property;_HighlightBStrength;Highlight B Strength;37;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;84;-4359.336,431.3161;Inherit;False;Property;_HighlightBOverlapEnd;Highlight B Overlap End;40;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;509;-4259.245,-135.2632;Inherit;False;58;root;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;524;-3805.556,-56.1289;Inherit;False;RL_Amplify_Function_Hair_IDBlend;-1;;789;6afb608343a58854589726462adfdb8b;0;9;26;COLOR;1,1,1,0;False;24;FLOAT;0.5;False;27;FLOAT;0.5;False;25;COLOR;0.9137256,0.7803922,0.6352941,0;False;21;FLOAT;1;False;20;FLOAT3;0.1,0.2,0.3;False;22;FLOAT;1;False;23;FLOAT;1;False;28;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;121;-2526.007,-395.2434;Inherit;False;1611.361;818.9382;;14;331;96;104;97;101;105;106;107;113;98;112;99;632;635;Final Color Blending;0.514151,1,0.6056049,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;520;-3195.436,-172.8687;Inherit;False;517;diffuseMap;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;96;-2471.786,-166.6682;Inherit;False;Property;_DiffuseStrength;Diffuse Strength;2;0;Create;True;0;0;0;False;0;False;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;104;-2146.046,182.9718;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;95;-2929.674,-76.43671;Inherit;False;Property;BOOLEAN_ENABLECOLOR;Enable Color;22;0;Create;False;0;0;0;False;0;False;0;0;0;True;BOOLEAN_ENABLECOLOR_ON;Toggle;2;Key0;Key1;Create;True;False;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;115;-2785.541,1954.936;Inherit;True;Property;_MaskMap;Mask Map;12;0;Create;True;0;0;0;False;0;False;19;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;130;-2254.14,1702.417;Inherit;False;1336.078;410.9783;;8;594;126;124;123;129;154;125;128;Smoothness;0.514151,1,0.9752312,1;0;0
Node;AmplifyShaderEditor.SamplerNode;98;-2016.306,-277.3997;Inherit;True;Property;_BlendMap;Blend Map;20;0;Create;True;0;0;0;False;0;False;19;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;106;-1944.258,290.4149;Inherit;False;Property;_VertexColorStrength;Vertex Color Strength;5;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;105;-1881.327,189.0002;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;97;-2160.596,-101.7776;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;123;-2196.421,1994.285;Inherit;False;Property;_SmoothnessPower;Smoothness Power;15;0;Create;True;0;0;0;False;0;False;1.25;1;0.5;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;99;-2001.331,16.97653;Inherit;False;Property;_BlendStrength;Blend Strength;21;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;154;-2215.662,1902.076;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-5663.463,1220.562;Inherit;False;Property;_AlphaRemap;Alpha Remap;8;0;Create;True;0;0;0;False;0;False;0.5;0.6;0.5;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;126;-1896.977,1868.215;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;101;-1658.146,-124.4951;Inherit;False;Multiply;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;113;-1661.103,22.41703;Inherit;False;Property;_VertexBaseColor;Vertex Base Color;4;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;122;-1909.03,2266.963;Inherit;False;990.7638;251.5405;;4;570;116;638;639;Ambient Occlusion;0.504717,1,0.9766926,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;107;-1625.77,230.7146;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;21;-5318.46,1133.561;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;639;-1878.637,2347.083;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;124;-1706.226,1752.417;Inherit;False;Property;_SmoothnessMin;Smoothness Min;16;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;22;-5163.459,1170.561;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;635;-1505.121,-321.8207;Inherit;False;Property;_DiffuseColor;Diffuse Color;1;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;24;-5293.459,1333.562;Inherit;False;Property;_AlphaPower;Alpha Power;7;0;Create;True;0;0;0;False;0;False;1;1;0.01;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;129;-1544.263,1941.09;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;112;-1425.348,5.108437;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;116;-1865.907,2431.265;Inherit;False;Property;_AOStrength;Ambient Occlusion Strength;13;0;Create;False;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;125;-1707.221,1837.011;Inherit;False;Property;_SmoothnessMax;Smoothness Max;17;0;Create;True;0;0;0;False;0;False;1;0.897;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;23;-4967.458,1242.563;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;638;-1471.226,2336.587;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;128;-1345.709,1820.173;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;636;-1259.121,-178.8207;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;570;-1144.033,2340.833;Inherit;False;ambientOcclusion;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;136;-1553.433,1059.366;Inherit;False;621.4995;462.2001;Comment;3;133;134;135;Emission;1,0.514151,0.9428412,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;533;-301.941,1388.536;Inherit;False;916.4373;616.015;;6;176;175;532;521;528;162;Alpha;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;518;-4746.722,1239.47;Inherit;False;alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;380;-1191.927,329.3215;Inherit;False;Property;_SpecularMultiplier;Specular Strength;50;0;Create;False;0;0;0;False;0;False;1;0.5;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;573;-759.7318,-401.0714;Inherit;False;1073.37;1585.308;;18;378;108;572;569;263;595;482;571;596;265;389;177;539;385;180;384;634;686;Specular Highlights;1,0.7932334,0.514151,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;594;-1124.683,1844.45;Inherit;False;smoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;632;-1204.654,138.827;Inherit;True;Property;_SpecularMap;Specular  Map;44;0;Create;True;0;0;0;False;0;False;19;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;331;-1130.497,0.835778;Inherit;False;baseColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;686;-173.9707,659.1857;Inherit;False;518;alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;596;-689.4732,354.8531;Inherit;False;Property;_SpecularPowerScale;Specular Smoothness;51;0;Create;False;0;0;0;False;0;False;2;2;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;385;-684.1522,771.6683;Inherit;False;Property;_SpecularShiftMin;Specular Shift Min;53;0;Create;True;0;0;0;False;0;False;-0.25;-0.25;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;595;-602.828,124.648;Inherit;False;594;smoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;389;-681.8292,847.2004;Inherit;False;Property;_SpecularShiftMax;Specular Shift Max;54;0;Create;True;0;0;0;False;0;False;0.25;0.25;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;482;-691.7015,199.9869;Inherit;False;Property;_SpecularMix;Specular Mix;52;0;Create;True;0;0;0;False;0;False;1;0.5;0.5;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;263;-676.3562,1073.421;Inherit;False;Property;_RimPower;Rim Hardness;47;0;Create;False;0;0;0;False;0;False;4;2.5;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;265;-678.6436,998.7183;Inherit;False;Property;_RimTransmissionIntensity;Rim Transmission Intensity;48;0;Create;True;0;0;0;False;0;False;10;10;0;75;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;634;-555.2641,268.3322;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;378;-628.2301,-49.07933;Inherit;False;Property;_SpecularTint;Specular Tint;49;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenPosInputsNode;176;-149.9035,1803.55;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;108;-694.5977,-200.0366;Inherit;False;Property;_AOOccludeAll;AO Occlude All;14;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;539;-679.4417,923.2449;Inherit;False;Property;_Translucency;Translucency;55;0;Create;True;0;0;0;False;0;False;0;0.15;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;180;-627.6543,619.2548;Inherit;False;Property;_FlowMapFlipGreen;Flow Map Flip Green;46;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;571;-637.0811,-277.3754;Inherit;False;570;ambientOcclusion;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;384;-582.3779,695.2554;Inherit;False;383;idMap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;133;-1503.434,1109.366;Inherit;True;Property;_EmissionMap;Emission Map;42;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;572;-594.7292,-351.0714;Inherit;False;331;baseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;134;-1461.834,1309.566;Inherit;False;Property;_EmissiveColor;Emissive Color;43;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;162;-231.9415,1580.146;Inherit;False;Property;_AlphaClip;Alpha Clip;10;0;Create;False;0;0;0;False;0;False;0.15;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;177;-709.0319,429.8401;Inherit;True;Property;_FlowMap;Flow Map;45;0;Create;True;0;0;0;False;0;False;19;None;None;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;687;-110.9783,9.531306;Inherit;False;RL_Amplify_Function_Hair_AnisotropicLighting_3D;-1;;1030;1c2ce0d33e6d0364e94912a58b37cdd2;2,264,0,88,0;19;42;COLOR;1,1,1,0;False;161;FLOAT;1;False;178;FLOAT;1;False;84;FLOAT3;0,0,1;False;26;FLOAT3;0,0,1;False;131;COLOR;1,1,1,0;False;7;FLOAT;50;False;172;FLOAT;0;False;132;FLOAT;1;False;245;FLOAT;2;False;108;COLOR;0,0,0,0;False;112;FLOAT;0;False;71;FLOAT;0.5;False;75;FLOAT;-0.1;False;80;FLOAT;0.1;False;282;FLOAT;0;False;207;FLOAT;0;False;208;FLOAT;0;False;310;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.CustomExpressionNode;175;101.3107,1748.551;Inherit;False;half2 uv = ScreenPosition.xy * _ScreenParams.xy@$half DITHER_THRESHOLDS[16] =${$                1.0 / 17.0,  9.0 / 17.0,  3.0 / 17.0, 11.0 / 17.0,$                13.0 / 17.0,  5.0 / 17.0, 15.0 / 17.0,  7.0 / 17.0,$                4.0 / 17.0, 12.0 / 17.0,  2.0 / 17.0, 10.0 / 17.0,$                16.0 / 17.0,  8.0 / 17.0, 14.0 / 17.0,  6.0 / 17.0$}@$uint index = (uint(uv.x) % 4) * 4 + uint(uv.y) % 4@$return In - DITHER_THRESHOLDS[index]@;1;Create;2;True;In;FLOAT;0;In;;Inherit;False;True;ScreenPosition;FLOAT2;0,0;In;;Inherit;False;Unity HDRP Dither;True;False;0;;False;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;135;-1093.935,1191.266;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;141;-1860.923,590.5557;Inherit;False;952.864;322.2571;;3;282;139;140;Normals;0.5235849,0.5572144,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;574;637.7153,1173.22;Inherit;False;2;2;0;COLOR;1,1,1,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;528;366.2788,1581.681;Inherit;False;Property;_ClipQuality;Clip Quality;9;0;Create;True;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;2;Standard;Dithered;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;521;423.4229,1466.535;Inherit;False;518;alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;532;324.4969,1887.09;Inherit;False;Property;_ShadowClip;Shadow Clip;11;0;Create;True;0;0;0;False;0;False;0.25;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;619;843.0594,1511.796;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;140;-1810.923,789.8129;Inherit;False;Property;_NormalStrength;Normal Strength;19;0;Create;True;0;0;0;False;0;False;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;139;-1484.06,640.5557;Inherit;True;Property;_NormalMap;Normal Map;18;0;Create;True;0;0;0;False;0;False;19;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;282;-1114.089,709.7084;Inherit;False;normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;569;-590.8998,-125.8811;Inherit;False;282;normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClipNode;608;808.0734,1249.929;Inherit;False;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;597;1076.754,1073.793;Half;False;True;-1;6;Reallusion.Import.CustomHairShaderGUI;0;0;CustomLighting;Reallusion/Amplify/RL_HairShader_Clipped_3D;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;1;True;True;0;True;Opaque;;AlphaTest;All;18;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;True;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;3;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;517;0;19;0
WireConnection;58;0;26;1
WireConnection;383;0;50;1
WireConnection;523;52;519;0
WireConnection;523;46;33;0
WireConnection;523;55;504;0
WireConnection;523;51;30;0
WireConnection;523;45;31;0
WireConnection;523;40;32;0
WireConnection;523;49;27;0
WireConnection;523;47;28;0
WireConnection;523;48;29;0
WireConnection;502;0;523;0
WireConnection;522;26;502;0
WireConnection;522;24;59;0
WireConnection;522;27;503;0
WireConnection;522;25;69;0
WireConnection;522;21;53;0
WireConnection;522;20;52;0
WireConnection;522;22;54;0
WireConnection;522;23;55;0
WireConnection;522;28;637;0
WireConnection;510;0;522;0
WireConnection;524;26;510;0
WireConnection;524;24;509;0
WireConnection;524;27;508;0
WireConnection;524;25;92;0
WireConnection;524;21;91;0
WireConnection;524;20;87;0
WireConnection;524;22;84;0
WireConnection;524;23;88;0
WireConnection;524;28;637;0
WireConnection;95;1;520;0
WireConnection;95;0;524;0
WireConnection;105;0;104;1
WireConnection;97;0;96;0
WireConnection;97;1;95;0
WireConnection;154;0;115;4
WireConnection;126;0;154;0
WireConnection;126;1;123;0
WireConnection;101;0;98;0
WireConnection;101;1;97;0
WireConnection;101;2;99;0
WireConnection;107;0;105;0
WireConnection;107;1;106;0
WireConnection;21;0;19;4
WireConnection;21;1;20;0
WireConnection;639;0;115;2
WireConnection;22;0;21;0
WireConnection;129;0;126;0
WireConnection;112;0;101;0
WireConnection;112;1;113;0
WireConnection;112;2;107;0
WireConnection;23;0;22;0
WireConnection;23;1;24;0
WireConnection;638;1;639;0
WireConnection;638;2;116;0
WireConnection;128;0;124;0
WireConnection;128;1;125;0
WireConnection;128;2;129;0
WireConnection;636;0;635;0
WireConnection;636;1;112;0
WireConnection;570;0;638;0
WireConnection;518;0;23;0
WireConnection;594;0;128;0
WireConnection;331;0;636;0
WireConnection;634;0;632;2
WireConnection;634;1;380;0
WireConnection;687;42;572;0
WireConnection;687;161;571;0
WireConnection;687;178;108;0
WireConnection;687;131;378;0
WireConnection;687;7;595;0
WireConnection;687;172;482;0
WireConnection;687;132;634;0
WireConnection;687;245;596;0
WireConnection;687;108;177;0
WireConnection;687;112;180;0
WireConnection;687;71;384;0
WireConnection;687;75;385;0
WireConnection;687;80;389;0
WireConnection;687;282;539;0
WireConnection;687;207;265;0
WireConnection;687;208;263;0
WireConnection;687;310;686;0
WireConnection;175;0;162;0
WireConnection;175;1;176;0
WireConnection;135;0;133;0
WireConnection;135;1;134;0
WireConnection;574;0;687;0
WireConnection;574;1;135;0
WireConnection;528;1;162;0
WireConnection;528;0;175;0
WireConnection;619;0;521;0
WireConnection;139;5;140;0
WireConnection;282;0;139;0
WireConnection;608;0;574;0
WireConnection;608;1;521;0
WireConnection;608;2;528;0
WireConnection;597;9;619;0
WireConnection;597;13;608;0
ASEEND*/
//CHKSM=24F5807E46FC878BC29162E70C96B05648C698D2