Shader "Unlit/Mask"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MainColor ("Main Color", Color) = (1, 1, 1, 1)
        _BumpMap ("Normal Map", 2D) = "bump" { }
        _BumpScale ("Normal Scale", Range(0, 5)) = 1.0
        _MaskMap ("Mask Map", 2D) = "white" { }
        _MaskScale ("Mask Scale", Range(0, 10)) = 1.0
        _SpecularColor ("Specular Color", Color) = (1, 1, 1, 1)
        _SpecularNum ("Specular Number", Range(0, 200)) = 20
        _GradientTex ("GradientTex", 2D) = "white" { }
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
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            sampler2D _MaskMap;
            float _MaskScale;
            fixed4 _MainColor;
            fixed4 _SpecularColor;
            float _SpecularNum;
            sampler2D _GradientTex;

            struct v2f
            {
                float4 vertex :SV_POSITION;
                float4 uv : TEXCOORD0;
                float4 wPos_TBN0 : TEXCOORD1;
                float4 wPos_TBN1 : TEXCOORD2;
                float4 wPos_TBN2 : TEXCOORD3;
            };
            fixed3  SpecularBlinn(in float3 normal,in float3 wPos)
            {
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - wPos);
                float3 halfDir = normalize(lightDir + viewDir);
                fixed3 specular = _LightColor0.rgb * _SpecularColor.rgb * pow(max(0, dot(halfDir, normal)), _SpecularNum);
                return specular;
            }
            v2f vert (appdata_full v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
                float3 wPos = mul(unity_ObjectToWorld, v.vertex);
                float3 wordNormal = UnityObjectToWorldNormal(v.normal);
                float3 wordTangent = UnityObjectToWorldDir(v.tangent);
                float3 binormal = cross(wordNormal, wordTangent) * v.tangent.w;
                float3x3 TBN = transpose(float3x3(wordTangent, binormal, wordNormal));
                o.wPos_TBN0 = float4(TBN[0], wPos.x);
                o.wPos_TBN1 = float4(TBN[1], wPos.y);
                o.wPos_TBN2 = float4(TBN[2], wPos.z);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 wPos = float3(i.wPos_TBN0.w, i.wPos_TBN1.w, i.wPos_TBN2.w);
                float4 packedTanget = tex2D(_BumpMap, i.uv.zw);
                float3 tangentNormal = UnpackNormal(packedTanget);
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
                float3 normal = float3(dot(tangentNormal, i.wPos_TBN0.xyz),
                                       dot(tangentNormal, i.wPos_TBN1.xyz),
                                       dot(tangentNormal, i.wPos_TBN2.xyz));
                float maskNum = tex2D(_MaskMap, i.uv.xy).r * _MaskScale;
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 mainColor = tex2D(_MainTex, i.uv.xy).rgb * _MainColor;
                fixed halfLambertNum = dot(normal, lightDir) * 0.5 + 0.5;
                float3 Lambert = _LightColor0.rgb * mainColor * tex2D(_GradientTex,float2( halfLambertNum,halfLambertNum)) ;
                fixed3 SpecularColor = SpecularBlinn(normal, wPos) * maskNum;
                fixed3 color = UNITY_LIGHTMODEL_AMBIENT.rgb * mainColor+ Lambert + SpecularColor;
                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
}
