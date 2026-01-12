Shader "Unlit/MoreLight"
{
    Properties
    {
        _MainColor ("Main Color", Color) = (1, 1, 1, 1)
        _SpecularColor ("Specular Color", Color) = (1, 1, 1, 1)
        _SpecNum ("Specular Number", Range(0, 200)) = 20
    }
    SubShader
    {

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"


            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            float4 _MainColor;
            float4 _SpecularColor;
            float _SpecNum;

            fixed3 SpecularBlinn(in float3 normal, in float3 wPos)
            {
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - wPos);
                float3 halfDir = normalize(lightDir + viewDir);
                fixed3 specular = _LightColor0.rgb * _SpecularColor.rgb * pow(max(0, dot(halfDir, normal)), _SpecNum);
                return specular;
            }

            fixed3 MainColor(in float3 normal)
            {
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float NdotL = dot(normal, lightDir) * 0.5 + 0.5;
                fixed3 diffuse = _LightColor0.rgb * _MainColor.rgb * NdotL;
                return diffuse;
            }

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 COLOR = MainColor(normalize(i.normal)) + SpecularBlinn(normalize(i.normal), i.worldPos);
                return fixed4(COLOR, 1.0);
            }
            ENDCG
        }
        Pass
        {
            Tags { "LightMode" = "ForwardAdd" }
            Blend One One
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fwdadd

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"


            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            float4 _MainColor;
            float4 _SpecularColor;
            float _SpecNum;

            fixed3 SpecularBlinn(in float3 normal, in float3 wPos,in float3 lightDir)
            {
                //float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - wPos);
                float3 halfDir = normalize(lightDir + viewDir);
                fixed3 specular = _LightColor0.rgb * _SpecularColor.rgb * pow(max(0, dot(halfDir, normal)), _SpecNum);
                return specular;
            }

            fixed3 Diffuse(in float3 normal,in float3 lightDir)
            {
                //float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float NdotL = dot(normal, lightDir) * 0.5 + 0.5;
                fixed3 diffuse = _LightColor0.rgb * _MainColor.rgb * NdotL;
                return diffuse;
            }

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 lightDir;

                #if defined(_DIRECTIONAL_LIGHT)
                    lightDir = normalize(_WorldSpaceLightPos0.xyz);
                #else
                    lightDir= normalize( _WorldSpaceLightPos0.xyz - i.worldPos);
                #endif

                fixed3 diffuse = Diffuse(normalize(i.normal), lightDir);
                fixed3 specular = SpecularBlinn(normalize(i.normal), i.worldPos, lightDir);

                fixed atten=1;

                #if defined(_POINT_LIGHT)
                    fixed3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1)).xyz;
                    atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).xx).UNITY_ATTEN_CHANNEL;
                #elif defined(SPOT)
                    fixed4 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1));
                    atten = (lightCoord.z > 0) *
                            tex2D(_LightTexture0, lightCoord.xy/ lightCoord.w + 0.5).w *
                            tex2D(_LightTextureB0, dot(lightCoord.xyz, lightCoord.xyz).rr).UNITY_ATTEN_CHANNEL;
                #endif
                fixed3 COLOR = (diffuse + specular) * atten;
                return fixed4(COLOR, 1.0);
            }
            ENDCG
        }
    }
}
