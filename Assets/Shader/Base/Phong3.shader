Shader "Unlit/Phong3"
{
    Properties
    {
        _ColorLambert ("ColorLambert", Color) = (1, 1, 1, 1)
        _ColorPhong ("ColorPhong", Color) = (1, 1, 1, 1)
        _Num("Num",Range(0,20))=5
    }
    SubShader
    {
        Tags { "LightMode" = "ForwardBase" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            fixed4 _ColorLambert;
            fixed4 _ColorPhong;
            float _Num;
            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed3 normal : NORMAL;
                float3 wPos : TEXCOORD0;
            };
            fixed3 Lambert(in fixed3 normal)
            {
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                return _LightColor0.rgb * _ColorLambert.rgb *( dot(normal, lightDir)*0.5+0.5);
            }
            fixed3 Phong(in fixed3 normal,in fixed3 wPos)
            {
                fixed3 lightDir=normalize(_WorldSpaceLightPos0.xyz);
                fixed3 reflectDir= normalize( reflect(-lightDir,normal));
                fixed3 viewDir =normalize(_WorldSpaceCameraPos.xyz - wPos.xyz);
                return _LightColor0*_ColorPhong*pow(max(0, dot(reflectDir,viewDir)),_Num);
            }
            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex);
                o.normal=UnityObjectToWorldNormal(v.normal);
                o.wPos= mul(unity_ObjectToWorld,v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 color= UNITY_LIGHTMODEL_AMBIENT.xyz+ Lambert(i.normal) +Phong(i.normal,i.wPos);
                return fixed4(color,1);
            }
            ENDCG
        }
    }
}
