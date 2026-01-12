Shader "Unlit/HalfLambert2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1, 1, 1, 1)
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
            sampler2D _MainTex;
            fixed4 _Color;
            struct v2f
            {
                float4 pos:SV_POSITION;
                float3 normal:NORMAL;
                float4 uv : TEXCOORD0;
            };
            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal.xyz);
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 halfLambert = dot(i.normal.xyz, lightDir) * 0.5 + 0.5;
                return fixed4(halfLambert * _LightColor0.rgb * _Color.rgb * tex2D(_MainTex, i.uv).rgb + UNITY_LIGHTMODEL_AMBIENT, 1);
            }
            ENDCG
        }
    }
}
