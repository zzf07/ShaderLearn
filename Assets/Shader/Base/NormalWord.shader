Shader "Unlit/NormalWord"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap ("BumpMap", 2D) = "white" { }
        _LambertColor ("LambertColor", Color) = (1, 1, 1, 1)
        _BlinnColor ("BlinnColor", Color) = (1, 1, 1, 1)
        _Num ("Num", Range(0, 200)) = 20
        _BumpScale ("BumpScale", Range(0, 1)) = 1
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

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 uv : TEXCOORD0;//¶þºÏÒ»
                //float3 wPos : TEXCOORD1;
                //float3x3 change: TEXCOORD2;
                float4 wPos_change0 : TEXCOORD1;
                float4 wPos_change1 : TEXCOORD2;
                float4 wPos_change2 : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            fixed3 _LambertColor;
            fixed3 _BlinnColor;
            float _Num;
            float _BumpScale;

            fixed3 Lambert(in float3 normal)
            {
                fixed3 Lambert = _LightColor0.rgb * _LambertColor 
                                    * max(dot(normal, normalize(_WorldSpaceLightPos0.xyz)), 0);
                return Lambert;

            }
            fixed3 Blinn(in float3 normal,in float3 wPos)
            {
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - wPos);
                float3 halfDir = normalize(normalize(_WorldSpaceLightPos0.xyz) + viewDir);
                fixed3 Blinn = _LightColor0.rgb * _BlinnColor.rgb * pow(max(0, dot(halfDir, normal)), _Num);
                return Blinn;
            }
            v2f vert (appdata_full v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
                float3 wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                float3 binormal = cross(normalize(worldNormal), normalize(worldTangent)) * v.tangent.w;
                float3x3 change = transpose( float3x3(worldTangent.xyz, binormal, worldNormal));
                o.wPos_change0 = float4(change[0],wPos.x);
                o.wPos_change1 = float4(change[1], wPos.y);
                o.wPos_change2 = float4(change[2], wPos.z);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 packedNormal = tex2D(_BumpMap, i.uv.zw);
                float3 tangentNormal = UnpackNormal(packedNormal);
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
                float3 worldNormal = float3(dot(tangentNormal, i.wPos_change0.xyz),
                                            dot(tangentNormal, i.wPos_change1.xyz), 
                                            dot(tangentNormal, i.wPos_change2.xyz));
                float3 texColor = tex2D(_MainTex, i.uv.xy).rgb ;
                float3 color = UNITY_LIGHTMODEL_AMBIENT.rgb * texColor + Lambert(worldNormal)*texColor 
                                + Blinn(worldNormal,float3( i.wPos_change0.w,i.wPos_change1.w,i.wPos_change2.w));
                return fixed4(color, 1);
            }
            ENDCG
        }
    }
}
