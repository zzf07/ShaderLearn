Shader "Unlit/Glass++"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" { }
        _CubemapTex("Cubemap Texture",Cube) = "white" {}
        _Reflectivity("Reflectivit",Range(0,1)) = 1
        _Distortion("Distortion",Range(0,10)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent"}
        GrabPass{}
        Pass
        {
            Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;//MainTexUV && BumpTexUV
                float3x3 TBN : TEXCOORD1;
                float3 wPos : TEXCOORD4;
                float4 screenPos : TEXCOORD5;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            sampler2D _GrabTexture;
            samplerCUBE _CubemapTex;
            float _Reflectivity;
            float _Distortion;

            v2f vert (appdata_full v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
                float3 wPos = mul( unity_ObjectToWorld,v.vertex);
                float3 wNormal = UnityObjectToWorldNormal(v.normal);
                float3 wTangent = UnityObjectToWorldDir(v.tangent);
                float3 wBitangent = cross(normalize( wNormal),normalize( wTangent)) * v.tangent.w;
                float3x3 TBN = transpose(float3x3(wTangent,wBitangent,wNormal));
                o.screenPos = ComputeGrabScreenPos(o.pos);
                o.wPos = wPos;
                o.TBN = TBN;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3x3 TBN = i.TBN;
                float3 wViewDir = normalize( UnityWorldSpaceViewDir(i.wPos));
                fixed4 texColor = tex2D(_MainTex, i.uv.xy);
                float4 packedNormal = tex2D(_BumpMap,i.uv.zw);
                float3 tangentNormal = UnpackNormal(packedNormal);

                float3 wNormal = float3(dot(tangentNormal , TBN[0]),
                                        dot(tangentNormal , TBN[1]),
                                        dot(tangentNormal , TBN[2]));
                //反射
                float3 wReflectDir = reflect(-wViewDir,wNormal);
                fixed4 reflectColor = texCUBE(_CubemapTex,wReflectDir) * texColor;
                //折射
                float2 offset = tangentNormal.xy  * _Distortion;
                i.screenPos.xy = offset * i.screenPos.z + i.screenPos.xy;
                float2 screenUV = i.screenPos.xy/i.screenPos.w;
                fixed4 refractColor = tex2D(_GrabTexture,screenUV);
                //菲涅尔反射率Schiick近似等式
                fixed R = _Reflectivity + (1- _Reflectivity)* pow(1-dot(normalize(wNormal),normalize(wViewDir)),5);
                fixed4 color = lerp( refractColor,reflectColor,R);
                return color;
            }
            ENDCG
        }
    }
}
