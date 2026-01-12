Shader "Unlit/Bloom"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LThreshold("L Threshold",Range(0,2)) = 1
        _BloomColor("Bloom Color",Color) = (1,1,1,1)
        _Bloom("Bloom",2D) = "white" {}
        _BlurSpread("BlurSpread",Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        ZWrite Off
        Cull Off
        ZTest Always
        
        CGINCLUDE
        
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half4 _MainTex_TexelSize;
            float _BlurSpread;

            struct v2f_blur
            {
                half2 uv[5] : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            fixed4 fragBlur(v2f_blur i) : SV_Target
            {
                float weight[3] = {0.4026,0.2442,0.0545};
                fixed3 sum = tex2D(_MainTex,i.uv[0]) * weight[0];

                for(int j = 1; j<3 ; j++)
                {
                    sum += tex2D(_MainTex,i.uv[j*2-1]) * weight[1];
                    sum += tex2D(_MainTex,i.uv[j*2]) * weight[2];
                }
                return fixed4(sum,1);
            }

        ENDCG

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            float _LThreshold;
            fixed4 _BloomColor;

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata_img v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }
            
            fixed Luminance(in fixed4 color)
            {
                return color.r*0.2125 + 0.7154*color.g + 0.0721*color.b;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 initColor = tex2D(_MainTex,i.uv);
                fixed val = clamp(Luminance(initColor) - _LThreshold,0,1);
                return fixed4(initColor.rgb * val * _BloomColor.rgb , 1);
            }
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vertHorizontal
            #pragma fragment fragBlur

            v2f_blur vertHorizontal(appdata_img v)
            {
                v2f_blur o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                float2 uv = v.texcoord;
                o.uv[0] = uv + half2(_MainTex_TexelSize.x * 0,0) * _BlurSpread;
                o.uv[1] = uv + half2(_MainTex_TexelSize.x * 1,0) * _BlurSpread;
                o.uv[2] = uv - half2(_MainTex_TexelSize.x * 1,0) * _BlurSpread;
                o.uv[3] = uv + half2(_MainTex_TexelSize.x * 2,0) * _BlurSpread;
                o.uv[4] = uv - half2(_MainTex_TexelSize.x * 2,0) * _BlurSpread;
                return o;
            }
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vertVertical
            #pragma fragment fragBlur

            v2f_blur vertVertical(appdata_img v)
            {
                v2f_blur o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                float2 uv = v.texcoord;
                o.uv[0] = uv + half2(0,_MainTex_TexelSize.y * 0) * _BlurSpread;
                o.uv[1] = uv + half2(0,_MainTex_TexelSize.y * 1) * _BlurSpread;
                o.uv[2] = uv - half2(0,_MainTex_TexelSize.y * 1) * _BlurSpread;
                o.uv[3] = uv + half2(0,_MainTex_TexelSize.y * 2) * _BlurSpread;
                o.uv[4] = uv - half2(0,_MainTex_TexelSize.y * 2) * _BlurSpread;
                return o;
            }
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            sampler2D _Bloom;

            struct v2f_bloom
            {
                float4 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f_bloom vert(appdata_img v)
            {
                v2f_bloom o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.texcoord;
                o.uv.zw = v.texcoord;
                #if UNITY_UV_STARTS_AT_TOP
                    if( _MainTex_TexelSize.y<0)
                        o.uv.w = 1 - o.uv.w;
                #endif
                return o;
            }

            fixed4 frag (v2f_bloom i) : SV_Target
            {
                return tex2D(_MainTex,i.uv.xy) + tex2D(_Bloom,i.uv.zw);
            }
            ENDCG
        }
    }
    Fallback Off
}
