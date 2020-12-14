// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "zzyCustom/HalfLambert"
{
	Properties{
		_Diffuse("Diffuse", Color) = (1, 1, 1, 1)
	}
	SubShader{
		Pass{
			Tags {"LightMode"="ForwardBase" "RenderType"="Opaque"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			#include "UnityLightingCommon.cginc"
			fixed4 _Diffuse;

			struct a2v
			{
				float4 pos : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
                fixed3 worldNormal : TEXCOORD0;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.worldNormal = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));
				o.pos = UnityObjectToClipPos(v.pos);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * (0.5*dot(worldLight, worldNormal) + 0.5); 
				fixed3 color = diffuse + ambient;
				return fixed4(color, 1.0);
			}
			ENDCG
		}
	}
}
