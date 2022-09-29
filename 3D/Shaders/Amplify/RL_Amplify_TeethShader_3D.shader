// Made with Amplify Shader Editor v1.9.0.1
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Reallusion/Amplify/RL_TeethShader_3D"
{
	Properties
	{
		_DiffuseMap("Diffuse Map", 2D) = "white" {}
		_GumsSaturation("Gums Saturation", Range( 0 , 2)) = 0.88
		_GumsBrightness("Gums Brightness", Range( 0 , 2)) = 1
		_TeethSaturation("Teeth Saturation", Range( 0 , 2)) = 0.88
		_TeethBrightness("Teeth Brightness", Range( 0 , 2)) = 1
		_GumsSSS("Gums Subsurface Scatter", Range( 0 , 1)) = 1
		_GumsThickness("Gums Thickness", Range( 0 , 1)) = 0.75
		_TeethSSS("Teeth Subsurface Scatter", Range( 0 , 1)) = 0.5
		_TeethThickness("Teeth Thickness", Range( 0 , 1)) = 0.75
		_SubsurfaceFalloff("Subsurface Falloff", Color) = (0.6509804,0.4823529,0.3960784,0)
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
		_GumsMaskMap("Gums Mask Map", 2D) = "white" {}
		_GradientAOMap("Gradient AO Map", 2D) = "white" {}
		_FrontAO("Front AO", Range( 0 , 1.5)) = 1
		_RearAO("Rear AO", Range( 0 , 1.5)) = 0
		_EmissionMap("Emission Map", 2D) = "white" {}
		_EmissiveColor("Emissive Color", Color) = (0,0,0,0)
		[Toggle]_IsUpperTeeth("Is Upper Teeth", Range( 0 , 1)) = 1
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

		uniform sampler2D _NormalMap;
		uniform half4 _NormalMap_ST;
		uniform half _NormalStrength;
		uniform sampler2D _MicroNormalMap;
		uniform half _MicroNormalTiling;
		uniform half _MicroNormalStrength;
		uniform half _RearAO;
		uniform sampler2D _DiffuseMap;
		uniform half4 _DiffuseMap_ST;
		uniform half _GumsSaturation;
		uniform half _GumsBrightness;
		uniform half _TeethSaturation;
		uniform half _TeethBrightness;
		uniform sampler2D _GumsMaskMap;
		uniform half4 _GumsMaskMap_ST;
		uniform half _FrontAO;
		uniform sampler2D _GradientAOMap;
		uniform half4 _GradientAOMap_ST;
		uniform half _IsUpperTeeth;
		uniform sampler2D _EmissionMap;
		uniform half4 _EmissionMap_ST;
		uniform half4 _EmissiveColor;
		uniform sampler2D _MaskMap;
		uniform half4 _MaskMap_ST;
		uniform half _SmoothnessRear;
		uniform half _SmoothnessFront;
		uniform half _SmoothnessMax;
		uniform half _SmoothnessPower;
		uniform half _AOStrength;
		uniform half _GumsThickness;
		uniform half _TeethThickness;
		uniform half4 _SubsurfaceFalloff;
		uniform half _Translucency;
		uniform half _TransNormalDistortion;
		uniform half _TransScattering;
		uniform half _TransDirect;
		uniform half _TransAmbient;
		uniform half _TransShadow;
		uniform half _GumsSSS;
		uniform half _TeethSSS;


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
			o.Normal = BlendNormals( UnpackScaleNormal( tex2D( _NormalMap, uv_NormalMap ), _NormalStrength ) , UnpackScaleNormal( tex2D( _MicroNormalMap, uv_TexCoord77 ), _MicroNormalStrength ) );
			float2 uv_DiffuseMap = i.uv_texcoord * _DiffuseMap_ST.xy + _DiffuseMap_ST.zw;
			half4 tex2DNode32 = tex2D( _DiffuseMap, uv_DiffuseMap );
			half3 hsvTorgb33 = RGBToHSV( tex2DNode32.rgb );
			half3 hsvTorgb36 = HSVToRGB( half3(hsvTorgb33.x,( _GumsSaturation * hsvTorgb33.y ),( hsvTorgb33.z * _GumsBrightness )) );
			half3 hsvTorgb96 = RGBToHSV( tex2DNode32.rgb );
			half3 hsvTorgb99 = HSVToRGB( half3(hsvTorgb96.x,( _TeethSaturation * hsvTorgb96.y ),( hsvTorgb96.z * _TeethBrightness )) );
			float2 uv_GumsMaskMap = i.uv_texcoord * _GumsMaskMap_ST.xy + _GumsMaskMap_ST.zw;
			half4 tex2DNode103 = tex2D( _GumsMaskMap, uv_GumsMaskMap );
			half3 lerpResult101 = lerp( hsvTorgb36 , hsvTorgb99 , tex2DNode103.g);
			float2 uv_GradientAOMap = i.uv_texcoord * _GradientAOMap_ST.xy + _GradientAOMap_ST.zw;
			half4 tex2DNode31 = tex2D( _GradientAOMap, uv_GradientAOMap );
			half lerpResult132 = lerp( tex2DNode31.r , tex2DNode31.g , _IsUpperTeeth);
			half3 lerpResult40 = lerp( ( _RearAO * lerpResult101 ) , ( lerpResult101 * _FrontAO ) , lerpResult132);
			o.Albedo = lerpResult40;
			float2 uv_EmissionMap = i.uv_texcoord * _EmissionMap_ST.xy + _EmissionMap_ST.zw;
			o.Emission = ( tex2D( _EmissionMap, uv_EmissionMap ) * _EmissiveColor ).rgb;
			float2 uv_MaskMap = i.uv_texcoord * _MaskMap_ST.xy + _MaskMap_ST.zw;
			half4 tex2DNode52 = tex2D( _MaskMap, uv_MaskMap );
			o.Metallic = tex2DNode52.r;
			half lerpResult58 = lerp( _SmoothnessFront , _SmoothnessMax , tex2DNode52.a);
			half lerpResult60 = lerp( _SmoothnessRear , lerpResult58 , lerpResult132);
			o.Smoothness = pow( saturate( lerpResult60 ) , _SmoothnessPower );
			o.Occlusion = ( 1.0 - ( _AOStrength * ( 1.0 - tex2DNode52.g ) ) );
			half lerpResult112 = lerp( _GumsThickness , _TeethThickness , tex2DNode103.g);
			half3 baseColor155 = lerpResult40;
			half4 temp_output_156_0 = ( _SubsurfaceFalloff * half4( baseColor155 , 0.0 ) );
			o.Transmission = ( lerpResult112 * temp_output_156_0 ).rgb;
			half lerpResult113 = lerp( _GumsSSS , _TeethSSS , tex2DNode103.g);
			o.Translucency = ( lerpResult113 * 0.5 * temp_output_156_0 ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
}
/*ASEBEGIN
Version=19001
1913;48;1920;981;4554.133;-705.5795;2.819794;True;False
Node;AmplifyShaderEditor.CommentaryNode;139;-4829.458,363.6766;Inherit;False;842.6992;426.936;;4;12;131;31;132;Gradient AO Map;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;109;-3795.151,-2528.385;Inherit;False;2612.074;1058.53;;27;138;136;40;38;39;101;23;24;137;104;36;99;98;97;37;34;100;35;33;21;94;95;96;22;32;8;155;Base Color;0,1,0.194277,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;106;-5123.6,-894.2192;Inherit;False;666.9336;346.7067;Comment;2;102;103;Teeth Gums Mask Map;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;12;-4779.458,413.6766;Inherit;True;Property;_GradientAOMap;Gradient AO Map;22;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;8;-3745.151,-2309.401;Inherit;True;Property;_DiffuseMap;Diffuse Map;0;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;131;-4506.226,674.6126;Inherit;False;Property;_IsUpperTeeth;Is Upper Teeth;27;1;[Toggle];Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;32;-3449.582,-2241.589;Inherit;True;Property;_TextureSample1;Texture Sample 1;22;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;102;-5073.6,-844.2194;Inherit;True;Property;_GumsMaskMap;Gums Mask Map;21;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;31;-4528.264,461.6078;Inherit;True;Property;_TextureSample0;Texture Sample 0;22;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;95;-2975.271,-1843.781;Inherit;False;Property;_TeethBrightness;Teeth Brightness;4;0;Create;True;0;0;0;False;0;False;1;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;94;-2968.271,-2100.779;Inherit;False;Property;_TeethSaturation;Teeth Saturation;3;0;Create;True;0;0;0;False;0;False;0.88;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;103;-4776.667,-777.5127;Inherit;True;Property;_TextureSample6;Texture Sample 6;22;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;132;-4168.759,490.8961;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-2962.104,-2478.385;Inherit;False;Property;_GumsSaturation;Gums Saturation;1;0;Create;True;0;0;0;False;0;False;0.88;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-2970.104,-2201.387;Inherit;False;Property;_GumsBrightness;Gums Brightness;2;0;Create;True;0;0;0;False;0;False;1;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RGBToHSVNode;33;-2910.877,-2381.581;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RGBToHSVNode;96;-2917.044,-2003.974;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WireNode;100;-2551.504,-2046.496;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;98;-2586.044,-1878.974;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;140;-3724.99,372.8264;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;97;-2584.044,-1986.974;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;105;-3237.308,-981.7743;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-2579.877,-2256.58;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-2577.877,-2364.581;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;37;-2529.697,-2426.412;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;99;-2369.265,-2075.008;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.HSVToRGBNode;36;-2372.198,-2339.517;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WireNode;104;-2181.61,-1923.354;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;137;-3469.69,-1567.505;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;92;-3512.011,379.2985;Inherit;False;718.9189;375.1714;;2;9;52;Mask Map;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;9;-3462.011,429.2985;Inherit;True;Property;_MaskMap;Mask Map;10;0;Create;True;0;0;0;False;0;False;None;None;False;black;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.WireNode;141;-3758.351,598.6987;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;120;-4320.351,-339.2945;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-2079.869,-2012.656;Inherit;False;Property;_FrontAO;Front AO;23;0;Create;True;0;0;0;False;0;False;1;0;0;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-2090.766,-2290.25;Inherit;False;Property;_RearAO;Rear AO;24;0;Create;True;0;0;0;False;0;False;0;0;0;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;101;-2087.001,-2165.697;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;138;-3154.114,-1678.536;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;136;-2080.786,-1718.556;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;135;-3454.536,911.9537;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;119;-5041.24,745.8491;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;122;-2319.254,1547.23;Inherit;False;1109.012;922.9466;;17;114;47;153;113;157;112;156;154;30;25;26;110;115;111;116;118;117;Subsurface;1,0,0,1;0;0
Node;AmplifyShaderEditor.SamplerNode;52;-3113.092,524.4697;Inherit;True;Property;_TextureSample3;Texture Sample 3;22;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-1687.831,-2097.99;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-1688.831,-2221.989;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;72;-2380.73,456.7613;Inherit;False;1173.782;459.0215;;11;19;20;18;58;60;17;63;81;133;134;143;Smoothness;0,1,0.9804161,1;0;0
Node;AmplifyShaderEditor.LerpOp;40;-1388.533,-2170.082;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;134;-2345.94,866.3615;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;114;-2259.215,1989.599;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;81;-2334.681,719.9363;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-2291.725,652.7829;Inherit;False;Property;_SmoothnessMax;Smoothness Max;15;0;Create;True;0;0;0;False;0;False;0.88;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-2293.725,575.7829;Inherit;False;Property;_SmoothnessFront;Smoothness Front;13;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;79;-2613.842,-1267.397;Inherit;False;1440.32;790.7128;;9;10;75;76;13;11;15;77;78;14;Normals;0,0.05740881,1,1;0;0
Node;AmplifyShaderEditor.WireNode;80;-2517.718,1219.369;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;65;-2045.468,1106.598;Inherit;False;837.4114;248.9116;;5;53;16;54;55;64;Ambient Occlusion;0,1,0.9903088,1;0;0
Node;AmplifyShaderEditor.LerpOp;58;-1908.994,638.6673;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-2022.723,538.7828;Inherit;False;Property;_SmoothnessRear;Smoothness Rear;14;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;73;-2054.3,-286.5739;Inherit;False;853.4982;554.0004;;4;28;29;48;49;Emission;0,1,0.2013595,1;0;0
Node;AmplifyShaderEditor.WireNode;116;-1990.104,1768.811;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;133;-1942.781,824.5431;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-2563.842,-701.6833;Inherit;False;Property;_MicroNormalTiling;Micro Normal Tiling;20;0;Create;True;0;0;0;False;0;False;4;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;64;-2003.08,1273.584;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;117;-1952.104,2270.808;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;155;-1405.837,-1988.149;Inherit;False;baseColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;77;-2233.357,-722.1161;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;28;-2004.299,-236.5739;Inherit;True;Property;_EmissionMap;Emission Map;25;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.WireNode;118;-1714.104,2287.808;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-1921.99,1677.315;Inherit;False;Property;_TeethThickness;Teeth Thickness;8;0;Create;True;0;0;0;False;0;False;0.75;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;154;-1873.38,1996.275;Inherit;False;155;baseColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;30;-1899.914,1816.091;Inherit;False;Property;_SubsurfaceFalloff;Subsurface Falloff;9;0;Create;True;0;0;0;False;0;False;0.6509804,0.4823529,0.3960784,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;25;-1936.805,2181.09;Inherit;False;Property;_TeethSSS;Teeth Subsurface Scatter;7;0;Create;False;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-1899.228,1156.597;Inherit;False;Property;_AOStrength;Ambient Occlusion Strength;11;0;Create;False;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;111;-1935.741,2093.227;Inherit;False;Property;_GumsSSS;Gums Subsurface Scatter;5;0;Create;False;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-2276.842,-1011.683;Inherit;False;Property;_NormalStrength;Normal Strength;17;0;Create;True;0;0;0;False;0;False;1;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;53;-1786.057,1244.509;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;115;-1663.104,1770.811;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;110;-1926.741,1597.23;Inherit;False;Property;_GumsThickness;Gums Thickness;6;0;Create;True;0;0;0;False;0;False;0.75;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-2277.842,-592.6829;Inherit;False;Property;_MicroNormalStrength;Micro Normal Strength;19;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;11;-2248.702,-920.4922;Inherit;True;Property;_MicroNormalMap;Micro Normal Map;18;0;Create;True;0;0;0;False;0;False;None;None;False;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;10;-2233.202,-1217.397;Inherit;True;Property;_NormalMap;Normal Map;16;0;Create;True;0;0;0;False;0;False;None;None;False;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.LerpOp;60;-1695.785,648.0538;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;29;-1682.3,55.42698;Inherit;False;Property;_EmissiveColor;Emissive Color;26;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;113;-1591.61,2136.57;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;156;-1627.251,1891.367;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-1582.057,1202.509;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;75;-1838.058,-1128.028;Inherit;True;Property;_TextureSample4;Texture Sample 4;22;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;48;-1732.801,-150.0964;Inherit;True;Property;_TextureSample2;Texture Sample 2;22;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;143;-1524.302,594.598;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;112;-1560.61,1630.573;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-1783.723,808.783;Inherit;False;Property;_SmoothnessPower;Smoothness Power;12;0;Create;True;0;0;0;False;0;False;0.5;0;0.25;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;153;-1935.38,2355.275;Inherit;False;Constant;_ConstTranslucencyWrap;Const Translucency Wrap;29;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;76;-1836.709,-864.7654;Inherit;True;Property;_TextureSample5;Texture Sample 5;22;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;147;-2408.777,364.0581;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-1362.242,2135.587;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;-1362.801,-29.09617;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendNormalsNode;78;-1401.523,-987.8505;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;63;-1382.945,656.0638;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;55;-1387.057,1219.509;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;145;-1236.522,320.641;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;157;-1364.251,1695.367;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;162;-527.9666,42.3182;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;164;-531.3475,-106.1821;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;165;-528.7713,-209.2226;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;158;-528.1463,392.9568;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;166;-521.7424,264.0499;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;160;-525.5538,170.9873;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;163;-529.7709,-4.592896;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;161;-525.358,98.4462;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;144;-153.9204,-76.92043;Half;False;True;-1;2;;0;0;Standard;Reallusion/Amplify/RL_TeethShader_3D;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;ForwardOnly;18;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;28;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;32;0;8;0
WireConnection;31;0;12;0
WireConnection;103;0;102;0
WireConnection;132;0;31;1
WireConnection;132;1;31;2
WireConnection;132;2;131;0
WireConnection;33;0;32;0
WireConnection;96;0;32;0
WireConnection;100;0;96;1
WireConnection;98;0;96;3
WireConnection;98;1;95;0
WireConnection;140;0;132;0
WireConnection;97;0;94;0
WireConnection;97;1;96;2
WireConnection;105;0;103;2
WireConnection;35;0;33;3
WireConnection;35;1;22;0
WireConnection;34;0;21;0
WireConnection;34;1;33;2
WireConnection;37;0;33;1
WireConnection;99;0;100;0
WireConnection;99;1;97;0
WireConnection;99;2;98;0
WireConnection;36;0;37;0
WireConnection;36;1;34;0
WireConnection;36;2;35;0
WireConnection;104;0;105;0
WireConnection;137;0;140;0
WireConnection;141;0;132;0
WireConnection;120;0;103;2
WireConnection;101;0;36;0
WireConnection;101;1;99;0
WireConnection;101;2;104;0
WireConnection;138;0;137;0
WireConnection;136;0;138;0
WireConnection;135;0;141;0
WireConnection;119;0;120;0
WireConnection;52;0;9;0
WireConnection;39;0;101;0
WireConnection;39;1;23;0
WireConnection;38;0;24;0
WireConnection;38;1;101;0
WireConnection;40;0;38;0
WireConnection;40;1;39;0
WireConnection;40;2;136;0
WireConnection;134;0;135;0
WireConnection;114;0;119;0
WireConnection;81;0;52;4
WireConnection;80;0;52;2
WireConnection;58;0;19;0
WireConnection;58;1;20;0
WireConnection;58;2;81;0
WireConnection;116;0;114;0
WireConnection;133;0;134;0
WireConnection;64;0;80;0
WireConnection;117;0;114;0
WireConnection;155;0;40;0
WireConnection;77;0;15;0
WireConnection;118;0;117;0
WireConnection;53;0;64;0
WireConnection;115;0;116;0
WireConnection;60;0;18;0
WireConnection;60;1;58;0
WireConnection;60;2;133;0
WireConnection;113;0;111;0
WireConnection;113;1;25;0
WireConnection;113;2;118;0
WireConnection;156;0;30;0
WireConnection;156;1;154;0
WireConnection;54;0;16;0
WireConnection;54;1;53;0
WireConnection;75;0;10;0
WireConnection;75;5;13;0
WireConnection;48;0;28;0
WireConnection;143;0;60;0
WireConnection;112;0;110;0
WireConnection;112;1;26;0
WireConnection;112;2;115;0
WireConnection;76;0;11;0
WireConnection;76;1;77;0
WireConnection;76;5;14;0
WireConnection;147;0;52;1
WireConnection;47;0;113;0
WireConnection;47;1;153;0
WireConnection;47;2;156;0
WireConnection;49;0;48;0
WireConnection;49;1;29;0
WireConnection;78;0;75;0
WireConnection;78;1;76;0
WireConnection;63;0;143;0
WireConnection;63;1;17;0
WireConnection;55;0;54;0
WireConnection;145;0;147;0
WireConnection;157;0;112;0
WireConnection;157;1;156;0
WireConnection;162;0;145;0
WireConnection;164;0;78;0
WireConnection;165;0;40;0
WireConnection;158;0;47;0
WireConnection;166;0;157;0
WireConnection;160;0;55;0
WireConnection;163;0;49;0
WireConnection;161;0;63;0
WireConnection;144;0;165;0
WireConnection;144;1;164;0
WireConnection;144;2;163;0
WireConnection;144;3;162;0
WireConnection;144;4;161;0
WireConnection;144;5;160;0
WireConnection;144;6;166;0
WireConnection;144;7;158;0
ASEEND*/
//CHKSM=7EBA05902BF8A7B11DC9DF5B11E52C6C33B0B413