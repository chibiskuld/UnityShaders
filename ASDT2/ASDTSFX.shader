﻿Shader "Skuld/Deprecated/Advance Shading + Dual Texture SFX"
{
	Properties {
		[space]
		_ShadeRange("Shade Range",Range(0,1)) = 1.0
		_ShadeSoftness("Edge Softness", Range(0,1)) = 0
		_ShadePivot("Center",Range(0,1)) = .5
		_ShadeMax("Max Brightness", Range(0,1)) = 1.0
		_ShadeMin("Min Brightness",Range(0,1)) = 0.0

		[space]
		[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("Source Blend", Float) = 1                 // "One"
		[Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("Destination Blend", Float) = 0            // "Zero"
		[Enum(UnityEngine.Rendering.BlendOp)] _BlendOp("Blend Operation", Float) = 0                 // "Add"
		[Enum(UnityEngine.Rendering.CullMode)] _CullMode("Cull Mode", Float) = 2                     // "Back"
		_TCut("Transparent Cut",Range(0,1)) = .1

		[space]
		_MainTex("Base Layer", 2D) = "black" {}
		_Color("Base Color",Color) = (1,1,1,1)
		_FresnelColor("Fresnel Color", Color)=(1, 1, 1, 1)
		_FresnelRetract("Fresnel Retract", Range(0,10)) = 0.5
		[space]
		_MaskTex("Mask Layer", 2D) = "black" {}
		[Toggle] _MaskGlow("Mask Glow", Float) = 0
		_MaskGlowColor("Glow Color", Color)=(1, 1, 1, 1)
		[Toggle] _MaskRainbow("Rainbow Effect", Float) = 0
		_MaskGlowSpeed("Glow Speed",Range(0,10)) = 1
		_MaskGlowSharpness("Glow Sharpness",Range(1,200)) = 1.0

		[space]
		_BumpTex("Bump Layer", 2D) = "black" {}
		_BumpScale("Bump Amount", Range(0,1)) = 1.0
	
	}

	SubShader {
		Tags { "RenderType"="TransparentCutout" "Queue"="Geometry+1"}

        Blend[_SrcBlend][_DstBlend]
        BlendOp[_BlendOp]
		Cull[_CullMode]
		AlphaTest Greater[_TCut] //cut amount
		Lighting Off
		SeparateSpecular Off
		ZWrite Off

		Pass {
			Tags { "LightMode" = "ForwardBase"}
			Cull Front
			CGPROGRAM
			#include "UnityCG.cginc"
			#include "UnityLightingCommon.cginc"
			#include "AutoLight.cginc"
			#include "UnityPBSLighting.cginc"
			
			#pragma target 5.0
			#pragma vertex vertfx
			#pragma fragment fragsfx

			#define VERTEXLIGHT_ON
			#define FORWARDBASE
			#define MODE_TCUT
			#pragma multi_compile _ SHADOWS_SCREEN

			#include "ASDT2.Globals.cginc"
			#include "ASDTSFX.Bump.cginc"
			ENDCG
		}
		Pass {
			Tags { "LightMode" = "ForwardBase"}
			Cull Back
			CGPROGRAM
			#include "UnityCG.cginc"
			#include "UnityLightingCommon.cginc"
			#include "AutoLight.cginc"
			#include "UnityPBSLighting.cginc"

			#pragma target 5.0
			#pragma vertex vertfx
			#pragma fragment fragsfx

			#pragma multi_compile
			#define FORWARDBASE
			#define MODE_TCUT

			#include "ASDT2.Globals.cginc"
			#include "ASDT2.FowardBase.cginc"
			#include "ASDTSFX.Bump.cginc"
			ENDCG
		}
		Pass {
			Tags { "LightMode" = "ForwardAdd"}
			Blend One One

			CGPROGRAM
			#include "UnityCG.cginc"
			#include "UnityLightingCommon.cginc"
			#include "AutoLight.cginc"
			#include "UnityPBSLighting.cginc"
			
			#pragma target 5.0
			
			#pragma vertex vertfx
			#pragma fragment fragfxfa
			
			#pragma multi_compile_fwdadd_fullshadows
			#define MODE_TCUT

			#include "ASDT2.Globals.cginc"
			#include "ASDT2.FowardAdd.cginc"
			#include "ASDTSFX.Bump.cginc"

			ENDCG
		}

		Pass {
			Tags { "LightMode" = "ShadowCaster"}

			CGPROGRAM
			#include "UnityCG.cginc"
			#include "UnityLightingCommon.cginc"
			#include "AutoLight.cginc"
			
			#pragma target 5.0
			
			#pragma vertex vert
			#pragma fragment frag
			
			#pragma multi_compile_fwdadd_fullshadows
			#define MODE_TCUT

			#include "ASDT2.Globals.cginc"
			#include "ASDT2.shadows.cginc"

			ENDCG
		}
	} 
	//FallBack "Diffuse"
}