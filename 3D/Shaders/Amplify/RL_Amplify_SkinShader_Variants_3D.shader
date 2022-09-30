// Made with Amplify Shader Editor v1.9.0.1
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Reallusion/Amplify/RL_SkinShader_Variants_3D"
{
	Properties
	{
		_DiffuseMap("Diffuse Map", 2D) = "white" {}
		_DiffuseColor("Diffuse Color", Color) = (1,1,1,0)
		_MaskMap("Mask Map", 2D) = "gray" {}
		_AOStrength("AO Strength", Range( 0 , 1)) = 0
		_SmoothnessPower("SmoothnessPower", Range( 0.1 , 2)) = 0.1
		_SmoothnessMin("SmoothnessMin", Range( 0 , 1)) = 0
		_SmoothnessMax("SmoothnessMax", Range( 0 , 1)) = 0
		[Normal]_NormalMap("Normal Map", 2D) = "bump" {}
		_NormalStrength("Normal Strength", Range( 0 , 2)) = 1
		[Normal]_MicroNormalMap("Micro Normal Map", 2D) = "bump" {}
		_MicroNormalStrength("Micro Normal Strength", Range( 0 , 1)) = 0.5
		_MicroNormalTiling("Micro Normal Tiling", Range( 0 , 50)) = 25
		_ColorBlendMap("Color Blend Map (Head)", 2D) = "gray" {}
		_ColorBlendStrength("Color Blend Strength", Range( 0 , 1)) = 0
		[Normal]_NormalBlendMap("Normal Blend Map (Head)", 2D) = "bump" {}
		_NormalBlendStrength("Normal Blend Strength (Head)", Range( 0 , 2)) = 0
		_SSSMap("Subsurface Map", 2D) = "white" {}
		_SubsurfaceScale("Subsurface Scale", Range( 0 , 1)) = 1
		_SubsurfaceFalloff("Subsurface Falloff", Color) = (1,0.3686275,0.2980392,0)
		_SubsurfaceNormalSoften("Subsurface Normal Soften", Range( 0 , 1)) = 0.65
		_ThicknessMap("Thickness Map", 2D) = "black" {}
		_ThicknessScale("ThicknessScale", Range( 0 , 2)) = 1
		[Toggle(BOOLEAN_IS_HEAD_ON)] BOOLEAN_IS_HEAD("Is Head", Float) = 1
		_MNAOMap("Cavity AO Map", 2D) = "white" {}
		_MouthCavityAO("Mouth Cavity AO", Range( 0 , 5)) = 2.5
		_NostrilCavityAO("Nostril Cavity AO", Range( 0 , 5)) = 2.5
		_LipsCavityAO("Lips Cavity AO", Range( 0 , 5)) = 2.5
		_RGBAMask("RGBAMask", 2D) = "black" {}
		_CFULCMask("CFULCMask", 2D) = "black" {}
		_EarNeckMask("EarNeckMask", 2D) = "black" {}
		_MicroSmoothnessMod("Micro Smoothness Mod", Range( -1.5 , 1.5)) = 0
		_RSmoothnessMod("Nose/R Smoothness Mod", Range( -1.5 , 1.5)) = 0
		_GSmoothnessMod("Mouth/G Smoothness Mod", Range( -1.5 , 1.5)) = 0
		_BSmoothnessMod("Upper Lid/B Smoothness Mod", Range( -1.5 , 1.5)) = 0
		_ASmoothnessMod("Inner Lid/A Smoothness Mod", Range( -1.5 , 1.5)) = 0
		_EarSmoothnessMod("Ear Smoothness Mod", Range( -1.5 , 1.5)) = 0
		_NeckSmoothnessMod("Neck Smoothness Mod", Range( -1.5 , 1.5)) = 0
		_CheekSmoothnessMod("Cheek Smoothness Mod", Range( -1.5 , 1.5)) = 0
		_ForeheadSmoothnessMod("Forehead Smoothness Mod", Range( -1.5 , 1.5)) = 0
		_UpperLipSmoothnessMod("Upper Lip Smoothness Mod", Range( -1.5 , 1.5)) = 0
		_ChinSmoothnessMod("Chin Smoothness Mod", Range( -1.5 , 1.5)) = 0
		_UnmaskedSmoothnessMod("Unmasked Smoothness Mod", Range( -1.5 , 1.5)) = 0
		_RScatterScale("Nose/R Scatter Scale", Range( 0 , 2)) = 1
		_GScatterScale("Mouth/G Scatter Scale", Range( 0 , 2)) = 1
		_BScatterScale("Upper Lid/B Scatter Scale", Range( 0 , 2)) = 1
		_AScatterScale("Inner Lid/A Scatter Scale", Range( 0 , 2)) = 1
		_EarScatterScale("Ear Scatter Scale", Range( 0 , 2)) = 1
		_NeckScatterScale("Neck Scatter Scale", Range( 0 , 2)) = 1
		_CheekScatterScale("Cheek Scatter Scale", Range( 0 , 2)) = 1
		_ForeheadScatterScale("Forehead Scatter Scale", Range( 0 , 2)) = 1
		_UpperLipScatterScale("Upper Lip Scatter Scale", Range( 0 , 2)) = 1
		_ChinScatterScale("Chin Scatter Scale", Range( 0 , 2)) = 1
		_UnmaskedScatterScale("Unmasked Scatter Scale", Range( 0 , 2)) = 1
		_EmissionMap("Emission Map", 2D) = "white" {}
		[HDR]_EmissiveColor("Emissive Color", Color) = (0,0,0,0)
		[Header(Translucency)]
		_Translucency("Strength", Range( 0 , 50)) = 1
		_TransNormalDistortion("Normal Distortion", Range( 0 , 1)) = 0.1
		_TransScattering("Scaterring Falloff", Range( 1 , 50)) = 2
		_TransDirect("Direct", Range( 0 , 1)) = 1
		_TransAmbient("Ambient", Range( 0 , 1)) = 0.2
		_TransShadow("Shadow", Range( 0 , 1)) = 0.9
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
		#pragma target 3.0
		#pragma shader_feature_local BOOLEAN_IS_HEAD_ON
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

		#pragma surface surf StandardCustom keepalpha addshadow fullforwardshadows exclude_path:deferred 
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

		UNITY_DECLARE_TEX2D_NOSAMPLER(_NormalMap);
		uniform half4 _NormalMap_ST;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_DiffuseMap);
		SamplerState sampler_DiffuseMap;
		uniform half _NormalStrength;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_SSSMap);
		uniform half4 _SSSMap_ST;
		uniform half _SubsurfaceScale;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_RGBAMask);
		uniform half4 _RGBAMask_ST;
		uniform half _RSmoothnessMod;
		uniform half _GSmoothnessMod;
		uniform half _BSmoothnessMod;
		uniform half _ASmoothnessMod;
		uniform half _RScatterScale;
		uniform half _GScatterScale;
		uniform half _BScatterScale;
		uniform half _AScatterScale;
		uniform half _UnmaskedSmoothnessMod;
		uniform half _UnmaskedScatterScale;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_CFULCMask);
		uniform half4 _CFULCMask_ST;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_EarNeckMask);
		uniform half4 _EarNeckMask_ST;
		uniform half _CheekSmoothnessMod;
		uniform half _ForeheadSmoothnessMod;
		uniform half _UpperLipSmoothnessMod;
		uniform half _ChinSmoothnessMod;
		uniform half _NeckSmoothnessMod;
		uniform half _EarSmoothnessMod;
		uniform half _CheekScatterScale;
		uniform half _ForeheadScatterScale;
		uniform half _UpperLipScatterScale;
		uniform half _ChinScatterScale;
		uniform half _NeckScatterScale;
		uniform half _EarScatterScale;
		uniform half _SubsurfaceNormalSoften;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_NormalBlendMap);
		uniform half4 _NormalBlendMap_ST;
		uniform half _NormalBlendStrength;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_MicroNormalMap);
		uniform half _MicroNormalTiling;
		SamplerState sampler_MicroNormalMap;
		uniform half _MicroNormalStrength;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_MaskMap);
		uniform half4 _MaskMap_ST;
		uniform half4 _DiffuseColor;
		uniform half4 _DiffuseMap_ST;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_ColorBlendMap);
		uniform half4 _ColorBlendMap_ST;
		uniform half _ColorBlendStrength;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_MNAOMap);
		uniform half4 _MNAOMap_ST;
		uniform half _MouthCavityAO;
		uniform half _NostrilCavityAO;
		uniform half _LipsCavityAO;
		uniform half4 _EmissiveColor;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_EmissionMap);
		uniform half4 _EmissionMap_ST;
		uniform half _SmoothnessMin;
		uniform half _SmoothnessMax;
		uniform half _SmoothnessPower;
		uniform half _MicroSmoothnessMod;
		uniform half _AOStrength;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_ThicknessMap);
		uniform half4 _ThicknessMap_ST;
		uniform half _ThicknessScale;
		uniform half4 _SubsurfaceFalloff;
		uniform half _Translucency;
		uniform half _TransNormalDistortion;
		uniform half _TransScattering;
		uniform half _TransDirect;
		uniform half _TransAmbient;
		uniform half _TransShadow;


		void SkinMask179( half4 In1, half4 Mod1, half4 Scatter1, half UMMS, half UMSS, out half SmoothnessMod, out half ScatterMask )
		{
			float mask = saturate(In1.r + In1.g + In1.b + In1.a);
			float unmask = 1.0 - mask;
			SmoothnessMod = dot(In1, Mod1) + (UMMS * unmask);
			ScatterMask = dot(In1, Scatter1) + (UMSS * unmask);
			return;
		}


		void HeadMask156( half4 In1, half4 In2, half4 In3, half4 Mod1, half4 Mod2, half4 Mod3, half4 Scatter1, half4 Scatter2, half4 Scatter3, half UMMS, half UMSS, out half SmoothnessMod, out half ScatterMask )
		{
			In3.zw = 0;
			float4 m = In1 + In2 + In3;
			float mask = saturate(m.x + m.y + m.z + m.w);
			float unmask = 1.0 - mask;
			SmoothnessMod = dot(In1, Mod1) + dot(In2, Mod2) + dot(In3, Mod3) + (UMMS * unmask);
			ScatterMask = dot(In1, Scatter1) + dot(In2, Scatter2) + dot(In3, Scatter3) + (UMSS * unmask);
			return;
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
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float2 uv_SSSMap = i.uv_texcoord * _SSSMap_ST.xy + _SSSMap_ST.zw;
			half localSkinMask179 = ( 0.0 );
			float2 uv_RGBAMask = i.uv_texcoord * _RGBAMask_ST.xy + _RGBAMask_ST.zw;
			half4 tex2DNode123 = SAMPLE_TEXTURE2D( _RGBAMask, sampler_DiffuseMap, uv_RGBAMask );
			half4 In1179 = tex2DNode123;
			half4 appendResult150 = (half4(_RSmoothnessMod , _GSmoothnessMod , _BSmoothnessMod , _ASmoothnessMod));
			half4 Mod1179 = appendResult150;
			half4 appendResult153 = (half4(_RScatterScale , _GScatterScale , _BScatterScale , _AScatterScale));
			half4 Scatter1179 = appendResult153;
			half UMMS179 = _UnmaskedSmoothnessMod;
			half UMSS179 = _UnmaskedScatterScale;
			half SmoothnessMod179 = 0.0;
			half ScatterMask179 = 0.0;
			SkinMask179( In1179 , Mod1179 , Scatter1179 , UMMS179 , UMSS179 , SmoothnessMod179 , ScatterMask179 );
			half localHeadMask156 = ( 0.0 );
			half4 In1156 = tex2DNode123;
			float2 uv_CFULCMask = i.uv_texcoord * _CFULCMask_ST.xy + _CFULCMask_ST.zw;
			half4 In2156 = SAMPLE_TEXTURE2D( _CFULCMask, sampler_DiffuseMap, uv_CFULCMask );
			float2 uv_EarNeckMask = i.uv_texcoord * _EarNeckMask_ST.xy + _EarNeckMask_ST.zw;
			half4 In3156 = SAMPLE_TEXTURE2D( _EarNeckMask, sampler_DiffuseMap, uv_EarNeckMask );
			half4 Mod1156 = appendResult150;
			half4 appendResult151 = (half4(_CheekSmoothnessMod , _ForeheadSmoothnessMod , _UpperLipSmoothnessMod , _ChinSmoothnessMod));
			half4 Mod2156 = appendResult151;
			half4 appendResult152 = (half4(_NeckSmoothnessMod , _EarSmoothnessMod , 0.0 , 0.0));
			half4 Mod3156 = appendResult152;
			half4 Scatter1156 = appendResult153;
			half4 appendResult154 = (half4(_CheekScatterScale , _ForeheadScatterScale , _UpperLipScatterScale , _ChinScatterScale));
			half4 Scatter2156 = appendResult154;
			half4 appendResult155 = (half4(_NeckScatterScale , _EarScatterScale , 0.0 , 0.0));
			half4 Scatter3156 = appendResult155;
			half UMMS156 = _UnmaskedSmoothnessMod;
			half UMSS156 = _UnmaskedScatterScale;
			half SmoothnessMod156 = 0.0;
			half ScatterMask156 = 0.0;
			HeadMask156( In1156 , In2156 , In3156 , Mod1156 , Mod2156 , Mod3156 , Scatter1156 , Scatter2156 , Scatter3156 , UMMS156 , UMSS156 , SmoothnessMod156 , ScatterMask156 );
			#ifdef BOOLEAN_IS_HEAD_ON
				half staticSwitch169 = ScatterMask156;
			#else
				half staticSwitch169 = ScatterMask179;
			#endif
			half microScatteringMultiplier277 = ( _SubsurfaceScale * staticSwitch169 );
			half temp_output_355_0 = saturate( ( SAMPLE_TEXTURE2D( _SSSMap, sampler_DiffuseMap, uv_SSSMap ).g * microScatteringMultiplier277 ) );
			half subsurfaceFlattenNormals340 = saturate( ( 1.0 - ( temp_output_355_0 * temp_output_355_0 * _SubsurfaceNormalSoften ) ) );
			half3 tex2DNode48 = UnpackScaleNormal( SAMPLE_TEXTURE2D( _NormalMap, sampler_DiffuseMap, uv_NormalMap ), ( _NormalStrength * subsurfaceFlattenNormals340 ) );
			float2 uv_NormalBlendMap = i.uv_texcoord * _NormalBlendMap_ST.xy + _NormalBlendMap_ST.zw;
			#ifdef BOOLEAN_IS_HEAD_ON
				half3 staticSwitch71 = BlendNormals( tex2DNode48 , UnpackScaleNormal( SAMPLE_TEXTURE2D( _NormalBlendMap, sampler_DiffuseMap, uv_NormalBlendMap ), ( subsurfaceFlattenNormals340 * _NormalBlendStrength ) ) );
			#else
				half3 staticSwitch71 = tex2DNode48;
			#endif
			half2 temp_cast_4 = (_MicroNormalTiling).xx;
			float2 uv_TexCoord344 = i.uv_texcoord * temp_cast_4;
			float2 uv_MaskMap = i.uv_texcoord * _MaskMap_ST.xy + _MaskMap_ST.zw;
			half4 tex2DNode32 = SAMPLE_TEXTURE2D( _MaskMap, sampler_DiffuseMap, uv_MaskMap );
			half microNormalMask287 = tex2DNode32.b;
			o.Normal = BlendNormals( staticSwitch71 , UnpackScaleNormal( SAMPLE_TEXTURE2D( _MicroNormalMap, sampler_MicroNormalMap, uv_TexCoord344 ), ( _MicroNormalStrength * microNormalMask287 * subsurfaceFlattenNormals340 ) ) );
			float2 uv_DiffuseMap = i.uv_texcoord * _DiffuseMap_ST.xy + _DiffuseMap_ST.zw;
			half4 temp_output_357_0 = ( _DiffuseColor * SAMPLE_TEXTURE2D( _DiffuseMap, sampler_DiffuseMap, uv_DiffuseMap ) );
			float2 uv_ColorBlendMap = i.uv_texcoord * _ColorBlendMap_ST.xy + _ColorBlendMap_ST.zw;
			half4 blendOpSrc13 = SAMPLE_TEXTURE2D( _ColorBlendMap, sampler_DiffuseMap, uv_ColorBlendMap );
			half4 blendOpDest13 = temp_output_357_0;
			half4 lerpBlendMode13 = lerp(blendOpDest13,(( blendOpDest13 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest13 ) * ( 1.0 - blendOpSrc13 ) ) : ( 2.0 * blendOpDest13 * blendOpSrc13 ) ),_ColorBlendStrength);
			float2 uv_MNAOMap = i.uv_texcoord * _MNAOMap_ST.xy + _MNAOMap_ST.zw;
			half4 tex2DNode196 = SAMPLE_TEXTURE2D( _MNAOMap, sampler_DiffuseMap, uv_MNAOMap );
			half saferPower201 = abs( tex2DNode196.g );
			half saferPower202 = abs( tex2DNode196.b );
			half saferPower203 = abs( tex2DNode196.a );
			half cavityAO280 = ( pow( saferPower201 , _MouthCavityAO ) * pow( saferPower202 , _NostrilCavityAO ) * pow( saferPower203 , _LipsCavityAO ) );
			#ifdef BOOLEAN_IS_HEAD_ON
				half4 staticSwitch72 = ( ( saturate( lerpBlendMode13 )) * cavityAO280 );
			#else
				half4 staticSwitch72 = temp_output_357_0;
			#endif
			half4 baseColor266 = staticSwitch72;
			o.Albedo = baseColor266.rgb;
			float2 uv_EmissionMap = i.uv_texcoord * _EmissionMap_ST.xy + _EmissionMap_ST.zw;
			o.Emission = ( _EmissiveColor * SAMPLE_TEXTURE2D( _EmissionMap, sampler_DiffuseMap, uv_EmissionMap ) ).rgb;
			half metallicMap285 = tex2DNode32.r;
			o.Metallic = metallicMap285;
			half smoothnessMap288 = tex2DNode32.a;
			half cavityMask295 = tex2DNode196.r;
			#ifdef BOOLEAN_IS_HEAD_ON
				half staticSwitch223 = ( cavityMask295 * smoothnessMap288 );
			#else
				half staticSwitch223 = smoothnessMap288;
			#endif
			half saferPower39 = abs( staticSwitch223 );
			half lerpResult41 = lerp( _SmoothnessMin , _SmoothnessMax , pow( saferPower39 , _SmoothnessPower ));
			#ifdef BOOLEAN_IS_HEAD_ON
				half staticSwitch170 = SmoothnessMod156;
			#else
				half staticSwitch170 = SmoothnessMod179;
			#endif
			half microSmoothnessMod276 = ( staticSwitch170 + _MicroSmoothnessMod );
			o.Smoothness = ( lerpResult41 + microSmoothnessMod276 );
			half ambientOcclusionMap286 = tex2DNode32.g;
			o.Occlusion = ( 1.0 - ( ( 1.0 - ambientOcclusionMap286 ) * _AOStrength ) );
			float2 uv_ThicknessMap = i.uv_texcoord * _ThicknessMap_ST.xy + _ThicknessMap_ST.zw;
			half4 temp_output_333_0 = ( baseColor266 * _SubsurfaceFalloff );
			o.Transmission = ( SAMPLE_TEXTURE2D( _ThicknessMap, sampler_DiffuseMap, uv_ThicknessMap ).g * _ThicknessScale * temp_output_333_0 ).rgb;
			o.Translucency = ( temp_output_333_0 * ( temp_output_355_0 * 0.5 ) ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
}
/*ASEBEGIN
Version=19001
1913;48;1920;981;2397.883;2029.306;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;229;-5908.021,48.08539;Inherit;False;3216.245;1858.522;;58;276;277;174;170;171;172;68;169;156;179;165;164;167;168;166;181;182;147;146;161;159;163;180;157;123;183;152;153;155;124;125;151;154;121;138;150;144;140;133;137;148;142;120;122;131;134;145;139;132;141;130;135;143;129;127;126;128;353;Micro-Smoothess/Scattering;0.4764151,1,0.9938402,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;129;-5858.021,849.2174;Inherit;False;Property;_ASmoothnessMod;Inner Lid/A Smoothness Mod;34;0;Create;False;0;0;0;False;0;False;0;0;-1.5;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;128;-5857.031,769.2485;Inherit;False;Property;_BSmoothnessMod;Upper Lid/B Smoothness Mod;33;0;Create;False;0;0;0;False;0;False;0;0;-1.5;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;127;-5858.013,693.2935;Inherit;False;Property;_GSmoothnessMod;Mouth/G Smoothness Mod;32;0;Create;False;0;0;0;False;0;False;0;0;-1.5;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;126;-5858.013,619.4265;Inherit;False;Property;_RSmoothnessMod;Nose/R Smoothness Mod;31;0;Create;False;0;0;0;False;0;False;0;0;-1.5;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;122;-5335.381,511.1195;Inherit;True;Property;_EarNeckMask;EarNeckMask;29;0;Create;True;0;0;0;False;0;False;None;None;False;black;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerStateNode;353;-5277.154,306.8142;Inherit;False;0;0;0;1;2;None;1;0;SAMPLER2D;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.RangedFloatNode;148;-5206.476,1070.36;Inherit;False;Property;_RScatterScale;Nose/R Scatter Scale;42;0;Create;False;0;0;0;False;0;False;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;144;-5202.717,1679.614;Inherit;False;Property;_NeckScatterScale;Neck Scatter Scale;47;0;Create;True;0;0;0;False;0;False;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;133;-5857.21,1159.966;Inherit;False;Property;_ChinSmoothnessMod;Chin Smoothness Mod;40;0;Create;True;0;0;0;False;0;False;0;0;-1.5;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;138;-5204.919,1214.915;Inherit;False;Property;_BScatterScale;Upper Lid/B Scatter Scale;44;0;Create;False;0;0;0;False;0;False;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;141;-5207.318,1445.414;Inherit;False;Property;_ForeheadScatterScale;Forehead Scatter Scale;49;0;Create;True;0;0;0;False;0;False;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;145;-5202.918,1762.014;Inherit;False;Property;_EarScatterScale;Ear Scatter Scale;46;0;Create;True;0;0;0;False;0;False;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;134;-5854.502,1236.706;Inherit;False;Property;_NeckSmoothnessMod;Neck Smoothness Mod;36;0;Create;True;0;0;0;False;0;False;0;0;-1.5;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;120;-5517.44,207.9764;Inherit;True;Property;_RGBAMask;RGBAMask;27;0;Create;True;0;0;0;False;0;False;None;None;False;black;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;143;-5203.217,1602.014;Inherit;False;Property;_ChinScatterScale;Chin Scatter Scale;51;0;Create;True;0;0;0;False;0;False;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;139;-5205.919,1285.915;Inherit;False;Property;_AScatterScale;Inner Lid/A Scatter Scale;45;0;Create;False;0;0;0;False;0;False;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;130;-5857.083,930.9144;Inherit;False;Property;_CheekSmoothnessMod;Cheek Smoothness Mod;37;0;Create;True;0;0;0;False;0;False;0;0;-1.5;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;131;-5857.152,1009.909;Inherit;False;Property;_ForeheadSmoothnessMod;Forehead Smoothness Mod;38;0;Create;True;0;0;0;False;0;False;0;0;-1.5;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;135;-5851.211,1314.774;Inherit;False;Property;_EarSmoothnessMod;Ear Smoothness Mod;35;0;Create;True;0;0;0;False;0;False;0;0;-1.5;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;121;-5564.381,417.1195;Inherit;True;Property;_CFULCMask;CFULCMask;28;0;Create;True;0;0;0;False;0;False;None;None;False;black;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;137;-5206.919,1138.915;Inherit;False;Property;_GScatterScale;Mouth/G Scatter Scale;43;0;Create;False;0;0;0;False;0;False;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;142;-5202.318,1525.714;Inherit;False;Property;_UpperLipScatterScale;Upper Lip Scatter Scale;50;0;Create;True;0;0;0;False;0;False;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;140;-5209.221,1370.914;Inherit;False;Property;_CheekScatterScale;Cheek Scatter Scale;48;0;Create;True;0;0;0;False;0;False;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;150;-5468.931,750.5865;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;132;-5855.17,1085.966;Inherit;False;Property;_UpperLipSmoothnessMod;Upper Lip Smoothness Mod;39;0;Create;True;0;0;0;False;0;False;0;0;-1.5;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;123;-4947.738,98.08542;Inherit;True;Property;_TextureSample8;Texture Sample 8;32;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;154;-4804.062,1393.852;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;152;-5465.315,1076.229;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WireNode;183;-5016.906,829.2422;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;153;-4809.106,1226.433;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;155;-4799.142,1555.208;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;151;-5471.796,906.7744;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;125;-4954.618,554.9945;Inherit;True;Property;_TextureSample10;Texture Sample 10;32;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;124;-4951.618,329.9945;Inherit;True;Property;_TextureSample9;Texture Sample 9;32;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;146;-4791.422,1720.184;Inherit;False;Property;_UnmaskedSmoothnessMod;Unmasked Smoothness Mod;41;0;Create;True;0;0;0;False;0;False;0;0;-1.5;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;161;-4467.744,1380.334;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WireNode;182;-4281.644,1267.539;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WireNode;165;-4484.802,892.7705;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;157;-4471.977,1300.425;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WireNode;181;-4269.323,865.2314;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;159;-4469.809,1343.422;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WireNode;168;-5031.45,910.5963;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WireNode;180;-4263.971,1253.895;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WireNode;164;-4475.381,827.9884;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;163;-4470.252,754.4565;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;166;-5022.944,855.5648;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;147;-4790.822,1794.684;Inherit;False;Property;_UnmaskedScatterScale;Unmasked Scatter Scale;52;0;Create;True;0;0;0;False;0;False;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;167;-5026.845,882.4905;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CustomExpressionNode;179;-4103.264,1453.281;Inherit;False;float mask = saturate(In1.r + In1.g + In1.b + In1.a)@$float unmask = 1.0 - mask@$$SmoothnessMod = dot(In1, Mod1) + (UMMS * unmask)@$ScatterMask = dot(In1, Scatter1) + (UMSS * unmask)@$return@;7;Create;7;True;In1;FLOAT4;0,0,0,0;In;;Inherit;False;True;Mod1;FLOAT4;0,0,0,0;In;;Inherit;False;True;Scatter1;FLOAT4;0,0,0,0;In;;Inherit;False;True;UMMS;FLOAT;0;In;;Inherit;False;True;UMSS;FLOAT;0;In;;Inherit;False;True;SmoothnessMod;FLOAT;0;Out;;Inherit;False;True;ScatterMask;FLOAT;0;Out;;Inherit;False;SkinMask;True;False;0;;False;8;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;3;FLOAT;0;FLOAT;7;FLOAT;8
Node;AmplifyShaderEditor.CustomExpressionNode;156;-4103.297,1089.082;Inherit;False;In3.zw = 0@$float4 m = In1 + In2 + In3@$float mask = saturate(m.x + m.y + m.z + m.w)@$float unmask = 1.0 - mask@$$SmoothnessMod = dot(In1, Mod1) + dot(In2, Mod2) + dot(In3, Mod3) + (UMMS * unmask)@$ScatterMask = dot(In1, Scatter1) + dot(In2, Scatter2) + dot(In3, Scatter3) + (UMSS * unmask)@$return@;7;Create;13;True;In1;FLOAT4;0,0,0,0;In;;Inherit;False;True;In2;FLOAT4;0,0,0,0;In;;Inherit;False;True;In3;FLOAT4;0,0,0,0;In;;Inherit;False;True;Mod1;FLOAT4;0,0,0,0;In;;Inherit;False;True;Mod2;FLOAT4;0,0,0,0;In;;Inherit;False;True;Mod3;FLOAT4;0,0,0,0;In;;Inherit;False;True;Scatter1;FLOAT4;0,0,0,0;In;;Inherit;False;True;Scatter2;FLOAT4;0,0,0,0;In;;Inherit;False;True;Scatter3;FLOAT4;0,0,0,0;In;;Inherit;False;True;UMMS;FLOAT;0;In;;Inherit;False;True;UMSS;FLOAT;0;In;;Inherit;False;True;SmoothnessMod;FLOAT;0;Out;;Inherit;False;True;ScatterMask;FLOAT;0;Out;;Inherit;False;HeadMask;True;False;0;;False;14;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;9;FLOAT4;0,0,0,0;False;10;FLOAT;0;False;11;FLOAT;0;False;12;FLOAT;0;False;13;FLOAT;0;False;3;FLOAT;0;FLOAT;13;FLOAT;14
Node;AmplifyShaderEditor.StaticSwitch;169;-3551.095,1558.494;Inherit;False;Property;BOOLEAN_IS_HEAD;Is Head;35;0;Create;False;0;0;0;False;0;False;0;1;1;True;BOOLEAN_IS_HEAD_ON;Toggle;2;Key0;Key1;Reference;170;True;False;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;68;-3574.522,1467.09;Inherit;False;Property;_SubsurfaceScale;Subsurface Scale;17;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;220;-1735.542,2667.253;Inherit;False;1910.26;862.4985;;17;119;115;333;267;66;261;69;334;279;28;27;30;114;29;350;351;355;Subsurface Scattering;1,0.5051794,0.495283,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;172;-3199.837,1508.122;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerStateNode;350;-1627.294,2977.373;Inherit;False;0;0;0;1;2;None;1;0;SAMPLER2D;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.TexturePropertyNode;27;-1670.56,3090.316;Inherit;True;Property;_SSSMap;Subsurface Map;16;0;Create;False;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;277;-2964.243,1523.669;Inherit;False;microScatteringMultiplier;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;279;-1362.846,3353.992;Inherit;False;277;microScatteringMultiplier;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;208;-4654.008,-805.9103;Inherit;False;1980.672;617.1674;;13;280;203;202;201;197;207;204;205;206;196;195;295;354;Head Cavity Mask;0.5235849,1,0.9775805,1;0;0
Node;AmplifyShaderEditor.SamplerNode;28;-1379.665,3092.988;Inherit;True;Property;_TextureSample2;Texture Sample 2;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerStateNode;354;-4461.872,-474.1744;Inherit;False;0;0;0;1;2;None;1;0;SAMPLER2D;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;334;-1044.151,3224.775;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;195;-4484.008,-668.7567;Inherit;True;Property;_MNAOMap;Cavity AO Map;23;0;Create;False;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.CommentaryNode;335;-1066.108,3586.445;Inherit;False;1243.882;319.7932;Subsurface Normal Flattening;5;340;339;338;337;336;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;205;-3977.836,-371.3848;Inherit;False;Property;_NostrilCavityAO;Nostril Cavity AO;25;0;Create;True;0;0;0;False;0;False;2.5;2.5;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;196;-3997.858,-661.9286;Inherit;True;Property;_TextureSample11;Texture Sample 11;32;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;355;-909.8523,3238.831;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;206;-3977.836,-296.3848;Inherit;False;Property;_LipsCavityAO;Lips Cavity AO;26;0;Create;True;0;0;0;False;0;False;2.5;2.5;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;336;-1032.108,3766.445;Inherit;False;Property;_SubsurfaceNormalSoften;Subsurface Normal Soften;19;0;Create;True;0;0;0;False;0;False;0.65;0.65;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;204;-3977.836,-446.3848;Inherit;False;Property;_MouthCavityAO;Mouth Cavity AO;24;0;Create;True;0;0;0;False;0;False;2.5;2.5;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;212;-1766.071,-1668.31;Inherit;False;1912.584;792.9118;;12;356;1;11;2;12;14;357;266;72;209;281;13;Base Color;0.495283,1,0.5625787,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;294;-3752.904,2143.511;Inherit;False;1090.966;451.807;;7;31;32;285;286;287;288;352;Mask Map;0.495283,1,0.986145,1;0;0
Node;AmplifyShaderEditor.PowerNode;203;-3341.862,-431.3848;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;337;-704.1087,3691.445;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;202;-3343.862,-536.3851;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;201;-3342.862,-643.385;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;2;-1724.642,-1370.82;Inherit;True;Property;_DiffuseMap;Diffuse Map;0;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;11;-1716.41,-1145.794;Inherit;True;Property;_ColorBlendMap;Color Blend Map (Head);12;0;Create;False;0;0;0;False;0;False;None;None;False;gray;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;31;-3702.905,2255.651;Inherit;True;Property;_MaskMap;Mask Map;2;0;Create;False;0;0;0;False;0;False;None;None;False;gray;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;1;-1420.008,-1423.188;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;356;-1368.703,-1620.314;Inherit;False;Property;_DiffuseColor;Diffuse Color;1;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;207;-3083.988,-560.6332;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;338;-518.1848,3721.851;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerStateNode;352;-3667.136,2459.509;Inherit;False;0;0;0;1;2;None;1;0;SAMPLER2D;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.SaturateNode;339;-319.1683,3723.269;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;32;-3340.386,2257.809;Inherit;True;Property;_TextureSample4;Texture Sample 4;6;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;280;-2885.78,-566.2528;Inherit;False;cavityAO;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-1321.204,-975.6169;Inherit;False;Property;_ColorBlendStrength;Color Blend Strength;13;0;Create;True;0;0;0;False;0;False;0;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;357;-1063.627,-1513.344;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;12;-1316.942,-1184.935;Inherit;True;Property;_TextureSample1;Texture Sample 1;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;281;-884.6882,-1038.317;Inherit;False;280;cavityAO;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;13;-894.8047,-1214.301;Inherit;False;Overlay;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;295;-3608.803,-715.5761;Inherit;False;cavityMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;213;-1940.1,-797.2799;Inherit;False;2092.409;1361.084;;21;61;52;71;53;57;54;58;50;289;62;48;60;51;49;59;341;343;342;344;345;348;Normal Blending;0.4858491,0.5398334,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;228;-1819.795,1486.553;Inherit;False;1972.428;431.256;;11;282;222;175;41;278;43;39;42;40;223;292;Smoothness;0.5330188,1,0.9963375,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;340;-124.655,3719.448;Inherit;False;subsurfaceFlattenNormals;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;288;-2905.118,2479.318;Inherit;False;smoothnessMap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-1879.764,-659.1192;Inherit;False;Property;_NormalStrength;Normal Strength;8;0;Create;True;0;0;0;False;0;False;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;209;-582.2052,-1133.262;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;292;-1781.937,1620.358;Inherit;False;288;smoothnessMap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;343;-1894.403,-361.8155;Inherit;False;340;subsurfaceFlattenNormals;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;282;-1778.271,1722.772;Inherit;False;295;cavityMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-1891.538,-49.41412;Inherit;False;Property;_NormalBlendStrength;Normal Blend Strength (Head);15;0;Create;False;0;0;0;False;0;False;0;0.5;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;341;-1592.49,-218.3322;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;82;-775.9232,2212.324;Inherit;False;929.907;257.7939;;5;293;37;35;36;33;Ambient Occlusion;0.495283,1,0.9960415,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;49;-1414.59,-747.28;Inherit;True;Property;_NormalMap;Normal Map;7;1;[Normal];Create;True;0;0;0;False;0;False;None;None;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.StaticSwitch;170;-3557.483,1206.089;Inherit;False;Property;BOOLEAN_IS_HEAD;Is Head;35;0;Create;False;0;0;0;False;0;False;0;1;1;True;BOOLEAN_IS_HEAD_ON;Toggle;2;Key0;Key1;Reference;-1;True;False;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;51;-1415.406,-434.2199;Inherit;True;Property;_NormalBlendMap;Normal Blend Map (Head);14;1;[Normal];Create;False;0;0;0;False;0;False;None;None;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;222;-1551.795,1754.497;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;72;-344.0569,-1330.624;Inherit;False;Property;BOOLEAN_IS_HEAD;Is Head;22;0;Create;False;0;0;0;False;0;False;0;1;1;True;BOOLEAN_IS_HEAD_ON;Toggle;2;Key0;Key1;Create;True;False;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;287;-2911.776,2386.466;Inherit;False;microNormalMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;171;-3562.313,1330.478;Inherit;False;Property;_MicroSmoothnessMod;Micro Smoothness Mod;30;0;Create;True;0;0;0;False;0;False;0;0;-1.5;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;342;-1590.995,-517.256;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerStateNode;348;-1394.07,-526.1101;Inherit;False;0;0;0;1;2;None;1;0;SAMPLER2D;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;286;-2926.939,2292.405;Inherit;False;ambientOcclusionMap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;289;-1793.066,278.1468;Inherit;False;287;microNormalMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-1858.759,85.457;Inherit;False;Property;_MicroNormalTiling;Micro Normal Tiling;11;0;Create;True;0;0;0;False;0;False;25;25;0;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;345;-1836.892,378.14;Inherit;False;340;subsurfaceFlattenNormals;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;48;-1068.29,-667.4806;Inherit;True;Property;_TextureSample5;Texture Sample 5;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;50;-1060.106,-354.4185;Inherit;True;Property;_TextureSample6;Texture Sample 6;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;266;-78.8293,-1230.746;Inherit;False;baseColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;235;-712.3485,727.3322;Inherit;False;853.0981;468.4968;;5;231;232;233;234;349;Emission;0.989594,0.495283,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-1858.379,181.1036;Inherit;False;Property;_MicroNormalStrength;Micro Normal Strength;10;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-871.9211,1800.792;Inherit;False;Property;_SmoothnessPower;SmoothnessPower;4;0;Create;True;0;0;0;False;0;False;0.1;1.25;0.1;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;293;-744.9214,2263.6;Inherit;False;286;ambientOcclusionMap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;174;-3191.699,1240.569;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;223;-1383.707,1655.434;Inherit;False;Property;BOOLEAN_IS_HEAD;Is Head;25;0;Create;False;0;0;0;False;0;False;0;1;1;True;BOOLEAN_IS_HEAD_ON;Toggle;2;Key0;Key1;Reference;-1;True;False;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-875.9194,1536.553;Inherit;False;Property;_SmoothnessMin;SmoothnessMin;5;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;54;-637.8616,-476.0903;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;39;-556.8064,1721.507;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;-1322.022,228.412;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;276;-2960.786,1235.781;Inherit;False;microSmoothnessMod;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;33;-419.5572,2268.659;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;267;-522.2372,2984.478;Inherit;False;266;baseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;344;-1409.892,80.13995;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;66;-553.8407,3074.174;Inherit;False;Property;_SubsurfaceFalloff;Subsurface Falloff;18;0;Create;True;0;0;0;False;0;False;1,0.3686275,0.2980392,0;1,0.3686274,0.2980391,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;29;-1342.003,2753.873;Inherit;True;Property;_ThicknessMap;Thickness Map;20;0;Create;True;0;0;0;False;0;False;None;None;False;black;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;43;-875.0477,1635.282;Inherit;False;Property;_SmoothnessMax;SmoothnessMax;6;0;Create;True;0;0;0;False;0;False;0;0.897;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;351;-1147.294,2964.373;Inherit;False;1;0;SAMPLERSTATE;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.RangedFloatNode;261;-721.6152,3362.953;Inherit;False;Constant;_SubsurfaceWrapMax;Subsurface Wrap Max;53;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;231;-662.3489,860.8763;Inherit;True;Property;_EmissionMap;Emission Map;53;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;36;-565.9235,2368.116;Inherit;False;Property;_AOStrength;AO Strength;3;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerStateNode;349;-643.3763,1075.025;Inherit;False;0;0;0;1;2;None;1;0;SAMPLER2D;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.TexturePropertyNode;53;-1423.622,-134.7473;Inherit;True;Property;_MicroNormalMap;Micro Normal Map;9;1;[Normal];Create;True;0;0;0;False;0;False;None;None;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;-352.7205,3236.028;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;232;-382.6018,965.829;Inherit;True;Property;_TextureSample12;Texture Sample 12;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;278;-325.832,1795.122;Inherit;False;276;microSmoothnessMod;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;285;-2905.11,2193.511;Inherit;False;metallicMap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;41;-287.2786,1612.065;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;52;-1062.202,15.95127;Inherit;True;Property;_TextureSample7;Texture Sample 7;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;71;-378.1487,-658.8517;Inherit;False;Property;BOOLEAN_IS_HEAD;Is Head;22;0;Create;False;0;0;0;False;0;False;0;1;1;True;BOOLEAN_IS_HEAD_ON;Toggle;2;Key0;Key1;Reference;-1;True;False;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;233;-313.2517,777.3322;Inherit;False;Property;_EmissiveColor;Emissive Color;54;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-198.9745,2262.323;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;114;-928.1096,2955.94;Inherit;False;Property;_ThicknessScale;ThicknessScale;21;0;Create;True;0;0;0;False;0;False;1;0.4;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;30;-939.8237,2737.313;Inherit;True;Property;_TextureSample3;Texture Sample 3;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;333;-296.9436,3018.595;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendNormalsNode;61;-75.69183,-462.3363;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;290;-35.24173,1274.675;Inherit;False;285;metallicMap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;175;5.836142,1715.487;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;234;-21.252,912.3322;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;115;18.53439,2739.98;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;37;-25.01527,2270.281;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;119;22.44539,3061.266;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.StickyNoteNode;197;-4275.65,-395.1431;Inherit;False;182.5439;132.5438;MNAO Map;;1,1,1,1;R - mouth cavity mask$G - mouth gradient$B - nostril gradient$A - lip gradient;0;0
Node;AmplifyShaderEditor.WireNode;328;880.9077,1160.497;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;330;883.8939,1357.387;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;326;882.9077,942.21;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;327;883.8939,1075.621;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;347;896.9354,1761.175;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;325;881.9077,826.496;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;329;877.9216,1257.331;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;346;884.6307,1707.031;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;323;1340.147,1015.257;Half;False;True;-1;2;;0;0;Standard;Reallusion/Amplify/RL_SkinShader_Variants_3D;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;ForwardOnly;18;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;55;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;True;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;150;0;126;0
WireConnection;150;1;127;0
WireConnection;150;2;128;0
WireConnection;150;3;129;0
WireConnection;123;0;120;0
WireConnection;123;7;353;0
WireConnection;154;0;140;0
WireConnection;154;1;141;0
WireConnection;154;2;142;0
WireConnection;154;3;143;0
WireConnection;152;0;134;0
WireConnection;152;1;135;0
WireConnection;183;0;150;0
WireConnection;153;0;148;0
WireConnection;153;1;137;0
WireConnection;153;2;138;0
WireConnection;153;3;139;0
WireConnection;155;0;144;0
WireConnection;155;1;145;0
WireConnection;151;0;130;0
WireConnection;151;1;131;0
WireConnection;151;2;132;0
WireConnection;151;3;133;0
WireConnection;125;0;122;0
WireConnection;125;7;353;0
WireConnection;124;0;121;0
WireConnection;124;7;353;0
WireConnection;161;0;155;0
WireConnection;182;0;153;0
WireConnection;165;0;125;0
WireConnection;157;0;153;0
WireConnection;181;0;123;0
WireConnection;159;0;154;0
WireConnection;168;0;152;0
WireConnection;180;0;183;0
WireConnection;164;0;124;0
WireConnection;163;0;123;0
WireConnection;166;0;150;0
WireConnection;167;0;151;0
WireConnection;179;1;181;0
WireConnection;179;2;180;0
WireConnection;179;3;182;0
WireConnection;179;4;146;0
WireConnection;179;5;147;0
WireConnection;156;1;163;0
WireConnection;156;2;164;0
WireConnection;156;3;165;0
WireConnection;156;4;166;0
WireConnection;156;5;167;0
WireConnection;156;6;168;0
WireConnection;156;7;157;0
WireConnection;156;8;159;0
WireConnection;156;9;161;0
WireConnection;156;10;146;0
WireConnection;156;11;147;0
WireConnection;169;1;179;8
WireConnection;169;0;156;14
WireConnection;172;0;68;0
WireConnection;172;1;169;0
WireConnection;277;0;172;0
WireConnection;28;0;27;0
WireConnection;28;7;350;0
WireConnection;334;0;28;2
WireConnection;334;1;279;0
WireConnection;196;0;195;0
WireConnection;196;7;354;0
WireConnection;355;0;334;0
WireConnection;203;0;196;4
WireConnection;203;1;206;0
WireConnection;337;0;355;0
WireConnection;337;1;355;0
WireConnection;337;2;336;0
WireConnection;202;0;196;3
WireConnection;202;1;205;0
WireConnection;201;0;196;2
WireConnection;201;1;204;0
WireConnection;1;0;2;0
WireConnection;207;0;201;0
WireConnection;207;1;202;0
WireConnection;207;2;203;0
WireConnection;338;0;337;0
WireConnection;339;0;338;0
WireConnection;32;0;31;0
WireConnection;32;7;352;0
WireConnection;280;0;207;0
WireConnection;357;0;356;0
WireConnection;357;1;1;0
WireConnection;12;0;11;0
WireConnection;12;7;2;1
WireConnection;13;0;12;0
WireConnection;13;1;357;0
WireConnection;13;2;14;0
WireConnection;295;0;196;1
WireConnection;340;0;339;0
WireConnection;288;0;32;4
WireConnection;209;0;13;0
WireConnection;209;1;281;0
WireConnection;341;0;343;0
WireConnection;341;1;59;0
WireConnection;170;1;179;7
WireConnection;170;0;156;13
WireConnection;222;0;282;0
WireConnection;222;1;292;0
WireConnection;72;1;357;0
WireConnection;72;0;209;0
WireConnection;287;0;32;3
WireConnection;342;0;60;0
WireConnection;342;1;343;0
WireConnection;286;0;32;2
WireConnection;48;0;49;0
WireConnection;48;5;342;0
WireConnection;48;7;348;0
WireConnection;50;0;51;0
WireConnection;50;5;341;0
WireConnection;50;7;348;0
WireConnection;266;0;72;0
WireConnection;174;0;170;0
WireConnection;174;1;171;0
WireConnection;223;1;292;0
WireConnection;223;0;222;0
WireConnection;54;0;48;0
WireConnection;54;1;50;0
WireConnection;39;0;223;0
WireConnection;39;1;40;0
WireConnection;57;0;58;0
WireConnection;57;1;289;0
WireConnection;57;2;345;0
WireConnection;276;0;174;0
WireConnection;33;0;293;0
WireConnection;344;0;62;0
WireConnection;351;0;350;0
WireConnection;69;0;355;0
WireConnection;69;1;261;0
WireConnection;232;0;231;0
WireConnection;232;7;349;0
WireConnection;285;0;32;1
WireConnection;41;0;42;0
WireConnection;41;1;43;0
WireConnection;41;2;39;0
WireConnection;52;0;53;0
WireConnection;52;1;344;0
WireConnection;52;5;57;0
WireConnection;71;1;48;0
WireConnection;71;0;54;0
WireConnection;35;0;33;0
WireConnection;35;1;36;0
WireConnection;30;0;29;0
WireConnection;30;7;351;0
WireConnection;333;0;267;0
WireConnection;333;1;66;0
WireConnection;61;0;71;0
WireConnection;61;1;52;0
WireConnection;175;0;41;0
WireConnection;175;1;278;0
WireConnection;234;0;233;0
WireConnection;234;1;232;0
WireConnection;115;0;30;2
WireConnection;115;1;114;0
WireConnection;115;2;333;0
WireConnection;37;0;35;0
WireConnection;119;0;333;0
WireConnection;119;1;69;0
WireConnection;328;0;290;0
WireConnection;330;0;37;0
WireConnection;326;0;61;0
WireConnection;327;0;234;0
WireConnection;347;0;119;0
WireConnection;325;0;266;0
WireConnection;329;0;175;0
WireConnection;346;0;115;0
WireConnection;323;0;325;0
WireConnection;323;1;326;0
WireConnection;323;2;327;0
WireConnection;323;3;328;0
WireConnection;323;4;329;0
WireConnection;323;5;330;0
WireConnection;323;6;346;0
WireConnection;323;7;347;0
ASEEND*/
//CHKSM=E4D144AE3686D3AD1B495D577F7DA4A8F68C068A