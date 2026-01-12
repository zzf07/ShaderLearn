Shader "Unlit/Phong1"
{
    Properties
    {
        _Reflect ("Refect", Range(0,10)) = 1
        _Color ("Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "LightMode"= "ForwardBase" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            fixed4 _Color;
            float _Reflect;
            struct v2f
            {
                float4 pos:SV_POSITION;
                fixed3 color : COLOR0;
            };
            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 reflectDir =normalize( reflect(-lightDir,UnityObjectToWorldNormal(v.normal.xyz)));
                o.color = _LightColor0.rgb * _Color.rgb * pow(max(dot(reflectDir, viewDir), 0), _Reflect);
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
