Shader "Unlit/MirrorBase"
{
    Properties
    {
        _RenderTex ("RenderTexture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                //SHADOW_COORDS(1)
            };

            sampler2D _RenderTex;
            float4 _RenderTex_ST;

            v2f vert (appdata_full v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord.xy * _RenderTex_ST.xy + _RenderTex_ST.zw;
                //TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                i.uv.x = 1-i.uv.x;
                fixed4 col = tex2D(_RenderTex,i.uv);
                return col;
            }
            ENDCG
        }
    }
    Fallback "Reflective/VertexLit"
}
