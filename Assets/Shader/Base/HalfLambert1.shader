Shader "Unlit/HalfLambert1"
{
    Properties
    {
        _Color ("Color", Color) = (0, 0, 0, 0)
        _Texture ("Texture", 2D) = "white" { }
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
                float4 pos:SV_POSITION;
                fixed3 color:COLOR;
                float4 uv : TEXCOORD0;
            };
            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                fixed3 normal = UnityObjectToWorldNormal(v.normal).xyz;
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 halfLambert = dot(normal, lightDir) * 0.5 + 0.5;
                o.color =_LightColor0.rgb * _Color.rgb * halfLambert+UNITY_LIGHTMODEL_AMBIENT;
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return fixed4(i.color*tex2D(_Texture,i.uv).rgb, 1);
            }
            ENDCG
        }
    }
}
