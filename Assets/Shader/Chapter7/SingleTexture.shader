// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "zzyCustom/Chapter/SingleTexture"
{
    Properties{
        _Color("Color", Color) = (1, 1, 1, 1)
        _MainTex("Main Tex", 2D) = "white" {}
        _Specular("Specular", Color) = (1, 1, 1, 1)
        _Gloss("Gloss", Range(8.0, 256)) = 20
    }
    SubShader{

        Pass{
            Tags{"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Specular;
            float _Gloss;
            
            struct a2v{
                float4 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
                float4 vertex : POSITION;
            };
            struct v2f{
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 worldPos : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 LightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 color;
                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                float3 ViewDir =normalize( _WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                float3 halfNormal = normalize(ViewDir + LightDir);
                
                fixed3 diffuse = _LightColor0.rgb * albedo.rgb * max(0, dot(i.worldNormal, LightDir));
                fixed3 specular = _LightColor0.rgb * _Specular.rbg * pow(max(0, dot(i.worldNormal, halfNormal)), _Gloss);
                color = diffuse + ambient + specular;
                return fixed4(color, 1.0);
            }

            ENDCG
        }
    }
}
