// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Reallusion/Amplify/RL_HairShader_Baked_3D"
{
	Properties
	{
		_MainTex("Main Tex", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,0)
		_MetallicGlossMap("Metallic Gloss Map", 2D) = "white" {}
		_VertexBaseColor("Vertex Base Color", Color) = (0,0,0,0)
		_VertexColorStrength("Vertex Color Strength", Range( 0 , 1)) = 0.5
		_GlossMapScale("Gloss Map Scale", Range( 0 , 1)) = 1
		_BumpMap("Bump Map", 2D) = "bump" {}
		_BumpScale("Bump Scale", Range( 0 , 2)) = 1
		[KeywordEnum(Standard,Dithered)] _ClipQuality("Clip Quality", Float) = 1
		_OcclusionMap("Occlusion Map", 2D) = "white" {}
		_AlphaClip2("Alpha Clip", Range( 0 , 1)) = 0.15
		_OcclusionStrength("Occlusion Strength", Range( 0 , 1)) = 1
		_EmissionMap("Emission Map", 2D) = "white" {}
		[HDR]_EmissionColor("Emission Color", Color) = (0,0,0,0)
		_AOOccludeAll("AO Occlude All", Range( 0 , 1)) = 0
		_IDMap("ID Map", 2D) = "gray" {}
		_FlowMap("Flow Map", 2D) = "gray" {}
		[Toggle]_FlowMapFlipGreen("Flow Map Flip Green", Float) = 0
		_RimPower("Rim Hardness", Range( 1 , 10)) = 4
		_RimTransmissionIntensity("Rim Transmission Intensity", Range( 0 , 20)) = 10
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
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
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

		uniform sampler2D _MainTex;
		uniform half4 _MainTex_ST;
		uniform sampler2D _FlowMap;
		uniform half4 _FlowMap_ST;
		uniform half _FlowMapFlipGreen;
		uniform sampler2D _BumpMap;
		uniform half4 _BumpMap_ST;
		uniform half _BumpScale;
		uniform half _SpecularShiftMin;
		uniform half _SpecularShiftMax;
		uniform sampler2D _IDMap;
		uniform half4 _IDMap_ST;
		uniform sampler2D _MetallicGlossMap;
		uniform half4 _MetallicGlossMap_ST;
		uniform half _GlossMapScale;
		uniform half _SpecularPowerScale;
		uniform sampler2D _OcclusionMap;
		uniform half4 _OcclusionMap_ST;
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
		uniform sampler2D _EmissionMap;
		uniform half4 _EmissionMap_ST;
		uniform half4 _EmissionColor;
		uniform half _AlphaClip2;


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
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			half4 tex2DNode19 = tex2D( _MainTex, uv_MainTex );
			half alpha518 = tex2DNode19.a;
			half temp_output_521_0 = alpha518;
			float2 uv_FlowMap = i.uv_texcoord * _FlowMap_ST.xy + _FlowMap_ST.zw;
			half4 break109_g849 = tex2D( _FlowMap, uv_FlowMap );
			half lerpResult123_g849 = lerp( break109_g849.g , ( 1.0 - break109_g849.g ) , _FlowMapFlipGreen);
			half3 appendResult98_g849 = (half3(break109_g849.r , lerpResult123_g849 , break109_g849.b));
			half3 flowTangent107_g849 = (WorldNormalVector( i , ( ( appendResult98_g849 * float3( 2,2,2 ) ) - float3( 1,1,1 ) ) ));
			float2 uv_BumpMap = i.uv_texcoord * _BumpMap_ST.xy + _BumpMap_ST.zw;
			half3 normal282 = UnpackScaleNormal( tex2D( _BumpMap, uv_BumpMap ), _BumpScale );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			half3 ase_worldlightDir = 0;
			#else //aseld
			half3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			half3 worldLight272_g849 = ase_worldlightDir;
			half dotResult266_g849 = dot( normalize( (WorldNormalVector( i , normal282 )) ) , worldLight272_g849 );
			half3 lerpResult269_g849 = lerp( normalize( (WorldNormalVector( i , normal282 )) ) , -normalize( (WorldNormalVector( i , normal282 )) ) , step( dotResult266_g849 , 0.0 ));
			half3 worldNormal86_g849 = lerpResult269_g849;
			float2 uv_IDMap = i.uv_texcoord * _IDMap_ST.xy + _IDMap_ST.zw;
			half idMap383 = tex2D( _IDMap, uv_IDMap ).r;
			half lerpResult81_g849 = lerp( _SpecularShiftMin , _SpecularShiftMax , idMap383);
			half3 normalizeResult10_g850 = normalize( ( flowTangent107_g849 + ( worldNormal86_g849 * lerpResult81_g849 ) ) );
			half3 shiftedTangent119_g849 = normalizeResult10_g850;
			half3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			half3 viewDIr52_g851 = ase_worldViewDir;
			half3 lightDIr80_g851 = worldLight272_g849;
			half3 normalizeResult14_g852 = normalize( ( viewDIr52_g851 + lightDIr80_g851 ) );
			half dotResult16_g852 = dot( shiftedTangent119_g849 , normalizeResult14_g852 );
			half smoothstepResult22_g852 = smoothstep( -1.0 , 0.0 , dotResult16_g852);
			float2 uv_MetallicGlossMap = i.uv_texcoord * _MetallicGlossMap_ST.xy + _MetallicGlossMap_ST.zw;
			half smoothness643 = ( tex2D( _MetallicGlossMap, uv_MetallicGlossMap ).a * _GlossMapScale );
			half temp_output_233_0_g849 = max( ( 1.0 - smoothness643 ) , 0.001 );
			half specularPower237_g849 = ( max( ( ( 2.0 / ( temp_output_233_0_g849 * temp_output_233_0_g849 ) ) - 2.0 ) , 0.001 ) * _SpecularPowerScale );
			float2 uv_OcclusionMap = i.uv_texcoord * _OcclusionMap_ST.xy + _OcclusionMap_ST.zw;
			half4 tex2DNode617 = tex2D( _OcclusionMap, uv_OcclusionMap );
			half specularMask646 = tex2DNode617.a;
			half translucencyWrap283_g849 = _Translucency;
			half lambertMask290_g849 = saturate( ( ( dotResult266_g849 * ( 1.0 - translucencyWrap283_g849 ) ) + translucencyWrap283_g849 ) );
			half temp_output_84_0_g851 = lambertMask290_g849;
			half lambertMask85_g851 = temp_output_84_0_g851;
			half4 temp_output_13_0_g851 = ( ( smoothstepResult22_g852 * pow( saturate( ( 1.0 - ( dotResult16_g852 * dotResult16_g852 ) ) ) , specularPower237_g849 ) ) * ( specularMask646 * _SpecularMultiplier ) * lambertMask85_g851 * _SpecularTint );
			half4 lerpResult112 = lerp( tex2DNode19 , _VertexBaseColor , ( ( 1.0 - i.vertexColor.r ) * _VertexColorStrength ));
			half4 baseColor331 = ( _Color * lerpResult112 );
			half4 temp_output_42_0_g849 = baseColor331;
			half4 temp_output_32_0_g851 = temp_output_42_0_g849;
			half4 lerpResult36_g851 = lerp( temp_output_13_0_g851 , ( temp_output_13_0_g851 * temp_output_32_0_g851 ) , _SpecularMix);
			half3 temp_output_24_0_g851 = worldNormal86_g849;
			half dotResult82_g851 = dot( lightDIr80_g851 , temp_output_24_0_g851 );
			half temp_output_40_0_g851 = translucencyWrap283_g849;
			half dotResult54_g851 = dot( temp_output_24_0_g851 , viewDIr52_g851 );
			half dotResult57_g851 = dot( viewDIr52_g851 , lightDIr80_g851 );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			half4 ase_lightColor = 0;
			#else //aselc
			half4 ase_lightColor = _LightColor0;
			#endif //aselc
			half4 temp_output_297_0_g849 = ( ase_lightAtten * ( ( lerpResult36_g851 + ( ( saturate( ( ( dotResult82_g851 * ( 1.0 - temp_output_40_0_g851 ) ) + temp_output_40_0_g851 ) ) + ( pow( ( max( ( 1.0 - abs( dotResult54_g851 ) ) , 0.0 ) * max( ( 0.0 - dotResult57_g851 ) , 0.0 ) ) , _RimPower ) * _RimTransmissionIntensity * temp_output_84_0_g851 ) ) * temp_output_32_0_g851 ) ) * ase_lightColor ) );
			UnityGI gi53_g849 = gi;
			float3 diffNorm53_g849 = WorldNormalVector( i , worldNormal86_g849 );
			gi53_g849 = UnityGI_Base( data, 1, diffNorm53_g849 );
			half3 indirectDiffuse53_g849 = gi53_g849.indirect.diffuse + diffNorm53_g849 * 0.0001;
			half ambientOcclusion570 = ( 1.0 - ( _OcclusionStrength * ( 1.0 - tex2DNode617.g ) ) );
			half temp_output_161_0_g849 = ambientOcclusion570;
			half temp_output_178_0_g849 = _AOOccludeAll;
			half lerpResult180_g849 = lerp( temp_output_161_0_g849 , 1.0 , temp_output_178_0_g849);
			#ifdef UNITY_PASS_FORWARDBASE
				half4 staticSwitch250_g849 = ( temp_output_297_0_g849 + ( half4( indirectDiffuse53_g849 , 0.0 ) * temp_output_42_0_g849 * lerpResult180_g849 ) );
			#else
				half4 staticSwitch250_g849 = temp_output_297_0_g849;
			#endif
			half lerpResult183_g849 = lerp( 1.0 , temp_output_161_0_g849 , temp_output_178_0_g849);
			float2 uv_EmissionMap = i.uv_texcoord * _EmissionMap_ST.xy + _EmissionMap_ST.zw;
			half In175 = _AlphaClip2;
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			half2 ScreenPosition175 = ase_screenPosNorm.xy;
			half localUnityHDRPDither175 = UnityHDRPDither175( In175 , ScreenPosition175 );
			#if defined(_CLIPQUALITY_STANDARD)
				half staticSwitch528 = _AlphaClip2;
			#elif defined(_CLIPQUALITY_DITHERED)
				half staticSwitch528 = localUnityHDRPDither175;
			#else
				half staticSwitch528 = localUnityHDRPDither175;
			#endif
			clip( alpha518 - staticSwitch528);
			c.rgb = ( ( staticSwitch250_g849 * lerpResult183_g849 ) + ( tex2D( _EmissionMap, uv_EmissionMap ) * _EmissionColor ) ).rgb;
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
}
/*ASEBEGIN
Version=18935
1920;0;1920;1029;2015.453;367.4944;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;121;-2209.837,-395.2434;Inherit;False;1295.191;809.48;;10;610;19;518;106;105;331;107;112;113;104;Final Color Blending;0.514151,1,0.6056049,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;612;-2173.329,2229.718;Inherit;False;1268.577;322.7186;Comment;7;570;637;627;623;622;617;646;;1,1,1,1;0;0
Node;AmplifyShaderEditor.VertexColorNode;104;-2146.046,182.9718;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;617;-2123.329,2308.437;Inherit;True;Property;_OcclusionMap;Occlusion Map;10;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;106;-1944.258,290.4149;Inherit;False;Property;_VertexColorStrength;Vertex Color Strength;5;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;19;-2148.696,-235.3144;Inherit;True;Property;_MainTex;Main Tex;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;105;-1881.327,189.0002;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;113;-1661.103,22.41703;Inherit;False;Property;_VertexBaseColor;Vertex Base Color;4;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;107;-1625.77,230.7146;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;610;-1597.214,-151.4336;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;613;-1879.579,493.4243;Inherit;False;961.1769;381.4063;Comment;3;620;629;282;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;621;-1707.991,1661.074;Inherit;False;797.2819;513.1732;Comment;4;638;632;630;643;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;623;-1810.752,2279.718;Inherit;False;Property;_OcclusionStrength;Occlusion Strength;12;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;622;-1736.753,2359.718;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;627;-1507.753,2326.718;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;512;-2387.855,1180.407;Inherit;False;680.6748;262.7862;;2;383;50;Maps;0.504717,0.9903985,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;620;-1813.03,676.0306;Inherit;False;Property;_BumpScale;Bump Scale;8;0;Create;True;0;0;0;False;0;False;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;649;-1524.953,-269.4944;Inherit;False;Property;_Color;Color;2;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;632;-1657.992,1810.155;Inherit;True;Property;_MetallicGlossMap;Metallic Gloss Map;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;112;-1414.348,8.108437;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;630;-1636.989,2023.247;Inherit;False;Property;_GlossMapScale;Gloss Map Scale;6;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;629;-1490.091,623.4471;Inherit;True;Property;_BumpMap;Bump Map;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;638;-1277.709,1914.066;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;50;-2337.855,1230.407;Inherit;True;Property;_IDMap;ID Map;16;0;Create;True;0;0;0;False;0;False;19;None;None;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;637;-1343.753,2329.718;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;624;-1531.789,1090.893;Inherit;False;622.4177;474.6811;Comment;3;635;634;633;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;646;-1761.354,2450.387;Inherit;False;specularMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;650;-1249.953,-135.4944;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;573;-759.7318,-401.0714;Inherit;False;1085.333;1589.565;;18;378;571;595;263;569;180;108;482;608;572;177;596;389;385;384;539;265;648;Specular Highlights;1,0.7932334,0.514151,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;643;-1107.433,1911.743;Inherit;False;smoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;633;-1481.79,1140.893;Inherit;True;Property;_EmissionMap;Emission Map;13;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;383;-1915.727,1306.731;Inherit;False;idMap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;282;-1137.676,647.9846;Inherit;False;normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;331;-1127.497,-1.164222;Inherit;False;baseColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;570;-1137.698,2328.423;Inherit;False;ambientOcclusion;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;533;-201.2043,1361.009;Inherit;False;923.0229;624.2474;;5;521;528;175;162;176;Alpha;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;647;-1110.953,237.0056;Inherit;False;646;specularMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;380;-1190.927,322.3215;Inherit;False;Property;_SpecularMultiplier;Specular Strength;22;0;Create;False;0;0;0;False;0;False;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;634;-1399.275,1353.574;Inherit;False;Property;_EmissionColor;Emission Color;14;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;385;-684.1522,771.6683;Inherit;False;Property;_SpecularShiftMin;Specular Shift Min;25;0;Create;True;0;0;0;False;0;False;-0.25;-0.25;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;180;-626.6543,619.2548;Inherit;False;Property;_FlowMapFlipGreen;Flow Map Flip Green;18;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;648;-549.9524,264.0056;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;539;-679.4417,923.2449;Inherit;False;Property;_Translucency;Translucency;27;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;572;-594.7292,-351.0714;Inherit;False;331;baseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;571;-637.0811,-277.3754;Inherit;False;570;ambientOcclusion;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;108;-694.5977,-200.0366;Inherit;False;Property;_AOOccludeAll;AO Occlude All;15;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;265;-678.6436,998.7183;Inherit;False;Property;_RimTransmissionIntensity;Rim Transmission Intensity;20;0;Create;True;0;0;0;False;0;False;10;10;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;389;-681.8292,847.2004;Inherit;False;Property;_SpecularShiftMax;Specular Shift Max;26;0;Create;True;0;0;0;False;0;False;0.25;0.25;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;384;-582.3779,695.2554;Inherit;False;383;idMap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;263;-676.3562,1073.421;Inherit;False;Property;_RimPower;Rim Hardness;19;0;Create;False;0;0;0;False;0;False;4;4;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;596;-689.4732,354.8531;Inherit;False;Property;_SpecularPowerScale;Specular Smoothness;23;0;Create;False;0;0;0;False;0;False;2;2;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;635;-1071.372,1270.615;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;569;-590.8998,-125.8811;Inherit;False;282;normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;177;-709.0319,429.8401;Inherit;True;Property;_FlowMap;Flow Map;17;0;Create;True;0;0;0;False;0;False;19;None;None;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenPosInputsNode;176;-49.1657,1776.023;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;378;-628.2301,-49.07933;Inherit;False;Property;_SpecularTint;Specular Tint;21;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;595;-602.828,124.648;Inherit;False;643;smoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;162;-131.2039,1552.618;Inherit;False;Property;_AlphaClip2;Alpha Clip;11;0;Create;False;0;0;0;False;0;False;0.15;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;482;-691.7015,199.9869;Inherit;False;Property;_SpecularMix;Specular Mix;24;0;Create;True;0;0;0;False;0;False;1;1;0.5;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;175;202.0481,1721.023;Inherit;False;half2 uv = ScreenPosition.xy * _ScreenParams.xy@$half DITHER_THRESHOLDS[16] =${$                1.0 / 17.0,  9.0 / 17.0,  3.0 / 17.0, 11.0 / 17.0,$                13.0 / 17.0,  5.0 / 17.0, 15.0 / 17.0,  7.0 / 17.0,$                4.0 / 17.0, 12.0 / 17.0,  2.0 / 17.0, 10.0 / 17.0,$                16.0 / 17.0,  8.0 / 17.0, 14.0 / 17.0,  6.0 / 17.0$}@$uint index = (uint(uv.x) % 4) * 4 + uint(uv.y) % 4@$return In - DITHER_THRESHOLDS[index]@;1;Create;2;True;In;FLOAT;0;In;;Inherit;False;True;ScreenPosition;FLOAT2;0,0;In;;Inherit;False;Unity HDRP Dither;True;False;0;;False;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;518;-1775.883,-67.44363;Inherit;False;alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;608;-110.9783,9.531306;Inherit;False;RL_Amplify_Function_Hair_AnisotropicLighting_3D;-1;;849;1c2ce0d33e6d0364e94912a58b37cdd2;2,264,1,88,0;18;42;COLOR;1,1,1,0;False;161;FLOAT;1;False;178;FLOAT;1;False;84;FLOAT3;0,0,1;False;26;FLOAT3;0,0,1;False;131;COLOR;1,1,1,0;False;7;FLOAT;50;False;172;FLOAT;0;False;132;FLOAT;1;False;245;FLOAT;2;False;108;COLOR;0,0,0,0;False;112;FLOAT;0;False;71;FLOAT;0.5;False;75;FLOAT;-0.1;False;80;FLOAT;0.1;False;282;FLOAT;0;False;207;FLOAT;0;False;208;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;642;-742.063,1236.563;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;528;467.0161,1554.153;Inherit;False;Property;_ClipQuality;Clip Quality;9;0;Create;True;0;0;0;False;0;False;0;1;1;True;;KeywordEnum;2;Standard;Dithered;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;574;638.7153,1173.22;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;521;524.1596,1439.007;Inherit;False;518;alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClipNode;645;805.3989,1276.367;Inherit;False;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;644;1078.293,1172.645;Half;False;True;-1;2;;0;0;CustomLighting;Reallusion/Amplify/RL_HairShader_Baked_3D;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Opaque;;AlphaTest;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;105;0;104;1
WireConnection;107;0;105;0
WireConnection;107;1;106;0
WireConnection;610;0;19;0
WireConnection;622;0;617;2
WireConnection;627;0;623;0
WireConnection;627;1;622;0
WireConnection;112;0;610;0
WireConnection;112;1;113;0
WireConnection;112;2;107;0
WireConnection;629;5;620;0
WireConnection;638;0;632;4
WireConnection;638;1;630;0
WireConnection;637;0;627;0
WireConnection;646;0;617;4
WireConnection;650;0;649;0
WireConnection;650;1;112;0
WireConnection;643;0;638;0
WireConnection;383;0;50;1
WireConnection;282;0;629;0
WireConnection;331;0;650;0
WireConnection;570;0;637;0
WireConnection;648;0;647;0
WireConnection;648;1;380;0
WireConnection;635;0;633;0
WireConnection;635;1;634;0
WireConnection;175;0;162;0
WireConnection;175;1;176;0
WireConnection;518;0;19;4
WireConnection;608;42;572;0
WireConnection;608;161;571;0
WireConnection;608;178;108;0
WireConnection;608;84;569;0
WireConnection;608;131;378;0
WireConnection;608;7;595;0
WireConnection;608;172;482;0
WireConnection;608;132;648;0
WireConnection;608;245;596;0
WireConnection;608;108;177;0
WireConnection;608;112;180;0
WireConnection;608;71;384;0
WireConnection;608;75;385;0
WireConnection;608;80;389;0
WireConnection;608;282;539;0
WireConnection;608;207;265;0
WireConnection;608;208;263;0
WireConnection;642;0;635;0
WireConnection;528;1;162;0
WireConnection;528;0;175;0
WireConnection;574;0;608;0
WireConnection;574;1;642;0
WireConnection;645;0;574;0
WireConnection;645;1;521;0
WireConnection;645;2;528;0
WireConnection;644;9;521;0
WireConnection;644;13;645;0
ASEEND*/
//CHKSM=630A4CD16E53A42B94A52A6FED65B35FB2EBFEB1