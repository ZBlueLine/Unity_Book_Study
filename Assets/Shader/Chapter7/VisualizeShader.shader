Shader "zzyCustom/VisualizeShader"
{
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            struct a2v
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                fixed4 color : COLOR;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                fixed4 color : COLOR;
                float4 scre : scrPos:TEXCOORD1;
            };
            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.scre = ComputeScreenPos(o.pos);
                o.uv = float4(v.texcoord, 0, 1);
                o.color = v.color;
                return o;
            }

            half4 frag( v2f i ) : SV_Target {
                return fixed4(i.scre.www, 1);
                half4 c = frac( i.uv );
                if (any(saturate(i.uv) - i.uv))
                    c.b = 0.5;
                return c;
            }

            ENDCG
        }
    }
    
}