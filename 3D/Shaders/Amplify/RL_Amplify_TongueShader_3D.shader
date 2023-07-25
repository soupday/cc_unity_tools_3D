// Made with Amplify Shader Editor v1.9.1.8
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Reallusion/Amplify/RL_TongueShader_3D"
{
	Properties
	{
		_DiffuseMap("Diffuse Map", 2D) = "white" {}
		_TongueSaturation("Tongue Saturation", Range( 0 , 2)) = 0.88
		_TongueBrightness("Tongue Brightness", Range( 0 , 2)) = 1
		_TongueSSS("Tongue Subsurface Scatter", Range( 0 , 1)) = 1
		_TongueThickness("Tongue Thickness", Range( 0 , 1)) = 0.75
		_SubsurfaceFalloff("Subsurface Falloff", Color) = (1,0.6163554,0.4858491,0)
		[Header(Translucency)]
		_Translucency("Strength", Range( 0 , 50)) = 1
		_TransNormalDistortion("Normal Distortion", Range( 0 , 1)) = 0.1
		_TransScattering("Scaterring Falloff", Range( 1 , 50)) = 2
		_TransDirect("Direct", Range( 0 , 1)) = 1
		_TransAmbient("Ambient", Range( 0 , 1)) = 0.2
		_TransShadow("Shadow", Range( 0 , 1)) = 0.9
		_MaskMap("Mask Map", 2D) = "black" {}
		_AOStrength("Ambient Occlusion Strength", Range( 0 , 1)) = 1
		_SmoothnessPower("Smoothness Power", Range( 0.25 , 2)) = 0.5
		_SmoothnessFront("Smoothness Front", Range( 0 , 1)) = 0
		_SmoothnessRear("Smoothness Rear", Range( 0 , 1)) = 0
		_SmoothnessMax("Smoothness Max", Range( 0 , 1)) = 0.88
		_NormalMap("Normal Map", 2D) = "bump" {}
		_NormalStrength("Normal Strength", Range( 0 , 2)) = 1
		_MicroNormalMap("Micro Normal Map", 2D) = "bump" {}
		_MicroNormalStrength("Micro Normal Strength", Range( 0 , 1)) = 0.5
		_MicroNormalTiling("Micro Normal Tiling", Range( 0 , 10)) = 4
		_EmissionMap("Emission Map", 2D) = "white" {}
		_EmissiveColor("Emissive Color", Color) = (0,0,0,0)
		_GradientAOMap("Gradient AO Map", 2D) = "white" {}
		_FrontAO("Front AO", Range( 0 , 1.5)) = 1
		_RearAO("Rear AO", Range( 0 , 1.5)) = 0
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
		#define ASE_USING_SAMPLING_MACROS 1
		#if defined(SHADER_API_D3D11) || defined(SHADER_API_XBOXONE) || defined(UNITY_COMPILER_HLSLCC) || defined(SHADER_API_PSSL) || (defined(SHADER_TARGET_SURFACE_ANALYSIS) && !defined(SHADER_TARGET_SURFACE_ANALYSIS_MOJOSHADER))//ASE Sampler Macros
		#define SAMPLE_TEXTURE2D(tex,samplerTex,coord) tex.Sample(samplerTex,coord)
		#else//ASE Sampling Macros
		#define SAMPLE_TEXTURE2D(tex,samplerTex,coord) tex2D(tex,coord)
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
		SamplerState sampler_NormalMap;
		uniform half _NormalStrength;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_MicroNormalMap);
		uniform half _MicroNormalTiling;
		SamplerState sampler_MicroNormalMap;
		uniform half _MicroNormalStrength;
		uniform half _RearAO;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_DiffuseMap);
		uniform half4 _DiffuseMap_ST;
		SamplerState sampler_DiffuseMap;
		uniform half _TongueSaturation;
		uniform half _TongueBrightness;
		uniform half _FrontAO;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_GradientAOMap);
		uniform half4 _GradientAOMap_ST;
		SamplerState sampler_GradientAOMap;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_EmissionMap);
		uniform half4 _EmissionMap_ST;
		SamplerState sampler_EmissionMap;
		uniform half4 _EmissiveColor;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_MaskMap);
		uniform half4 _MaskMap_ST;
		SamplerState sampler_MaskMap;
		uniform half _SmoothnessRear;
		uniform half _SmoothnessFront;
		uniform half _SmoothnessMax;
		uniform half _SmoothnessPower;
		uniform half _AOStrength;
		uniform half _TongueThickness;
		uniform half4 _SubsurfaceFalloff;
		uniform half _Translucency;
		uniform half _TransNormalDistortion;
		uniform half _TransScattering;
		uniform half _TransDirect;
		uniform half _TransAmbient;
		uniform half _TransShadow;
		uniform half _TongueSSS;


		half3 HSVToRGB( half3 c )
		{
			half4 K = half4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
			half3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
			return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
		}


		half3 RGBToHSV(half3 c)
		{
			half4 K = half4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
			half4 p = lerp( half4( c.bg, K.wz ), half4( c.gb, K.xy ), step( c.b, c.g ) );
			half4 q = lerp( half4( p.xyw, c.r ), half4( c.r, p.yzx ), step( p.x, c.r ) );
			half d = q.x - min( q.w, q.y );
			half e = 1.0e-10;
			return half3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
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
			half2 temp_cast_0 = (_MicroNormalTiling).xx;
			float2 uv_TexCoord77 = i.uv_texcoord * temp_cast_0;
			o.Normal = BlendNormals( UnpackScaleNormal( SAMPLE_TEXTURE2D( _NormalMap, sampler_NormalMap, uv_NormalMap ), _NormalStrength ) , UnpackScaleNormal( SAMPLE_TEXTURE2D( _MicroNormalMap, sampler_MicroNormalMap, uv_TexCoord77 ), _MicroNormalStrength ) );
			float2 uv_DiffuseMap = i.uv_texcoord * _DiffuseMap_ST.xy + _DiffuseMap_ST.zw;
			half3 hsvTorgb33 = RGBToHSV( SAMPLE_TEXTURE2D( _DiffuseMap, sampler_DiffuseMap, uv_DiffuseMap ).rgb );
			half3 hsvTorgb36 = HSVToRGB( half3(hsvTorgb33.x,( _TongueSaturation * hsvTorgb33.y ),( hsvTorgb33.z * _TongueBrightness )) );
			float2 uv_GradientAOMap = i.uv_texcoord * _GradientAOMap_ST.xy + _GradientAOMap_ST.zw;
			half4 tex2DNode31 = SAMPLE_TEXTURE2D( _GradientAOMap, sampler_GradientAOMap, uv_GradientAOMap );
			half3 lerpResult40 = lerp( ( _RearAO * hsvTorgb36 ) , ( hsvTorgb36 * _FrontAO ) , tex2DNode31.b);
			o.Albedo = lerpResult40;
			float2 uv_EmissionMap = i.uv_texcoord * _EmissionMap_ST.xy + _EmissionMap_ST.zw;
			o.Emission = ( SAMPLE_TEXTURE2D( _EmissionMap, sampler_EmissionMap, uv_EmissionMap ) * _EmissiveColor ).rgb;
			float2 uv_MaskMap = i.uv_texcoord * _MaskMap_ST.xy + _MaskMap_ST.zw;
			half4 tex2DNode52 = SAMPLE_TEXTURE2D( _MaskMap, sampler_MaskMap, uv_MaskMap );
			o.Metallic = tex2DNode52.r;
			half lerpResult58 = lerp( _SmoothnessFront , _SmoothnessMax , tex2DNode52.a);
			half lerpResult60 = lerp( _SmoothnessRear , lerpResult58 , tex2DNode31.b);
			o.Smoothness = pow( saturate( lerpResult60 ) , _SmoothnessPower );
			o.Occlusion = ( 1.0 - ( _AOStrength * ( 1.0 - tex2DNode52.g ) ) );
			half3 baseColor101 = lerpResult40;
			half4 temp_output_103_0 = ( _SubsurfaceFalloff * half4( baseColor101 , 0.0 ) );
			o.Transmission = ( _TongueThickness * temp_output_103_0 ).rgb;
			o.Translucency = ( _TongueSSS * 0.5 * temp_output_103_0 ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
}
/*ASEBEGIN
Version=19108
Node;AmplifyShaderEditor.CommentaryNode;74;-3493.593,-1702.376;Inherit;False;2241.031;624.6102;;17;8;32;33;21;22;35;34;37;24;36;42;23;39;38;41;40;101;Base Color;0,1,0.1846018,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;8;-3443.593,-1607.289;Inherit;True;Property;_DiffuseMap;Diffuse Map;0;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.CommentaryNode;93;-4471.664,-192.7987;Inherit;False;667.9326;346.7067;Comment;2;12;31;Gradient AO Map;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;32;-3153.32,-1539.403;Inherit;True;Property;_TextureSample1;Texture Sample 1;22;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;92;-4445.581,982.2064;Inherit;False;718.9189;375.1714;Comment;2;9;52;Mask Map;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-2768.547,-1352.211;Inherit;False;Property;_TongueBrightness;Tongue Brightness;2;0;Create;True;0;0;0;False;0;False;1;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RGBToHSVNode;33;-2709.32,-1532.403;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TexturePropertyNode;12;-4421.664,-142.7987;Inherit;True;Property;_GradientAOMap;Gradient AO Map;26;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;21;-2760.547,-1629.209;Inherit;False;Property;_TongueSaturation;Tongue Saturation;1;0;Create;True;0;0;0;False;0;False;0.88;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;9;-4395.581,1032.206;Inherit;True;Property;_MaskMap;Mask Map;13;0;Create;True;0;0;0;False;0;False;None;None;False;black;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;31;-4123.732,-76.09189;Inherit;True;Property;_TextureSample0;Texture Sample 0;22;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-2376.32,-1515.403;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;37;-2335.94,-1582.436;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-2378.32,-1407.403;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;52;-4046.661,1127.378;Inherit;True;Property;_TextureSample3;Texture Sample 3;22;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;42;-3376.364,-1159.767;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-2103.724,-1310.377;Inherit;False;Property;_FrontAO;Front AO;27;0;Create;True;0;0;0;False;0;False;1;0;0;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-2082.724,-1652.376;Inherit;False;Property;_RearAO;Rear AO;28;0;Create;True;0;0;0;False;0;False;0;0;0;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;36;-2145.94,-1512.436;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-1756.494,-1554.113;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;41;-1877.158,-1170.437;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-1755.494,-1430.113;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;95;-3350.252,1114.407;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;62;-3345.506,941.0639;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;72;-2432.572,705.6859;Inherit;False;1173.782;459.0215;;11;19;20;18;58;61;60;17;63;71;81;96;Smoothness;0,0.9706273,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;40;-1451.411,-1437.577;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;65;-2105.592,1349.446;Inherit;False;837.4114;248.9116;;5;53;16;54;55;64;Ambient Occlusion;0,0.9703217,1,1;0;0
Node;AmplifyShaderEditor.WireNode;71;-2386.571,1033.568;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;81;-2386.523,968.8609;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;79;-2687.586,-941.2751;Inherit;False;1440.32;790.7128;;9;10;75;76;13;11;15;77;78;14;Normals;0,0.05203342,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-2345.567,824.7075;Inherit;False;Property;_SmoothnessFront;Smoothness Front;16;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-2343.567,901.7075;Inherit;False;Property;_SmoothnessMax;Smoothness Max;18;0;Create;True;0;0;0;False;0;False;0.88;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;80;-3341.4,1394.731;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;61;-1884.255,1028.881;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;73;-2099.196,-6.643385;Inherit;False;853.4982;554.0004;;4;28;29;48;49;Emission;0,1,0.1634262,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-2637.586,-375.5628;Inherit;False;Property;_MicroNormalTiling;Micro Normal Tiling;23;0;Create;True;0;0;0;False;0;False;4;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;70;-2032.559,1781.668;Inherit;False;762.3082;639.7178;;8;47;104;26;105;103;25;102;30;Subsurface;1,0,0,1;0;0
Node;AmplifyShaderEditor.WireNode;64;-2063.204,1516.432;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;58;-1960.836,887.5919;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;101;-1471.468,-1288.117;Inherit;False;baseColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-2074.565,787.7074;Inherit;False;Property;_SmoothnessRear;Smoothness Rear;17;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-2350.586,-685.5624;Inherit;False;Property;_NormalStrength;Normal Strength;20;0;Create;True;0;0;0;False;0;False;1;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;28;-2049.196,43.35661;Inherit;True;Property;_EmissionMap;Emission Map;24;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;10;-2306.945,-891.2751;Inherit;True;Property;_NormalMap;Normal Map;19;0;Create;True;0;0;0;False;0;False;None;None;False;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;14;-2351.586,-266.5624;Inherit;False;Property;_MicroNormalStrength;Micro Normal Strength;22;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;102;-1928.587,2113.471;Inherit;False;101;baseColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;77;-2307.1,-395.9956;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;53;-1846.181,1487.357;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-1959.352,1399.445;Inherit;False;Property;_AOStrength;Ambient Occlusion Strength;14;0;Create;False;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;60;-1750.107,896.8268;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;11;-2322.445,-594.3717;Inherit;True;Property;_MicroNormalMap;Micro Normal Map;21;0;Create;True;0;0;0;False;0;False;None;None;False;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.ColorNode;30;-1952.693,1925.792;Inherit;False;Property;_SubsurfaceFalloff;Subsurface Falloff;5;0;Create;True;0;0;0;False;0;False;1,0.6163554,0.4858491,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-1642.181,1445.357;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;105;-1970.587,2314.471;Inherit;False;Constant;_ConstTranslucencyWrap;Const Translucency Wrap;23;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;-1697.861,2016.197;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;96;-1574.723,851.9303;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;29;-1727.197,335.3574;Inherit;False;Property;_EmissiveColor;Emissive Color;25;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;25;-1971.559,2227.934;Inherit;False;Property;_TongueSSS;Tongue Subsurface Scatter;3;0;Create;False;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-1981.559,1831.668;Inherit;False;Property;_TongueThickness;Tongue Thickness;4;0;Create;True;0;0;0;False;0;False;0.75;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;76;-1910.454,-538.645;Inherit;True;Property;_TextureSample5;Texture Sample 4;22;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;48;-1777.698,129.8341;Inherit;True;Property;_TextureSample2;Texture Sample 2;22;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;75;-1911.803,-801.9069;Inherit;True;Property;_TextureSample4;Texture Sample 4;22;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;99;-2470.812,639.3951;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-1782.565,1048.708;Inherit;False;Property;_SmoothnessPower;Smoothness Power;15;0;Create;True;0;0;0;False;0;False;0.5;0;0.25;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;78;-1475.268,-661.73;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;55;-1447.181,1462.357;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;63;-1435.787,904.9884;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;-1407.698,250.8343;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;98;-1300.726,616.6018;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-1431.996,2111.434;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;104;-1425.587,1846.471;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;108;-277.5022,-142.8375;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;113;-267.0724,404.7371;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;112;-267.0724,284.7922;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;111;-272.2874,214.3896;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;109;-272.2873,159.6325;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;114;-267.0723,488.1772;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;106;-274.8949,76.19246;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;107;-277.5022,-59.39759;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;97;343.2724,31.8975;Half;False;True;-1;2;;0;0;Standard;Reallusion/Amplify/RL_TongueShader_3D;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;ForwardOnly;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;6;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;True;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;32;0;8;0
WireConnection;33;0;32;0
WireConnection;31;0;12;0
WireConnection;34;0;21;0
WireConnection;34;1;33;2
WireConnection;37;0;33;1
WireConnection;35;0;33;3
WireConnection;35;1;22;0
WireConnection;52;0;9;0
WireConnection;42;0;31;3
WireConnection;36;0;37;0
WireConnection;36;1;34;0
WireConnection;36;2;35;0
WireConnection;38;0;24;0
WireConnection;38;1;36;0
WireConnection;41;0;42;0
WireConnection;39;0;36;0
WireConnection;39;1;23;0
WireConnection;95;0;52;4
WireConnection;62;0;31;3
WireConnection;40;0;38;0
WireConnection;40;1;39;0
WireConnection;40;2;41;0
WireConnection;71;0;62;0
WireConnection;81;0;95;0
WireConnection;80;0;52;2
WireConnection;61;0;71;0
WireConnection;64;0;80;0
WireConnection;58;0;19;0
WireConnection;58;1;20;0
WireConnection;58;2;81;0
WireConnection;101;0;40;0
WireConnection;77;0;15;0
WireConnection;53;0;64;0
WireConnection;60;0;18;0
WireConnection;60;1;58;0
WireConnection;60;2;61;0
WireConnection;54;0;16;0
WireConnection;54;1;53;0
WireConnection;103;0;30;0
WireConnection;103;1;102;0
WireConnection;96;0;60;0
WireConnection;76;0;11;0
WireConnection;76;1;77;0
WireConnection;76;5;14;0
WireConnection;48;0;28;0
WireConnection;75;0;10;0
WireConnection;75;5;13;0
WireConnection;99;0;52;1
WireConnection;78;0;75;0
WireConnection;78;1;76;0
WireConnection;55;0;54;0
WireConnection;63;0;96;0
WireConnection;63;1;17;0
WireConnection;49;0;48;0
WireConnection;49;1;29;0
WireConnection;98;0;99;0
WireConnection;47;0;25;0
WireConnection;47;1;105;0
WireConnection;47;2;103;0
WireConnection;104;0;26;0
WireConnection;104;1;103;0
WireConnection;108;0;40;0
WireConnection;113;0;104;0
WireConnection;112;0;55;0
WireConnection;111;0;63;0
WireConnection;109;0;98;0
WireConnection;114;0;47;0
WireConnection;106;0;49;0
WireConnection;107;0;78;0
WireConnection;97;0;108;0
WireConnection;97;1;107;0
WireConnection;97;2;106;0
WireConnection;97;3;109;0
WireConnection;97;4;111;0
WireConnection;97;5;112;0
WireConnection;97;6;113;0
WireConnection;97;7;114;0
ASEEND*/
//CHKSM=812D4B6D8CD3A5BE4ED41ADAEC9E8A94DEDE968C