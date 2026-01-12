Shader "Unlit/ComplexLight"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" { }
        _Bump_Scale ("Normal Scale", Float) = 1.0
        _MaskMap ("Mask Map", 2D) = "white" { }
        _MaskScale ("Mask Scale", Float) = 1.0
        _MainColor ("Main Color", Color) = (1, 1, 1, 1)
        _SpecularColor ("Specular Color", Color) = (1, 1, 1, 1)
        _SpecNum ("Specular Number", Range(0, 200)) = 20
        _GradientFullMap ("Gradient Full Map", 2D) = "white" { }
        _SpecularPower("Specular Power",Range(0,1)) = 1
    }
    SubShader
    {
        

        Pass
        {
            Tags { "LightMode"="ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float4 TBN_wPos0 : TEXCOORD1;
                float4 TBN_wPos1 : TEXCOORD3;
                float4 TBN_wPos2 : TEXCOORD4;
                SHADOW_COORDS(2)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _Bump_Scale;
            sampler2D _MaskMap;
            float _MaskScale;
            float4 _MainColor;
            float4 _SpecularColor;
            float _SpecNum;
            sampler2D _GradientFullMap;
            float _SpecularPower;

            fixed3 SpecularBlinn(in float3 normal, in float3 wPos,in float3 lightDir)
            {
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - wPos);
                float3 halfDir = normalize(lightDir + viewDir);
                fixed3 specular=_LightColor0.rgb *_SpecularColor.rgb * pow(max(0,dot(normalize(normal),halfDir)),_SpecNum);
                return specular* _SpecularPower;
            }
            v2f vert (appdata_full v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
                float3 wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                float3 wNormal = UnityObjectToWorldNormal(v.normal);
                float3 wTangent = UnityObjectToWorldDir(v.tangent.xyz);
                float3 wBitangent = cross(wNormal, wTangent) * v.tangent.w;
                float3x3 TBN = transpose(float3x3(wTangent, wBitangent, wNormal));
                o.TBN_wPos0 = float4(TBN[0], wPos.x);
                o.TBN_wPos1 = float4(TBN[1], wPos.y);
                o.TBN_wPos2 = float4(TBN[2], wPos.z);
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 wPos = float3(i.TBN_wPos0.w, i.TBN_wPos1.w, i.TBN_wPos2.w);
                float4 packedTangent = tex2D(_BumpMap, i.uv.zw);
                float3 normalT = UnpackNormal(packedTangent);
                normalT.xy *= _Bump_Scale;
                normalT.z = sqrt(saturate(1 - dot(normalT.xy, normalT.xy)));
                float3 normal=float3(dot(i.TBN_wPos0.xyz, normalT),
                                     dot(i.TBN_wPos1.xyz, normalT),
                                     dot(i.TBN_wPos2.xyz, normalT));
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed diffuseNum = dot(normal, lightDir) * 0.5 + 0.5;
                UNITY_LIGHT_ATTENUATION(atten, i, wPos);
                fixed3 specular = SpecularBlinn(normal, wPos, lightDir) * tex2D(_MaskMap, i.uv.xy ).r*_MaskScale;
                fixed3 mainColor = tex2D(_MainTex, i.uv.xy).rgb * _MainColor;
                fixed3 diffuse = _LightColor0.rgb * mainColor.rgb * tex2D(_GradientFullMap, float2(diffuseNum, diffuseNum)).rgb;
                fixed3 color = UNITY_LIGHTMODEL_AMBIENT.rgb * mainColor + (diffuse + specular) * atten;
                return float4(color, 1.0);
            }
            ENDCG
        }
        Pass
        {
            Tags { "LightMode"="ForwardAdd" }
            Blend One One
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fwdadd_fullshadows

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float4 TBN_wPos0 : TEXCOORD1;
                float4 TBN_wPos1 : TEXCOORD4;
                float4 TBN_wPos2 : TEXCOORD3;
                SHADOW_COORDS(2)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _Bump_Scale;
            sampler2D _MaskMap;
            float _MaskScale;
            float4 _MainColor;
            float4 _SpecularColor;
            float _SpecNum;
            sampler2D _GradientFullMap;
            float _SpecularPower;

            fixed3 SpecularBlinn(in float3 normal, in float3 wPos,in float3 lightDir)
            {
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - wPos);
                float3 halfDir = normalize(lightDir + viewDir);
                fixed3 specular=_LightColor0.rgb *_SpecularColor.rgb * pow(max(0,dot(normalize(normal),halfDir)),_SpecNum);
                return specular* _SpecularPower;
            }
            v2f vert (appdata_full v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
                float3 wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                float3 wNormal = UnityObjectToWorldNormal(v.normal);
                float3 wTangent = UnityObjectToWorldDir(v.tangent.xyz);
                float3 wBitangent = cross(wNormal, wTangent) * v.tangent.w;
                float3x3 TBN = transpose(float3x3(wTangent, wBitangent, wNormal));
                o.TBN_wPos0 = float4(TBN[0], wPos.x);
                o.TBN_wPos1 = float4(TBN[1], wPos.y);
                o.TBN_wPos2 = float4(TBN[2], wPos.z);
                TRANSFER_SHADOW(o)
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 wPos = float3(i.TBN_wPos0.w, i.TBN_wPos1.w, i.TBN_wPos2.w);
                float4 packedTangent = tex2D(_BumpMap, i.uv.zw);
                float3 normalT = UnpackNormal(packedTangent);
                normalT.xy *= _Bump_Scale;
                normalT.z = sqrt(saturate(1 - dot(normalT.xy, normalT.xy)));
                float3 normal=float3(dot(i.TBN_wPos0.xyz, normalT),
                                     dot(i.TBN_wPos1.xyz, normalT),
                                     dot(i.TBN_wPos2.xyz, normalT));
                #ifdef _USING_DIRECTIONAL_LIGHT
                    fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                #else
                    fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz - wPos);
                #endif

                //fixed atten=1;
                //#ifdef _USING_DIRECTIONAL_LIGHT
                //    // do nothing
                //#elif defined(POINT)
                //    fixed3 lightCoord = mul(unity_WorldToLight, float4(wPos, 1)).xyz;
                //    atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).xx).UNITY_ATTEN_CHANNEL;
                //#elif defined(SPOT)
                //    fixed4 lightCoord = mul(unity_WorldToLight, float4(wPos, 1));
                //    atten = (lightCoord.z>0)*
                //            tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5).w *
                //            tex2D(_LightTextureB0,dot(lightCoord,lightCoord).rr).UNITY_ATTEN_CHANNEL;
                //#endif
                UNITY_LIGHT_ATTENUATION(atten, i, wPos);

                fixed diffuseNum = dot(normal, lightDir) * 0.5 + 0.5;
                fixed3 specular = SpecularBlinn(normal, wPos, lightDir) * tex2D(_MaskMap, i.uv.xy ).r*_MaskScale;
                fixed3 mainColor = tex2D(_MainTex, i.uv.xy).rgb * _MainColor;
                fixed3 diffuse = _LightColor0.rgb * mainColor.rgb * tex2D(_GradientFullMap, float2(diffuseNum, diffuseNum)).rgb;
                fixed3 color = ( diffuse + specular)*atten;
                return float4(color, 1.0);
            }
            ENDCG
        }
        Pass
        {
            Tags{ "LightMode"="ShadowCaster" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            struct v2f
            {
                V2F_SHADOW_CASTER;
            };
            v2f vert (appdata_base v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o);
                return o;
            }
            fixed4 frag (v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i);
                return 0;
            }
            ENDCG
        }
    }
}
