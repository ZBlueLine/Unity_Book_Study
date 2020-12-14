Shader "Unlit/CHapter8-AlphaBlend"
{
    Properties{
        _MainTex("Main Tex", 2D) = "white" {}
        _Color("Color", Color) = (1, 1, 1, 1)
        _AlphaScale("Alpha Scale", Range(0, 1)) = 0.5
    }
    Subshader
    {
        Tags{"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "TransparentCutout"}
        Pass
        {
            Tags{"LightMode" = "ForwardBase"}
            
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            sampler2D _MainTex;
            fixed4 _Color;
            fixed _AlphaScale;
            float4 _MainTex_ST;

            struct a2v{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };
            struct v2f{
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 worldpos : TEXCOORD2;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldpos = mul(unity_ObjectToWorld, v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }


            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 color;
                fixed3 LightDir = UnityWorldSpaceLightDir(i.worldpos);

                fixed4 texColor = tex2D(_MainTex, i.uv);
                // if((texColor.a - _Cutoff) < 0.0)
                //     discard;
                fixed3 albedo = texColor.rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(normalize(i.normal), LightDir));
                color = fixed4(ambient + diffuse, texColor.a*_AlphaScale);
                return color;
            }
            ENDCG
        }
    }
    Fallback "Transparent/VertexLit"
}
