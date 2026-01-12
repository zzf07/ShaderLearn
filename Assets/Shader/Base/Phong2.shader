Shader "Unlit/Phong2"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _Num ("Shininess", Range(1, 256)) = 32
         _MainTex ("Texture", 2D) = "white" {}
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
            float _Num;
            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed3 normal:NORMAL;
                float3 wPos : TEXCOORD0;
            };
            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normal = normalize( UnityObjectToWorldNormal(v.normal)).xyz;
                o.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.wPos.xyz);
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 reflectDir = reflect(-lightDir, i.normal);
                fixed3 halfLambert = _LightColor0.rgb * _Color.rgb * dot(i.normal.xyz, lightDir) * 0.5 + 0.5;
                fixed3 Phong = _LightColor0.rgb * _Color.rgb * pow(max(0, dot(viewDir, reflectDir)), _Num);
                return fixed4(Phong + halfLambert + UNITY_LIGHTMODEL_AMBIENT.rgb , 1);
            }
            ENDCG
        }
    }
}
