Shader "Unlit/Blinn_Phong1"
{
    Properties
    {
        _BlinnColor ("BlinnColor", Color) = (1, 1, 1, 1)
        _LambertColor ("LambertColor", Color) = (1, 1, 1, 1)
        _Num ("Num", Range(0, 20)) = 5
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
            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed3 normal : NORMAL;
                fixed3 tangent : TANGENT;
                float3 wPos : TEXCOORD0;
            };

            fixed4 _BlinnColor;
            fixed4 _LambertColor;
            float _Num;
            fixed3 Blinn(in fixed3 normal,in fixed3 wPos)
            {
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - wPos.xyz);
                fixed3 halfDir = normalize(lightDir + viewDir);
                return _LightColor0.rgb * _BlinnColor.rgb * pow(max(0, dot(halfDir, normal)), _Num);
            }
            fixed3 Lambert(in fixed3 normal)
            {
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                return _LightColor0.rgb * _LambertColor.rgb * (dot(normal, lightDir) * 0.5 + 0.5);
            }
            v2f vert (appdata_full v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.tangent = UnityObjectToWorldDir(v.tangent);
                o.wPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 color = UNITY_LIGHTMODEL_AMBIENT.xyz + Lambert(i.normal) + Blinn(i.normal, i.wPos);
                return fixed4(color, 1);
            }
            ENDCG
        }
    }
}
