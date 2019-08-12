﻿Shader "Skuld/Grabpass/Glass"
{
	Properties{
		_Depth("Depth", Range(-10,10)) = 1
		_Focal("Focal",Range(-10,10)) = 0
	}
	SubShader {
        // Draw ourselves after all opaque geometry
        Tags { "Queue" = "Transparent" }

        // Grab the screen behind the object into _BackgroundTexture
        GrabPass
        {
            "_Background"
        }
		Pass
        {
			Cull Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct IO
            {
				float2 uv : TEXCOORD0;
				float4 position : SV_POSITION;
				float3 worldNormal : TEXCOORD2;
                float4 grabPosition : TEXCOORD3;
				float4 objectPosition: TEXCOORD4;
				float4 worldPosition : TEXCOORD5;
				float3 normal : NORMAL;
            };

			struct APPInput
			{
				float4 position : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};
			
			float _Depth;
			float _Focal;
            sampler2D _Background;

			/*
			fixed4 shiftColor( fixed4 inColor, float shift )
			{
				float r = shift * 0.01745329251994329576923690768489;
				float u = cos(r);
				float w = sin(r);
				fixed4 ret;
				ret.r = (.299+.701 * u+.168 * w)*inColor.r
					+ (.587-.587 * u+.330 * w)*inColor.g
					+ (.114-.114 * u-.497 * w)*inColor.b;
				ret.g = (.299-.299 * u-.328 * w)*inColor.r
					+ (.587+.413 * u+.035 * w)*inColor.g
					+ (.114-.114 * u+.292 * w)*inColor.b;
				ret.b = (.299-.3 * u+1.25 * w)*inColor.r
					+ (.587-.588 * u-1.05 * w)*inColor.g
					+ (.114+.886 * u-.203 * w)*inColor.b;	
				ret[3] = inColor[3];
				ret.a = 1;
				return ret;
			}
			*/

            IO vert(APPInput vertex) {
                IO output;
				output.objectPosition = vertex.position;
				output.worldPosition = mul(unity_ObjectToWorld,vertex.position);
				output.uv = vertex.uv;
				output.normal = vertex.normal;
				output.worldNormal = normalize( UnityObjectToWorldNormal( vertex.normal ));

				output.position = UnityObjectToClipPos( vertex.position );

				float4 grabPosition = vertex.position;
				grabPosition = UnityObjectToClipPos(grabPosition);
				output.grabPosition = ComputeGrabScreenPos(grabPosition);

				return output;
            }

            half4 frag(IO vertex) : SV_Target
            {
				float3 viewDirection = normalize(vertex.worldPosition - _WorldSpaceCameraPos);
				float scale = (_Focal-saturate(-dot(viewDirection, vertex.worldNormal))+_Focal) * _Depth;
				float2 uv = vertex.grabPosition.xy / vertex.grabPosition.w;
				float4 offset = ComputeGrabScreenPos(UnityObjectToClipPos(float3(0,0,0)));
				offset.xy /= offset.w;
				uv.xy -= offset.xy;
				uv *= scale;
				uv.xy += offset.xy;
				
				half4 baseColor = tex2D(_Background, uv);
				
					
                return baseColor;
            }
            ENDCG
        }
    } 
}