Shader "Unlit/MusicView"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MaxHeight("Max Height",Range(0,1)) = 1
        _Color("Color",Color) = (1,1,1,1)
        _MaxColor("Max Color",Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100
        ZWrite Off
        Blend One One
        Cull Off
        //Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Audio[8];
            float _MaxHeight;
            fixed4 _Color;
            fixed4 _MaxColor;

            v2f vert (appdata_img v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv =v.texcoord;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float x = 1.0/8.0;
                float h;
                for(int j = 0;j<8;j++)
                {
                    if(i.uv.x >= x * j && i.uv.x < x * (j+1) )
                        h = _Audio[j];
                }
                fixed4 color;
                if(i.uv.y < h * _MaxHeight)
                    color = lerp(_Color,_MaxColor,i.uv.y/_MaxHeight);
                else 
                    color = fixed4(0,0,0,0);
                return color;
            }
            ENDCG
        }
    }
}
