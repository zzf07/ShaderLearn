// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unlit/Lambert1"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags {"LightMode"="ForwardBase"}

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            fixed4 _Color;
            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed3 color:COLOR;
            };
            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                fixed3 normalWorld = UnityObjectToWorldNormal(v.normal.xyz);
                //fixed3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed NdotL = max(0, dot(normalWorld, lightDir));
                o.color = _LightColor0.rgb * _Color.rgb * NdotL+UNITY_LIGHTMODEL_AMBIENT.rgb;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return fixed4(i.color, 1);
            }
            ENDCG
        }
    }
}
