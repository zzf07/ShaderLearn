Shader "Unlit/GradientFull"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" { }
        _BumpScale ("Normal Scale", Range(0, 1)) = 1.0
        _GradientMap ("Gradient Map", 2D) = "white" { }
        _LambertColor ("Lambert Color", Color) = (1, 1, 1, 1)
        _BlinnColor ("Blinn Color", Color) = (1, 1, 1, 1)
        _Num("Num",Range(0,200))=20
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

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            sampler2D _GradientMap;
            fixed3 _LambertColor;
            fixed3 _BlinnColor;
            float _Num;

            struct v2f
            {
                float4 vertex :SV_POSITION;
                float4 uv : TEXCOORD0;
                float4 wPos_change0 :TEXCOORD1;
                float4 wPos_change1 :TEXCOORD2;
                float4 wPos_change2 :TEXCOORD3;
            };
            fixed3 Blinn(in float3 normal,in float3 wPos)
            {
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - wPos );
                float3 halfDir = normalize(lightDir + viewDir);
                fixed3 Blinn = _LightColor0.rgb*_BlinnColor.rgb* pow(max(0,dot(halfDir,normal)),_Num);
                return Blinn;
            }
            v2f vert (appdata_full v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.texcoord.xy* _MainTex_ST.xy+ _MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy *_BumpMap_ST.xy +_BumpMap_ST.zw;
                float3 wPos = mul( unity_ObjectToWorld,v.vertex);
                float3 wordNormal= UnityObjectToWorldNormal(v.normal);
                float3 wordTangent = UnityObjectToWorldDir(v.tangent);
                float3 binormal = cross(normalize(wordNormal),normalize(wordTangent))* v.tangent.w;
                float3x3 change = transpose(float3x3( wordTangent,binormal,wordNormal));
                o.wPos_change0 = float4(change[0],wPos.x);
                o.wPos_change1 = float4(change[1],wPos.y);
                o.wPos_change2 = float4(change[2],wPos.z);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 packedNormal = tex2D(_BumpMap,i.uv.zw);
                float3 tangentNormal = UnpackNormal(packedNormal);
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1- saturate(dot( tangentNormal.xy, tangentNormal.xy)));
                float3 normal = float3(dot(tangentNormal,i.wPos_change0.xyz),
                                       dot(tangentNormal,i.wPos_change1.xyz),
                                       dot(tangentNormal,i.wPos_change2.xyz));
               fixed3 texColor = tex2D(_MainTex,i.uv.xy) * _LambertColor;
               float3 wPos=float3(i.wPos_change0.w,i.wPos_change1.w,i.wPos_change2.w);
               float3 lightDir = normalize( _WorldSpaceLightPos0.xyz);
               fixed halfLambertNum = dot(normal, lightDir)*0.5+0.5;
               fixed3 MainColor= tex2D( _GradientMap,float2( halfLambertNum, halfLambertNum) )*_LightColor0.rgb *texColor;
               fixed3 color = UNITY_LIGHTMODEL_AMBIENT.rgb * texColor.rgb + MainColor + Blinn(normal,wPos);
               return fixed4(color,1);
            }
            ENDCG
        }
    }
}
