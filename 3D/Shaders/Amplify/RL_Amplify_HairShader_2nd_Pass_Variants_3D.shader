// Made with Amplify Shader Editor v1.9.1.8
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Reallusion/Amplify/RL_HairShader_2nd_Pass_Variants_3D"
{
	Properties
	{
		_DiffuseMap("Diffuse Map", 2D) = "white" {}
		_DiffuseColor("Diffuse Color", Color) = (1,1,1,0)
		_DiffuseStrength("Diffuse Strength", Range( 0 , 2)) = 1
		_VertexBaseColor("Vertex Base Color", Color) = (0,0,0,0)
		_VertexColorStrength("Vertex Color Strength", Range( 0 , 1)) = 0.5
		_AlphaPower("Alpha Power", Range( 0.01 , 2)) = 1
		_AlphaRemap("Alpha Remap", Range( 0.5 , 1)) = 0.5
		_MaskMap("Mask Map", 2D) = "white" {}
		_AOStrength("Ambient Occlusion Strength", Range( 0 , 1)) = 1
		_AOOccludeAll("AO Occlude All", Range( 0 , 1)) = 0
		_SmoothnessPower("Smoothness Power", Range( 0.5 , 2)) = 1.25
		_SmoothnessMin("Smoothness Min", Range( 0 , 1)) = 0
		_SmoothnessMax("Smoothness Max", Range( 0 , 1)) = 1
		_NormalMap("Normal Map", 2D) = "bump" {}
		_NormalStrength("Normal Strength", Range( 0 , 2)) = 1
		_BlendMap("Blend Map", 2D) = "white" {}
		_BlendStrength("Blend Strength", Range( 0 , 1)) = 1
		_FlowMap("Flow Map", 2D) = "gray" {}
		[Toggle]_FlowMapFlipGreen("Flow Map Flip Green", Float) = 0
		_SpecularMap("Specular  Map", 2D) = "white" {}
		_SpecularTint("Specular Tint", Color) = (1,1,1,0)
		_SpecularMultiplier("Specular Strength", Range( 0 , 2)) = 1
		_SpecularPower("Specular Smoothness", Range( 0 , 10)) = 2
		_SpecularMix("Specular Mix", Range( 0.5 , 1)) = 1
		_SpecularShiftMin("Specular Shift Min", Range( -1 , 1)) = -0.25
		_SpecularShiftMax("Specular Shift Max", Range( -1 , 1)) = 0.25
		_Translucency("Translucency", Range( 0 , 1)) = 0
		_RimPower("Rim Hardness", Range( 1 , 10)) = 4
		_RimTransmissionIntensity("Rim Transmission Intensity", Range( 0 , 75)) = 10
		_EmissionMap("Emission Map", 2D) = "white" {}
		_EmissiveColor("Emissive Color", Color) = (0,0,0,0)
		[Toggle(BOOLEAN_ENABLECOLOR_ON)] BOOLEAN_ENABLECOLOR("Enable Color", Float) = 0
		_RootMap("Root Map", 2D) = "gray" {}
		_BaseColorStrength("Base Color Strength", Range( 0 , 1)) = 1
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
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Off
		ZWrite Off
		ZTest Less
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma shader_feature_local BOOLEAN_ENABLECOLOR_ON
		#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
		#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
		#define ASE_USING_SAMPLING_MACROS 1
		#if defined(SHADER_API_D3D11) || defined(SHADER_API_XBOXONE) || defined(UNITY_COMPILER_HLSLCC) || defined(SHADER_API_PSSL) || (defined(SHADER_TARGET_SURFACE_ANALYSIS) && !defined(SHADER_TARGET_SURFACE_ANALYSIS_MOJOSHADER))//ASE Sampler Macros
		#define SAMPLE_TEXTURE2D(tex,samplerTex,coord) tex.Sample(samplerTex,coord)
		#define SAMPLE_TEXTURE2D_LOD(tex,samplerTex,coord,lod) tex.SampleLevel(samplerTex,coord, lod)
		#define SAMPLE_TEXTURE2D_BIAS(tex,samplerTex,coord,bias) tex.SampleBias(samplerTex,coord,bias)
		#define SAMPLE_TEXTURE2D_GRAD(tex,samplerTex,coord,ddx,ddy) tex.SampleGrad(samplerTex,coord,ddx,ddy)
		#else//ASE Sampling Macros
		#define SAMPLE_TEXTURE2D(tex,samplerTex,coord) tex2D(tex,coord)
		#define SAMPLE_TEXTURE2D_LOD(tex,samplerTex,coord,lod) tex2Dlod(tex,float4(coord,0,lod))
		#define SAMPLE_TEXTURE2D_BIAS(tex,samplerTex,coord,bias) tex2Dbias(tex,float4(coord,0,bias))
		#define SAMPLE_TEXTURE2D_GRAD(tex,samplerTex,coord,ddx,ddy) tex2Dgrad(tex,coord,ddx,ddy)
		#endif//ASE Sampling Macros

		#pragma surface surf StandardCustomLighting keepalpha noshadow nometa  alpha:fade
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

		UNITY_DECLARE_TEX2D_NOSAMPLER(_DiffuseMap);
		uniform half4 _DiffuseMap_ST;
		SamplerState sampler_DiffuseMap;
		uniform half _AlphaRemap;
		uniform half _AlphaPower;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_FlowMap);
		uniform half4 _FlowMap_ST;
		uniform half _FlowMapFlipGreen;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_NormalMap);
		uniform half4 _NormalMap_ST;
		uniform half _NormalStrength;
		uniform half _SpecularShiftMin;
		uniform half _SpecularShiftMax;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_IDMap);
		uniform half4 _IDMap_ST;
		uniform half _SmoothnessMin;
		uniform half _SmoothnessMax;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_MaskMap);
		uniform half4 _MaskMap_ST;
		uniform half _SmoothnessPower;
		uniform half _SpecularPower;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_SpecularMap);
		uniform half4 _SpecularMap_ST;
		uniform half _SpecularMultiplier;
		uniform half _Translucency;
		uniform half4 _SpecularTint;
		uniform half4 _DiffuseColor;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_BlendMap);
		uniform half4 _BlendMap_ST;
		uniform half _DiffuseStrength;
		uniform half _BaseColorStrength;
		uniform half4 _RootColor;
		uniform half4 _EndColor;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_RootMap);
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
		UNITY_DECLARE_TEX2D_NOSAMPLER(_EmissionMap);
		uniform half4 _EmissionMap_ST;
		SamplerState sampler_EmissionMap;
		uniform half4 _EmissiveColor;


		half ThreePointDistribution( half3 From, half ID, half Fac )
		{
			float lower = smoothstep(From.x, From.y, ID);
			float upper = 1.0 - smoothstep(From.y, From.z, ID);
			return Fac * lerp(lower, upper, step(From.y, ID));
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
			half4 tex2DNode19 = SAMPLE_TEXTURE2D( _DiffuseMap, sampler_DiffuseMap, uv_DiffuseMap );
			half saferPower23 = abs( saturate( ( tex2DNode19.a / _AlphaRemap ) ) );
			half alpha518 = pow( saferPower23 , _AlphaPower );
			half temp_output_521_0 = alpha518;
			float2 uv_FlowMap = i.uv_texcoord * _FlowMap_ST.xy + _FlowMap_ST.zw;
			half4 break109_g958 = SAMPLE_TEXTURE2D( _FlowMap, sampler_DiffuseMap, uv_FlowMap );
			half lerpResult123_g958 = lerp( break109_g958.g , ( 1.0 - break109_g958.g ) , _FlowMapFlipGreen);
			half3 appendResult98_g958 = (half3(break109_g958.r , lerpResult123_g958 , break109_g958.b));
			half3 flowTangent107_g958 = (WorldNormalVector( i , ( ( appendResult98_g958 * float3( 2,2,2 ) ) - float3( 1,1,1 ) ) ));
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			half3 normal282 = UnpackScaleNormal( SAMPLE_TEXTURE2D( _NormalMap, sampler_DiffuseMap, uv_NormalMap ), _NormalStrength );
			half3 worldNormal86_g958 = normalize( (WorldNormalVector( i , normal282 )) );
			float2 uv_IDMap = i.uv_texcoord * _IDMap_ST.xy + _IDMap_ST.zw;
			half idMap383 = SAMPLE_TEXTURE2D( _IDMap, sampler_DiffuseMap, uv_IDMap ).r;
			half lerpResult81_g958 = lerp( _SpecularShiftMin , _SpecularShiftMax , idMap383);
			half3 normalizeResult10_g961 = normalize( ( flowTangent107_g958 + ( worldNormal86_g958 * lerpResult81_g958 ) ) );
			half3 shiftedTangent119_g958 = normalizeResult10_g961;
			float3 ase_worldPos = i.worldPos;
			half3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			half3 viewDIr52_g959 = ase_worldViewDir;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			half3 ase_worldlightDir = 0;
			#else //aseld
			half3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			half3 worldLight272_g958 = ase_worldlightDir;
			half3 lightDIr80_g959 = worldLight272_g958;
			half3 normalizeResult14_g960 = normalize( ( viewDIr52_g959 + lightDIr80_g959 ) );
			half dotResult16_g960 = dot( shiftedTangent119_g958 , normalizeResult14_g960 );
			half smoothstepResult22_g960 = smoothstep( -1.0 , 0.0 , dotResult16_g960);
			float2 uv_MaskMap = i.uv_texcoord * _MaskMap_ST.xy + _MaskMap_ST.zw;
			half4 tex2DNode115 = SAMPLE_TEXTURE2D( _MaskMap, sampler_DiffuseMap, uv_MaskMap );
			half saferPower126 = abs( tex2DNode115.a );
			half lerpResult128 = lerp( _SmoothnessMin , _SmoothnessMax , pow( saferPower126 , _SmoothnessPower ));
			half smoothness601 = lerpResult128;
			half temp_output_233_0_g958 = max( ( 1.0 - smoothness601 ) , 0.001 );
			half specularPower237_g958 = ( max( ( ( 2.0 / ( temp_output_233_0_g958 * temp_output_233_0_g958 ) ) - 2.0 ) , 0.001 ) * _SpecularPower );
			float2 uv_SpecularMap = i.uv_texcoord * _SpecularMap_ST.xy + _SpecularMap_ST.zw;
			half dotResult266_g958 = dot( normalize( (WorldNormalVector( i , normal282 )) ) , worldLight272_g958 );
			half translucencyWrap283_g958 = _Translucency;
			half lambertMask290_g958 = saturate( ( ( dotResult266_g958 * ( 1.0 - translucencyWrap283_g958 ) ) + translucencyWrap283_g958 ) );
			half temp_output_84_0_g959 = lambertMask290_g958;
			half4 temp_output_13_0_g959 = ( ( smoothstepResult22_g960 * pow( saturate( ( 1.0 - ( dotResult16_g960 * dotResult16_g960 ) ) ) , specularPower237_g958 ) ) * ( SAMPLE_TEXTURE2D( _SpecularMap, sampler_DiffuseMap, uv_SpecularMap ).g * _SpecularMultiplier ) * temp_output_84_0_g959 * _SpecularTint * alpha518 );
			float2 uv_BlendMap = i.uv_texcoord * _BlendMap_ST.xy + _BlendMap_ST.zw;
			half4 diffuseMap517 = tex2DNode19;
			half4 lerpResult41_g842 = lerp( float4( 1,1,1,0 ) , diffuseMap517 , _BaseColorStrength);
			float2 uv_RootMap = i.uv_texcoord * _RootMap_ST.xy + _RootMap_ST.zw;
			half root58 = SAMPLE_TEXTURE2D( _RootMap, sampler_DiffuseMap, uv_RootMap ).r;
			half temp_output_55_0_g842 = root58;
			half lerpResult50_g842 = lerp( temp_output_55_0_g842 , ( 1.0 - temp_output_55_0_g842 ) , _InvertRootMap);
			half4 lerpResult44_g842 = lerp( _RootColor , _EndColor , lerpResult50_g842);
			half lerpResult43_g842 = lerp( _RootColorStrength , _EndColorStrength , lerpResult50_g842);
			half4 lerpResult53_g842 = lerp( lerpResult41_g842 , lerpResult44_g842 , ( lerpResult43_g842 * _GlobalStrength ));
			half3 From8_g844 = _HighlightADistribution;
			half ID8_g844 = idMap383;
			half Fac8_g844 = _HighlightAStrength;
			half localThreePointDistribution8_g844 = ThreePointDistribution( From8_g844 , ID8_g844 , Fac8_g844 );
			half temp_output_24_0_g844 = root58;
			half lerpResult16_g844 = lerp( temp_output_24_0_g844 , ( 1.0 - temp_output_24_0_g844 ) , _HighlightAOverlapInvert);
			half4 lerpResult18_g844 = lerp( lerpResult53_g842 , _HighlightAColor , saturate( ( localThreePointDistribution8_g844 * ( 1.0 - ( _HighlightAOverlapEnd * lerpResult16_g844 ) ) * _HighlightBlend ) ));
			half3 From8_g845 = _HighlightBDistribution;
			half ID8_g845 = idMap383;
			half Fac8_g845 = _HighlightBStrength;
			half localThreePointDistribution8_g845 = ThreePointDistribution( From8_g845 , ID8_g845 , Fac8_g845 );
			half temp_output_24_0_g845 = root58;
			half lerpResult16_g845 = lerp( temp_output_24_0_g845 , ( 1.0 - temp_output_24_0_g845 ) , _HighlightBOverlapInvert);
			half4 lerpResult18_g845 = lerp( lerpResult18_g844 , _HighlightBColor , saturate( ( localThreePointDistribution8_g845 * ( 1.0 - ( _HighlightBOverlapEnd * lerpResult16_g845 ) ) * _HighlightBlend ) ));
			#ifdef BOOLEAN_ENABLECOLOR_ON
				half4 staticSwitch95 = lerpResult18_g845;
			#else
				half4 staticSwitch95 = diffuseMap517;
			#endif
			half4 blendOpSrc101 = SAMPLE_TEXTURE2D( _BlendMap, sampler_DiffuseMap, uv_BlendMap );
			half4 blendOpDest101 = ( _DiffuseStrength * staticSwitch95 );
			half4 lerpBlendMode101 = lerp(blendOpDest101,( blendOpSrc101 * blendOpDest101 ),_BlendStrength);
			half4 lerpResult112 = lerp( ( saturate( lerpBlendMode101 )) , _VertexBaseColor , ( ( 1.0 - i.vertexColor.r ) * _VertexColorStrength ));
			half4 baseColor331 = ( _DiffuseColor * lerpResult112 );
			half4 temp_output_42_0_g958 = baseColor331;
			half4 temp_output_32_0_g959 = temp_output_42_0_g958;
			half4 lerpResult36_g959 = lerp( temp_output_13_0_g959 , ( temp_output_13_0_g959 * temp_output_32_0_g959 ) , _SpecularMix);
			half3 temp_output_24_0_g959 = worldNormal86_g958;
			half dotResult82_g959 = dot( lightDIr80_g959 , temp_output_24_0_g959 );
			half temp_output_40_0_g959 = translucencyWrap283_g958;
			half dotResult54_g959 = dot( temp_output_24_0_g959 , viewDIr52_g959 );
			half dotResult57_g959 = dot( viewDIr52_g959 , lightDIr80_g959 );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			half4 ase_lightColor = 0;
			#else //aselc
			half4 ase_lightColor = _LightColor0;
			#endif //aselc
			half lerpResult629 = lerp( 1.0 , tex2DNode115.g , _AOStrength);
			half ambientOcclusion570 = lerpResult629;
			half temp_output_161_0_g958 = ambientOcclusion570;
			half lerpResult183_g958 = lerp( 1.0 , temp_output_161_0_g958 , _AOOccludeAll);
			half4 temp_output_182_0_g958 = ( ( ( lerpResult36_g959 + ( ( saturate( ( ( dotResult82_g959 * ( 1.0 - temp_output_40_0_g959 ) ) + temp_output_40_0_g959 ) ) + ( pow( ( max( ( 1.0 - abs( dotResult54_g959 ) ) , 0.0 ) * max( ( 0.0 - dotResult57_g959 ) , 0.0 ) ) , _RimPower ) * _RimTransmissionIntensity * temp_output_84_0_g959 ) ) * temp_output_32_0_g959 ) ) * ase_lightColor * ase_lightAtten ) * lerpResult183_g958 );
			UnityGI gi53_g958 = gi;
			float3 diffNorm53_g958 = worldNormal86_g958;
			gi53_g958 = UnityGI_Base( data, 1, diffNorm53_g958 );
			half3 indirectDiffuse53_g958 = gi53_g958.indirect.diffuse + diffNorm53_g958 * 0.0001;
			#ifdef UNITY_PASS_FORWARDBASE
				half4 staticSwitch250_g958 = ( temp_output_182_0_g958 + ( half4( indirectDiffuse53_g958 , 0.0 ) * temp_output_42_0_g958 * temp_output_161_0_g958 ) );
			#else
				half4 staticSwitch250_g958 = temp_output_182_0_g958;
			#endif
			float2 uv_EmissionMap = i.uv_texcoord * _EmissionMap_ST.xy + _EmissionMap_ST.zw;
			clip( alpha518 - 0.05882353);
			c.rgb = ( staticSwitch250_g958 + ( SAMPLE_TEXTURE2D( _EmissionMap, sampler_EmissionMap, uv_EmissionMap ) * _EmissiveColor ) ).rgb;
			c.a = temp_output_521_0;
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
	}
}
/*ASEBEGIN
Version=19108
Node;AmplifyShaderEditor.CommentaryNode;512;-5718.366,1661.348;Inherit;False;696.6748;494.7862;;4;26;58;383;50;Maps;0.504717,0.9903985,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;25;-5721.536,873.5989;Inherit;False;1176.518;561.6434;;8;518;517;23;22;24;21;20;19;Diffuse & Alpha;0.5235849,1,0.631946,1;0;0
Node;AmplifyShaderEditor.SamplerNode;26;-5664.931,1926.134;Inherit;True;Property;_RootMap;Root Map;33;0;Create;True;0;0;0;False;0;False;19;None;None;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;19;-5671.535,923.5991;Inherit;True;Property;_DiffuseMap;Diffuse Map;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;516;-5730.066,-1036.8;Inherit;False;2272.674;1645.196;;29;91;88;92;87;84;508;69;53;52;54;55;503;519;504;27;31;32;33;29;30;28;59;510;509;502;524;523;522;628;Hair Color Blending;0.5330188,1,0.6022252,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;58;-5245.691,1959.615;Inherit;False;root;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;517;-5312.597,999.702;Inherit;False;diffuseMap;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;31;-5612.955,-600.91;Inherit;False;Property;_RootColor;Root Color;39;0;Create;True;0;0;0;False;0;False;0.3294118,0.1411765,0.05098039,0;0.3294117,0.1411764,0.05098033,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;33;-5674.055,-876.1475;Inherit;False;Property;_BaseColorStrength;Base Color Strength;34;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-5668.135,-688.8041;Inherit;False;Property;_GlobalStrength;Global Strength;35;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;32;-5612.805,-421.4388;Inherit;False;Property;_EndColor;End Color;40;0;Create;True;0;0;0;False;0;False;0.6039216,0.454902,0.2862745,0;0.6039216,0.454902,0.2862744,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;519;-5581.311,-960.5982;Inherit;False;517;diffuseMap;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-5669.347,-147.4745;Inherit;False;Property;_EndColorStrength;End Color Strength;37;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-5666.166,-64.65891;Inherit;False;Property;_InvertRootMap;Invert Root Map;38;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;50;-5668.366,1711.348;Inherit;True;Property;_IDMap;ID Map;41;0;Create;True;0;0;0;False;0;False;19;None;None;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;27;-5671.595,-237.5661;Inherit;False;Property;_RootColorStrength;Root Color Strength;36;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;504;-5567.181,-781.3913;Inherit;False;58;root;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;523;-5087.463,-880.7275;Inherit;False;RL_Amplify_Function_Hair_RootBlend;-1;;842;3304ef6ee2139bd4cab5d899498bc3dd;0;9;52;COLOR;0,0,0,0;False;46;FLOAT;1;False;55;FLOAT;0;False;51;FLOAT;1;False;45;COLOR;0.3294118,0.1411765,0.05098039,0;False;40;COLOR;0.6039216,0.454902,0.2862745,0;False;49;FLOAT;1;False;47;FLOAT;1;False;48;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;383;-5246.238,1787.672;Inherit;False;idMap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;503;-4915.507,-514.9556;Inherit;False;383;idMap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-5014.418,58.35992;Inherit;False;Property;_HighlightAOverlapInvert;Highlight A Overlap Invert;47;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;502;-4641.802,-723.1288;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;69;-4960.777,-437.1049;Inherit;False;Property;_HighlightAColor;Highlight A Color;44;0;Create;True;0;0;0;False;0;False;0.9137255,0.7803922,0.6352941,0;0.9137255,0.7803922,0.635294,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;628;-4891.855,311.4836;Inherit;False;Property;_HighlightBlend;Highlight Blend;42;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-5017.305,-22.45101;Inherit;False;Property;_HighlightAOverlapEnd;Highlight A Overlap End;46;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;59;-4915.522,-589.2163;Inherit;False;58;root;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;52;-4972.563,-178.1671;Inherit;False;Property;_HighlightADistribution;Highlight A Distribution;45;0;Create;True;0;0;0;False;0;False;0.1,0.2,0.3;0.1,0.2,0.3;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;53;-5017.905,-259.2123;Inherit;False;Property;_HighlightAStrength;Highlight A Strength;43;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;522;-4431.044,-426.122;Inherit;False;RL_Amplify_Function_Hair_IDBlend;-1;;844;6afb608343a58854589726462adfdb8b;0;9;26;COLOR;1,1,1,0;False;24;FLOAT;0.5;False;27;FLOAT;0.5;False;25;COLOR;0.9137256,0.7803922,0.6352941,0;False;21;FLOAT;1;False;20;FLOAT3;0.1,0.2,0.3;False;22;FLOAT;1;False;23;FLOAT;1;False;28;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;509;-4259.245,-135.2632;Inherit;False;58;root;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;525;-3245.436,-222.8687;Inherit;False;622.7622;286.4321;Enable Color;2;95;520;Keyword;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;88;-4359.578,513.0045;Inherit;False;Property;_HighlightBOverlapInvert;Highlight B Overlap Invert;52;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;92;-4296.681,19.90401;Inherit;False;Property;_HighlightBColor;Highlight B Color;49;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;510;-3968.615,-191.6566;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;508;-4260.21,-59.08698;Inherit;False;383;idMap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;84;-4359.336,431.3161;Inherit;False;Property;_HighlightBOverlapEnd;Highlight B Overlap End;51;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;87;-4315.965,276.4831;Inherit;False;Property;_HighlightBDistribution;Highlight B Distribution;50;0;Create;True;0;0;0;False;0;False;0.1,0.2,0.3;0.6,0.7,0.8;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;91;-4364.522,197.3449;Inherit;False;Property;_HighlightBStrength;Highlight B Strength;48;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;121;-2526.007,-395.2434;Inherit;False;1611.361;818.9382;;16;331;96;104;97;101;105;106;107;113;98;112;99;622;380;626;627;Final Color Blending;0.514151,1,0.6056049,1;0;0
Node;AmplifyShaderEditor.FunctionNode;524;-3805.556,-56.1289;Inherit;False;RL_Amplify_Function_Hair_IDBlend;-1;;845;6afb608343a58854589726462adfdb8b;0;9;26;COLOR;1,1,1,0;False;24;FLOAT;0.5;False;27;FLOAT;0.5;False;25;COLOR;0.9137256,0.7803922,0.6352941,0;False;21;FLOAT;1;False;20;FLOAT3;0.1,0.2,0.3;False;22;FLOAT;1;False;23;FLOAT;1;False;28;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;520;-3195.436,-172.8687;Inherit;False;517;diffuseMap;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;130;-2263.5,1718.709;Inherit;False;1345.432;409.9395;;8;601;126;125;128;124;154;129;123;Smoothness;0.514151,1,0.9752312,1;0;0
Node;AmplifyShaderEditor.StaticSwitch;95;-2929.674,-76.43671;Inherit;False;Property;BOOLEAN_ENABLECOLOR;Enable Color;32;0;Create;False;0;0;0;False;0;False;0;0;0;True;BOOLEAN_ENABLECOLOR_ON;Toggle;2;Key0;Key1;Create;True;False;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;115;-2794.9,1971.228;Inherit;True;Property;_MaskMap;Mask Map;8;0;Create;True;0;0;0;False;0;False;19;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;96;-2471.786,-166.6682;Inherit;False;Property;_DiffuseStrength;Diffuse Strength;3;0;Create;True;0;0;0;False;0;False;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;104;-2146.046,182.9718;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;123;-2205.782,2010.577;Inherit;False;Property;_SmoothnessPower;Smoothness Power;11;0;Create;True;0;0;0;False;0;False;1.25;1;0.5;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-5663.463,1220.562;Inherit;False;Property;_AlphaRemap;Alpha Remap;7;0;Create;True;0;0;0;False;0;False;0.5;1;0.5;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;105;-1881.327,189.0002;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;106;-1944.258,290.4149;Inherit;False;Property;_VertexColorStrength;Vertex Color Strength;5;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;154;-2225.022,1918.368;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;98;-2016.306,-277.3997;Inherit;True;Property;_BlendMap;Blend Map;16;0;Create;True;0;0;0;False;0;False;19;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;99;-2001.331,16.97653;Inherit;False;Property;_BlendStrength;Blend Strength;17;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;97;-2160.596,-101.7776;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendOpsNode;101;-1658.146,-124.4951;Inherit;False;Multiply;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;122;-1908.03,2266.963;Inherit;False;990.7638;251.5405;;4;570;116;629;630;Ambient Occlusion;0.504717,1,0.9766926,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;107;-1625.77,230.7146;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;126;-1906.336,1884.507;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;21;-5318.46,1133.561;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;141;-1860.923,590.5557;Inherit;False;952.864;322.2571;;3;282;139;140;Normals;0.5235849,0.5572144,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;113;-1661.103,22.41703;Inherit;False;Property;_VertexBaseColor;Vertex Base Color;4;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;125;-1716.581,1853.303;Inherit;False;Property;_SmoothnessMax;Smoothness Max;13;0;Create;True;0;0;0;False;0;False;1;0.88;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;626;-1482.566,-305.8973;Inherit;False;Property;_DiffuseColor;Diffuse Color;2;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;140;-1810.923,789.8129;Inherit;False;Property;_NormalStrength;Normal Strength;15;0;Create;True;0;0;0;False;0;False;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-5293.459,1333.562;Inherit;False;Property;_AlphaPower;Alpha Power;6;0;Create;True;0;0;0;False;0;False;1;1;0.01;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;22;-5163.459,1170.561;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;124;-1715.585,1768.709;Inherit;False;Property;_SmoothnessMin;Smoothness Min;12;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;112;-1415.348,4.108437;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;116;-1845.578,2442.963;Inherit;False;Property;_AOStrength;Ambient Occlusion Strength;9;0;Create;False;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;630;-1866.226,2358.162;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;129;-1553.623,1957.382;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;573;-759.7318,-401.0714;Inherit;False;1094.991;1595.513;;19;609;263;180;177;265;384;539;385;389;482;378;569;602;571;108;572;623;625;633;Specular Highlights;1,0.7932334,0.514151,1;0;0
Node;AmplifyShaderEditor.PowerNode;23;-4967.458,1242.563;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;128;-1355.069,1836.465;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;380;-1202.927,328.3215;Inherit;False;Property;_SpecularMultiplier;Specular Strength;22;0;Create;False;0;0;0;False;0;False;1;0.5;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;629;-1474.602,2342.361;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;139;-1484.06,640.5557;Inherit;True;Property;_NormalMap;Normal Map;14;0;Create;True;0;0;0;False;0;False;19;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;627;-1232.566,-158.8973;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;601;-1122.379,1854.793;Inherit;False;smoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;136;-1553.433,1059.366;Inherit;False;621.4995;462.2001;Comment;3;133;134;135;Emission;1,0.514151,0.9428412,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;518;-4746.722,1239.47;Inherit;False;alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;282;-1114.089,709.7084;Inherit;False;normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;625;-753.3994,343.645;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;622;-1222.789,130.1398;Inherit;True;Property;_SpecularMap;Specular  Map;20;0;Create;True;0;0;0;False;0;False;19;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;570;-1143.033,2340.833;Inherit;False;ambientOcclusion;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;331;-1128.497,7.835778;Inherit;False;baseColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;177;-707.1387,433.9277;Inherit;True;Property;_FlowMap;Flow Map;18;0;Create;True;0;0;0;False;0;False;19;None;None;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;134;-1461.834,1309.566;Inherit;False;Property;_EmissiveColor;Emissive Color;31;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;633;-208.4628,755.1962;Inherit;False;518;alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;385;-682.259,775.7559;Inherit;False;Property;_SpecularShiftMin;Specular Shift Min;25;0;Create;True;0;0;0;False;0;False;-0.25;-0.25;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;133;-1503.434,1109.366;Inherit;True;Property;_EmissionMap;Emission Map;30;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;384;-580.4847,699.343;Inherit;False;383;idMap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;609;-689.9568,361.3112;Inherit;False;Property;_SpecularPower;Specular Smoothness;23;0;Create;False;0;0;0;False;0;False;2;2;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;265;-675.7505,1002.806;Inherit;False;Property;_RimTransmissionIntensity;Rim Transmission Intensity;29;0;Create;True;0;0;0;False;0;False;10;10;0;75;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;378;-628.2301,-49.07933;Inherit;False;Property;_SpecularTint;Specular Tint;21;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;569;-590.8998,-125.8811;Inherit;False;282;normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;602;-605.4546,119.9099;Inherit;False;601;smoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;623;-554.3994,267.645;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;108;-694.5977,-200.0366;Inherit;False;Property;_AOOccludeAll;AO Occlude All;10;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;263;-673.4631,1077.508;Inherit;False;Property;_RimPower;Rim Hardness;28;0;Create;False;0;0;0;False;0;False;4;2.5;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;572;-594.7292,-351.0714;Inherit;False;331;baseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;389;-679.936,851.2879;Inherit;False;Property;_SpecularShiftMax;Specular Shift Max;26;0;Create;True;0;0;0;False;0;False;0.25;0.25;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;180;-625.7612,623.3423;Inherit;False;Property;_FlowMapFlipGreen;Flow Map Flip Green;19;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;482;-692.7015,194.9869;Inherit;False;Property;_SpecularMix;Specular Mix;24;0;Create;True;0;0;0;False;0;False;1;0.5;0.5;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;571;-637.0811,-277.3754;Inherit;False;570;ambientOcclusion;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;539;-677.5486,927.3325;Inherit;False;Property;_Translucency;Translucency;27;0;Create;True;0;0;0;False;0;False;0;0.15;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;533;328.1068,1357.125;Inherit;False;352.2995;261.2863;;2;578;521;Alpha;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;651;-110.9783,9.531306;Inherit;False;RL_Amplify_Function_Hair_AnisotropicLighting_3D;-1;;958;1c2ce0d33e6d0364e94912a58b37cdd2;2,264,0,88,0;19;42;COLOR;1,1,1,0;False;161;FLOAT;1;False;178;FLOAT;1;False;84;FLOAT3;0,0,1;False;26;FLOAT3;0,0,1;False;131;COLOR;1,1,1,0;False;7;FLOAT;50;False;172;FLOAT;0;False;132;FLOAT;1;False;245;FLOAT;2;False;108;COLOR;0,0,0,0;False;112;FLOAT;0;False;71;FLOAT;0.5;False;75;FLOAT;-0.1;False;80;FLOAT;0.1;False;282;FLOAT;0;False;207;FLOAT;0;False;208;FLOAT;0;False;310;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;135;-1093.935,1191.266;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;521;472.1129,1407.031;Inherit;False;518;alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;578;373.4657,1503.249;Inherit;False;Constant;_TransparencyAlphaClip0;Transparency Alpha Clip 0;49;0;Create;True;0;0;0;False;0;False;0.05882353;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;574;668.0759,1164.947;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClipNode;612;829.2889,1249.731;Inherit;False;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;611;1122.054,1161.637;Half;False;True;-1;2;;0;0;CustomLighting;Reallusion/Amplify/RL_HairShader_2nd_Pass_Variants_3D;False;False;False;False;False;False;False;False;False;False;True;False;False;False;True;False;False;False;False;False;False;Off;2;False;;1;False;;False;0;False;;0;False;;False;1;Custom;0;True;False;0;True;Transparent;AlphaZLess;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;False;2;5;False;;10;False;;0;7;False;;8;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;1;alpha:fade;0;False;0.1;False;;0;False;;True;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;58;0;26;1
WireConnection;517;0;19;0
WireConnection;523;52;519;0
WireConnection;523;46;33;0
WireConnection;523;55;504;0
WireConnection;523;51;30;0
WireConnection;523;45;31;0
WireConnection;523;40;32;0
WireConnection;523;49;27;0
WireConnection;523;47;28;0
WireConnection;523;48;29;0
WireConnection;383;0;50;1
WireConnection;502;0;523;0
WireConnection;522;26;502;0
WireConnection;522;24;59;0
WireConnection;522;27;503;0
WireConnection;522;25;69;0
WireConnection;522;21;53;0
WireConnection;522;20;52;0
WireConnection;522;22;54;0
WireConnection;522;23;55;0
WireConnection;522;28;628;0
WireConnection;510;0;522;0
WireConnection;524;26;510;0
WireConnection;524;24;509;0
WireConnection;524;27;508;0
WireConnection;524;25;92;0
WireConnection;524;21;91;0
WireConnection;524;20;87;0
WireConnection;524;22;84;0
WireConnection;524;23;88;0
WireConnection;524;28;628;0
WireConnection;95;1;520;0
WireConnection;95;0;524;0
WireConnection;105;0;104;1
WireConnection;154;0;115;4
WireConnection;97;0;96;0
WireConnection;97;1;95;0
WireConnection;101;0;98;0
WireConnection;101;1;97;0
WireConnection;101;2;99;0
WireConnection;107;0;105;0
WireConnection;107;1;106;0
WireConnection;126;0;154;0
WireConnection;126;1;123;0
WireConnection;21;0;19;4
WireConnection;21;1;20;0
WireConnection;22;0;21;0
WireConnection;112;0;101;0
WireConnection;112;1;113;0
WireConnection;112;2;107;0
WireConnection;630;0;115;2
WireConnection;129;0;126;0
WireConnection;23;0;22;0
WireConnection;23;1;24;0
WireConnection;128;0;124;0
WireConnection;128;1;125;0
WireConnection;128;2;129;0
WireConnection;629;1;630;0
WireConnection;629;2;116;0
WireConnection;139;5;140;0
WireConnection;627;0;626;0
WireConnection;627;1;112;0
WireConnection;601;0;128;0
WireConnection;518;0;23;0
WireConnection;282;0;139;0
WireConnection;625;0;380;0
WireConnection;570;0;629;0
WireConnection;331;0;627;0
WireConnection;623;0;622;2
WireConnection;623;1;625;0
WireConnection;651;42;572;0
WireConnection;651;161;571;0
WireConnection;651;178;108;0
WireConnection;651;84;569;0
WireConnection;651;131;378;0
WireConnection;651;7;602;0
WireConnection;651;172;482;0
WireConnection;651;132;623;0
WireConnection;651;245;609;0
WireConnection;651;108;177;0
WireConnection;651;112;180;0
WireConnection;651;71;384;0
WireConnection;651;75;385;0
WireConnection;651;80;389;0
WireConnection;651;282;539;0
WireConnection;651;207;265;0
WireConnection;651;208;263;0
WireConnection;651;310;633;0
WireConnection;135;0;133;0
WireConnection;135;1;134;0
WireConnection;574;0;651;0
WireConnection;574;1;135;0
WireConnection;612;0;574;0
WireConnection;612;1;521;0
WireConnection;612;2;578;0
WireConnection;611;9;521;0
WireConnection;611;13;612;0
ASEEND*/
//CHKSM=8671DBF9AA15F16C4FB2B11E1EC61BFC3224646F