Shader "zzyCustom/Chapter7/MaskTexture"
{
    Properties{
        _Color("Color Tint", Color) = (1, 1, 1, 1)
        _Specular("_Specular", Color) = (1, 1, 1, 1)
        _SpecularMask("_Specular Mask", 2D) = "white" {}
        _SpecularScale("Specular Scale", Float) = 1.0
        _Gloss("Gloss", Range(8.0, 256)) = 20
        _BumpMap("Bump Map", 2D) = "bump" {}
        _BumpScale("Bump Scale", Float) = 1.0
        _MainTex("Main Texture", 2D) = "white" {}
    }
    Subshader{
        Pass{
            Tags {"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            fixed4 _Color;
            fixed4 _Specular;
            sampler2D _SpecularMask;
            float _SpecularScale;
            float _Gloss;
            sampler2D _BumpMap;
            float _BumpScale;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            struct a2v{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0; 
            };

            struct v2f{
                float4 pos : SV_POSITION;
                float3 ViewDir : TEXCOORD0;
                float3 LightDir : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                TANGENT_SPACE_ROTATION;
                o.ViewDir = mul(rotation, ObjSpaceViewDir(v.vertex).xyz);
                o.LightDir = mul(rotation, ObjSpaceLightDir(v.vertex).xyz);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 tangentLightDir = normalize(i.LightDir);
                float3 tangentViewDir = normalize(i.ViewDir);
                float3 tangentnormal = UnpackNormal(tex2D(_BumpMap, i.uv));
                tangentnormal.xy *= _BumpScale;
                tangentnormal.z = sqrt(1.0 - saturate(dot(tangentnormal.xy, tangentnormal.xy)));

                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(tangentnormal, tangentLightDir));
                fixed3 halfDir = normalize(tangentViewDir + tangentLightDir);

                float specularMask = tex2D(_SpecularMask, i.uv).r * _SpecularScale;

                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(halfDir, tangentnormal)), _Gloss) * specularMask;

                return fixed4(ambient + diffuse + specular, 1.0);
            }

            ENDCG
        }
    }

}
