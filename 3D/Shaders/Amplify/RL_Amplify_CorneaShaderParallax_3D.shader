// Made with Amplify Shader Editor v1.9.0.1
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Reallusion/Amplify/RL_CorneaShaderParallax_3D"
{
	Properties
	{
		_ScleraDiffuseMap("Sclera Diffuse Map", 2D) = "white" {}
		_ScleraScale("Sclera Scale", Range( 0.25 , 2)) = 1
		_ScleraHue("Sclera Hue", Range( 0 , 1)) = 0.5
		_ScleraSaturation("Sclera Saturation", Range( 0 , 2)) = 1
		_ScleraBrightness("Sclera Brightness", Range( 0 , 2)) = 1
		_CorneaDiffuseMap("Cornea Diffuse Map", 2D) = "white" {}
		_IrisScale("Iris Scale", Range( 0 , 2)) = 1
		_IrisHue("Iris Hue", Range( 0 , 1)) = 0.5
		_IrisSaturation("Iris Saturation", Range( 0 , 2)) = 1
		_IrisBrightness("Iris Brightness", Range( 0 , 2)) = 1
		_IrisRadius("Iris Radius", Range( 0.01 , 0.2)) = 0.15
		_LimbusWidth("Limbus Width", Range( 0.01 , 0.1)) = 0.055
		_LimbusDarkRadius("Limbus Dark Radius", Range( 0.01 , 0.2)) = 0.1
		_LimbusDarkWidth("Limbus Dark Width", Range( 0.01 , 0.1)) = 0.025
		_LimbusColor("Limbus Color", Color) = (0,0,0,0)
		_IrisColor("Iris Color", Color) = (0,0,0,0)
		_IrisCloudyColor("Iris Cloudy Color", Color) = (0,0,0,0)
		_ShadowRadius("Shadow Radius", Range( 0 , 0.5)) = 0.275
		_ShadowHardness("Shadow Hardness", Range( 0.01 , 0.99)) = 0.5
		_CornerShadowColor("Corner Shadow Color", Color) = (1,0.7333333,0.6980392,0)
		_ScleraSubsurfaceScale("Sclera Subsurface Scale", Range( 0 , 1)) = 0.5
		_IrisSubsurfaceScale("Iris Subsurface Scale", Range( 0 , 1)) = 0
		_SubsurfaceFalloff("Subsurface Falloff", Color) = (1,1,1,0)
		_MaskMap("Mask Map", 2D) = "white" {}
		_AOStrength("Ambient Occlusion Strength", Range( 0 , 1)) = 0.2
		_ScleraSmoothness("Sclera Smoothness", Range( 0 , 1)) = 0.8
		_CorneaSmoothness("Cornea Smoothness", Range( 0 , 1)) = 1
		_ColorBlendMap("Color Blend Map", 2D) = "white" {}
		_ColorBlendStrength("Color Blend Strength", Range( 0 , 1)) = 0.2
		_ScleraNormalMap("Sclera Normal Map", 2D) = "bump" {}
		_ScleraNormalStrength("Sclera Normal Strength", Range( 0 , 1)) = 0.1
		_ScleraNormalTiling("Sclera Normal Tiling", Range( 1 , 10)) = 2
		_EmissionMap("Emission Map", 2D) = "white" {}
		_EmissiveColor("Emissive Color", Color) = (0,0,0,0)
		_PupilScale("Pupil Scale", Range( 0.1 , 2)) = 0.8
		_IrisDepth("Iris Depth", Range( 0.1 , 1)) = 0.3
		_IOR("IOR", Range( 1 , 2)) = 1.4
		_PMod("Parrallax Mod", Range( 0 , 10)) = 6.4
		_ParallaxRadius("Parallax Radius", Range( 0 , 0.16)) = 0.1175
		_DepthRadius("Depth Radius", Range( 0 , 1)) = 0.8
		[Toggle]_IsLeftEye("Is Left Eye", Range( 0 , 1)) = 0
		[Toggle(BOOLEAN_ISCORNEA_ON)] BOOLEAN_ISCORNEA("IsCornea", Float) = 1
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
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma shader_feature_local BOOLEAN_ISCORNEA_ON
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
			half3 viewDir;
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
			half3 Translucency;
		};

		uniform half _IsLeftEye;
		uniform sampler2D _ScleraNormalMap;
		uniform half _ScleraNormalTiling;
		uniform half _ScleraNormalStrength;
		uniform half _IrisRadius;
		uniform half _IrisScale;
		uniform half _LimbusWidth;
		uniform sampler2D _ColorBlendMap;
		uniform half4 _ColorBlendMap_ST;
		uniform half4 _LimbusColor;
		uniform half4 _IrisCloudyColor;
		uniform half _IrisHue;
		uniform sampler2D _CorneaDiffuseMap;
		uniform half _IrisDepth;
		uniform half _PupilScale;
		uniform half _DepthRadius;
		uniform half _IOR;
		uniform half _PMod;
		uniform half _ParallaxRadius;
		uniform half4 _IrisColor;
		uniform half _IrisSaturation;
		uniform half _IrisBrightness;
		uniform half _LimbusDarkRadius;
		uniform half _LimbusDarkWidth;
		uniform half4 _CornerShadowColor;
		uniform half _ScleraHue;
		uniform sampler2D _ScleraDiffuseMap;
		uniform half _ScleraScale;
		uniform half _ScleraSaturation;
		uniform half _ScleraBrightness;
		uniform half _ShadowHardness;
		uniform half _ShadowRadius;
		uniform half _ColorBlendStrength;
		uniform sampler2D _EmissionMap;
		uniform half4 _EmissionMap_ST;
		uniform half4 _EmissiveColor;
		uniform half _CorneaSmoothness;
		uniform half _ScleraSmoothness;
		uniform half _AOStrength;
		uniform sampler2D _MaskMap;
		uniform half4 _MaskMap_ST;
		uniform half _Translucency;
		uniform half _TransNormalDistortion;
		uniform half _TransScattering;
		uniform half _TransDirect;
		uniform half _TransAmbient;
		uniform half _TransShadow;
		uniform half _IrisSubsurfaceScale;
		uniform half _ScleraSubsurfaceScale;
		uniform half4 _SubsurfaceFalloff;


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

			SurfaceOutputStandard r;
			r.Albedo = s.Albedo;
			r.Normal = s.Normal;
			r.Emission = s.Emission;
			r.Metallic = s.Metallic;
			r.Smoothness = s.Smoothness;
			r.Occlusion = s.Occlusion;
			r.Alpha = s.Alpha;
			return LightingStandard (r, viewDir, gi) + c;
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
			half2 temp_cast_0 = (_ScleraNormalTiling).xx;
			float2 uv_TexCoord294 = i.uv_texcoord * temp_cast_0;
			half scaledIrisRadius209 = ( _IrisRadius * _IrisScale );
			half irisScale208 = _IrisScale;
			half radial203 = length( ( i.uv_texcoord - float2( 0.5,0.5 ) ) );
			half smoothstepResult28 = smoothstep( ( scaledIrisRadius209 - ( irisScale208 * _LimbusWidth ) ) , scaledIrisRadius209 , radial203);
			half irisMask213 = smoothstepResult28;
			o.Normal = UnpackScaleNormal( tex2D( _ScleraNormalMap, uv_TexCoord294 ), ( _ScleraNormalStrength * irisMask213 ) );
			float2 uv_ColorBlendMap = i.uv_texcoord * _ColorBlendMap_ST.xy + _ColorBlendMap_ST.zw;
			half irisDepth219 = _IrisDepth;
			half temp_output_1_0_g1 = ( _DepthRadius * scaledIrisRadius209 );
			half lerpResult83 = lerp( irisScale208 , ( irisScale208 * ( ( 0.333 / ( 0.333 + irisDepth219 ) ) * _PupilScale ) ) , saturate( ( ( radial203 - temp_output_1_0_g1 ) / ( 0.0 - temp_output_1_0_g1 ) ) ));
			half temp_output_88_0 = ( 1.0 / lerpResult83 );
			half2 temp_cast_1 = (temp_output_88_0).xx;
			half2 temp_cast_2 = (( ( 1.0 - temp_output_88_0 ) * 0.5 )).xx;
			float2 uv_TexCoord93 = i.uv_texcoord * temp_cast_1 + temp_cast_2;
			half3 ase_worldNormal = WorldNormalVector( i, half3( 0, 0, 1 ) );
			half3 ase_worldTangent = WorldNormalVector( i, half3( 1, 0, 0 ) );
			half3 ase_worldBitangent = WorldNormalVector( i, half3( 0, 1, 0 ) );
			half3x3 ase_worldToTangent = float3x3( ase_worldTangent, ase_worldBitangent, ase_worldNormal );
			half3 normalizeResult117 = normalize( ( ( mul( ase_worldToTangent, ase_worldNormal ) * ( _IOR - 0.8 ) ) + i.viewDir ) );
			half temp_output_122_0 = ( 1.0 / ( ( _IrisDepth * _PMod ) + 0.91 ) );
			half temp_output_152_0 = ( irisScale208 * _ParallaxRadius );
			half saferPower157 = abs( ( ( temp_output_152_0 - radial203 ) / temp_output_152_0 ) );
			half2 lerpResult136 = lerp( uv_TexCoord93 , (( uv_TexCoord93 - ( (normalizeResult117).xy * _IrisDepth ) )*temp_output_122_0 + ( ( 1.0 - temp_output_122_0 ) * 0.5 )) , pow( saferPower157 , 0.25 ));
			half3 hsvTorgb174 = RGBToHSV( ( tex2D( _CorneaDiffuseMap, lerpResult136 ) * _IrisColor ).rgb );
			half3 hsvTorgb184 = HSVToRGB( half3(( ( _IrisHue - 0.5 ) + hsvTorgb174.x ),( hsvTorgb174.y * _IrisSaturation ),( hsvTorgb174.z * _IrisBrightness )) );
			half4 blendOpSrc201 = _LimbusColor;
			half4 blendOpDest201 = ( ( _IrisCloudyColor * float4( 0.5,0.5,0.5,1 ) ) + half4( hsvTorgb184 , 0.0 ) );
			half temp_output_193_0 = ( _LimbusDarkRadius * irisScale208 );
			half smoothstepResult196 = smoothstep( temp_output_193_0 , ( temp_output_193_0 + ( irisScale208 * _LimbusDarkWidth ) ) , radial203);
			half4 lerpBlendMode201 = lerp(blendOpDest201,( blendOpSrc201 * blendOpDest201 ),smoothstepResult196);
			half temp_output_223_0 = ( 1.0 / _ScleraScale );
			half2 temp_cast_5 = (temp_output_223_0).xx;
			half2 temp_cast_6 = (( ( 1.0 - temp_output_223_0 ) * 0.5 )).xx;
			float2 uv_TexCoord228 = i.uv_texcoord * temp_cast_5 + temp_cast_6;
			half3 hsvTorgb231 = RGBToHSV( tex2D( _ScleraDiffuseMap, uv_TexCoord228 ).rgb );
			half3 hsvTorgb232 = HSVToRGB( half3(( ( _ScleraHue - 0.5 ) + hsvTorgb231.x ),( hsvTorgb231.y * _ScleraSaturation ),( hsvTorgb231.z * _ScleraBrightness )) );
			half4 blendOpSrc23 = _CornerShadowColor;
			half4 blendOpDest23 = half4( hsvTorgb232 , 0.0 );
			half temp_output_247_0 = ( _ScleraScale * _ShadowRadius );
			half temp_output_1_0_g13 = ( ( _ShadowHardness * _ScleraScale ) * temp_output_247_0 );
			half4 lerpBlendMode23 = lerp(blendOpDest23,( blendOpSrc23 * blendOpDest23 ),saturate( ( ( radial203 - temp_output_1_0_g13 ) / ( temp_output_247_0 - temp_output_1_0_g13 ) ) ));
			half4 lerpResult261 = lerp( ( saturate( lerpBlendMode201 )) , ( saturate( lerpBlendMode23 )) , irisMask213);
			half4 blendOpSrc21 = tex2D( _ColorBlendMap, uv_ColorBlendMap );
			half4 blendOpDest21 = lerpResult261;
			half4 lerpBlendMode21 = lerp(blendOpDest21,( blendOpSrc21 * blendOpDest21 ),_ColorBlendStrength);
			half4 temp_output_21_0 = ( saturate( lerpBlendMode21 ));
			o.Albedo = temp_output_21_0.rgb;
			float2 uv_EmissionMap = i.uv_texcoord * _EmissionMap_ST.xy + _EmissionMap_ST.zw;
			o.Emission = ( tex2D( _EmissionMap, uv_EmissionMap ) * _EmissiveColor ).rgb;
			half lerpResult271 = lerp( _CorneaSmoothness , _ScleraSmoothness , irisMask213);
			o.Smoothness = lerpResult271;
			float2 uv_MaskMap = i.uv_texcoord * _MaskMap_ST.xy + _MaskMap_ST.zw;
			o.Occlusion = ( 1.0 - ( _AOStrength * ( 1.0 - tex2D( _MaskMap, uv_MaskMap ).g ) ) );
			half lerpResult315 = lerp( _IrisSubsurfaceScale , _ScleraSubsurfaceScale , irisMask213);
			half4 baseColor370 = temp_output_21_0;
			o.Translucency = ( lerpResult315 * 0.5 * ( _SubsurfaceFalloff * baseColor370 ) ).rgb;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustom keepalpha fullforwardshadows exclude_path:deferred 

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
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
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
				surfIN.viewDir = IN.tSpace0.xyz * worldViewDir.x + IN.tSpace1.xyz * worldViewDir.y + IN.tSpace2.xyz * worldViewDir.z;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandardCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandardCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
}
/*ASEBEGIN
Version=19001
1913;48;1920;981;4402.488;597.5202;1.3;True;False
Node;AmplifyShaderEditor.CommentaryNode;204;-6596.911,-3587.629;Inherit;False;1134.455;323.4619;Comment;5;37;36;40;38;203;Radial Gradient;1,0,0.9132481,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;59;-6599.231,-2888.385;Inherit;False;755.1367;301.8584;;5;27;26;25;208;209;Scaled Iris Radius;1,0,0.8158517,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;36;-6546.911,-3537.629;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;146;-6253.872,-493.0329;Inherit;False;2015.933;1087.732;Comment;22;114;106;109;116;113;131;130;121;133;124;120;123;119;117;115;122;132;144;110;112;72;219;Parallax Mapping;1,0.959195,0,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-6549.231,-2838.385;Inherit;False;Property;_IrisRadius;Iris Radius;10;0;Create;True;0;0;0;False;0;False;0.15;0.15;0.01;0.2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-6116.004,121.286;Inherit;False;Property;_IrisDepth;Iris Depth;35;0;Create;True;0;0;0;False;0;False;0.3;0.004;0.1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;37;-6286.913,-3448.629;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-6548.356,-2702.526;Inherit;False;Property;_IrisScale;Iris Scale;6;0;Create;True;0;0;0;False;0;False;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;219;-5764.856,244.6688;Inherit;False;irisDepth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;168;-7097.884,-1391.027;Inherit;False;2236.97;563.6326;;13;83;82;89;93;88;91;73;71;74;69;70;218;220;Pupil Scaling;1,0.9427493,0,1;0;0
Node;AmplifyShaderEditor.LengthOpNode;38;-6118.912,-3521.629;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-6212.122,-2796.185;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;209;-6048.701,-2802.239;Inherit;False;scaledIrisRadius;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;40;-5952.937,-3518.167;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-7045.296,-1194.541;Inherit;False;Constant;_DepthCorrection;Depth Correction;7;0;Create;True;0;0;0;False;0;False;0.333;0;0.3;0.4;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;53;-7622.302,-616.9117;Inherit;False;1099.865;540.9683;;6;45;48;43;47;205;217;Pupil Scale Mask;0,1,0.9709253,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;220;-6998.739,-1051.702;Inherit;False;219;irisDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;217;-7534.302,-455.734;Inherit;False;209;scaledIrisRadius;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;71;-6703.296,-1095.541;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;203;-5686.437,-3523.698;Inherit;False;radial;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-7572.302,-566.9115;Inherit;False;Property;_DepthRadius;Depth Radius;39;0;Create;True;0;0;0;False;0;False;0.8;0.8;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-7249.302,-500.9114;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;205;-7282.567,-235.5991;Inherit;False;203;radial;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;73;-6777.356,-974.6068;Inherit;False;Property;_PupilScale;Pupil Scale;34;0;Create;True;0;0;0;False;0;False;0.8;0.8;0.1;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;208;-6045.01,-2702.917;Inherit;False;irisScale;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;70;-6503.296,-1179.541;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-6333.296,-1113.541;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;47;-6926.164,-405.7781;Inherit;False;Inverse Lerp;-1;;1;09cbe79402f023141a4dc1fddd4c9511;0;3;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;218;-6283.93,-1272.166;Inherit;False;208;irisScale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;48;-6720.438,-406.1374;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;-6091.217,-1135.869;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldToTangentMatrix;109;-6131.872,-443.0333;Inherit;False;0;1;FLOAT3x3;0
Node;AmplifyShaderEditor.RangedFloatNode;112;-6203.872,-120.0343;Inherit;False;Property;_IOR;IOR;36;0;Create;True;0;0;0;False;0;False;1.4;1.4;1;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;106;-6123.872,-346.0336;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;83;-5831.006,-1156.134;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;113;-5878.872,-203.0339;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.8;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;88;-5617.896,-1237.898;Inherit;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;110;-5888.872,-410.0334;Inherit;False;2;2;0;FLOAT3x3;0,0,0,1,1,1,1,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;114;-5686.872,-306.0336;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;116;-5884.988,-52.86908;Inherit;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;131;-5696.866,341.2151;Inherit;False;Property;_PMod;Parrallax Mod;37;0;Create;False;0;0;0;False;0;False;6.4;6.2717;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;89;-5438.554,-1119.105;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;160;-5909.006,856.857;Inherit;False;1194.943;369.2668;;7;152;151;155;154;157;207;215;Parallax Height Mask;0,1,0.9901032,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;130;-5343.229,214.3489;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;91;-5240.831,-1050.036;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;115;-5520.731,-197.0258;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;132;-5693.569,431.6167;Inherit;False;Constant;_ParallaxBase;Parallax Base;11;0;Create;True;0;0;0;False;0;False;0.91;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;215;-5811.718,936.4778;Inherit;False;208;irisScale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;151;-5866.006,1044.189;Inherit;False;Property;_ParallaxRadius;Parallax Radius;38;0;Create;True;0;0;0;False;0;False;0.1175;0.1175;0;0.16;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;152;-5538.07,987.3333;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;117;-5368.597,-234.1364;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;207;-5574.071,1125.396;Inherit;False;203;radial;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;93;-5099.142,-1256.788;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;121;-5136.273,314.6995;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;304;-4669.953,-857.2544;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;122;-4955.855,294.6348;Inherit;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;144;-5200.039,-153.7305;Inherit;False;True;True;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;155;-5357.333,1078.568;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;119;-4962.215,112.5333;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;241;-4892.149,-2323.169;Inherit;False;2538.815;665.9999;Comment;16;228;223;226;224;222;229;230;231;235;236;237;238;232;233;239;240;Sclera Base Color;0,1,0.1720126,1;0;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;154;-5165.42,970.9197;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;306;-4888.594,-353.7926;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;123;-4758.28,377.501;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;157;-4974.065,972.1238;Inherit;True;True;2;0;FLOAT;0;False;1;FLOAT;0.25;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;222;-4842.149,-1967.676;Inherit;False;Property;_ScleraScale;Sclera Scale;1;0;Create;True;0;0;0;False;0;False;1;1;0.25;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;124;-4579.706,459.6981;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;120;-4730.475,15.26049;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;268;-4167.973,723.1008;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;223;-4467.333,-2013.766;Inherit;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;133;-4454.939,218.0967;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;185;-4048.178,-535.7908;Inherit;False;1838.599;651.9883;Comment;17;383;382;379;172;183;179;171;381;380;184;181;182;178;177;174;175;136;Iris Base Color;0,1,0.1510973,1;0;0
Node;AmplifyShaderEditor.WireNode;305;-4401.626,-1084.778;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;224;-4290.334,-1920.766;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;136;-3998.178,-109.7211;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;171;-3997.09,-427.4135;Inherit;True;Property;_CorneaDiffuseMap;Cornea Diffuse Map;5;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.CommentaryNode;259;-4192.131,-1473.21;Inherit;False;1402.463;452.699;;10;248;249;243;242;247;246;252;254;253;318;Corner Shadow  Mask;0,1,0.9703217,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;200;-3804.905,331.6779;Inherit;False;1196.184;459.7933;Comment;8;186;195;194;193;187;196;206;216;Limbus Mask;0,1,0.9804161,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;226;-4103.334,-1850.766;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;248;-4140.653,-1350.334;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;172;-3719.307,-318.1438;Inherit;True;Property;_TextureSample1;Texture Sample 1;13;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;242;-4069.911,-1423.21;Inherit;False;Property;_ShadowHardness;Shadow Hardness;18;0;Create;True;0;0;0;False;0;False;0.5;0.5;0.01;0.99;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;249;-4142.133,-1326.678;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;243;-4067.687,-1193.44;Inherit;False;Property;_ShadowRadius;Shadow Radius;17;0;Create;True;0;0;0;False;0;False;0.275;0.275;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;379;-3706.622,-110.7072;Inherit;False;Property;_IrisColor;Iris Color;15;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;382;-3404.411,-225.5902;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;187;-3753.622,675.4706;Inherit;False;Property;_LimbusDarkWidth;Limbus Dark Width;13;0;Create;True;0;0;0;False;0;False;0.025;0.025;0.01;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;175;-3538.217,-485.7911;Inherit;False;Property;_IrisHue;Iris Hue;7;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;246;-3715.117,-1383.124;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;186;-3754.905,459.1052;Inherit;False;Property;_LimbusDarkRadius;Limbus Dark Radius;12;0;Create;True;0;0;0;False;0;False;0.1;0.1;0.01;0.2;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;216;-3656.726,565.6792;Inherit;False;208;irisScale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;247;-3716.595,-1276.673;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;230;-3932.333,-2256.764;Inherit;True;Property;_ScleraDiffuseMap;Sclera Diffuse Map;0;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.CommentaryNode;214;-6621.079,-2266.734;Inherit;False;1274.695;425.925;Comment;8;28;34;35;29;211;210;212;213;Iris Mask;1,0,0.909091,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;228;-3921.333,-2038.765;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;252;-3520.672,-1342.511;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;193;-3294.721,498.8979;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-6571.078,-1956.81;Inherit;False;Property;_LimbusWidth;Limbus Width;11;0;Create;True;0;0;0;False;0;False;0.055;0.055;0.01;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;179;-3389.183,-91.10484;Inherit;False;Property;_IrisSaturation;Iris Saturation;8;0;Create;True;0;0;0;False;0;False;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RGBToHSVNode;174;-3266.353,-269.7334;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;177;-3224.556,-473.3551;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;229;-3605.333,-2126.765;Inherit;True;Property;_TextureSample2;Texture Sample 2;20;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;211;-6505.249,-2082.404;Inherit;False;208;irisScale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;194;-3292.721,639.8973;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;233;-3336.919,-2254.169;Inherit;False;Property;_ScleraHue;Sclera Hue;2;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;254;-3601.672,-1136.511;Inherit;False;203;radial;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;183;-3390.145,6.739311;Inherit;False;Property;_IrisBrightness;Iris Brightness;9;0;Create;True;0;0;0;False;0;False;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;181;-2969.556,-214.3551;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;206;-3301.531,395.153;Inherit;False;203;radial;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;210;-6538.344,-2165.394;Inherit;False;209;scaledIrisRadius;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RGBToHSVNode;231;-3197.332,-2062.765;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;239;-3246.919,-1863.171;Inherit;False;Property;_ScleraSaturation;Sclera Saturation;3;0;Create;True;0;0;0;False;0;False;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;253;-3360.672,-1299.511;Inherit;False;Inverse Lerp;-1;;13;09cbe79402f023141a4dc1fddd4c9511;0;3;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;380;-2768.485,-437.4521;Inherit;False;Property;_IrisCloudyColor;Iris Cloudy Color;16;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;195;-3075.721,564.8978;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;240;-3245.919,-1773.171;Inherit;False;Property;_ScleraBrightness;Sclera Brightness;4;0;Create;True;0;0;0;False;0;False;1;0.65;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;182;-2970.556,-101.355;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;178;-2965.556,-325.3551;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;235;-2989.919,-2224.169;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-6280.078,-2020.81;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;318;-3144.17,-1317.416;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;35;-6116.076,-2097.81;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;381;-2516.485,-376.4521;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0.5,0.5,0.5,1;False;1;COLOR;0
Node;AmplifyShaderEditor.HSVToRGBNode;184;-2770.556,-237.6381;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SmoothstepOpNode;196;-2862.721,447.898;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;238;-2801.92,-1854.171;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;237;-2800.92,-1967.171;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;212;-6230.766,-2216.734;Inherit;False;203;radial;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;236;-2796.92,-2078.17;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;232;-2591.333,-2002.766;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WireNode;266;-2348.194,385.2512;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;28;-5858.131,-2190.278;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;49;-2555.033,-1620.931;Inherit;False;Property;_CornerShadowColor;Corner Shadow Color;19;0;Create;True;0;0;0;False;0;False;1,0.7333333,0.6980392,0;1,0.7333333,0.6980392,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;384;-2458.733,-1360.061;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;221;-2518.918,169.4791;Inherit;False;Property;_LimbusColor;Limbus Color;14;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;383;-2361.45,-256.7308;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendOpsNode;23;-2211.956,-1618.656;Inherit;True;Multiply;True;3;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;213;-5570.38,-2193.003;Inherit;False;irisMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;201;-2165.983,169.1272;Inherit;False;Multiply;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;265;-1656.663,-997.2845;Inherit;False;1124.059;806.899;;9;299;298;21;261;20;17;262;19;370;Final Color Blend;0,1,0.1510973,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;19;-1481.16,-481.0281;Inherit;True;Property;_ColorBlendMap;Color Blend Map;27;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.WireNode;298;-1629.234,-704.7217;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;299;-1631.821,-876.0963;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;262;-1355.289,-660.3757;Inherit;False;213;irisMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;283;-1737.899,2004.369;Inherit;False;1221.501;386.8221;Comment;6;277;279;278;280;281;276;Ambient Occlusion;0,0.9905019,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-1185.414,-308.748;Inherit;False;Property;_ColorBlendStrength;Color Blend Strength;28;0;Create;True;0;0;0;False;0;False;0.2;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;261;-1107.176,-824.1899;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;17;-1162.524,-533.1462;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BlendOpsNode;21;-794.7435,-531.2834;Inherit;True;Multiply;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;276;-1687.899,2084.608;Inherit;True;Property;_MaskMap;Mask Map;23;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;277;-1401.591,2161.191;Inherit;True;Property;_TextureSample3;Texture Sample 3;28;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;295;-1525.056,-4.54176;Inherit;False;989.1453;594.651;Comment;7;289;292;284;293;294;291;290;Normals;0,0.06795359,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;370;-773.0361,-680.1356;Inherit;False;baseColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;324;-1334.31,745.6045;Inherit;False;800.9006;462.2003;;4;319;321;320;322;Emission;0,1,0.1282372,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;337;-1317.389,2530.509;Inherit;False;814.2482;776.946;;9;339;338;342;315;302;316;314;371;372;Subsurface;1,0,0,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;316;-1205.675,2797.797;Inherit;False;213;irisMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;279;-1387.606,2054.369;Inherit;False;Property;_AOStrength;Ambient Occlusion Strength;24;0;Create;False;0;0;0;False;0;False;0.2;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;290;-1474.911,375.0162;Inherit;False;Property;_ScleraNormalStrength;Sclera Normal Strength;30;0;Create;True;0;0;0;False;0;False;0.1;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;338;-1195.414,2984.79;Inherit;False;Property;_SubsurfaceFalloff;Subsurface Falloff;22;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;292;-1345.056,474.1088;Inherit;False;213;irisMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;319;-1284.31,795.6045;Inherit;True;Property;_EmissionMap;Emission Map;32;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;314;-1258.675,2615.98;Inherit;False;Property;_IrisSubsurfaceScale;Iris Subsurface Scale;21;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;273;-1240.785,1391.808;Inherit;False;683.4199;377.4617;;4;269;270;272;271;Smoothness;0,0.9901032,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;293;-1475.056,278.1091;Inherit;False;Property;_ScleraNormalTiling;Sclera Normal Tiling;31;0;Create;True;0;0;0;False;0;False;2;2;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;302;-1257.718,2701.489;Inherit;False;Property;_ScleraSubsurfaceScale;Sclera Subsurface Scale;20;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;278;-1073.011,2215.228;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;371;-1160.261,3178.143;Inherit;False;370;baseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;291;-1093.911,410.0161;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;270;-1187.958,1532.285;Inherit;False;Property;_ScleraSmoothness;Sclera Smoothness;25;0;Create;True;0;0;0;False;0;False;0.8;0.7;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;269;-1190.785,1441.808;Inherit;False;Property;_CorneaSmoothness;Cornea Smoothness;26;0;Create;True;0;0;0;False;0;False;1;0.88;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;294;-1160.056,275.1091;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;320;-1017.811,802.1045;Inherit;True;Property;_TextureSample5;Texture Sample 5;38;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;372;-926.2607,3064.143;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;280;-883.1517,2126.562;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;315;-887.6747,2684.797;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;321;-1281.712,995.8048;Inherit;False;Property;_EmissiveColor;Emissive Color;33;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;342;-1261.315,2891.409;Inherit;False;Constant;_SubsurfaceWrapMax;Subsurface Wrap Max;40;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;284;-1227.431,45.45831;Inherit;True;Property;_ScleraNormalMap;Sclera Normal Map;29;0;Create;True;0;0;0;False;0;False;None;None;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;272;-1134.691,1642.508;Inherit;False;213;irisMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;281;-695.3975,2126.842;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;289;-861.8445,195.7588;Inherit;True;Property;_TextureSample4;Texture Sample 4;30;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;271;-822.3649,1515.271;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;341;-2776.429,1793.617;Inherit;False;350;286.2859;Not currently used, but could be in future;2;313;325;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;322;-695.4097,939.9047;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;339;-671.9481,2737.249;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;378;499.403,1174.896;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;325;-2726.429,1963.902;Inherit;False;Property;_IsLeftEye;Is Left Eye;40;1;[Toggle];Create;True;0;0;0;True;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;313;-2718.15,1843.617;Inherit;False;Property;BOOLEAN_ISCORNEA;IsCornea;41;0;Create;False;0;0;0;True;0;False;0;1;1;True;BOOLEAN_ISCORNEA_ON;Toggle;2;Key0;Key1;Create;True;False;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;376;500.1655,949.3455;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;373;497.5204,570.3694;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;374;498.9136,712.3886;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;375;495.321,817.2252;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;377;499.1292,1050.968;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;369;996.8561,720.2521;Half;False;True;-1;2;;0;0;Standard;Reallusion/Amplify/RL_CorneaShaderParallax_3D;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;ForwardOnly;18;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;42;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;37;0;36;0
WireConnection;219;0;72;0
WireConnection;38;0;37;0
WireConnection;27;0;26;0
WireConnection;27;1;25;0
WireConnection;209;0;27;0
WireConnection;40;0;38;0
WireConnection;71;0;69;0
WireConnection;71;1;220;0
WireConnection;203;0;40;0
WireConnection;45;0;43;0
WireConnection;45;1;217;0
WireConnection;208;0;25;0
WireConnection;70;0;69;0
WireConnection;70;1;71;0
WireConnection;74;0;70;0
WireConnection;74;1;73;0
WireConnection;47;1;45;0
WireConnection;47;3;205;0
WireConnection;48;0;47;0
WireConnection;82;0;218;0
WireConnection;82;1;74;0
WireConnection;83;0;218;0
WireConnection;83;1;82;0
WireConnection;83;2;48;0
WireConnection;113;0;112;0
WireConnection;88;1;83;0
WireConnection;110;0;109;0
WireConnection;110;1;106;0
WireConnection;114;0;110;0
WireConnection;114;1;113;0
WireConnection;89;0;88;0
WireConnection;130;0;72;0
WireConnection;130;1;131;0
WireConnection;91;0;89;0
WireConnection;115;0;114;0
WireConnection;115;1;116;0
WireConnection;152;0;215;0
WireConnection;152;1;151;0
WireConnection;117;0;115;0
WireConnection;93;0;88;0
WireConnection;93;1;91;0
WireConnection;121;0;130;0
WireConnection;121;1;132;0
WireConnection;304;0;93;0
WireConnection;122;1;121;0
WireConnection;144;0;117;0
WireConnection;155;0;152;0
WireConnection;155;1;207;0
WireConnection;119;0;144;0
WireConnection;119;1;72;0
WireConnection;154;0;155;0
WireConnection;154;1;152;0
WireConnection;306;0;304;0
WireConnection;123;0;122;0
WireConnection;157;0;154;0
WireConnection;124;0;123;0
WireConnection;120;0;306;0
WireConnection;120;1;119;0
WireConnection;268;0;157;0
WireConnection;223;1;222;0
WireConnection;133;0;120;0
WireConnection;133;1;122;0
WireConnection;133;2;124;0
WireConnection;305;0;93;0
WireConnection;224;0;223;0
WireConnection;136;0;305;0
WireConnection;136;1;133;0
WireConnection;136;2;268;0
WireConnection;226;0;224;0
WireConnection;248;0;222;0
WireConnection;172;0;171;0
WireConnection;172;1;136;0
WireConnection;249;0;222;0
WireConnection;382;0;172;0
WireConnection;382;1;379;0
WireConnection;246;0;242;0
WireConnection;246;1;248;0
WireConnection;247;0;249;0
WireConnection;247;1;243;0
WireConnection;228;0;223;0
WireConnection;228;1;226;0
WireConnection;252;0;246;0
WireConnection;252;1;247;0
WireConnection;193;0;186;0
WireConnection;193;1;216;0
WireConnection;174;0;382;0
WireConnection;177;0;175;0
WireConnection;229;0;230;0
WireConnection;229;1;228;0
WireConnection;194;0;216;0
WireConnection;194;1;187;0
WireConnection;181;0;174;2
WireConnection;181;1;179;0
WireConnection;231;0;229;0
WireConnection;253;1;252;0
WireConnection;253;2;247;0
WireConnection;253;3;254;0
WireConnection;195;0;193;0
WireConnection;195;1;194;0
WireConnection;182;0;174;3
WireConnection;182;1;183;0
WireConnection;178;0;177;0
WireConnection;178;1;174;1
WireConnection;235;0;233;0
WireConnection;34;0;211;0
WireConnection;34;1;29;0
WireConnection;318;0;253;0
WireConnection;35;0;210;0
WireConnection;35;1;34;0
WireConnection;381;0;380;0
WireConnection;184;0;178;0
WireConnection;184;1;181;0
WireConnection;184;2;182;0
WireConnection;196;0;206;0
WireConnection;196;1;193;0
WireConnection;196;2;195;0
WireConnection;238;0;231;3
WireConnection;238;1;240;0
WireConnection;237;0;231;2
WireConnection;237;1;239;0
WireConnection;236;0;235;0
WireConnection;236;1;231;1
WireConnection;232;0;236;0
WireConnection;232;1;237;0
WireConnection;232;2;238;0
WireConnection;266;0;196;0
WireConnection;28;0;212;0
WireConnection;28;1;35;0
WireConnection;28;2;210;0
WireConnection;384;0;318;0
WireConnection;383;0;381;0
WireConnection;383;1;184;0
WireConnection;23;0;49;0
WireConnection;23;1;232;0
WireConnection;23;2;384;0
WireConnection;213;0;28;0
WireConnection;201;0;221;0
WireConnection;201;1;383;0
WireConnection;201;2;266;0
WireConnection;298;0;201;0
WireConnection;299;0;23;0
WireConnection;261;0;298;0
WireConnection;261;1;299;0
WireConnection;261;2;262;0
WireConnection;17;0;19;0
WireConnection;21;0;17;0
WireConnection;21;1;261;0
WireConnection;21;2;20;0
WireConnection;277;0;276;0
WireConnection;370;0;21;0
WireConnection;278;0;277;2
WireConnection;291;0;290;0
WireConnection;291;1;292;0
WireConnection;294;0;293;0
WireConnection;320;0;319;0
WireConnection;372;0;338;0
WireConnection;372;1;371;0
WireConnection;280;0;279;0
WireConnection;280;1;278;0
WireConnection;315;0;314;0
WireConnection;315;1;302;0
WireConnection;315;2;316;0
WireConnection;281;0;280;0
WireConnection;289;0;284;0
WireConnection;289;1;294;0
WireConnection;289;5;291;0
WireConnection;271;0;269;0
WireConnection;271;1;270;0
WireConnection;271;2;272;0
WireConnection;322;0;320;0
WireConnection;322;1;321;0
WireConnection;339;0;315;0
WireConnection;339;1;342;0
WireConnection;339;2;372;0
WireConnection;378;0;339;0
WireConnection;376;0;271;0
WireConnection;373;0;21;0
WireConnection;374;0;289;0
WireConnection;375;0;322;0
WireConnection;377;0;281;0
WireConnection;369;0;373;0
WireConnection;369;1;374;0
WireConnection;369;2;375;0
WireConnection;369;4;376;0
WireConnection;369;5;377;0
WireConnection;369;7;378;0
ASEEND*/
//CHKSM=D66590112E123F70D22E32920777BD7942DDF278