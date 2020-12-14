// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/DepthGrayscale" { 
    Properties{
        _MainTex("Main Tex", 2D) = "" {}
    } 
    SubShader {  
        Tags { "RenderType"="Opaque" }  
          
        Pass{  
            CGPROGRAM  
            #pragma vertex vert  
            #pragma fragment frag  
            #include "UnityCG.cginc"  
            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;  
              
            struct v2f {  
               float4 pos : SV_POSITION;  
               float4 scrPos:TEXCOORD1;  
               float2 uv : TEXCOORD2;
            };  
              
            //Vertex Shader  
            v2f vert (appdata_base v){  
                v2f o;   
                o.pos = UnityObjectToClipPos (v.vertex);  
                o.uv.x=(o.pos.x+o.pos.w)/2;
                o.uv.y=(o.pos.y+o.pos.w)/2;
                // o.scrPos=ComputeScreenPos(o.pos/o.pos.w);  //变换到[0, w];
                //o.scrPos /= o.scrPos.w;
                return o;  
            }  

            //Fragment Shader  i
            float4 frag (v2f i) : COLOR{  
                return fixed4(_ProjectionParams.x + 1, _ProjectionParams.x + 1, _ProjectionParams.x + 1, 1.0);
                return tex2D(_MainTex, i.uv/i.pos.w);
                //float depthValue =Linear01Depth (tex2Dproj(_MainTex,UNITY_PROJ_COORD(i.scrPos)).r);  
                // fixed4 albedo = tex2D(_MainTex, i.scrPos).rgba;
                // return albedo;
                //return half4(depthValue,depthValue,depthValue,1);   
            }  
            ENDCG  
        }  
    }  
    FallBack "Diffuse"  
}  