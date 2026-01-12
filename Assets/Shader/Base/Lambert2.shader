Shader "Unlit/Lambert2"
{
    Properties
    {
        _Color ("Color", Color) = (0,0,0,0)
        _Texture ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "LightMode"="ForwardBase" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            fixed4 _Color;
            sampler2D _Texture;
            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 normal:NORMAL;
                float2 uv:TEXCOORD0;
            };
            
            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normal = mul(unity_ObjectToWorld, v.normal);
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 normal = normalize(i.normal.xyz);
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 color = UNITY_LIGHTMODEL_AMBIENT.rbg + _LightColor0.rgb * _Color.rgb * max(0, dot(normal, lightDir)) * tex2D(_Texture, i.uv).rgb;
                return fixed4(color, 1);
            }
            ENDCG
        }
    }
}
