// Made with Amplify Shader Editor v1.9.1.8
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Reallusion/Amplify/RL_HeadShaderWrinkle_Baked_3D_Tessellation"
{
	Properties
	{
		_EdgeLength ( "Edge length", Range( 2, 50 ) ) = 15
		_TessPhongStrength( "Phong Tess Strength", Range( 0, 1 ) ) = 0.5
		_MainTex("Main Tex", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,0)
		_MetallicGlossMap("Metallic Gloss Map", 2D) = "white" {}
		_Metallic("Metallic", Range( 0 , 1)) = 0
		_GlossMapScale("Gloss Map Scale", Range( 0 , 1)) = 1
		_BumpMap("Bump Map", 2D) = "bump" {}
		_BumpScale("Bump Scale", Range( 0 , 2)) = 1
		_OcclusionMap("Occlusion Map", 2D) = "white" {}
		_OcclusionStrength("Occlusion Strength", Range( 0 , 1)) = 1
		_EmissionMap("Emission Map", 2D) = "white" {}
		[HDR]_EmissionColor("Emission Color", Color) = (0,0,0,0)
		_SubsurfaceMaskMap("Subsurface Mask Map", 2D) = "white" {}
		_SubsurfaceMask("Subsurface Mask", Range( 0 , 1)) = 1
		_ThicknessMap("Tramsission Map", 2D) = "white" {}
		_Thickness("Transmission", Range( 0 , 2)) = 1
		_SubsurfaceFalloff("Subsurface Falloff", Color) = (1,1,1,0)
		_DetailMask("Detail Mask", 2D) = "white" {}
		_DetailNormalMap("Detail Normal Map", 2D) = "bump" {}
		_DetailNormalMapScale("Detail Normal Map Scale", Range( 0 , 2)) = 1
		[Header(Translucency)]
		_Translucency("Strength", Range( 0 , 50)) = 1
		_TransNormalDistortion("Normal Distortion", Range( 0 , 1)) = 0.1
		_TransScattering("Scaterring Falloff", Range( 1 , 50)) = 2
		_TransDirect("Direct", Range( 0 , 1)) = 1
		_TransAmbient("Ambient", Range( 0 , 1)) = 0.2
		_TransShadow("Shadow", Range( 0 , 1)) = 0.9
		[Toggle(BOOLEAN_USE_WRINKLE_ON)] BOOLEAN_USE_WRINKLE("Use Wrinkle", Float) = 0
		_WrinkleMaskSet1A("Wrinkle Mask Set 1A", 2D) = "black" {}
		_WrinkleMaskSet1B("Wrinkle Mask Set 1B", 2D) = "black" {}
		_WrinkleMaskSet2("Wrinkle Mask Set 2", 2D) = "black" {}
		_WrinkleMaskSet3("Wrinkle Mask Set 3", 2D) = "black" {}
		_WrinkleMaskSet123("Wrinkle Mask Set 123", 2D) = "black" {}
		_WrinkleDiffuseBlend1("Wrinkle Diffuse Blend 1", 2D) = "white" {}
		_WrinkleDiffuseBlend2("Wrinkle Diffuse Blend 2", 2D) = "white" {}
		_WrinkleDiffuseBlend3("Wrinkle Diffuse Blend 3", 2D) = "white" {}
		_WrinkleSmoothnessPack("Wrinkle Smoothness Pack", 2D) = "gray" {}
		_WrinkleFlowPack("Wrinkle Flow Pack", 2D) = "white" {}
		[Normal]_WrinkleNormalBlend1("Wrinkle Normal Blend 1", 2D) = "bump" {}
		[Normal]_WrinkleNormalBlend2("Wrinkle Normal Blend 2", 2D) = "bump" {}
		[Normal]_WrinkleNormalBlend3("Wrinkle Normal Blend 3", 2D) = "bump" {}
		_WrinkleValueSet1AL("Wrinkle Value Set 1A Left", Vector) = (0,0,0,0)
		_WrinkleValueSet1BL("Wrinkle Value Set 1B Left", Vector) = (0,0,0,0)
		_WrinkleValueSet2L("Wrinkle Value Set 2 Left", Vector) = (0,0,0,0)
		_WrinkleValueSet3L("Wrinkle Value Set 3 Left", Vector) = (0,0,0,0)
		_WrinkleValueSet12CL("Wrinkle Value Set 12C Left", Vector) = (0,0,0,0)
		_WrinkleValueSet1AR("Wrinkle Value Set 1A Right", Vector) = (0,0,0,0)
		_WrinkleValueSet1BR("Wrinkle Value Set 1B Right", Vector) = (0,0,0,0)
		_WrinkleValueSet2R("Wrinkle Value Set 2 Right", Vector) = (0,0,0,0)
		_WrinkleValueSet3R("Wrinkle Value Set 3 Right", Vector) = (0,0,0,0)
		_WrinkleValueSet12CR("Wrinkle Value Set 12C Right", Vector) = (0,0,0,0)
		_WrinkleValueSet3DB("Wrinkle Value Set 3D Both", Vector) = (0,0,0,0)
		_WrinkleValueSetBCCB("Wrinkle Value Set BCC Both", Vector) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityStandardUtils.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Tessellation.cginc"
		#pragma target 4.6
		#pragma multi_compile_local __ BOOLEAN_USE_WRINKLE_ON
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

		#pragma surface surf StandardCustom keepalpha addshadow fullforwardshadows exclude_path:deferred vertex:vertexDataFunc tessellate:tessFunction tessphong:_TessPhongStrength 
		struct Input
		{
			float2 uv_texcoord;
		};

		struct SurfaceOutputStandardCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			half3 Transmission;
			half3 Translucency;
		};

		UNITY_DECLARE_TEX2D_NOSAMPLER(_BumpMap);
		uniform half4 _BumpMap_ST;
		SamplerState sampler_BumpMap;
		uniform half _BumpScale;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_WrinkleNormalBlend1);
		uniform half4 _WrinkleNormalBlend1_ST;
		SamplerState sampler_Linear_Repeat;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_WrinkleFlowPack);
		uniform half4 _WrinkleFlowPack_ST;
		uniform half4 _WrinkleValueSet12CL;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_WrinkleMaskSet123);
		uniform half4 _WrinkleMaskSet123_ST;
		uniform half4 _WrinkleValueSet1AL;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_WrinkleMaskSet1A);
		uniform half4 _WrinkleMaskSet1A_ST;
		uniform half4 _WrinkleValueSet1BL;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_WrinkleMaskSet1B);
		uniform half4 _WrinkleMaskSet1B_ST;
		uniform half4 _WrinkleValueSet1AR;
		uniform half4 _WrinkleValueSet1BR;
		uniform half4 _WrinkleValueSet12CR;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_WrinkleNormalBlend2);
		uniform half4 _WrinkleNormalBlend2_ST;
		uniform half4 _WrinkleValueSet2L;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_WrinkleMaskSet2);
		uniform half4 _WrinkleMaskSet2_ST;
		uniform half4 _WrinkleValueSet2R;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_WrinkleNormalBlend3);
		uniform half4 _WrinkleNormalBlend3_ST;
		uniform half4 _WrinkleValueSetBCCB;
		uniform half4 _WrinkleValueSet3DB;
		uniform half4 _WrinkleValueSet3L;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_WrinkleMaskSet3);
		uniform half4 _WrinkleMaskSet3_ST;
		uniform half4 _WrinkleValueSet3R;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_DetailNormalMap);
		uniform half4 _DetailNormalMap_ST;
		SamplerState sampler_DetailNormalMap;
		uniform half _DetailNormalMapScale;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_DetailMask);
		uniform half4 _DetailMask_ST;
		uniform half4 _Color;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_MainTex);
		uniform half4 _MainTex_ST;
		SamplerState sampler_MainTex;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_WrinkleDiffuseBlend1);
		uniform half4 _WrinkleDiffuseBlend1_ST;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_WrinkleDiffuseBlend2);
		uniform half4 _WrinkleDiffuseBlend2_ST;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_WrinkleDiffuseBlend3);
		uniform half4 _WrinkleDiffuseBlend3_ST;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_EmissionMap);
		uniform half4 _EmissionMap_ST;
		uniform half4 _EmissionColor;
		uniform half _Metallic;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_MetallicGlossMap);
		uniform half4 _MetallicGlossMap_ST;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_WrinkleSmoothnessPack);
		uniform half4 _WrinkleSmoothnessPack_ST;
		uniform half _GlossMapScale;
		uniform half _OcclusionStrength;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_OcclusionMap);
		uniform half4 _OcclusionMap_ST;
		uniform half _Thickness;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_ThicknessMap);
		uniform half4 _ThicknessMap_ST;
		uniform half4 _SubsurfaceFalloff;
		uniform half _Translucency;
		uniform half _TransNormalDistortion;
		uniform half _TransScattering;
		uniform half _TransDirect;
		uniform half _TransAmbient;
		uniform half _TransShadow;
		uniform half _SubsurfaceMask;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_SubsurfaceMaskMap);
		uniform half4 _SubsurfaceMaskMap_ST;
		uniform float _EdgeLength;
		uniform float _TessPhongStrength;


		half3 MinMaxDeltaBlend3183_g17( half3 In, half3 In1, half3 In2, half3 In3 )
		{
			return max(max(In1, In2), In3) + min(min(In1, In2), In3) + In;
		}


		half4 MinMaxDeltaBlend4181_g17( half4 In, half4 In1, half4 In2, half4 In3 )
		{
			return max(max(In1, In2), In3) + min(min(In1, In2), In3) + In;
		}


		half MinMaxDeltaBlend1182_g17( half In, half In1, half In2, half In3 )
		{
			return max(max(In1, In2), In3) + min(min(In1, In2), In3) + In;
		}


		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			return UnityEdgeLengthBasedTess (v0.vertex, v1.vertex, v2.vertex, _EdgeLength);
		}

		void vertexDataFunc( inout appdata_full v )
		{
		}

		inline half4 LightingStandardCustom(SurfaceOutputStandardCustom s, half3 viewDir, UnityGI gi )
		{
			#if !defined(DIRECTIONAL)
			float3 lightAtten = gi.light.color;
			#else
			float3 lightAtten = lerp( _LightColor0.rgb, gi.light.color, _TransShadow );
			#endif
			half3 lightDir = gi.light.dir + s.Normal * _TransNormalDistortion;
			half transVdotL = pow( saturate( dot( viewDir, -lightDir ) ), _TransScattering );
			half3 translucency = lightAtten * (transVdotL * _TransDirect + gi.indirect.diffuse * _TransAmbient) * s.Translucency;
			half4 c = half4( s.Albedo * translucency * _Translucency, 0 );

			half3 transmission = max(0 , -dot(s.Normal, gi.light.dir)) * gi.light.color * s.Transmission;
			half4 d = half4(s.Albedo * transmission , 0);

			SurfaceOutputStandard r;
			r.Albedo = s.Albedo;
			r.Normal = s.Normal;
			r.Emission = s.Emission;
			r.Metallic = s.Metallic;
			r.Smoothness = s.Smoothness;
			r.Occlusion = s.Occlusion;
			r.Alpha = s.Alpha;
			return LightingStandard (r, viewDir, gi) + c + d;
		}

		inline void LightingStandardCustom_GI(SurfaceOutputStandardCustom s, UnityGIInput data, inout UnityGI gi )
		{
			#if defined(UNITY_PASS_DEFERRED) && UNITY_ENABLE_REFLECTION_BUFFERS
				gi = UnityGlobalIllumination(data, s.Occlusion, s.Normal);
			#else
				UNITY_GLOSSY_ENV_FROM_SURFACE( g, s, data );
				gi = UnityGlobalIllumination( data, s.Occlusion, s.Normal, g );
			#endif
		}

		void surf( Input i , inout SurfaceOutputStandardCustom o )
		{
			float2 uv_BumpMap = i.uv_texcoord * _BumpMap_ST.xy + _BumpMap_ST.zw;
			half normalMapScale259 = _BumpScale;
			half3 normalMap218 = UnpackScaleNormal( SAMPLE_TEXTURE2D( _BumpMap, sampler_BumpMap, uv_BumpMap ), normalMapScale259 );
			half3 normal186_g17 = normalMap218;
			half3 In183_g17 = normal186_g17;
			float2 uv_WrinkleNormalBlend1 = i.uv_texcoord * _WrinkleNormalBlend1_ST.xy + _WrinkleNormalBlend1_ST.zw;
			float2 uv_WrinkleFlowPack = i.uv_texcoord * _WrinkleFlowPack_ST.xy + _WrinkleFlowPack_ST.zw;
			half4 tex2DNode260 = SAMPLE_TEXTURE2D( _WrinkleFlowPack, sampler_Linear_Repeat, uv_WrinkleFlowPack );
			half temp_output_1_0_g19 = 0.49;
			half leftMask27_g17 = saturate( ( ( i.uv_texcoord.x - temp_output_1_0_g19 ) / ( 0.51 - temp_output_1_0_g19 ) ) );
			half4 break107_g17 = _WrinkleValueSet12CL;
			half2 appendResult112_g17 = (half2(break107_g17.x , break107_g17.y));
			float2 uv_WrinkleMaskSet123 = i.uv_texcoord * _WrinkleMaskSet123_ST.xy + _WrinkleMaskSet123_ST.zw;
			half4 break109_g17 = SAMPLE_TEXTURE2D( _WrinkleMaskSet123, sampler_Linear_Repeat, uv_WrinkleMaskSet123 );
			half2 appendResult115_g17 = (half2(break109_g17.x , break109_g17.y));
			half dotResult121_g17 = dot( appendResult112_g17 , appendResult115_g17 );
			half value1CLeft135_g17 = dotResult121_g17;
			float2 uv_WrinkleMaskSet1A = i.uv_texcoord * _WrinkleMaskSet1A_ST.xy + _WrinkleMaskSet1A_ST.zw;
			half4 maskSet1A214_g17 = SAMPLE_TEXTURE2D( _WrinkleMaskSet1A, sampler_Linear_Repeat, uv_WrinkleMaskSet1A );
			half dotResult29_g17 = dot( _WrinkleValueSet1AL , maskSet1A214_g17 );
			float2 uv_WrinkleMaskSet1B = i.uv_texcoord * _WrinkleMaskSet1B_ST.xy + _WrinkleMaskSet1B_ST.zw;
			half4 temp_output_16_0_g17 = SAMPLE_TEXTURE2D( _WrinkleMaskSet1B, sampler_Linear_Repeat, uv_WrinkleMaskSet1B );
			half dotResult35_g17 = dot( _WrinkleValueSet1BL , temp_output_16_0_g17 );
			half dotResult30_g17 = dot( maskSet1A214_g17 , _WrinkleValueSet1AR );
			half dotResult36_g17 = dot( temp_output_16_0_g17 , _WrinkleValueSet1BR );
			half4 break108_g17 = _WrinkleValueSet12CR;
			half2 appendResult117_g17 = (half2(break108_g17.x , break108_g17.y));
			half dotResult122_g17 = dot( appendResult115_g17 , appendResult117_g17 );
			half value1CRight136_g17 = dotResult122_g17;
			half temp_output_1_0_g18 = 0.51;
			half rightMask28_g17 = saturate( ( ( i.uv_texcoord.x - temp_output_1_0_g18 ) / ( 0.49 - temp_output_1_0_g18 ) ) );
			half temp_output_16_0_g70 = ( ( leftMask27_g17 * ( value1CLeft135_g17 + dotResult29_g17 + dotResult35_g17 ) ) + ( ( dotResult30_g17 + dotResult36_g17 + value1CRight136_g17 ) * rightMask28_g17 ) );
			half temp_output_23_0_g70 = ( saturate( ( tex2DNode260.r + temp_output_16_0_g70 ) ) * temp_output_16_0_g70 );
			half3 In1183_g17 = ( ( UnpackScaleNormal( SAMPLE_TEXTURE2D( _WrinkleNormalBlend1, sampler_Linear_Repeat, uv_WrinkleNormalBlend1 ), normalMapScale259 ) - normal186_g17 ) * temp_output_23_0_g70 );
			float2 uv_WrinkleNormalBlend2 = i.uv_texcoord * _WrinkleNormalBlend2_ST.xy + _WrinkleNormalBlend2_ST.zw;
			half2 appendResult113_g17 = (half2(break107_g17.z , break107_g17.w));
			half2 appendResult114_g17 = (half2(break109_g17.z , break109_g17.w));
			half dotResult123_g17 = dot( appendResult113_g17 , appendResult114_g17 );
			half value2CLeft137_g17 = dotResult123_g17;
			float2 uv_WrinkleMaskSet2 = i.uv_texcoord * _WrinkleMaskSet2_ST.xy + _WrinkleMaskSet2_ST.zw;
			half4 temp_output_17_0_g17 = SAMPLE_TEXTURE2D( _WrinkleMaskSet2, sampler_Linear_Repeat, uv_WrinkleMaskSet2 );
			half dotResult41_g17 = dot( _WrinkleValueSet2L , temp_output_17_0_g17 );
			half dotResult42_g17 = dot( temp_output_17_0_g17 , _WrinkleValueSet2R );
			half2 appendResult116_g17 = (half2(break108_g17.z , break108_g17.w));
			half dotResult124_g17 = dot( appendResult114_g17 , appendResult116_g17 );
			half value2CRight138_g17 = dotResult124_g17;
			half temp_output_16_0_g71 = ( ( leftMask27_g17 * ( value2CLeft137_g17 + dotResult41_g17 ) ) + ( ( dotResult42_g17 + value2CRight138_g17 ) * rightMask28_g17 ) );
			half temp_output_23_0_g71 = ( saturate( ( tex2DNode260.g + temp_output_16_0_g71 ) ) * temp_output_16_0_g71 );
			half3 In2183_g17 = ( ( UnpackScaleNormal( SAMPLE_TEXTURE2D( _WrinkleNormalBlend2, sampler_Linear_Repeat, uv_WrinkleNormalBlend2 ), normalMapScale259 ) - normal186_g17 ) * temp_output_23_0_g71 );
			float2 uv_WrinkleNormalBlend3 = i.uv_texcoord * _WrinkleNormalBlend3_ST.xy + _WrinkleNormalBlend3_ST.zw;
			half4 break211_g17 = _WrinkleValueSetBCCB;
			half valueBCCLeft217_g17 = ( break211_g17.x * maskSet1A214_g17.y );
			half4 break118_g17 = _WrinkleValueSet3DB;
			half2 appendResult120_g17 = (half2(break118_g17.x , break118_g17.y));
			half dotResult127_g17 = dot( appendResult120_g17 , appendResult115_g17 );
			half value3DLeft129_g17 = dotResult127_g17;
			float2 uv_WrinkleMaskSet3 = i.uv_texcoord * _WrinkleMaskSet3_ST.xy + _WrinkleMaskSet3_ST.zw;
			half4 temp_output_18_0_g17 = SAMPLE_TEXTURE2D( _WrinkleMaskSet3, sampler_Linear_Repeat, uv_WrinkleMaskSet3 );
			half dotResult47_g17 = dot( _WrinkleValueSet3L , temp_output_18_0_g17 );
			half dotResult48_g17 = dot( temp_output_18_0_g17 , _WrinkleValueSet3R );
			half2 appendResult119_g17 = (half2(break118_g17.z , break118_g17.w));
			half dotResult128_g17 = dot( appendResult115_g17 , appendResult119_g17 );
			half value3DRight130_g17 = dotResult128_g17;
			half valueBCCRight219_g17 = ( maskSet1A214_g17.y * break211_g17.y );
			half temp_output_16_0_g69 = ( ( leftMask27_g17 * ( valueBCCLeft217_g17 + value3DLeft129_g17 + dotResult47_g17 ) ) + ( ( dotResult48_g17 + value3DRight130_g17 + valueBCCRight219_g17 ) * rightMask28_g17 ) );
			half temp_output_23_0_g69 = ( saturate( ( tex2DNode260.b + temp_output_16_0_g69 ) ) * temp_output_16_0_g69 );
			half3 In3183_g17 = ( ( UnpackScaleNormal( SAMPLE_TEXTURE2D( _WrinkleNormalBlend3, sampler_Linear_Repeat, uv_WrinkleNormalBlend3 ), normalMapScale259 ) - normal186_g17 ) * temp_output_23_0_g69 );
			half3 localMinMaxDeltaBlend3183_g17 = MinMaxDeltaBlend3183_g17( In183_g17 , In1183_g17 , In2183_g17 , In3183_g17 );
			half3 normalWrinkle231 = localMinMaxDeltaBlend3183_g17;
			#ifdef BOOLEAN_USE_WRINKLE_ON
				half3 staticSwitch220 = normalWrinkle231;
			#else
				half3 staticSwitch220 = normalMap218;
			#endif
			float2 uv_DetailNormalMap = i.uv_texcoord * _DetailNormalMap_ST.xy + _DetailNormalMap_ST.zw;
			float2 uv_DetailMask = i.uv_texcoord * _DetailMask_ST.xy + _DetailMask_ST.zw;
			o.Normal = BlendNormals( staticSwitch220 , UnpackScaleNormal( SAMPLE_TEXTURE2D( _DetailNormalMap, sampler_DetailNormalMap, uv_DetailNormalMap ), ( _DetailNormalMapScale * SAMPLE_TEXTURE2D( _DetailMask, sampler_Linear_Repeat, uv_DetailMask ).g ) ) );
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			half4 diffuseMap216 = SAMPLE_TEXTURE2D( _MainTex, sampler_MainTex, uv_MainTex );
			half4 diffuse184_g17 = diffuseMap216;
			half4 In181_g17 = diffuse184_g17;
			float2 uv_WrinkleDiffuseBlend1 = i.uv_texcoord * _WrinkleDiffuseBlend1_ST.xy + _WrinkleDiffuseBlend1_ST.zw;
			half4 In1181_g17 = ( ( SAMPLE_TEXTURE2D( _WrinkleDiffuseBlend1, sampler_Linear_Repeat, uv_WrinkleDiffuseBlend1 ) - diffuse184_g17 ) * temp_output_23_0_g70 );
			float2 uv_WrinkleDiffuseBlend2 = i.uv_texcoord * _WrinkleDiffuseBlend2_ST.xy + _WrinkleDiffuseBlend2_ST.zw;
			half4 In2181_g17 = ( ( SAMPLE_TEXTURE2D( _WrinkleDiffuseBlend2, sampler_Linear_Repeat, uv_WrinkleDiffuseBlend2 ) - diffuse184_g17 ) * temp_output_23_0_g71 );
			float2 uv_WrinkleDiffuseBlend3 = i.uv_texcoord * _WrinkleDiffuseBlend3_ST.xy + _WrinkleDiffuseBlend3_ST.zw;
			half4 In3181_g17 = ( ( SAMPLE_TEXTURE2D( _WrinkleDiffuseBlend3, sampler_Linear_Repeat, uv_WrinkleDiffuseBlend3 ) - diffuse184_g17 ) * temp_output_23_0_g69 );
			half4 localMinMaxDeltaBlend4181_g17 = MinMaxDeltaBlend4181_g17( In181_g17 , In1181_g17 , In2181_g17 , In3181_g17 );
			half4 diffuseWrinkle229 = localMinMaxDeltaBlend4181_g17;
			#ifdef BOOLEAN_USE_WRINKLE_ON
				half4 staticSwitch217 = diffuseWrinkle229;
			#else
				half4 staticSwitch217 = diffuseMap216;
			#endif
			half4 baseColor200 = ( _Color * staticSwitch217 );
			o.Albedo = baseColor200.rgb;
			float2 uv_EmissionMap = i.uv_texcoord * _EmissionMap_ST.xy + _EmissionMap_ST.zw;
			o.Emission = ( SAMPLE_TEXTURE2D( _EmissionMap, sampler_Linear_Repeat, uv_EmissionMap ) * _EmissionColor ).rgb;
			float2 uv_MetallicGlossMap = i.uv_texcoord * _MetallicGlossMap_ST.xy + _MetallicGlossMap_ST.zw;
			half4 tex2DNode150 = SAMPLE_TEXTURE2D( _MetallicGlossMap, sampler_Linear_Repeat, uv_MetallicGlossMap );
			o.Metallic = ( _Metallic * tex2DNode150.g );
			half smoothnessMap221 = tex2DNode150.a;
			half smoothness185_g17 = smoothnessMap221;
			half In182_g17 = smoothness185_g17;
			float2 uv_WrinkleSmoothnessPack = i.uv_texcoord * _WrinkleSmoothnessPack_ST.xy + _WrinkleSmoothnessPack_ST.zw;
			half4 tex2DNode252 = SAMPLE_TEXTURE2D( _WrinkleSmoothnessPack, sampler_Linear_Repeat, uv_WrinkleSmoothnessPack );
			half In1182_g17 = ( ( tex2DNode252.r - smoothness185_g17 ) * temp_output_23_0_g70 );
			half In2182_g17 = ( ( tex2DNode252.g - smoothness185_g17 ) * temp_output_23_0_g71 );
			half In3182_g17 = ( ( tex2DNode252.b - smoothness185_g17 ) * temp_output_23_0_g69 );
			half localMinMaxDeltaBlend1182_g17 = MinMaxDeltaBlend1182_g17( In182_g17 , In1182_g17 , In2182_g17 , In3182_g17 );
			half smoothnessWrinkle230 = localMinMaxDeltaBlend1182_g17;
			#ifdef BOOLEAN_USE_WRINKLE_ON
				half staticSwitch223 = smoothnessWrinkle230;
			#else
				half staticSwitch223 = smoothnessMap221;
			#endif
			o.Smoothness = ( staticSwitch223 * _GlossMapScale );
			float2 uv_OcclusionMap = i.uv_texcoord * _OcclusionMap_ST.xy + _OcclusionMap_ST.zw;
			o.Occlusion = ( 1.0 - ( _OcclusionStrength * ( 1.0 - SAMPLE_TEXTURE2D( _OcclusionMap, sampler_Linear_Repeat, uv_OcclusionMap ).g ) ) );
			float2 uv_ThicknessMap = i.uv_texcoord * _ThicknessMap_ST.xy + _ThicknessMap_ST.zw;
			half4 temp_output_214_0 = ( _SubsurfaceFalloff * baseColor200 );
			o.Transmission = ( _Thickness * SAMPLE_TEXTURE2D( _ThicknessMap, sampler_Linear_Repeat, uv_ThicknessMap ) * temp_output_214_0 ).rgb;
			float2 uv_SubsurfaceMaskMap = i.uv_texcoord * _SubsurfaceMaskMap_ST.xy + _SubsurfaceMaskMap_ST.zw;
			o.Translucency = ( _SubsurfaceMask * 0.5 * SAMPLE_TEXTURE2D( _SubsurfaceMaskMap, sampler_Linear_Repeat, uv_SubsurfaceMaskMap ) * temp_output_214_0 ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
}
/*ASEBEGIN
Version=19108
Node;AmplifyShaderEditor.CommentaryNode;179;-1904.055,1265.129;Inherit;False;1263.896;335.3456;Comment;6;172;171;169;170;151;266;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;176;-2396.917,-618.7704;Inherit;False;1740.638;654.7353;Comment;12;219;218;220;146;153;156;147;154;155;148;259;263;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;175;-2017.212,-1175.145;Inherit;False;1360.688;491.4623;Comment;7;200;174;173;145;215;216;217;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;151;-1598.736,1343.848;Inherit;True;Property;_OcclusionMap;Occlusion Map;12;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;170;-1213.159,1462.129;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;178;-2154.179,686.485;Inherit;False;1509.063;529.1631;Comment;10;223;222;221;150;224;164;168;167;165;265;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;173;-1448.932,-1125.145;Inherit;False;Property;_Color;Color;6;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;197;-1513.398,1656.15;Inherit;False;889.1161;1062.981;Comment;11;190;195;189;194;193;214;213;211;192;196;267;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;169;-1286.159,1315.129;Inherit;False;Property;_OcclusionStrength;Occlusion Strength;13;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;177;-1558.196,114.3046;Inherit;False;910.4177;463.6811;Comment;4;264;158;149;157;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;171;-983.1591,1362.129;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;174;-1108.525,-959.8234;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;157;-1137.681,376.9857;Inherit;False;Property;_EmissionColor;Emission Color;15;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;165;-1174.212,736.485;Inherit;False;Property;_Metallic;Metallic;8;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;148;-1315.187,-353.4468;Inherit;True;Property;_DetailNormalMap;Detail Normal Map;22;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;149;-1220.196,164.3046;Inherit;True;Property;_EmissionMap;Emission Map;14;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;200;-875.3445,-915.9561;Inherit;False;baseColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;167;-807.7693,806.5468;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;196;-805.146,1767.444;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;168;-807.1151,939.4771;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;158;-809.778,294.0263;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendNormalsNode;155;-884.2813,-458.5963;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;172;-819.1592,1365.129;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;207;-139.0539,516.7986;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;208;-142.2709,592.3815;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;203;-141.0717,108.4694;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;209;-140.9079,696.5897;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;210;-136.0006,788.8021;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;204;-143.0898,217.2567;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;205;-142.3788,327.9482;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;206;-142.4345,411.0686;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;192;-1189.487,2028.771;Inherit;False;Property;_SubsurfaceMask;Subsurface Mask;17;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;211;-1202.998,2408.775;Inherit;False;Property;_SubsurfaceFalloff;Subsurface Falloff;20;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;213;-1175.583,2596.151;Inherit;False;200;baseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;214;-976.5835,2475.151;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;193;-789.0947,2114.271;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;194;-1187.487,2115.57;Inherit;False;Constant;_ConstTranslucencyWrap;Const Translucency Wrap;17;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;189;-1205.472,2203.485;Inherit;True;Property;_SubsurfaceMaskMap;Subsurface Mask Map;16;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;195;-1176.749,1725.444;Inherit;False;Property;_Thickness;Transmission;19;0;Create;False;0;0;0;False;0;False;1;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;190;-1196.935,1821.459;Inherit;True;Property;_ThicknessMap;Tramsission Map;18;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;202;322.3807,257.9512;Half;False;True;-1;6;;0;0;Standard;Reallusion/Amplify/RL_HeadShaderWrinkle_Baked_3D_Tessellation;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;ForwardOnly;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;2;15;10;25;True;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;24;-1;0;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;True;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.SamplerNode;145;-2007.219,-919.5163;Inherit;True;Property;_MainTex;Main Tex;5;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;217;-1443.549,-872.3288;Inherit;False;Property;BOOLEAN_USE_WRINKLE;Use Wrinkle;31;0;Create;False;0;0;0;False;0;False;1;0;0;True;BOOLEAN_USE_WRINKLE_ON;Toggle;2;Key0;Key1;Create;True;False;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;154;-2110.44,-297.8357;Inherit;False;Property;_DetailNormalMapScale;Detail Normal Map Scale;23;0;Create;True;0;0;0;False;0;False;1;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;156;-1741.162,-239.0549;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;146;-1765.358,-564.0937;Inherit;True;Property;_BumpMap;Bump Map;10;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;164;-1171.638,1087.455;Inherit;False;Property;_GlossMapScale;Gloss Map Scale;9;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;225;-5196.062,-617.9283;Inherit;False;2700.847;2041.228;;34;226;228;227;244;252;251;250;249;248;247;246;245;243;242;241;240;239;238;237;236;235;234;233;232;231;230;229;254;255;256;257;260;261;262;Wrinkle System;1,0.5137255,0.7779443,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;229;-2780.533,-255.9874;Inherit;False;diffuseWrinkle;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;230;-2800.533,-141.9883;Inherit;False;smoothnessWrinkle;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;231;-2785.533,-31.98799;Inherit;False;normalWrinkle;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;224;-1461.594,834.7779;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;150;-1813.843,830.624;Inherit;True;Property;_MetallicGlossMap;Metallic Gloss Map;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;220;-1214.007,-528.2222;Inherit;False;Property;BOOLEAN_USE_WRINKLE1;Use Wrinkle;31;0;Create;False;0;0;0;False;0;False;0;0;0;True;BOOLEAN_USE_WRINKLE_ON;Toggle;2;Key0;Key1;Reference;217;True;False;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;216;-1662.571,-903.2975;Inherit;False;diffuseMap;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;215;-1662.778,-814.576;Inherit;False;229;diffuseWrinkle;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;218;-1453.549,-562.6266;Inherit;False;normalMap;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;219;-1454.242,-478.0932;Inherit;False;231;normalWrinkle;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;221;-1459.931,922.4847;Inherit;False;smoothnessMap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;222;-1466.332,1009.746;Inherit;False;230;smoothnessWrinkle;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;223;-1200.437,934.4524;Inherit;False;Property;BOOLEAN_USE_WRINKLE2;Use Wrinkle;31;0;Create;False;0;0;0;False;0;False;0;0;0;True;BOOLEAN_USE_WRINKLE_ON;Toggle;2;Key0;Key1;Reference;217;True;False;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;227;-3602.622,-357.2242;Inherit;False;218;normalMap;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;228;-3634.622,-446.2238;Inherit;False;221;smoothnessMap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;226;-3606.917,-530.5425;Inherit;False;216;diffuseMap;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector4Node;233;-4922.803,1135.375;Inherit;False;Property;_WrinkleValueSet2L;Wrinkle Value Set 2 Left;47;0;Create;False;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;234;-4686.808,1201.374;Inherit;False;Property;_WrinkleValueSet3L;Wrinkle Value Set 3 Left;48;0;Create;False;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;235;-4438.664,1134.231;Inherit;False;Property;_WrinkleValueSet2R;Wrinkle Value Set 2 Right;52;0;Create;False;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;236;-4183.667,1187.23;Inherit;False;Property;_WrinkleValueSet3R;Wrinkle Value Set 3 Right;53;0;Create;False;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;245;-4799.682,-110.2309;Inherit;True;Property;_WrinkleDiffuseBlend1;Wrinkle Diffuse Blend 1;37;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;247;-4179.939,104.9185;Inherit;True;Property;_WrinkleDiffuseBlend3;Wrinkle Diffuse Blend 3;39;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;246;-4497.217,-24.40163;Inherit;True;Property;_WrinkleDiffuseBlend2;Wrinkle Diffuse Blend 2;38;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;248;-4806.242,315.3972;Inherit;True;Property;_WrinkleNormalBlend1;Wrinkle Normal Blend 1;42;1;[Normal];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;249;-4498.453,422.0821;Inherit;True;Property;_WrinkleNormalBlend2;Wrinkle Normal Blend 2;43;1;[Normal];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;250;-4185.133,519.4941;Inherit;True;Property;_WrinkleNormalBlend3;Wrinkle Normal Blend 3;44;1;[Normal];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerStateNode;251;-5115.076,86.76053;Inherit;False;0;0;0;1;2;None;1;0;SAMPLER2D;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.SamplerNode;242;-4804.652,-332.5127;Inherit;True;Property;_WrinkleMaskSet3;Wrinkle Mask Set 3;35;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;240;-4182.965,994.5209;Inherit;False;Property;_WrinkleValueSet1BR;Wrinkle Value Set 1B Right;51;0;Create;False;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;239;-4438.962,951.5211;Inherit;False;Property;_WrinkleValueSet1AR;Wrinkle Value Set 1A Right;50;0;Create;False;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;238;-4688.105,1011.665;Inherit;False;Property;_WrinkleValueSet1BL;Wrinkle Value Set 1B Left;46;0;Create;False;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;237;-4923.1,952.6652;Inherit;False;Property;_WrinkleValueSet1AL;Wrinkle Value Set 1A Left;45;0;Create;False;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;257;-3665.482,989.2074;Inherit;False;Property;_WrinkleValueSet3DB;Wrinkle Value Set 3D Both;55;0;Create;False;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;256;-3923.108,949.3359;Inherit;False;Property;_WrinkleValueSet12CL;Wrinkle Value Set 12C Left;49;0;Create;False;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;255;-3923.137,1136.423;Inherit;False;Property;_WrinkleValueSet12CR;Wrinkle Value Set 12C Right;54;0;Create;False;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;254;-4497.854,-236.4908;Inherit;True;Property;_WrinkleMaskSet123;Wrinkle Mask Set 123;36;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;241;-4793.884,-542.6848;Inherit;True;Property;_WrinkleMaskSet1A;Wrinkle Mask Set 1A;32;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;244;-4500.472,-439.6077;Inherit;True;Property;_WrinkleMaskSet1B;Wrinkle Mask Set 1B;33;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;243;-4200.036,-335.8185;Inherit;True;Property;_WrinkleMaskSet2;Wrinkle Mask Set 2;34;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;258;-3270.997,-186.733;Inherit;False;RL_Amplify_WrinkleMapSystem;-1;;17;66048c3ae18f3f84c9195a84e20ae59a;0;32;7;COLOR;0,0,0,0;False;8;FLOAT;0;False;9;FLOAT3;0,0,0;False;15;FLOAT4;0,0,0,0;False;16;FLOAT4;0,0,0,0;False;17;FLOAT4;0,0,0,0;False;18;FLOAT4;0,0,0,0;False;105;FLOAT4;0,0,0,0;False;67;COLOR;0,0,0,0;False;71;COLOR;0,0,0,0;False;76;COLOR;0,0,0,0;False;68;FLOAT;0;False;72;FLOAT;0;False;77;FLOAT;0;False;69;FLOAT3;0,0,0;False;73;FLOAT3;0,0,0;False;78;FLOAT3;0,0,0;False;151;FLOAT;0;False;155;FLOAT;0;False;156;FLOAT;0;False;19;FLOAT4;0,0,0,0;False;20;FLOAT4;0,0,0,0;False;23;FLOAT4;0,0,0,0;False;24;FLOAT4;0,0,0,0;False;103;FLOAT4;0,0,0,0;False;21;FLOAT4;0,0,0,0;False;22;FLOAT4;0,0,0,0;False;25;FLOAT4;0,0,0,0;False;26;FLOAT4;0,0,0,0;False;104;FLOAT4;0,0,0,0;False;106;FLOAT4;0,0,0,0;False;210;FLOAT4;0,0,0,0;False;3;FLOAT4;0;FLOAT;1;FLOAT3;6
Node;AmplifyShaderEditor.RangedFloatNode;153;-2342.297,-518.5097;Inherit;False;Property;_BumpScale;Bump Scale;11;0;Create;True;0;0;0;False;0;False;1;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;259;-2019.033,-427.5625;Inherit;False;normalMapScale;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;232;-5054.76,664.8648;Inherit;False;259;normalMapScale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;252;-4498.753,190.8336;Inherit;True;Property;_WrinkleSmoothnessPack;Wrinkle Smoothness Pack;40;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;260;-4180.02,307.7042;Inherit;True;Property;_WrinkleFlowPack;Wrinkle Flow Pack;41;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;261;-3561.661,1180.72;Inherit;False;Property;_WrinkleValueSetBCCB;Wrinkle Value Set BCC Both;56;0;Create;False;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;262;-5118.013,215.6795;Inherit;False;mainSamplerState;-1;True;1;0;SAMPLERSTATE;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.SamplerNode;147;-2117.865,-210.1417;Inherit;True;Property;_DetailMask;Detail Mask;21;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;263;-2373.306,-155.9299;Inherit;False;262;mainSamplerState;1;0;OBJECT;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.GetLocalVarNode;264;-1518.809,305.943;Inherit;False;262;mainSamplerState;1;0;OBJECT;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.GetLocalVarNode;265;-2092.809,906.943;Inherit;False;262;mainSamplerState;1;0;OBJECT;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.GetLocalVarNode;266;-1867.947,1434.661;Inherit;False;262;mainSamplerState;1;0;OBJECT;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.GetLocalVarNode;267;-1492.306,2105.403;Inherit;False;262;mainSamplerState;1;0;OBJECT;;False;1;SAMPLERSTATE;0
WireConnection;151;7;266;0
WireConnection;170;0;151;2
WireConnection;171;0;169;0
WireConnection;171;1;170;0
WireConnection;174;0;173;0
WireConnection;174;1;217;0
WireConnection;148;5;156;0
WireConnection;149;7;264;0
WireConnection;200;0;174;0
WireConnection;167;0;165;0
WireConnection;167;1;224;0
WireConnection;196;0;195;0
WireConnection;196;1;190;0
WireConnection;196;2;214;0
WireConnection;168;0;223;0
WireConnection;168;1;164;0
WireConnection;158;0;149;0
WireConnection;158;1;157;0
WireConnection;155;0;220;0
WireConnection;155;1;148;0
WireConnection;172;0;171;0
WireConnection;207;0;168;0
WireConnection;208;0;172;0
WireConnection;203;0;200;0
WireConnection;209;0;196;0
WireConnection;210;0;193;0
WireConnection;204;0;155;0
WireConnection;205;0;158;0
WireConnection;206;0;167;0
WireConnection;214;0;211;0
WireConnection;214;1;213;0
WireConnection;193;0;192;0
WireConnection;193;1;194;0
WireConnection;193;2;189;0
WireConnection;193;3;214;0
WireConnection;189;7;267;0
WireConnection;190;7;267;0
WireConnection;202;0;203;0
WireConnection;202;1;204;0
WireConnection;202;2;205;0
WireConnection;202;3;206;0
WireConnection;202;4;207;0
WireConnection;202;5;208;0
WireConnection;202;6;209;0
WireConnection;202;7;210;0
WireConnection;217;1;216;0
WireConnection;217;0;215;0
WireConnection;156;0;154;0
WireConnection;156;1;147;2
WireConnection;146;5;259;0
WireConnection;229;0;258;0
WireConnection;230;0;258;1
WireConnection;231;0;258;6
WireConnection;224;0;150;2
WireConnection;150;7;265;0
WireConnection;220;1;218;0
WireConnection;220;0;219;0
WireConnection;216;0;145;0
WireConnection;218;0;146;0
WireConnection;221;0;150;4
WireConnection;223;1;221;0
WireConnection;223;0;222;0
WireConnection;245;7;251;0
WireConnection;247;7;251;0
WireConnection;246;7;251;0
WireConnection;248;5;232;0
WireConnection;248;7;251;0
WireConnection;249;5;232;0
WireConnection;249;7;251;0
WireConnection;250;5;232;0
WireConnection;250;7;251;0
WireConnection;242;7;251;0
WireConnection;254;7;251;0
WireConnection;241;7;251;0
WireConnection;244;7;251;0
WireConnection;243;7;251;0
WireConnection;258;7;226;0
WireConnection;258;8;228;0
WireConnection;258;9;227;0
WireConnection;258;15;241;0
WireConnection;258;16;244;0
WireConnection;258;17;243;0
WireConnection;258;18;242;0
WireConnection;258;105;254;0
WireConnection;258;67;245;0
WireConnection;258;71;246;0
WireConnection;258;76;247;0
WireConnection;258;68;252;1
WireConnection;258;72;252;2
WireConnection;258;77;252;3
WireConnection;258;69;248;0
WireConnection;258;73;249;0
WireConnection;258;78;250;0
WireConnection;258;151;260;1
WireConnection;258;155;260;2
WireConnection;258;156;260;3
WireConnection;258;19;237;0
WireConnection;258;20;238;0
WireConnection;258;23;233;0
WireConnection;258;24;234;0
WireConnection;258;103;256;0
WireConnection;258;21;239;0
WireConnection;258;22;240;0
WireConnection;258;25;235;0
WireConnection;258;26;236;0
WireConnection;258;104;255;0
WireConnection;258;106;257;0
WireConnection;258;210;261;0
WireConnection;259;0;153;0
WireConnection;252;7;251;0
WireConnection;260;7;251;0
WireConnection;262;0;251;0
WireConnection;147;7;263;0
ASEEND*/
//CHKSM=F53238D1673ACED7906F0DA4675AAC627804EC45