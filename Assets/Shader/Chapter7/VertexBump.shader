// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "zzyCustom/VertexPhong"
{
	Properties{
		_Diffuse("Diffuse", Color) = (1, 1, 1, 1)
	}
	SubShader{
		Pass{
			Tags { "LightMode"="ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			#include "UnityLightingCommon.cginc"
			fixed4 _Diffuse;

			float random (float2 uv)
			{
				return frac(sin(dot(uv,float2(12.9898,78.233)))*43758.5453123);
			}
			struct a2v
			{
				float4 pos : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed3 color : COLOR;
			};
			v2f vert(a2v v)
			{
				v2f o;
				//v.pos += float4(v.normal * random(v.pos.xy), 1);
				o.pos = UnityObjectToClipPos(v.pos);
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 worldNormal = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldLight, worldNormal)); 
				o.color = diffuse + ambient;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				return fixed4(i.color, 1.0);
			}
			ENDCG
		}
	}
}
