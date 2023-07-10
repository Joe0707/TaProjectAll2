// Made with Amplify Shader Editor v1.9.0.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Grass"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		_Albedo("Albedo", 2D) = "white" {}
		_AlphaCutoff("Alpha Cutoff", Range( 0 , 1)) = 0.35
		[Header(Color Settings)][Space(5)][KeywordEnum(UV,VertexColor)] _ColorGradient("ColorGradient", Float) = 0
		[Toggle]_UseTexColor("UseTexColor", Float) = 0
		_BaseColor("Base Color", Color) = (0.04705882,0.4431373,0.04313726,0)
		_TipColor("Tip Color", Color) = (0.4313726,1,0.007843138,0)
		_TipGradient("Tip Gradient", Float) = 1
		_VariationMask("Variation Mask", 2D) = "black" {}
		_VariationMaskScale("Variation Mask Scale", Float) = 50
		_VariationColorA("Variation Color A", Color) = (0.2470588,1,0,0)
		_VariationColorB("Variation Color B", Color) = (0,0.4039216,0.427451,0)
		[Header(Wind Settings)][Space(5)][KeywordEnum(UV,VertexColor)] _WindGradient("WindGradient", Float) = 0
		_WindIntensity("WindIntensity", Float) = 0.2
		_WindSpeed("Wind Speed", Float) = 0.5
		_WindDirection("Wind Direction", Range( 0 , 360)) = 45
		_WindSizeBig("Wind Size Big", Float) = 10
		_WindSizeSmall("Wind Size Small", Float) = 4
		_WindStetch("Wind Stetch", Vector) = (0,1,0,0)
		_WindLine("WindLine", 2D) = "black" {}
		_WindLineColor("Wind Line Color", Color) = (0.07843138,0.2980392,0,0)
		_WindLineScale("Wind Line Scale", Float) = 50
		_WindLineRotate("Wind Line Rotate", Range( 0 , 2)) = 0.8
		_WindLineSpeed("Wind Line Speed", Vector) = (0,0.3,0,0)
		[Header(Light Settings)][Space(5)]_DirectLightIntensity("Direct Light Intensity", Range( 1 , 10)) = 1
		_IndirectLightIntensity("Indirect Light Intensity", Range( 1 , 10)) = 1
		_AO("AO", Range( 0 , 1)) = 0
		[Toggle]_FixedNormal("FixedNormal", Float) = 0
		_SpecifyNormal("SpecifyNormal", Vector) = (0,1,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}


		[HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1

        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}

		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25
	}

	SubShader
	{
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="AlphaTest" "NatureRendererInstancing"="True" }

		Cull Off
		AlphaToMask Off

		

		HLSLINCLUDE

		#pragma target 4.5

		#pragma prefer_hlslcc gles
		#pragma exclude_renderers d3d11_9x 

		#ifndef ASE_TESS_FUNCS
		#define ASE_TESS_FUNCS
		float4 FixedTess( float tessValue )
		{
			return tessValue;
		}
		
		float CalcDistanceTessFactor (float4 vertex, float minDist, float maxDist, float tess, float4x4 o2w, float3 cameraPos )
		{
			float3 wpos = mul(o2w,vertex).xyz;
			float dist = distance (wpos, cameraPos);
			float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
			return f;
		}

		float4 CalcTriEdgeTessFactors (float3 triVertexFactors)
		{
			float4 tess;
			tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
			tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
			tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
			tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
			return tess;
		}

		float CalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen, float3 cameraPos, float4 scParams )
		{
			float dist = distance (0.5 * (wpos0+wpos1), cameraPos);
			float len = distance(wpos0, wpos1);
			float f = max(len * scParams.y / (edgeLen * dist), 1.0);
			return f;
		}

		float DistanceFromPlane (float3 pos, float4 plane)
		{
			float d = dot (float4(pos,1.0f), plane);
			return d;
		}

		bool WorldViewFrustumCull (float3 wpos0, float3 wpos1, float3 wpos2, float cullEps, float4 planes[6] )
		{
			float4 planeTest;
			planeTest.x = (( DistanceFromPlane(wpos0, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[0]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.y = (( DistanceFromPlane(wpos0, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[1]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.z = (( DistanceFromPlane(wpos0, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[2]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.w = (( DistanceFromPlane(wpos0, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[3]) > -cullEps) ? 1.0f : 0.0f );
			return !all (planeTest);
		}

		float4 DistanceBasedTess( float4 v0, float4 v1, float4 v2, float tess, float minDist, float maxDist, float4x4 o2w, float3 cameraPos )
		{
			float3 f;
			f.x = CalcDistanceTessFactor (v0,minDist,maxDist,tess,o2w,cameraPos);
			f.y = CalcDistanceTessFactor (v1,minDist,maxDist,tess,o2w,cameraPos);
			f.z = CalcDistanceTessFactor (v2,minDist,maxDist,tess,o2w,cameraPos);

			return CalcTriEdgeTessFactors (f);
		}

		float4 EdgeLengthBasedTess( float4 v0, float4 v1, float4 v2, float edgeLength, float4x4 o2w, float3 cameraPos, float4 scParams )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;
			tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
			tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
			tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
			tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			return tess;
		}

		float4 EdgeLengthBasedTessCull( float4 v0, float4 v1, float4 v2, float edgeLength, float maxDisplacement, float4x4 o2w, float3 cameraPos, float4 scParams, float4 planes[6] )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;

			if (WorldViewFrustumCull(pos0, pos1, pos2, maxDisplacement, planes))
			{
				tess = 0.0f;
			}
			else
			{
				tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
				tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
				tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
				tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			}
			return tess;
		}
		#endif //ASE_TESS_FUNCS

		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForwardOnly" }
			
			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA

			

			HLSLPROGRAM

			#pragma multi_compile_instancing
			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 120107
			#define ASE_USING_SAMPLING_MACROS 1


			#pragma multi_compile _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3

			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma shader_feature _ _SAMPLE_GI
			#pragma multi_compile _ DEBUG_DISPLAY

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_UNLIT

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging3D.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"
			
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_SHADOWCOORDS
			#define ASE_NEEDS_VERT_NORMAL
			#pragma shader_feature_local _WINDGRADIENT_UV _WINDGRADIENT_VERTEXCOLOR
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile _ _SHADOWS_SOFT
			#pragma shader_feature_local _COLORGRADIENT_UV _COLORGRADIENT_VERTEXCOLOR
			#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#include "Assets/Visual Design Cafe/Nature Renderer/Shader Includes/Nature Renderer.templatex"
			#pragma instancing_options procedural:SetupNatureRenderer
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 texcoord1 : TEXCOORD1;
				float4 ase_tangent : TANGENT;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD1;
				#endif
				#ifdef ASE_FOG
					float fogFactor : TEXCOORD2;
				#endif
				float3 ase_normal : NORMAL;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_color : COLOR;
				float4 lightmapUVOrVertexSH : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				float4 ase_texcoord7 : TEXCOORD7;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _VariationColorA;
			float4 _Albedo_ST;
			float4 _WindLineColor;
			float4 _BaseColor;
			float4 _TipColor;
			float4 _VariationColorB;
			float3 _WindStetch;
			float3 _SpecifyNormal;
			float2 _WindLineSpeed;
			float _DirectLightIntensity;
			float _AO;
			float _WindLineRotate;
			float _WindLineScale;
			float _TipGradient;
			float _WindSpeed;
			float _IndirectLightIntensity;
			float _UseTexColor;
			float _FixedNormal;
			float _WindIntensity;
			float _WindSizeSmall;
			float _WindSizeBig;
			float _WindDirection;
			float _VariationMaskScale;
			float _AlphaCutoff;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			TEXTURE2D(_Albedo);
			SAMPLER(sampler_Albedo);
			TEXTURE2D(_VariationMask);
			SAMPLER(sampler_VariationMask);
			TEXTURE2D(_WindLine);
			SAMPLER(sampler_WindLine);


			float3 RotateXY165_g57( float3 R, float degrees )
			{
				float3 reflUVW = R;
				half theta = degrees * PI / 180.0f;
				half costha = cos(theta);
				half sintha = sin(theta);
				reflUVW = half3(reflUVW.x * costha - reflUVW.z * sintha, reflUVW.y, reflUVW.x * sintha + reflUVW.z * costha);
				return reflUVW;
			}
			
			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			
			float3 ASEIndirectDiffuse( float2 uvStaticLightmap, float3 normalWS )
			{
			#ifdef LIGHTMAP_ON
				return SampleLightmap( uvStaticLightmap, normalWS );
			#else
				return SampleSH(normalWS);
			#endif
			}
			
			float3 AdditionalLightsHalfLambert( float3 WorldPosition, float3 WorldNormal )
			{
				float3 Color = 0;
				#ifdef _ADDITIONAL_LIGHTS
				int numLights = GetAdditionalLightsCount();
				for(int i = 0; i<numLights;i++)
				{
					Light light = GetAdditionalLight(i, WorldPosition);
					half3 AttLightColor = light.color *(light.distanceAttenuation * light.shadowAttenuation);
					Color +=(dot(light.direction, WorldNormal)*0.5+0.5 )* AttLightColor;
					
				}
				#endif
				return Color;
			}
			

			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 _Vector0 = float3(0,0,1);
				float3 RotateAxis34_g57 = cross( _Vector0 , float3(0,1,0) );
				float3 wind_direction31_g57 = _Vector0;
				float3 wind_speed40_g57 = ( ( _TimeParameters.x * _WindSpeed ) * float3(0.5,-0.5,-0.5) );
				float2 texCoord313 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				#if defined(_WINDGRADIENT_UV)
				float staticSwitch315 = texCoord313.y;
				#elif defined(_WINDGRADIENT_VERTEXCOLOR)
				float staticSwitch315 = v.ase_color.g;
				#else
				float staticSwitch315 = texCoord313.y;
				#endif
				float WindGradient316 = staticSwitch315;
				float temp_output_214_0 = ( WindGradient316 * WindGradient316 );
				float3 appendResult247 = (float3(_WindStetch.x , 1.0 , _WindStetch.z));
				float3 normalizeResult181 = normalize( appendResult247 );
				float3 break183 = normalizeResult181;
				float3 appendResult187 = (float3(break183.x , 0.0 , break183.z));
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float3 temp_output_193_0 = ( ( temp_output_214_0 * appendResult187 ) + ase_worldPos );
				float3 WorldPosition161_g57 = temp_output_193_0;
				float3 R165_g57 = WorldPosition161_g57;
				float degrees165_g57 = _WindDirection;
				float3 localRotateXY165_g57 = RotateXY165_g57( R165_g57 , degrees165_g57 );
				float3 temp_cast_0 = (1.0).xxx;
				float3 temp_output_22_0_g57 = abs( ( ( frac( ( ( ( wind_direction31_g57 * wind_speed40_g57 ) + ( localRotateXY165_g57 / _WindSizeBig ) ) + 0.5 ) ) * 2.0 ) - temp_cast_0 ) );
				float3 temp_cast_1 = (3.0).xxx;
				float dotResult30_g57 = dot( ( ( temp_output_22_0_g57 * temp_output_22_0_g57 ) * ( temp_cast_1 - ( temp_output_22_0_g57 * 2.0 ) ) ) , wind_direction31_g57 );
				float BigTriangleWave42_g57 = dotResult30_g57;
				float3 temp_cast_2 = (1.0).xxx;
				float3 temp_output_59_0_g57 = abs( ( ( frac( ( ( wind_speed40_g57 + ( localRotateXY165_g57 / _WindSizeSmall ) ) + 0.5 ) ) * 2.0 ) - temp_cast_2 ) );
				float3 temp_cast_3 = (3.0).xxx;
				float SmallTriangleWave52_g57 = distance( ( ( temp_output_59_0_g57 * temp_output_59_0_g57 ) * ( temp_cast_3 - ( temp_output_59_0_g57 * 2.0 ) ) ) , float3(0,0,0) );
				float3 rotatedValue72_g57 = RotateAroundAxis( ( float3( 0,0,0 ) - float3(0,0.1,0) ), WorldPosition161_g57, normalize( RotateAxis34_g57 ), ( ( BigTriangleWave42_g57 + SmallTriangleWave52_g57 ) * ( 2.0 * PI ) ) );
				float3 worldToObj197 = mul( GetWorldToObjectMatrix(), float4( ( ( ( rotatedValue72_g57 - WorldPosition161_g57 ) * temp_output_214_0 * _WindIntensity * 0.1 ) + temp_output_193_0 ), 1 ) ).xyz;
				float3 Wind198 = worldToObj197;
				
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				OUTPUT_LIGHTMAP_UV( v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy );
				OUTPUT_SH( ase_worldNormal, o.lightmapUVOrVertexSH.xyz );
				o.ase_texcoord5.xyz = ase_worldNormal;
				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord6.xyz = ase_worldTangent;
				float ase_vertexTangentSign = v.ase_tangent.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord7.xyz = ase_worldBitangent;
				
				o.ase_normal = v.ase_normal;
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;
				o.ase_texcoord5.w = 0;
				o.ase_texcoord6.w = 0;
				o.ase_texcoord7.w = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = Wind198;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.worldPos = positionWS;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				#ifdef ASE_FOG
					o.fogFactor = ComputeFogFactor( positionCS.z );
				#endif

				o.clipPos = positionCS;

				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 texcoord1 : TEXCOORD1;
				float4 ase_tangent : TANGENT;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_color = v.ase_color;
				o.texcoord1 = v.texcoord1;
				o.ase_tangent = v.ase_tangent;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag ( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = IN.worldPos;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float3 lerpResult331 = lerp( IN.ase_normal , _SpecifyNormal , _FixedNormal);
				float3 objToWorldDir327 = normalize( mul( GetObjectToWorldMatrix(), float4( lerpResult331, 0 ) ).xyz );
				float3 WorldNormal333 = objToWorldDir327;
				float dotResult115 = dot( SafeNormalize(_MainLightPosition.xyz) , WorldNormal333 );
				float ase_lightAtten = 0;
				Light ase_mainLight = GetMainLight( ShadowCoords );
				ase_lightAtten = ase_mainLight.distanceAttenuation * ase_mainLight.shadowAttenuation;
				float4 temp_cast_0 = (1.0).xxxx;
				float2 uv_Albedo = IN.ase_texcoord3.xy * _Albedo_ST.xy + _Albedo_ST.zw;
				float4 tex2DNode205 = SAMPLE_TEXTURE2D( _Albedo, sampler_Albedo, uv_Albedo );
				float4 lerpResult321 = lerp( temp_cast_0 , tex2DNode205 , _UseTexColor);
				float4 TexColor319 = lerpResult321;
				float4 tex2DNode251 = SAMPLE_TEXTURE2D( _VariationMask, sampler_VariationMask, ( (WorldPosition).xz / _VariationMaskScale ) );
				float4 lerpResult254 = lerp( _BaseColor , _VariationColorA , tex2DNode251.r);
				float4 lerpResult258 = lerp( lerpResult254 , _VariationColorB , tex2DNode251.g);
				float4 VariationColor260 = lerpResult258;
				float2 texCoord200 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				#if defined(_COLORGRADIENT_UV)
				float staticSwitch202 = texCoord200.y;
				#elif defined(_COLORGRADIENT_VERTEXCOLOR)
				float staticSwitch202 = IN.ase_color.g;
				#else
				float staticSwitch202 = texCoord200.y;
				#endif
				float ColorGradient201 = staticSwitch202;
				float clampResult211 = clamp( ( ColorGradient201 * _TipGradient ) , 0.0 , 1.0 );
				float4 lerpResult206 = lerp( VariationColor260 , _TipColor , clampResult211);
				float cos278 = cos( ( _WindLineRotate * PI ) );
				float sin278 = sin( ( _WindLineRotate * PI ) );
				float2 rotator278 = mul( ( (WorldPosition).xz / _WindLineScale ) - float2( 0,0 ) , float2x2( cos278 , -sin278 , sin278 , cos278 )) + float2( 0,0 );
				float2 panner283 = ( 0.1 * _Time.y * _WindLineSpeed + rotator278);
				float4 WindLine276 = SAMPLE_TEXTURE2D( _WindLine, sampler_WindLine, panner283 );
				float lerpResult306 = lerp( 1.0 , ColorGradient201 , _AO);
				float4 BaseColor121 = ( TexColor319 * ( lerpResult206 + ( _WindLineColor * WindLine276 ) ) * lerpResult306 );
				float4 DirectLight120 = ( ( (dotResult115*0.5 + 0.5) * ase_lightAtten ) * _MainLightColor * BaseColor121 * _DirectLightIntensity );
				float3 ase_worldNormal = IN.ase_texcoord5.xyz;
				float3 bakedGI177 = ASEIndirectDiffuse( IN.lightmapUVOrVertexSH.xy, ase_worldNormal);
				MixRealtimeAndBakedGI(ase_mainLight, ase_worldNormal, bakedGI177, half4(0,0,0,0));
				float4 IndirectLight107 = ( float4( bakedGI177 , 0.0 ) * BaseColor121 * _IndirectLightIntensity );
				float3 worldPosValue44_g108 = WorldPosition;
				float3 WorldPosition22_g108 = worldPosValue44_g108;
				float3 ase_worldTangent = IN.ase_texcoord6.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord7.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal12_g108 = float3(0,0,1);
				float3 worldNormal12_g108 = float3(dot(tanToWorld0,tanNormal12_g108), dot(tanToWorld1,tanNormal12_g108), dot(tanToWorld2,tanNormal12_g108));
				float3 worldNormalValue50_g108 = worldNormal12_g108;
				float3 WorldNormal22_g108 = worldNormalValue50_g108;
				float3 localAdditionalLightsHalfLambert22_g108 = AdditionalLightsHalfLambert( WorldPosition22_g108 , WorldNormal22_g108 );
				float3 halfLambertResult58_g108 = localAdditionalLightsHalfLambert22_g108;
				
				float OpacityMask96 = tex2DNode205.a;
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( DirectLight120 + IndirectLight107 + ( float4( halfLambertResult58_g108 , 0.0 ) * BaseColor121 ) ).rgb;
				float Alpha = OpacityMask96;
				float AlphaClipThreshold = _AlphaCutoff;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#if defined(_DBUFFER)
					ApplyDecalToBaseColor(IN.clipPos, Color);
				#endif

				#if defined(_ALPHAPREMULTIPLY_ON)
				Color *= Alpha;
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
				#endif

				return half4( Color, Alpha );
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual
			AlphaToMask Off
			ColorMask 0

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 120107
			#define ASE_USING_SAMPLING_MACROS 1

			
			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile _ _CASTING_PUNCTUAL_LIGHT_SHADOW

			#define SHADERPASS SHADERPASS_SHADOWCASTER

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#pragma shader_feature_local _WINDGRADIENT_UV _WINDGRADIENT_VERTEXCOLOR
			#include "Assets/Visual Design Cafe/Nature Renderer/Shader Includes/Nature Renderer.templatex"
			#pragma instancing_options procedural:SetupNatureRenderer
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _VariationColorA;
			float4 _Albedo_ST;
			float4 _WindLineColor;
			float4 _BaseColor;
			float4 _TipColor;
			float4 _VariationColorB;
			float3 _WindStetch;
			float3 _SpecifyNormal;
			float2 _WindLineSpeed;
			float _DirectLightIntensity;
			float _AO;
			float _WindLineRotate;
			float _WindLineScale;
			float _TipGradient;
			float _WindSpeed;
			float _IndirectLightIntensity;
			float _UseTexColor;
			float _FixedNormal;
			float _WindIntensity;
			float _WindSizeSmall;
			float _WindSizeBig;
			float _WindDirection;
			float _VariationMaskScale;
			float _AlphaCutoff;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			TEXTURE2D(_Albedo);
			SAMPLER(sampler_Albedo);


			float3 RotateXY165_g57( float3 R, float degrees )
			{
				float3 reflUVW = R;
				half theta = degrees * PI / 180.0f;
				half costha = cos(theta);
				half sintha = sin(theta);
				reflUVW = half3(reflUVW.x * costha - reflUVW.z * sintha, reflUVW.y, reflUVW.x * sintha + reflUVW.z * costha);
				return reflUVW;
			}
			
			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			

			float3 _LightDirection;
			float3 _LightPosition;

			VertexOutput VertexFunction( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float3 _Vector0 = float3(0,0,1);
				float3 RotateAxis34_g57 = cross( _Vector0 , float3(0,1,0) );
				float3 wind_direction31_g57 = _Vector0;
				float3 wind_speed40_g57 = ( ( _TimeParameters.x * _WindSpeed ) * float3(0.5,-0.5,-0.5) );
				float2 texCoord313 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				#if defined(_WINDGRADIENT_UV)
				float staticSwitch315 = texCoord313.y;
				#elif defined(_WINDGRADIENT_VERTEXCOLOR)
				float staticSwitch315 = v.ase_color.g;
				#else
				float staticSwitch315 = texCoord313.y;
				#endif
				float WindGradient316 = staticSwitch315;
				float temp_output_214_0 = ( WindGradient316 * WindGradient316 );
				float3 appendResult247 = (float3(_WindStetch.x , 1.0 , _WindStetch.z));
				float3 normalizeResult181 = normalize( appendResult247 );
				float3 break183 = normalizeResult181;
				float3 appendResult187 = (float3(break183.x , 0.0 , break183.z));
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float3 temp_output_193_0 = ( ( temp_output_214_0 * appendResult187 ) + ase_worldPos );
				float3 WorldPosition161_g57 = temp_output_193_0;
				float3 R165_g57 = WorldPosition161_g57;
				float degrees165_g57 = _WindDirection;
				float3 localRotateXY165_g57 = RotateXY165_g57( R165_g57 , degrees165_g57 );
				float3 temp_cast_0 = (1.0).xxx;
				float3 temp_output_22_0_g57 = abs( ( ( frac( ( ( ( wind_direction31_g57 * wind_speed40_g57 ) + ( localRotateXY165_g57 / _WindSizeBig ) ) + 0.5 ) ) * 2.0 ) - temp_cast_0 ) );
				float3 temp_cast_1 = (3.0).xxx;
				float dotResult30_g57 = dot( ( ( temp_output_22_0_g57 * temp_output_22_0_g57 ) * ( temp_cast_1 - ( temp_output_22_0_g57 * 2.0 ) ) ) , wind_direction31_g57 );
				float BigTriangleWave42_g57 = dotResult30_g57;
				float3 temp_cast_2 = (1.0).xxx;
				float3 temp_output_59_0_g57 = abs( ( ( frac( ( ( wind_speed40_g57 + ( localRotateXY165_g57 / _WindSizeSmall ) ) + 0.5 ) ) * 2.0 ) - temp_cast_2 ) );
				float3 temp_cast_3 = (3.0).xxx;
				float SmallTriangleWave52_g57 = distance( ( ( temp_output_59_0_g57 * temp_output_59_0_g57 ) * ( temp_cast_3 - ( temp_output_59_0_g57 * 2.0 ) ) ) , float3(0,0,0) );
				float3 rotatedValue72_g57 = RotateAroundAxis( ( float3( 0,0,0 ) - float3(0,0.1,0) ), WorldPosition161_g57, normalize( RotateAxis34_g57 ), ( ( BigTriangleWave42_g57 + SmallTriangleWave52_g57 ) * ( 2.0 * PI ) ) );
				float3 worldToObj197 = mul( GetWorldToObjectMatrix(), float4( ( ( ( rotatedValue72_g57 - WorldPosition161_g57 ) * temp_output_214_0 * _WindIntensity * 0.1 ) + temp_output_193_0 ), 1 ) ).xyz;
				float3 Wind198 = worldToObj197;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = Wind198;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.worldPos = positionWS;
				#endif

				float3 normalWS = TransformObjectToWorldDir( v.ase_normal );

				#if _CASTING_PUNCTUAL_LIGHT_SHADOW
					float3 lightDirectionWS = normalize(_LightPosition - positionWS);
				#else
					float3 lightDirectionWS = _LightDirection;
				#endif

				float4 clipPos = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));

				#if UNITY_REVERSED_Z
					clipPos.z = min(clipPos.z, UNITY_NEAR_CLIP_VALUE);
				#else
					clipPos.z = max(clipPos.z, UNITY_NEAR_CLIP_VALUE);
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.clipPos = clipPos;

				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_color = v.ase_color;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = IN.worldPos;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_Albedo = IN.ase_texcoord2.xy * _Albedo_ST.xy + _Albedo_ST.zw;
				float4 tex2DNode205 = SAMPLE_TEXTURE2D( _Albedo, sampler_Albedo, uv_Albedo );
				float OpacityMask96 = tex2DNode205.a;
				

				float Alpha = OpacityMask96;
				float AlphaClipThreshold = _AlphaCutoff;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					#ifdef _ALPHATEST_SHADOW_ON
						clip(Alpha - AlphaClipThresholdShadow);
					#else
						clip(Alpha - AlphaClipThreshold);
					#endif
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0
			AlphaToMask Off

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 120107
			#define ASE_USING_SAMPLING_MACROS 1

			
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#pragma shader_feature_local _WINDGRADIENT_UV _WINDGRADIENT_VERTEXCOLOR
			#include "Assets/Visual Design Cafe/Nature Renderer/Shader Includes/Nature Renderer.templatex"
			#pragma instancing_options procedural:SetupNatureRenderer
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _VariationColorA;
			float4 _Albedo_ST;
			float4 _WindLineColor;
			float4 _BaseColor;
			float4 _TipColor;
			float4 _VariationColorB;
			float3 _WindStetch;
			float3 _SpecifyNormal;
			float2 _WindLineSpeed;
			float _DirectLightIntensity;
			float _AO;
			float _WindLineRotate;
			float _WindLineScale;
			float _TipGradient;
			float _WindSpeed;
			float _IndirectLightIntensity;
			float _UseTexColor;
			float _FixedNormal;
			float _WindIntensity;
			float _WindSizeSmall;
			float _WindSizeBig;
			float _WindDirection;
			float _VariationMaskScale;
			float _AlphaCutoff;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			TEXTURE2D(_Albedo);
			SAMPLER(sampler_Albedo);


			float3 RotateXY165_g57( float3 R, float degrees )
			{
				float3 reflUVW = R;
				half theta = degrees * PI / 180.0f;
				half costha = cos(theta);
				half sintha = sin(theta);
				reflUVW = half3(reflUVW.x * costha - reflUVW.z * sintha, reflUVW.y, reflUVW.x * sintha + reflUVW.z * costha);
				return reflUVW;
			}
			
			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 _Vector0 = float3(0,0,1);
				float3 RotateAxis34_g57 = cross( _Vector0 , float3(0,1,0) );
				float3 wind_direction31_g57 = _Vector0;
				float3 wind_speed40_g57 = ( ( _TimeParameters.x * _WindSpeed ) * float3(0.5,-0.5,-0.5) );
				float2 texCoord313 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				#if defined(_WINDGRADIENT_UV)
				float staticSwitch315 = texCoord313.y;
				#elif defined(_WINDGRADIENT_VERTEXCOLOR)
				float staticSwitch315 = v.ase_color.g;
				#else
				float staticSwitch315 = texCoord313.y;
				#endif
				float WindGradient316 = staticSwitch315;
				float temp_output_214_0 = ( WindGradient316 * WindGradient316 );
				float3 appendResult247 = (float3(_WindStetch.x , 1.0 , _WindStetch.z));
				float3 normalizeResult181 = normalize( appendResult247 );
				float3 break183 = normalizeResult181;
				float3 appendResult187 = (float3(break183.x , 0.0 , break183.z));
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float3 temp_output_193_0 = ( ( temp_output_214_0 * appendResult187 ) + ase_worldPos );
				float3 WorldPosition161_g57 = temp_output_193_0;
				float3 R165_g57 = WorldPosition161_g57;
				float degrees165_g57 = _WindDirection;
				float3 localRotateXY165_g57 = RotateXY165_g57( R165_g57 , degrees165_g57 );
				float3 temp_cast_0 = (1.0).xxx;
				float3 temp_output_22_0_g57 = abs( ( ( frac( ( ( ( wind_direction31_g57 * wind_speed40_g57 ) + ( localRotateXY165_g57 / _WindSizeBig ) ) + 0.5 ) ) * 2.0 ) - temp_cast_0 ) );
				float3 temp_cast_1 = (3.0).xxx;
				float dotResult30_g57 = dot( ( ( temp_output_22_0_g57 * temp_output_22_0_g57 ) * ( temp_cast_1 - ( temp_output_22_0_g57 * 2.0 ) ) ) , wind_direction31_g57 );
				float BigTriangleWave42_g57 = dotResult30_g57;
				float3 temp_cast_2 = (1.0).xxx;
				float3 temp_output_59_0_g57 = abs( ( ( frac( ( ( wind_speed40_g57 + ( localRotateXY165_g57 / _WindSizeSmall ) ) + 0.5 ) ) * 2.0 ) - temp_cast_2 ) );
				float3 temp_cast_3 = (3.0).xxx;
				float SmallTriangleWave52_g57 = distance( ( ( temp_output_59_0_g57 * temp_output_59_0_g57 ) * ( temp_cast_3 - ( temp_output_59_0_g57 * 2.0 ) ) ) , float3(0,0,0) );
				float3 rotatedValue72_g57 = RotateAroundAxis( ( float3( 0,0,0 ) - float3(0,0.1,0) ), WorldPosition161_g57, normalize( RotateAxis34_g57 ), ( ( BigTriangleWave42_g57 + SmallTriangleWave52_g57 ) * ( 2.0 * PI ) ) );
				float3 worldToObj197 = mul( GetWorldToObjectMatrix(), float4( ( ( ( rotatedValue72_g57 - WorldPosition161_g57 ) * temp_output_214_0 * _WindIntensity * 0.1 ) + temp_output_193_0 ), 1 ) ).xyz;
				float3 Wind198 = worldToObj197;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = Wind198;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.worldPos = positionWS;
				#endif

				o.clipPos = TransformWorldToHClip( positionWS );
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = o.clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_color = v.ase_color;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = IN.worldPos;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_Albedo = IN.ase_texcoord2.xy * _Albedo_ST.xy + _Albedo_ST.zw;
				float4 tex2DNode205 = SAMPLE_TEXTURE2D( _Albedo, sampler_Albedo, uv_Albedo );
				float OpacityMask96 = tex2DNode205.a;
				

				float Alpha = OpacityMask96;
				float AlphaClipThreshold = _AlphaCutoff;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Universal2D"
			Tags { "LightMode"="Universal2D" }

			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 120107
			#define ASE_USING_SAMPLING_MACROS 1

			
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma shader_feature _ _SAMPLE_GI
			#pragma multi_compile _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
			#pragma multi_compile _ DEBUG_DISPLAY
			#define SHADERPASS SHADERPASS_UNLIT


			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging3D.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"

			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_SHADOWCOORDS
			#define ASE_NEEDS_VERT_NORMAL
			#pragma shader_feature_local _WINDGRADIENT_UV _WINDGRADIENT_VERTEXCOLOR
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile _ _SHADOWS_SOFT
			#pragma shader_feature_local _COLORGRADIENT_UV _COLORGRADIENT_VERTEXCOLOR
			#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#include "Assets/Visual Design Cafe/Nature Renderer/Shader Includes/Nature Renderer.templatex"
			#pragma instancing_options procedural:SetupNatureRenderer
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 texcoord1 : TEXCOORD1;
				float4 ase_tangent : TANGENT;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD1;
				#endif
				#ifdef ASE_FOG
					float fogFactor : TEXCOORD2;
				#endif
				float3 ase_normal : NORMAL;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_color : COLOR;
				float4 lightmapUVOrVertexSH : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				float4 ase_texcoord7 : TEXCOORD7;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _VariationColorA;
			float4 _Albedo_ST;
			float4 _WindLineColor;
			float4 _BaseColor;
			float4 _TipColor;
			float4 _VariationColorB;
			float3 _WindStetch;
			float3 _SpecifyNormal;
			float2 _WindLineSpeed;
			float _DirectLightIntensity;
			float _AO;
			float _WindLineRotate;
			float _WindLineScale;
			float _TipGradient;
			float _WindSpeed;
			float _IndirectLightIntensity;
			float _UseTexColor;
			float _FixedNormal;
			float _WindIntensity;
			float _WindSizeSmall;
			float _WindSizeBig;
			float _WindDirection;
			float _VariationMaskScale;
			float _AlphaCutoff;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			TEXTURE2D(_Albedo);
			SAMPLER(sampler_Albedo);
			TEXTURE2D(_VariationMask);
			SAMPLER(sampler_VariationMask);
			TEXTURE2D(_WindLine);
			SAMPLER(sampler_WindLine);


			float3 RotateXY165_g57( float3 R, float degrees )
			{
				float3 reflUVW = R;
				half theta = degrees * PI / 180.0f;
				half costha = cos(theta);
				half sintha = sin(theta);
				reflUVW = half3(reflUVW.x * costha - reflUVW.z * sintha, reflUVW.y, reflUVW.x * sintha + reflUVW.z * costha);
				return reflUVW;
			}
			
			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			
			float3 ASEIndirectDiffuse( float2 uvStaticLightmap, float3 normalWS )
			{
			#ifdef LIGHTMAP_ON
				return SampleLightmap( uvStaticLightmap, normalWS );
			#else
				return SampleSH(normalWS);
			#endif
			}
			
			float3 AdditionalLightsHalfLambert( float3 WorldPosition, float3 WorldNormal )
			{
				float3 Color = 0;
				#ifdef _ADDITIONAL_LIGHTS
				int numLights = GetAdditionalLightsCount();
				for(int i = 0; i<numLights;i++)
				{
					Light light = GetAdditionalLight(i, WorldPosition);
					half3 AttLightColor = light.color *(light.distanceAttenuation * light.shadowAttenuation);
					Color +=(dot(light.direction, WorldNormal)*0.5+0.5 )* AttLightColor;
					
				}
				#endif
				return Color;
			}
			

			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 _Vector0 = float3(0,0,1);
				float3 RotateAxis34_g57 = cross( _Vector0 , float3(0,1,0) );
				float3 wind_direction31_g57 = _Vector0;
				float3 wind_speed40_g57 = ( ( _TimeParameters.x * _WindSpeed ) * float3(0.5,-0.5,-0.5) );
				float2 texCoord313 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				#if defined(_WINDGRADIENT_UV)
				float staticSwitch315 = texCoord313.y;
				#elif defined(_WINDGRADIENT_VERTEXCOLOR)
				float staticSwitch315 = v.ase_color.g;
				#else
				float staticSwitch315 = texCoord313.y;
				#endif
				float WindGradient316 = staticSwitch315;
				float temp_output_214_0 = ( WindGradient316 * WindGradient316 );
				float3 appendResult247 = (float3(_WindStetch.x , 1.0 , _WindStetch.z));
				float3 normalizeResult181 = normalize( appendResult247 );
				float3 break183 = normalizeResult181;
				float3 appendResult187 = (float3(break183.x , 0.0 , break183.z));
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float3 temp_output_193_0 = ( ( temp_output_214_0 * appendResult187 ) + ase_worldPos );
				float3 WorldPosition161_g57 = temp_output_193_0;
				float3 R165_g57 = WorldPosition161_g57;
				float degrees165_g57 = _WindDirection;
				float3 localRotateXY165_g57 = RotateXY165_g57( R165_g57 , degrees165_g57 );
				float3 temp_cast_0 = (1.0).xxx;
				float3 temp_output_22_0_g57 = abs( ( ( frac( ( ( ( wind_direction31_g57 * wind_speed40_g57 ) + ( localRotateXY165_g57 / _WindSizeBig ) ) + 0.5 ) ) * 2.0 ) - temp_cast_0 ) );
				float3 temp_cast_1 = (3.0).xxx;
				float dotResult30_g57 = dot( ( ( temp_output_22_0_g57 * temp_output_22_0_g57 ) * ( temp_cast_1 - ( temp_output_22_0_g57 * 2.0 ) ) ) , wind_direction31_g57 );
				float BigTriangleWave42_g57 = dotResult30_g57;
				float3 temp_cast_2 = (1.0).xxx;
				float3 temp_output_59_0_g57 = abs( ( ( frac( ( ( wind_speed40_g57 + ( localRotateXY165_g57 / _WindSizeSmall ) ) + 0.5 ) ) * 2.0 ) - temp_cast_2 ) );
				float3 temp_cast_3 = (3.0).xxx;
				float SmallTriangleWave52_g57 = distance( ( ( temp_output_59_0_g57 * temp_output_59_0_g57 ) * ( temp_cast_3 - ( temp_output_59_0_g57 * 2.0 ) ) ) , float3(0,0,0) );
				float3 rotatedValue72_g57 = RotateAroundAxis( ( float3( 0,0,0 ) - float3(0,0.1,0) ), WorldPosition161_g57, normalize( RotateAxis34_g57 ), ( ( BigTriangleWave42_g57 + SmallTriangleWave52_g57 ) * ( 2.0 * PI ) ) );
				float3 worldToObj197 = mul( GetWorldToObjectMatrix(), float4( ( ( ( rotatedValue72_g57 - WorldPosition161_g57 ) * temp_output_214_0 * _WindIntensity * 0.1 ) + temp_output_193_0 ), 1 ) ).xyz;
				float3 Wind198 = worldToObj197;
				
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				OUTPUT_LIGHTMAP_UV( v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy );
				OUTPUT_SH( ase_worldNormal, o.lightmapUVOrVertexSH.xyz );
				o.ase_texcoord5.xyz = ase_worldNormal;
				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord6.xyz = ase_worldTangent;
				float ase_vertexTangentSign = v.ase_tangent.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord7.xyz = ase_worldBitangent;
				
				o.ase_normal = v.ase_normal;
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;
				o.ase_texcoord5.w = 0;
				o.ase_texcoord6.w = 0;
				o.ase_texcoord7.w = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = Wind198;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.worldPos = positionWS;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				#ifdef ASE_FOG
					o.fogFactor = ComputeFogFactor( positionCS.z );

				#endif

				o.clipPos = positionCS;

				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 texcoord1 : TEXCOORD1;
				float4 ase_tangent : TANGENT;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_color = v.ase_color;
				o.texcoord1 = v.texcoord1;
				o.ase_tangent = v.ase_tangent;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag ( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = IN.worldPos;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float3 lerpResult331 = lerp( IN.ase_normal , _SpecifyNormal , _FixedNormal);
				float3 objToWorldDir327 = normalize( mul( GetObjectToWorldMatrix(), float4( lerpResult331, 0 ) ).xyz );
				float3 WorldNormal333 = objToWorldDir327;
				float dotResult115 = dot( SafeNormalize(_MainLightPosition.xyz) , WorldNormal333 );
				float ase_lightAtten = 0;
				Light ase_mainLight = GetMainLight( ShadowCoords );
				ase_lightAtten = ase_mainLight.distanceAttenuation * ase_mainLight.shadowAttenuation;
				float4 temp_cast_0 = (1.0).xxxx;
				float2 uv_Albedo = IN.ase_texcoord3.xy * _Albedo_ST.xy + _Albedo_ST.zw;
				float4 tex2DNode205 = SAMPLE_TEXTURE2D( _Albedo, sampler_Albedo, uv_Albedo );
				float4 lerpResult321 = lerp( temp_cast_0 , tex2DNode205 , _UseTexColor);
				float4 TexColor319 = lerpResult321;
				float4 tex2DNode251 = SAMPLE_TEXTURE2D( _VariationMask, sampler_VariationMask, ( (WorldPosition).xz / _VariationMaskScale ) );
				float4 lerpResult254 = lerp( _BaseColor , _VariationColorA , tex2DNode251.r);
				float4 lerpResult258 = lerp( lerpResult254 , _VariationColorB , tex2DNode251.g);
				float4 VariationColor260 = lerpResult258;
				float2 texCoord200 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				#if defined(_COLORGRADIENT_UV)
				float staticSwitch202 = texCoord200.y;
				#elif defined(_COLORGRADIENT_VERTEXCOLOR)
				float staticSwitch202 = IN.ase_color.g;
				#else
				float staticSwitch202 = texCoord200.y;
				#endif
				float ColorGradient201 = staticSwitch202;
				float clampResult211 = clamp( ( ColorGradient201 * _TipGradient ) , 0.0 , 1.0 );
				float4 lerpResult206 = lerp( VariationColor260 , _TipColor , clampResult211);
				float cos278 = cos( ( _WindLineRotate * PI ) );
				float sin278 = sin( ( _WindLineRotate * PI ) );
				float2 rotator278 = mul( ( (WorldPosition).xz / _WindLineScale ) - float2( 0,0 ) , float2x2( cos278 , -sin278 , sin278 , cos278 )) + float2( 0,0 );
				float2 panner283 = ( 0.1 * _Time.y * _WindLineSpeed + rotator278);
				float4 WindLine276 = SAMPLE_TEXTURE2D( _WindLine, sampler_WindLine, panner283 );
				float lerpResult306 = lerp( 1.0 , ColorGradient201 , _AO);
				float4 BaseColor121 = ( TexColor319 * ( lerpResult206 + ( _WindLineColor * WindLine276 ) ) * lerpResult306 );
				float4 DirectLight120 = ( ( (dotResult115*0.5 + 0.5) * ase_lightAtten ) * _MainLightColor * BaseColor121 * _DirectLightIntensity );
				float3 ase_worldNormal = IN.ase_texcoord5.xyz;
				float3 bakedGI177 = ASEIndirectDiffuse( IN.lightmapUVOrVertexSH.xy, ase_worldNormal);
				MixRealtimeAndBakedGI(ase_mainLight, ase_worldNormal, bakedGI177, half4(0,0,0,0));
				float4 IndirectLight107 = ( float4( bakedGI177 , 0.0 ) * BaseColor121 * _IndirectLightIntensity );
				float3 worldPosValue44_g108 = WorldPosition;
				float3 WorldPosition22_g108 = worldPosValue44_g108;
				float3 ase_worldTangent = IN.ase_texcoord6.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord7.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal12_g108 = float3(0,0,1);
				float3 worldNormal12_g108 = float3(dot(tanToWorld0,tanNormal12_g108), dot(tanToWorld1,tanNormal12_g108), dot(tanToWorld2,tanNormal12_g108));
				float3 worldNormalValue50_g108 = worldNormal12_g108;
				float3 WorldNormal22_g108 = worldNormalValue50_g108;
				float3 localAdditionalLightsHalfLambert22_g108 = AdditionalLightsHalfLambert( WorldPosition22_g108 , WorldNormal22_g108 );
				float3 halfLambertResult58_g108 = localAdditionalLightsHalfLambert22_g108;
				
				float OpacityMask96 = tex2DNode205.a;
				

				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( DirectLight120 + IndirectLight107 + ( float4( halfLambertResult58_g108 , 0.0 ) * BaseColor121 ) ).rgb;
				float Alpha = OpacityMask96;
				float AlphaClipThreshold = _AlphaCutoff;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#if defined(_DBUFFER)
					ApplyDecalToBaseColor(IN.clipPos, Color);
				#endif

				#if defined(_ALPHAPREMULTIPLY_ON)
				Color *= Alpha;
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
				#endif

				return half4( Color, Alpha );
			}
			ENDHLSL
		}

		
		Pass
		{
			
            Name "SceneSelectionPass"
            Tags { "LightMode"="SceneSelectionPass" }
        
			Cull Off

			HLSLPROGRAM

			#pragma multi_compile_instancing
			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 120107
			#define ASE_USING_SAMPLING_MACROS 1


			#pragma only_renderers d3d11 glcore gles gles3 
			#pragma vertex vert
			#pragma fragment frag

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#pragma shader_feature_local _WINDGRADIENT_UV _WINDGRADIENT_VERTEXCOLOR
			#include "Assets/Visual Design Cafe/Nature Renderer/Shader Includes/Nature Renderer.templatex"
			#pragma instancing_options procedural:SetupNatureRenderer
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _VariationColorA;
			float4 _Albedo_ST;
			float4 _WindLineColor;
			float4 _BaseColor;
			float4 _TipColor;
			float4 _VariationColorB;
			float3 _WindStetch;
			float3 _SpecifyNormal;
			float2 _WindLineSpeed;
			float _DirectLightIntensity;
			float _AO;
			float _WindLineRotate;
			float _WindLineScale;
			float _TipGradient;
			float _WindSpeed;
			float _IndirectLightIntensity;
			float _UseTexColor;
			float _FixedNormal;
			float _WindIntensity;
			float _WindSizeSmall;
			float _WindSizeBig;
			float _WindDirection;
			float _VariationMaskScale;
			float _AlphaCutoff;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			TEXTURE2D(_Albedo);
			SAMPLER(sampler_Albedo);


			float3 RotateXY165_g57( float3 R, float degrees )
			{
				float3 reflUVW = R;
				half theta = degrees * PI / 180.0f;
				half costha = cos(theta);
				half sintha = sin(theta);
				reflUVW = half3(reflUVW.x * costha - reflUVW.z * sintha, reflUVW.y, reflUVW.x * sintha + reflUVW.z * costha);
				return reflUVW;
			}
			
			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			

			int _ObjectId;
			int _PassValue;

			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};
        
			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 _Vector0 = float3(0,0,1);
				float3 RotateAxis34_g57 = cross( _Vector0 , float3(0,1,0) );
				float3 wind_direction31_g57 = _Vector0;
				float3 wind_speed40_g57 = ( ( _TimeParameters.x * _WindSpeed ) * float3(0.5,-0.5,-0.5) );
				float2 texCoord313 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				#if defined(_WINDGRADIENT_UV)
				float staticSwitch315 = texCoord313.y;
				#elif defined(_WINDGRADIENT_VERTEXCOLOR)
				float staticSwitch315 = v.ase_color.g;
				#else
				float staticSwitch315 = texCoord313.y;
				#endif
				float WindGradient316 = staticSwitch315;
				float temp_output_214_0 = ( WindGradient316 * WindGradient316 );
				float3 appendResult247 = (float3(_WindStetch.x , 1.0 , _WindStetch.z));
				float3 normalizeResult181 = normalize( appendResult247 );
				float3 break183 = normalizeResult181;
				float3 appendResult187 = (float3(break183.x , 0.0 , break183.z));
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float3 temp_output_193_0 = ( ( temp_output_214_0 * appendResult187 ) + ase_worldPos );
				float3 WorldPosition161_g57 = temp_output_193_0;
				float3 R165_g57 = WorldPosition161_g57;
				float degrees165_g57 = _WindDirection;
				float3 localRotateXY165_g57 = RotateXY165_g57( R165_g57 , degrees165_g57 );
				float3 temp_cast_0 = (1.0).xxx;
				float3 temp_output_22_0_g57 = abs( ( ( frac( ( ( ( wind_direction31_g57 * wind_speed40_g57 ) + ( localRotateXY165_g57 / _WindSizeBig ) ) + 0.5 ) ) * 2.0 ) - temp_cast_0 ) );
				float3 temp_cast_1 = (3.0).xxx;
				float dotResult30_g57 = dot( ( ( temp_output_22_0_g57 * temp_output_22_0_g57 ) * ( temp_cast_1 - ( temp_output_22_0_g57 * 2.0 ) ) ) , wind_direction31_g57 );
				float BigTriangleWave42_g57 = dotResult30_g57;
				float3 temp_cast_2 = (1.0).xxx;
				float3 temp_output_59_0_g57 = abs( ( ( frac( ( ( wind_speed40_g57 + ( localRotateXY165_g57 / _WindSizeSmall ) ) + 0.5 ) ) * 2.0 ) - temp_cast_2 ) );
				float3 temp_cast_3 = (3.0).xxx;
				float SmallTriangleWave52_g57 = distance( ( ( temp_output_59_0_g57 * temp_output_59_0_g57 ) * ( temp_cast_3 - ( temp_output_59_0_g57 * 2.0 ) ) ) , float3(0,0,0) );
				float3 rotatedValue72_g57 = RotateAroundAxis( ( float3( 0,0,0 ) - float3(0,0.1,0) ), WorldPosition161_g57, normalize( RotateAxis34_g57 ), ( ( BigTriangleWave42_g57 + SmallTriangleWave52_g57 ) * ( 2.0 * PI ) ) );
				float3 worldToObj197 = mul( GetWorldToObjectMatrix(), float4( ( ( ( rotatedValue72_g57 - WorldPosition161_g57 ) * temp_output_214_0 * _WindIntensity * 0.1 ) + temp_output_193_0 ), 1 ) ).xyz;
				float3 Wind198 = worldToObj197;
				
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = Wind198;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				o.clipPos = TransformWorldToHClip(positionWS);

				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_color = v.ase_color;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif
			
			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float2 uv_Albedo = IN.ase_texcoord.xy * _Albedo_ST.xy + _Albedo_ST.zw;
				float4 tex2DNode205 = SAMPLE_TEXTURE2D( _Albedo, sampler_Albedo, uv_Albedo );
				float OpacityMask96 = tex2DNode205.a;
				

				surfaceDescription.Alpha = OpacityMask96;
				surfaceDescription.AlphaClipThreshold = _AlphaCutoff;

				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
					clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = half4(_ObjectId, _PassValue, 1.0, 1.0);
				return outColor;
			}
			ENDHLSL
		}

		
		Pass
		{
			
            Name "ScenePickingPass"
            Tags { "LightMode"="Picking" }

			HLSLPROGRAM

			#pragma multi_compile_instancing
			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 120107
			#define ASE_USING_SAMPLING_MACROS 1


			#pragma only_renderers d3d11 glcore gles gles3 
			#pragma vertex vert
			#pragma fragment frag

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY
			
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#pragma shader_feature_local _WINDGRADIENT_UV _WINDGRADIENT_VERTEXCOLOR
			#include "Assets/Visual Design Cafe/Nature Renderer/Shader Includes/Nature Renderer.templatex"
			#pragma instancing_options procedural:SetupNatureRenderer
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _VariationColorA;
			float4 _Albedo_ST;
			float4 _WindLineColor;
			float4 _BaseColor;
			float4 _TipColor;
			float4 _VariationColorB;
			float3 _WindStetch;
			float3 _SpecifyNormal;
			float2 _WindLineSpeed;
			float _DirectLightIntensity;
			float _AO;
			float _WindLineRotate;
			float _WindLineScale;
			float _TipGradient;
			float _WindSpeed;
			float _IndirectLightIntensity;
			float _UseTexColor;
			float _FixedNormal;
			float _WindIntensity;
			float _WindSizeSmall;
			float _WindSizeBig;
			float _WindDirection;
			float _VariationMaskScale;
			float _AlphaCutoff;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			TEXTURE2D(_Albedo);
			SAMPLER(sampler_Albedo);


			float3 RotateXY165_g57( float3 R, float degrees )
			{
				float3 reflUVW = R;
				half theta = degrees * PI / 180.0f;
				half costha = cos(theta);
				half sintha = sin(theta);
				reflUVW = half3(reflUVW.x * costha - reflUVW.z * sintha, reflUVW.y, reflUVW.x * sintha + reflUVW.z * costha);
				return reflUVW;
			}
			
			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			
        
			float4 _SelectionID;

        
			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};
        
			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 _Vector0 = float3(0,0,1);
				float3 RotateAxis34_g57 = cross( _Vector0 , float3(0,1,0) );
				float3 wind_direction31_g57 = _Vector0;
				float3 wind_speed40_g57 = ( ( _TimeParameters.x * _WindSpeed ) * float3(0.5,-0.5,-0.5) );
				float2 texCoord313 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				#if defined(_WINDGRADIENT_UV)
				float staticSwitch315 = texCoord313.y;
				#elif defined(_WINDGRADIENT_VERTEXCOLOR)
				float staticSwitch315 = v.ase_color.g;
				#else
				float staticSwitch315 = texCoord313.y;
				#endif
				float WindGradient316 = staticSwitch315;
				float temp_output_214_0 = ( WindGradient316 * WindGradient316 );
				float3 appendResult247 = (float3(_WindStetch.x , 1.0 , _WindStetch.z));
				float3 normalizeResult181 = normalize( appendResult247 );
				float3 break183 = normalizeResult181;
				float3 appendResult187 = (float3(break183.x , 0.0 , break183.z));
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float3 temp_output_193_0 = ( ( temp_output_214_0 * appendResult187 ) + ase_worldPos );
				float3 WorldPosition161_g57 = temp_output_193_0;
				float3 R165_g57 = WorldPosition161_g57;
				float degrees165_g57 = _WindDirection;
				float3 localRotateXY165_g57 = RotateXY165_g57( R165_g57 , degrees165_g57 );
				float3 temp_cast_0 = (1.0).xxx;
				float3 temp_output_22_0_g57 = abs( ( ( frac( ( ( ( wind_direction31_g57 * wind_speed40_g57 ) + ( localRotateXY165_g57 / _WindSizeBig ) ) + 0.5 ) ) * 2.0 ) - temp_cast_0 ) );
				float3 temp_cast_1 = (3.0).xxx;
				float dotResult30_g57 = dot( ( ( temp_output_22_0_g57 * temp_output_22_0_g57 ) * ( temp_cast_1 - ( temp_output_22_0_g57 * 2.0 ) ) ) , wind_direction31_g57 );
				float BigTriangleWave42_g57 = dotResult30_g57;
				float3 temp_cast_2 = (1.0).xxx;
				float3 temp_output_59_0_g57 = abs( ( ( frac( ( ( wind_speed40_g57 + ( localRotateXY165_g57 / _WindSizeSmall ) ) + 0.5 ) ) * 2.0 ) - temp_cast_2 ) );
				float3 temp_cast_3 = (3.0).xxx;
				float SmallTriangleWave52_g57 = distance( ( ( temp_output_59_0_g57 * temp_output_59_0_g57 ) * ( temp_cast_3 - ( temp_output_59_0_g57 * 2.0 ) ) ) , float3(0,0,0) );
				float3 rotatedValue72_g57 = RotateAroundAxis( ( float3( 0,0,0 ) - float3(0,0.1,0) ), WorldPosition161_g57, normalize( RotateAxis34_g57 ), ( ( BigTriangleWave42_g57 + SmallTriangleWave52_g57 ) * ( 2.0 * PI ) ) );
				float3 worldToObj197 = mul( GetWorldToObjectMatrix(), float4( ( ( ( rotatedValue72_g57 - WorldPosition161_g57 ) * temp_output_214_0 * _WindIntensity * 0.1 ) + temp_output_193_0 ), 1 ) ).xyz;
				float3 Wind198 = worldToObj197;
				
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = Wind198;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				o.clipPos = TransformWorldToHClip(positionWS);
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_color = v.ase_color;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float2 uv_Albedo = IN.ase_texcoord.xy * _Albedo_ST.xy + _Albedo_ST.zw;
				float4 tex2DNode205 = SAMPLE_TEXTURE2D( _Albedo, sampler_Albedo, uv_Albedo );
				float OpacityMask96 = tex2DNode205.a;
				

				surfaceDescription.Alpha = OpacityMask96;
				surfaceDescription.AlphaClipThreshold = _AlphaCutoff;

				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
					clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = 0;
				outColor = _SelectionID;
				
				return outColor;
			}

			ENDHLSL
		}

		
		Pass
		{
			
            Name "DepthNormals"
            Tags { "LightMode"="DepthNormalsOnly" }

			ZTest LEqual
			ZWrite On


			HLSLPROGRAM

			#pragma multi_compile_instancing
			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 120107
			#define ASE_USING_SAMPLING_MACROS 1


			#pragma only_renderers d3d11 glcore gles gles3 
			#pragma multi_compile_fog
			#pragma instancing_options renderinglayer

			#pragma vertex vert
			#pragma fragment frag

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define VARYINGS_NEED_NORMAL_WS

			#define SHADERPASS SHADERPASS_DEPTHNORMALSONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#pragma shader_feature_local _WINDGRADIENT_UV _WINDGRADIENT_VERTEXCOLOR
			#include "Assets/Visual Design Cafe/Nature Renderer/Shader Includes/Nature Renderer.templatex"
			#pragma instancing_options procedural:SetupNatureRenderer
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float3 normalWS : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
        
			CBUFFER_START(UnityPerMaterial)
			float4 _VariationColorA;
			float4 _Albedo_ST;
			float4 _WindLineColor;
			float4 _BaseColor;
			float4 _TipColor;
			float4 _VariationColorB;
			float3 _WindStetch;
			float3 _SpecifyNormal;
			float2 _WindLineSpeed;
			float _DirectLightIntensity;
			float _AO;
			float _WindLineRotate;
			float _WindLineScale;
			float _TipGradient;
			float _WindSpeed;
			float _IndirectLightIntensity;
			float _UseTexColor;
			float _FixedNormal;
			float _WindIntensity;
			float _WindSizeSmall;
			float _WindSizeBig;
			float _WindDirection;
			float _VariationMaskScale;
			float _AlphaCutoff;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			TEXTURE2D(_Albedo);
			SAMPLER(sampler_Albedo);


			float3 RotateXY165_g57( float3 R, float degrees )
			{
				float3 reflUVW = R;
				half theta = degrees * PI / 180.0f;
				half costha = cos(theta);
				half sintha = sin(theta);
				reflUVW = half3(reflUVW.x * costha - reflUVW.z * sintha, reflUVW.y, reflUVW.x * sintha + reflUVW.z * costha);
				return reflUVW;
			}
			
			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			

			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};
        
			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 _Vector0 = float3(0,0,1);
				float3 RotateAxis34_g57 = cross( _Vector0 , float3(0,1,0) );
				float3 wind_direction31_g57 = _Vector0;
				float3 wind_speed40_g57 = ( ( _TimeParameters.x * _WindSpeed ) * float3(0.5,-0.5,-0.5) );
				float2 texCoord313 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				#if defined(_WINDGRADIENT_UV)
				float staticSwitch315 = texCoord313.y;
				#elif defined(_WINDGRADIENT_VERTEXCOLOR)
				float staticSwitch315 = v.ase_color.g;
				#else
				float staticSwitch315 = texCoord313.y;
				#endif
				float WindGradient316 = staticSwitch315;
				float temp_output_214_0 = ( WindGradient316 * WindGradient316 );
				float3 appendResult247 = (float3(_WindStetch.x , 1.0 , _WindStetch.z));
				float3 normalizeResult181 = normalize( appendResult247 );
				float3 break183 = normalizeResult181;
				float3 appendResult187 = (float3(break183.x , 0.0 , break183.z));
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float3 temp_output_193_0 = ( ( temp_output_214_0 * appendResult187 ) + ase_worldPos );
				float3 WorldPosition161_g57 = temp_output_193_0;
				float3 R165_g57 = WorldPosition161_g57;
				float degrees165_g57 = _WindDirection;
				float3 localRotateXY165_g57 = RotateXY165_g57( R165_g57 , degrees165_g57 );
				float3 temp_cast_0 = (1.0).xxx;
				float3 temp_output_22_0_g57 = abs( ( ( frac( ( ( ( wind_direction31_g57 * wind_speed40_g57 ) + ( localRotateXY165_g57 / _WindSizeBig ) ) + 0.5 ) ) * 2.0 ) - temp_cast_0 ) );
				float3 temp_cast_1 = (3.0).xxx;
				float dotResult30_g57 = dot( ( ( temp_output_22_0_g57 * temp_output_22_0_g57 ) * ( temp_cast_1 - ( temp_output_22_0_g57 * 2.0 ) ) ) , wind_direction31_g57 );
				float BigTriangleWave42_g57 = dotResult30_g57;
				float3 temp_cast_2 = (1.0).xxx;
				float3 temp_output_59_0_g57 = abs( ( ( frac( ( ( wind_speed40_g57 + ( localRotateXY165_g57 / _WindSizeSmall ) ) + 0.5 ) ) * 2.0 ) - temp_cast_2 ) );
				float3 temp_cast_3 = (3.0).xxx;
				float SmallTriangleWave52_g57 = distance( ( ( temp_output_59_0_g57 * temp_output_59_0_g57 ) * ( temp_cast_3 - ( temp_output_59_0_g57 * 2.0 ) ) ) , float3(0,0,0) );
				float3 rotatedValue72_g57 = RotateAroundAxis( ( float3( 0,0,0 ) - float3(0,0.1,0) ), WorldPosition161_g57, normalize( RotateAxis34_g57 ), ( ( BigTriangleWave42_g57 + SmallTriangleWave52_g57 ) * ( 2.0 * PI ) ) );
				float3 worldToObj197 = mul( GetWorldToObjectMatrix(), float4( ( ( ( rotatedValue72_g57 - WorldPosition161_g57 ) * temp_output_214_0 * _WindIntensity * 0.1 ) + temp_output_193_0 ), 1 ) ).xyz;
				float3 Wind198 = worldToObj197;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = Wind198;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 normalWS = TransformObjectToWorldNormal(v.ase_normal);

				o.clipPos = TransformWorldToHClip(positionWS);
				o.normalWS.xyz =  normalWS;

				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_color = v.ase_color;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float2 uv_Albedo = IN.ase_texcoord1.xy * _Albedo_ST.xy + _Albedo_ST.zw;
				float4 tex2DNode205 = SAMPLE_TEXTURE2D( _Albedo, sampler_Albedo, uv_Albedo );
				float OpacityMask96 = tex2DNode205.a;
				

				surfaceDescription.Alpha = OpacityMask96;
				surfaceDescription.AlphaClipThreshold = _AlphaCutoff;

				#if _ALPHATEST_ON
					clip(surfaceDescription.Alpha - surfaceDescription.AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				float3 normalWS = IN.normalWS;

				return half4(NormalizeNormalPerPixel(normalWS), 0.0);
			}

			ENDHLSL
		}

		
		Pass
		{
			
            Name "DepthNormalsOnly"
            Tags { "LightMode"="DepthNormalsOnly" }
        
			ZTest LEqual
			ZWrite On
        
			HLSLPROGRAM

			#pragma multi_compile_instancing
			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 120107
			#define ASE_USING_SAMPLING_MACROS 1


			#pragma exclude_renderers glcore gles gles3 
			#pragma vertex vert
			#pragma fragment frag

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define ATTRIBUTES_NEED_TEXCOORD1
			#define VARYINGS_NEED_NORMAL_WS
			#define VARYINGS_NEED_TANGENT_WS

			#define SHADERPASS SHADERPASS_DEPTHNORMALSONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#pragma shader_feature_local _WINDGRADIENT_UV _WINDGRADIENT_VERTEXCOLOR
			#include "Assets/Visual Design Cafe/Nature Renderer/Shader Includes/Nature Renderer.templatex"
			#pragma instancing_options procedural:SetupNatureRenderer
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float3 normalWS : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
        
			CBUFFER_START(UnityPerMaterial)
			float4 _VariationColorA;
			float4 _Albedo_ST;
			float4 _WindLineColor;
			float4 _BaseColor;
			float4 _TipColor;
			float4 _VariationColorB;
			float3 _WindStetch;
			float3 _SpecifyNormal;
			float2 _WindLineSpeed;
			float _DirectLightIntensity;
			float _AO;
			float _WindLineRotate;
			float _WindLineScale;
			float _TipGradient;
			float _WindSpeed;
			float _IndirectLightIntensity;
			float _UseTexColor;
			float _FixedNormal;
			float _WindIntensity;
			float _WindSizeSmall;
			float _WindSizeBig;
			float _WindDirection;
			float _VariationMaskScale;
			float _AlphaCutoff;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			TEXTURE2D(_Albedo);
			SAMPLER(sampler_Albedo);


			float3 RotateXY165_g57( float3 R, float degrees )
			{
				float3 reflUVW = R;
				half theta = degrees * PI / 180.0f;
				half costha = cos(theta);
				half sintha = sin(theta);
				reflUVW = half3(reflUVW.x * costha - reflUVW.z * sintha, reflUVW.y, reflUVW.x * sintha + reflUVW.z * costha);
				return reflUVW;
			}
			
			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			

			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};
      
			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 _Vector0 = float3(0,0,1);
				float3 RotateAxis34_g57 = cross( _Vector0 , float3(0,1,0) );
				float3 wind_direction31_g57 = _Vector0;
				float3 wind_speed40_g57 = ( ( _TimeParameters.x * _WindSpeed ) * float3(0.5,-0.5,-0.5) );
				float2 texCoord313 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				#if defined(_WINDGRADIENT_UV)
				float staticSwitch315 = texCoord313.y;
				#elif defined(_WINDGRADIENT_VERTEXCOLOR)
				float staticSwitch315 = v.ase_color.g;
				#else
				float staticSwitch315 = texCoord313.y;
				#endif
				float WindGradient316 = staticSwitch315;
				float temp_output_214_0 = ( WindGradient316 * WindGradient316 );
				float3 appendResult247 = (float3(_WindStetch.x , 1.0 , _WindStetch.z));
				float3 normalizeResult181 = normalize( appendResult247 );
				float3 break183 = normalizeResult181;
				float3 appendResult187 = (float3(break183.x , 0.0 , break183.z));
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float3 temp_output_193_0 = ( ( temp_output_214_0 * appendResult187 ) + ase_worldPos );
				float3 WorldPosition161_g57 = temp_output_193_0;
				float3 R165_g57 = WorldPosition161_g57;
				float degrees165_g57 = _WindDirection;
				float3 localRotateXY165_g57 = RotateXY165_g57( R165_g57 , degrees165_g57 );
				float3 temp_cast_0 = (1.0).xxx;
				float3 temp_output_22_0_g57 = abs( ( ( frac( ( ( ( wind_direction31_g57 * wind_speed40_g57 ) + ( localRotateXY165_g57 / _WindSizeBig ) ) + 0.5 ) ) * 2.0 ) - temp_cast_0 ) );
				float3 temp_cast_1 = (3.0).xxx;
				float dotResult30_g57 = dot( ( ( temp_output_22_0_g57 * temp_output_22_0_g57 ) * ( temp_cast_1 - ( temp_output_22_0_g57 * 2.0 ) ) ) , wind_direction31_g57 );
				float BigTriangleWave42_g57 = dotResult30_g57;
				float3 temp_cast_2 = (1.0).xxx;
				float3 temp_output_59_0_g57 = abs( ( ( frac( ( ( wind_speed40_g57 + ( localRotateXY165_g57 / _WindSizeSmall ) ) + 0.5 ) ) * 2.0 ) - temp_cast_2 ) );
				float3 temp_cast_3 = (3.0).xxx;
				float SmallTriangleWave52_g57 = distance( ( ( temp_output_59_0_g57 * temp_output_59_0_g57 ) * ( temp_cast_3 - ( temp_output_59_0_g57 * 2.0 ) ) ) , float3(0,0,0) );
				float3 rotatedValue72_g57 = RotateAroundAxis( ( float3( 0,0,0 ) - float3(0,0.1,0) ), WorldPosition161_g57, normalize( RotateAxis34_g57 ), ( ( BigTriangleWave42_g57 + SmallTriangleWave52_g57 ) * ( 2.0 * PI ) ) );
				float3 worldToObj197 = mul( GetWorldToObjectMatrix(), float4( ( ( ( rotatedValue72_g57 - WorldPosition161_g57 ) * temp_output_214_0 * _WindIntensity * 0.1 ) + temp_output_193_0 ), 1 ) ).xyz;
				float3 Wind198 = worldToObj197;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = Wind198;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 normalWS = TransformObjectToWorldNormal(v.ase_normal);

				o.clipPos = TransformWorldToHClip(positionWS);
				o.normalWS.xyz =  normalWS;

				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_color = v.ase_color;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float2 uv_Albedo = IN.ase_texcoord1.xy * _Albedo_ST.xy + _Albedo_ST.zw;
				float4 tex2DNode205 = SAMPLE_TEXTURE2D( _Albedo, sampler_Albedo, uv_Albedo );
				float OpacityMask96 = tex2DNode205.a;
				

				surfaceDescription.Alpha = OpacityMask96;
				surfaceDescription.AlphaClipThreshold = _AlphaCutoff;

				#if _ALPHATEST_ON
					clip(surfaceDescription.Alpha - surfaceDescription.AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				float3 normalWS = IN.normalWS;

				return half4(NormalizeNormalPerPixel(normalWS), 0.0);
			}

			ENDHLSL
		}
		
	}
	
	CustomEditor "ASEMaterialInspector"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=19002
