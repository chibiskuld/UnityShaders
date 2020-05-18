﻿Shader "Skuld/Experiments/Neuron Simulator Echo"
{
    Properties
    {
		_MainTex("Main Texture", 2D) = "white" {}
	}
	
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100
		Cull Back

        Pass
        {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fwdbase

			#include "UnityCG.cginc"


			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _MainTex_TexelSize;

			v2f vert (appdata v)
			{
				//if (any(_ScreenParams.xy != abs(_MainTex_TexelSize.zw))) {
				v2f o;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				if (any(_ScreenParams.xy != abs(_MainTex_TexelSize.zw))) 
				{
					o.vertex = 0;
				}
				else {
					o.vertex = UnityObjectToClipPos(v.vertex);
				}
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			ENDCG
        }
    }
}
