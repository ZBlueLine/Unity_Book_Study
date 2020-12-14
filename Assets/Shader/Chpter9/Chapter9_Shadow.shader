// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

Shader "zzyCustom/Chapter9/Chapter9_Shadow"
{
    Properties{
        _Color("DiffuseColor", Color) = (1, 1, 1, 1)
        _Specular("S[ecularColor", Color) = (1, 1, 1, 1)
        _Gloss("Gloss", Range(8.0, 256)) = 20.0
    }
    Subshader
    {
		Tags { "RenderType"="Opaque" }
        Pass
        {
            Tags{"LightMode" = "ForwardBase"}
            CGPROGRAM
            #include "Lighting.cginc"
            #include "AutoLight.cginc" 
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            fixed4 _Color;
            fixed4 _Specular;
            float _Gloss;

            struct a2v{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f{
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 Normal : TEXCOORD1;
                SHADOW_COORDS(2)
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                o.Normal = UnityObjectToWorldNormal(v.normal);

                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                TRANSFER_SHADOW(o);

                return o;
            }
            
            fixed4 frag(v2f i) : SV_Target
            {
                float3 worldNormal = normalize(i.Normal);

                float3 LightDir = normalize(_WorldSpaceLightPos0.xyz);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0, dot(worldNormal, LightDir));
                

                float3 ViewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                float3 halfDir = normalize(LightDir + ViewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);
                
                fixed atten = 1.0;
                fixed shadow = SHADOW_ATTENUATION(i);

                return fixed4(ambient + shadow * (diffuse + specular) * atten, 1);
            }
            ENDCG
        }
        Pass
        {
            Tags{"LightMode" = "ForwardAdd"}
            Blend One One
            CGPROGRAM
            #pragma multi_compile_fwdadd
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            #pragma vertex vert
            #pragma fragment frag

            fixed4 _Color;
            fixed4 _Specular;
            float _Gloss;

            struct a2v{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f{
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 Normal : TEXCOORD1;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                o.Normal = UnityObjectToWorldNormal(v.normal);

                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                return o;
            }
            
            fixed4 frag(v2f i) : SV_Target
            {
                //float3 LightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                float3 worldNormal = normalize(i.Normal);

                #ifdef USING_DIRECTIONAL_LIGHT
                    float3 LightDir = normalize(_WorldSpaceLightPos0.xyz);
                #else
                    float3 LightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
                #endif

                fixed3 albedo = _Color.rgb;

                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(LightDir, worldNormal));


                //fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                #ifdef USING_DIRECTIONAL_LIGHT
                    fixed atten = 1.0;
                #else
                    float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1)).xyz;
                    fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
                #endif
                

                float3 ViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 halfDir = normalize(LightDir + ViewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);
                return fixed4((diffuse + specular) * atten, 1);
            }


            ENDCG
        }
    }
    Fallback "Specular"
}