7;43;1906;1009;9269.155;3743.766;2.843737;True;True
Node;AmplifyShaderEditor.CommentaryNode;42;-4029.886,-834.4345;Inherit;False;2500.774;1068.399;;21;198;197;196;244;193;223;191;199;194;192;245;187;214;318;246;183;181;247;179;248;338;Wind;0.49,0.6290355,0.7,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;317;-3111.753,-2294.459;Inherit;False;801.999;396.3252;Wind Gradient;4;313;314;315;316;Wind Gradient;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;313;-3061.753,-2244.459;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;314;-3034.635,-2105.134;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;248;-3883.818,-90.26897;Inherit;False;Constant;_Float12;Float 12;19;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;179;-3923.143,-271.2516;Inherit;False;Property;_WindStetch;Wind Stetch;19;0;Create;True;0;0;0;False;0;False;0,1,0;0.3,1,0.3;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StaticSwitch;315;-2796.755,-2163.459;Inherit;False;Property;_WindGradient;WindGradient;13;0;Create;True;0;0;0;False;2;Header(Wind Settings);Space(5);False;0;0;0;True;;KeywordEnum;2;UV;VertexColor;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;247;-3730.818,-243.269;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;316;-2531.754,-2175.459;Inherit;False;WindGradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;181;-3585.362,-246.4337;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;246;-3466.818,-107.2691;Inherit;False;Constant;_Float10;Float 10;20;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;318;-3551.913,-714.2778;Inherit;False;316;WindGradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;183;-3437.442,-242.9549;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;187;-3281.31,-247.2772;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;214;-3292.255,-714.7482;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;338;-3105.63,-108.5895;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;245;-3071.563,-268.8628;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;194;-2935.254,-537.1828;Inherit;False;Property;_WindSizeBig;Wind Size Big;17;0;Create;True;0;0;0;False;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;192;-2891.254,-455.1828;Inherit;False;Property;_WindSizeSmall;Wind Size Small;18;0;Create;True;0;0;0;False;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;223;-3074.488,-617.9727;Inherit;False;Property;_WindDirection;Wind Direction;16;0;Create;True;0;0;0;False;0;False;45;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;191;-2936.254,-686.1826;Inherit;False;Property;_WindSpeed;Wind Speed;15;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;193;-2791.006,-244.9485;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;199;-2926.871,-778.4798;Inherit;False;Property;_WindIntensity;WindIntensity;14;0;Create;True;0;0;0;False;0;False;0.2;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;244;-2602.253,-713.7125;Inherit;False;GrassWind;-1;;57;db826050c91347f49bd480b8176038c0;0;7;158;FLOAT;1;False;160;FLOAT;1;False;1;FLOAT;1;False;167;FLOAT;0;False;156;FLOAT;10;False;157;FLOAT;2;False;147;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;196;-2205.416,-286.0412;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;44;-4020.783,-1801.677;Inherit;False;2497.869;869.1619;BaseColor;24;209;289;262;121;274;208;206;211;305;307;288;207;145;96;205;319;301;287;303;306;321;322;324;325;BaseColor;0.5177868,0.7,0.49,1;0;0
Node;AmplifyShaderEditor.SamplerNode;205;-3937.189,-1675.272;Inherit;True;Property;_Albedo;Albedo;2;0;Create;True;0;0;0;False;0;False;-1;None;bf4779508f878134d895fac276675631;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TransformPositionNode;197;-2032.703,-292.6215;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;45;-4042.725,322.4949;Inherit;False;2481.069;1251.129;;2;51;47;Lighting;0.7,0.686289,0.49,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;96;-3415.415,-1582.75;Inherit;False;OpacityMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;286;-5961.779,-817.379;Inherit;False;1869.595;543.9856;WindLine;12;276;267;283;285;278;269;268;271;270;279;292;291;WindLine;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;51;-3981.859,425.8695;Inherit;False;1714.063;614.3447;;11;154;98;120;312;115;130;119;150;157;139;334;Direct Light;0.8,0.7843137,0.5607843,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;198;-1790.138,-295.3347;Inherit;False;Wind;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;352;-8311.226,-3275.064;Inherit;False;1695.688;550.0243;TerrainColor(测试);10;351;350;346;344;342;349;348;343;345;357;TerrainColor(测试);1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;47;-3969.303,1132.743;Inherit;False;933.2305;378.5339;;5;177;175;173;118;107;Indirect Light;0.8,0.7843137,0.5607843,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;217;-2211.203,-2271.141;Inherit;False;531;387;GPU Instance Indirect;1;27;GPU Instance Indirect;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;335;-5887.707,296.188;Inherit;False;1777.27;860.3399;WorldNormal;8;333;332;327;331;326;330;339;341;WorldNormal;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;43;-4006.384,-2285.995;Inherit;False;785.9;393.4999;Color Gradient;4;202;200;201;204;Color Gradient;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;252;-6346.433,-1805.957;Inherit;False;2244.191;870.7308;Variation Color;11;250;251;258;254;249;260;263;265;264;266;167;Variation Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;201;-3454.832,-2143.141;Inherit;False;ColorGradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;173;-3825.303,1276.742;Inherit;False;121;BaseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;224;-160.0754,-379.0828;Inherit;False;198;Wind;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;321;-3547.091,-1719.229;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;309;-663.5256,-720.7041;Inherit;False;SRP Additional Light;-1;;108;6c86746ad131a0a408ca599df5f40861;7,6,1,9,0,23,1,26,0,27,0,24,0,25,0;6;2;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;15;FLOAT3;0,0,0;False;14;FLOAT3;1,1,1;False;18;FLOAT;0.5;False;32;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;209;-3578.561,-1192.722;Inherit;False;Property;_TipGradient;Tip Gradient;8;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;263;-6298.63,-1266.532;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;139;-2749.859,729.8695;Inherit;False;4;4;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SwizzleNode;271;-5729.779,-742.8383;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;288;-2529.889,-1504.666;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;249;-5264.905,-1463.002;Inherit;False;Property;_VariationColorA;Variation Color A;11;0;Create;True;0;0;0;False;0;False;0.2470588,1,0,0;1,0.6313726,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;294;-442.7267,-774.2706;Inherit;False;107;IndirectLight;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RotatorNode;278;-5290.932,-736.8936;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;269;-5475.777,-736.4381;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;301;-2481.889,-1120.666;Inherit;False;201;ColorGradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;265;-6116.63,-1271.532;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;319;-3352.756,-1722.948;Inherit;False;TexColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;324;-3764.091,-1452.229;Inherit;False;Property;_UseTexColor;UseTexColor;5;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;204;-3949.713,-2079.816;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;339;-5511.554,805.4617;Inherit;True;Property;_NormalMap;NormalMap;30;0;Create;True;0;0;0;False;0;False;-1;None;cec07d28a4fac6e4b8d00bc318da7fe5;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;285;-5221.429,-571.6935;Inherit;False;Property;_WindLineSpeed;Wind Line Speed;24;0;Create;True;0;0;0;False;0;False;0,0.3;0,0.3;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;208;-3329.889,-1216.666;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;289;-2689.889,-1184.666;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;118;-3905.303,1372.742;Inherit;False;Property;_IndirectLightIntensity;Indirect Light Intensity;26;0;Create;True;0;0;0;False;0;False;1;1;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;210;-433.8282,-887.94;Inherit;False;120;DirectLight;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;167;-5324.389,-1699.117;Inherit;False;Property;_BaseColor;Base Color;6;0;Create;True;0;0;0;False;0;False;0.04705882,0.4431373,0.04313726,0;0.3113208,0.2055892,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;207;-3588.452,-1277.444;Inherit;False;201;ColorGradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;276;-4316.184,-767.379;Inherit;False;WindLine;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;130;-2989.859,713.8695;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.PannerNode;283;-4936.339,-734.0285;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;0.1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-269.3699,-482.2037;Inherit;False;Property;_AlphaCutoff;Alpha Cutoff;3;0;Create;False;0;0;0;False;0;False;0.35;0.35;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;267;-4696.486,-763.9753;Inherit;True;Property;_WindLine;WindLine;20;0;Create;True;0;0;0;False;0;False;-1;0dc6145d2eb310147a7837d5a44f211b;0dc6145d2eb310147a7837d5a44f211b;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;258;-4703.416,-1242.457;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.IndirectDiffuseLighting;177;-3873.303,1180.742;Inherit;False;Tangent;1;0;FLOAT3;0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;291;-5498.082,-502.972;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;333;-5145.707,511.1881;Inherit;False;WorldNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;120;-2573.859,729.8695;Inherit;False;DirectLight;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldNormalVector;341;-5191.881,808.8121;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;279;-5820.23,-506.3936;Inherit;False;Property;_WindLineRotate;Wind Line Rotate;23;0;Create;True;0;0;0;False;0;False;0.8;0.8;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;251;-5723.905,-1258.003;Inherit;True;Property;_VariationMask;Variation Mask;9;0;Create;True;0;0;0;False;0;False;-1;37cf721143238594ca716960ee3a3058;37cf721143238594ca716960ee3a3058;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;254;-4895.198,-1456.503;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightAttenuation;119;-3213.859,681.8693;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;330;-5823.707,558.188;Inherit;False;Property;_SpecifyNormal;SpecifyNormal;29;0;Create;True;0;0;0;False;0;False;0,1,0;0,1,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;266;-6195.63,-1084.532;Inherit;False;Property;_VariationMaskScale;Variation Mask Scale;10;0;Create;True;0;0;0;False;0;False;50;50;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;175;-3553.303,1260.742;Inherit;True;3;3;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;200;-3976.831,-2219.141;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;350;-7264.43,-3225.064;Inherit;True;Global;_ColorMap;_ColorMap;31;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;115;-3645.859,569.8696;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;274;-2929.889,-1264.666;Inherit;False;Property;_WindLineColor;Wind Line Color;21;0;Create;True;0;0;0;False;0;False;0.07843138,0.2980392,0,0;1,0.6313726,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;270;-5911.779,-737.8383;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;306;-2273.889,-1152.666;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;107;-3265.304,1260.742;Inherit;False;IndirectLight;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.NormalVertexDataNode;326;-5837.707,346.188;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;331;-5604.707,517.188;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;322;-3764.091,-1763.229;Inherit;False;Constant;_Float2;Float 2;25;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;264;-5930.63,-1220.532;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;287;-2881.889,-1072.666;Inherit;False;276;WindLine;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;268;-5740.777,-600.4381;Inherit;False;Property;_WindLineScale;Wind Line Scale;22;0;Create;True;0;0;0;False;0;False;50;50;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;157;-3005.859,841.8695;Inherit;False;121;BaseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;310;-404.5256,-692.7041;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;202;-3712.833,-2138.141;Inherit;False;Property;_ColorGradient;ColorGradient;4;0;Create;True;0;0;0;False;2;Header(Color Settings);Space(5);False;0;0;0;True;;KeywordEnum;2;UV;VertexColor;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;325;-2267.344,-1698.755;Inherit;False;319;TexColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.PiNode;292;-5752.082,-386.972;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;206;-2881.889,-1504.666;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;27;-2161.203,-2221.141;Inherit;False;NatureRendererInstancing;-1;;106;fc3b478351ccebd45b623e71d6460ef5;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;145;-3173.889,-1488.666;Inherit;False;Property;_TipColor;Tip Color;7;0;Create;True;0;0;0;False;0;False;0.4313726,1,0.007843138,0;1,0.6313726,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;211;-3153.889,-1200.666;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;150;-3949.859,505.8695;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;98;-3117.859,921.8695;Inherit;False;Property;_DirectLightIntensity;Direct Light Intensity;25;0;Create;True;0;0;0;False;2;Header(Light Settings);Space(5);False;1;1;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;260;-4487.868,-1247.435;Inherit;False;VariationColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;262;-3157.889,-1613.666;Inherit;False;260;VariationColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;293;-179.302,-788.5803;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;311;-657.5256,-595.7041;Inherit;False;121;BaseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;60;-186.4033,-570.0414;Inherit;False;96;OpacityMask;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;303;-2593.889,-1024.666;Inherit;False;Property;_AO;AO;27;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;334;-3905.215,837.7688;Inherit;False;333;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;305;-2027.891,-1518.666;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;250;-5166.546,-1261.072;Inherit;False;Property;_VariationColorB;Variation Color B;12;0;Create;True;0;0;0;False;0;False;0,0.4039216,0.427451,0;0.8588236,0.7176471,0.4431372,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;342;-8261.226,-3207.032;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ScaleAndOffsetNode;312;-3412.845,565.8839;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;332;-5824.707,749.188;Inherit;False;Property;_FixedNormal;FixedNormal;28;1;[Toggle];Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;307;-2449.889,-1216.666;Inherit;False;Constant;_Float0;Float 0;26;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;327;-5405.707,512.1881;Inherit;False;Object;World;True;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;154;-2971.666,579.9376;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;346;-7469.433,-3198.454;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;357;-7224.166,-2948.793;Inherit;False;GetTerrainColor;0;;107;266c18bf660db554a825b0fbd87b0d49;0;0;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;348;-7838.433,-3026.454;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;121;-1794.891,-1520.666;Inherit;False;BaseColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;351;-6893.299,-3202.346;Inherit;False;TerrainColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;349;-7665.433,-2982.454;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;343;-8151.856,-3029.558;Inherit;False;Global;_ColorMapUV;_ColorMapUV;29;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;344;-8040.433,-3207.454;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;345;-7835.433,-3202.454;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;33;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;12;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=Universal2D;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;28;-72,-34;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;12;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;30;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;12;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;36;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;12;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormals;0;8;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;True;4;d3d11;glcore;gles;gles3;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;37;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;12;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormalsOnly;0;9;DepthNormalsOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;True;15;d3d9;d3d11_9x;d3d11;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;32;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;12;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;29;190.4754,-602.0711;Float;False;True;-1;2;ASEMaterialInspector;0;12;Grass;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;2;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=AlphaTest=Queue=0;NatureRendererInstancing=True;True;5;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalForwardOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;23;Surface;0;0;  Blend;0;0;Two Sided;0;638043145277367111;Forward Only;0;0;Cast Shadows;1;0;  Use Shadow Threshold;0;0;Receive Shadows;1;0;GPU Instancing;1;0;LOD CrossFade;0;0;Built-in Fog;0;0;DOTS Instancing;0;0;Meta Pass;0;0;Extra Pre Pass;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,;0;  Type;0;0;  Tess;16,False,;0;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Vertex Position,InvertActionOnDeselection;0;638043171708848109;0;10;False;True;True;True;False;True;True;True;True;True;False;;True;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;35;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;12;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ScenePickingPass;0;7;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;True;4;d3d11;glcore;gles;gles3;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;34;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;12;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;SceneSelectionPass;0;6;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;True;4;d3d11;glcore;gles;gles3;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;31;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;12;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
WireConnection;315;1;313;2
WireConnection;315;0;314;2
WireConnection;247;0;179;1
WireConnection;247;1;248;0
WireConnection;247;2;179;3
WireConnection;316;0;315;0
WireConnection;181;0;247;0
WireConnection;183;0;181;0
WireConnection;187;0;183;0
WireConnection;187;1;246;0
WireConnection;187;2;183;2
WireConnection;214;0;318;0
WireConnection;214;1;318;0
WireConnection;245;0;214;0
WireConnection;245;1;187;0
WireConnection;193;0;245;0
WireConnection;193;1;338;0
WireConnection;244;158;214;0
WireConnection;244;160;199;0
WireConnection;244;1;191;0
WireConnection;244;167;223;0
WireConnection;244;156;194;0
WireConnection;244;157;192;0
WireConnection;244;147;193;0
WireConnection;196;0;244;0
WireConnection;196;1;193;0
WireConnection;197;0;196;0
WireConnection;96;0;205;4
WireConnection;198;0;197;0
WireConnection;201;0;202;0
WireConnection;321;0;322;0
WireConnection;321;1;205;0
WireConnection;321;2;324;0
WireConnection;139;0;154;0
WireConnection;139;1;130;0
WireConnection;139;2;157;0
WireConnection;139;3;98;0
WireConnection;271;0;270;0
WireConnection;288;0;206;0
WireConnection;288;1;289;0
WireConnection;278;0;269;0
WireConnection;278;2;291;0
WireConnection;269;0;271;0
WireConnection;269;1;268;0
WireConnection;265;0;263;0
WireConnection;319;0;321;0
WireConnection;208;0;207;0
WireConnection;208;1;209;0
WireConnection;289;0;274;0
WireConnection;289;1;287;0
WireConnection;276;0;267;0
WireConnection;283;0;278;0
WireConnection;283;2;285;0
WireConnection;267;1;283;0
WireConnection;258;0;254;0
WireConnection;258;1;250;0
WireConnection;258;2;251;2
WireConnection;291;0;279;0
WireConnection;291;1;292;0
WireConnection;333;0;327;0
WireConnection;120;0;139;0
WireConnection;341;0;339;0
WireConnection;251;1;264;0
WireConnection;254;0;167;0
WireConnection;254;1;249;0
WireConnection;254;2;251;1
WireConnection;175;0;177;0
WireConnection;175;1;173;0
WireConnection;175;2;118;0
WireConnection;350;1;346;0
WireConnection;115;0;150;0
WireConnection;115;1;334;0
WireConnection;306;0;307;0
WireConnection;306;1;301;0
WireConnection;306;2;303;0
WireConnection;107;0;175;0
WireConnection;331;0;326;0
WireConnection;331;1;330;0
WireConnection;331;2;332;0
WireConnection;264;0;265;0
WireConnection;264;1;266;0
WireConnection;310;0;309;0
WireConnection;310;1;311;0
WireConnection;202;1;200;2
WireConnection;202;0;204;2
WireConnection;206;0;262;0
WireConnection;206;1;145;0
WireConnection;206;2;211;0
WireConnection;211;0;208;0
WireConnection;260;0;258;0
WireConnection;293;0;210;0
WireConnection;293;1;294;0
WireConnection;293;2;310;0
WireConnection;305;0;325;0
WireConnection;305;1;288;0
WireConnection;305;2;306;0
WireConnection;312;0;115;0
WireConnection;327;0;331;0
WireConnection;154;0;312;0
WireConnection;154;1;119;0
WireConnection;346;0;345;0
WireConnection;346;1;349;0
WireConnection;348;0;343;1
WireConnection;348;1;343;2
WireConnection;121;0;305;0
WireConnection;351;0;357;0
WireConnection;349;0;348;0
WireConnection;349;1;343;3
WireConnection;344;0;342;0
WireConnection;345;0;344;0
WireConnection;345;1;343;3
WireConnection;29;2;293;0
WireConnection;29;3;60;0
WireConnection;29;4;56;0
WireConnection;29;5;224;0
ASEEND*/
//CHKSM=1F9F8AA1234EED2F93856D8485458291DE740012