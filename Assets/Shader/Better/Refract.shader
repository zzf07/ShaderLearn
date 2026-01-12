Shader "Unlit/Refract"
{
    Properties
    {
        _CubeMap("Cube Map",Cube) = "white"{}
        _RefractiveIndexA("Refractive Index A",Range(1,2)) = 1
        _RefractiveIndexB("Refractive Index B",Range(1,2)) = 1.3
        _RefractivePower("Refractive Power",Range(0,1)) = 1
        _MainColor("Main Color",Color) = (1,1,1,1)
        _SpecularColor("Specular Color",Color) = (1,1,1,1)
        _SpecularNum("Specular Num",Range(1,500)) = 100
        _SpecularPower("Specular Power",Range(0,1)) = 1
        _ShadowPower("Shadow Power" ,Range(0,0.5)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags{"LightMode" = "ForwardBase"}
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
                //float3 wNormal : NORMAL;
                float4 wPos_wNormalX : TEXCOORD0;
                float4 wRefract_wNormalY : TEXCOORD1;
                float4 wViewDir_wNormalZ : TEXCOORD2;
                SHADOW_COORDS(4)
            };

            samplerCUBE _CubeMap;
            float _RefractiveIndexA;
            float _RefractiveIndexB;
            float _RefractivePower;
            fixed4 _MainColor;
            fixed4 _SpecularColor;
            float _SpecularNum;
            float _SpecularPower;
            float _ShadowPower;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                float3 wNormal = UnityObjectToWorldNormal(v.normal);
                o.wPos_wNormalX.xyz = mul( unity_ObjectToWorld,v.vertex).xyz;
                float3 wViewDir = normalize(UnityWorldSpaceViewDir(o.wPos_wNormalX.xyz));
                float Index = _RefractiveIndexA/_RefractiveIndexB;
                o.wRefract_wNormalY.xyz = refract(- wViewDir ,normalize( wNormal),Index);
                o.wPos_wNormalX.w = wNormal.x;
                o.wRefract_wNormalY.w = wNormal.y;
                o.wViewDir_wNormalZ.xyz = wViewDir;
                o.wViewDir_wNormalZ.w = wNormal.z;
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 wNormal = normalize(float3(i.wPos_wNormalX.w , i.wRefract_wNormalY.w , i.wViewDir_wNormalZ.w));
                float3 wPos = i.wPos_wNormalX.xyz;
                float3 wRefract = normalize( i.wRefract_wNormalY.xyz);
                float3 wViewDir = normalize(i.wViewDir_wNormalZ .xyz);
                float3 wLightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 halfDir = normalize(wLightDir+wViewDir);

                fixed3 diffuse = _LightColor0.rgb * _MainColor.rgb * (dot(wLightDir,wNormal) * 0.5 + 0.5);
                fixed3 specular = _LightColor0.rgb * _SpecularColor.rgb * pow(max(0,dot(wNormal,halfDir)),_SpecularNum);
                fixed3 cubemapColor = texCUBE(_CubeMap,i.wRefract_wNormalY.xyz);
                UNITY_LIGHT_ATTENUATION(atten, i, wPos);
                float3 color = UNITY_LIGHTMODEL_AMBIENT.rgb +  (lerp( diffuse,cubemapColor,_RefractivePower) + specular) * max(atten,_ShadowPower);
                return fixed4( color,1);
            }
            ENDCG
        }
        Pass
        {
            Tags{"LightMode" = "ForwardAdd"}
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
                //float3 wNormal : NORMAL;
                float4 wPos_wNormalX : TEXCOORD0;
                float4 wRefract_wNormalY : TEXCOORD1;
                float4 wViewDir_wNormalZ : TEXCOORD2;
                SHADOW_COORDS(4)
            };

            samplerCUBE _CubeMap;
            float _RefractiveIndexA;
            float _RefractiveIndexB;
            float _RefractivePower;
            fixed4 _MainColor;
            fixed4 _SpecularColor;
            float _SpecularNum;
            float _SpecularPower;
            float _ShadowPower;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                float3 wNormal = UnityObjectToWorldNormal(v.normal);
                o.wPos_wNormalX.xyz = mul( unity_ObjectToWorld,v.vertex).xyz;
                float3 wViewDir = normalize(UnityWorldSpaceViewDir(o.wPos_wNormalX.xyz));
                float Index = _RefractiveIndexA/_RefractiveIndexB;
                o.wRefract_wNormalY.xyz = refract(- wViewDir ,normalize( wNormal),Index);
                o.wPos_wNormalX.w = wNormal.x;
                o.wRefract_wNormalY.w = wNormal.y;
                o.wViewDir_wNormalZ.xyz = wViewDir;
                o.wViewDir_wNormalZ.w = wNormal.z;
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 wNormal = normalize(float3(i.wPos_wNormalX.w , i.wRefract_wNormalY.w , i.wViewDir_wNormalZ.w));
                float3 wPos = i.wPos_wNormalX.xyz;
                float3 wRefract = normalize( i.wRefract_wNormalY.xyz);
                float3 wViewDir = normalize(i.wViewDir_wNormalZ .xyz);
                //float3 wLightDir = normalize(_WorldSpaceLightPos0.xyz);
                #ifdef USING_DIRECTIONAL_LIGHT
                    float3 wLightDir = normalize(_WorldSpaceLightPos0.xyz);
                #else
                    float3 wLightDir = normalize(_WorldSpaceLightPos0.xyz - wPos);
                #endif

                float3 halfDir = normalize(wLightDir+wViewDir);

                fixed3 diffuse = _LightColor0.rgb * _MainColor.rgb * (dot(wLightDir,wNormal) * 0.5 + 0.5);
                fixed3 specular = _LightColor0.rgb * _SpecularColor.rgb * pow(max(0,dot(wNormal,halfDir)),_SpecularNum);
                fixed3 cubemapColor = texCUBE(_CubeMap,i.wRefract_wNormalY.xyz);
                UNITY_LIGHT_ATTENUATION(atten, i, wPos);
                float3 color = UNITY_LIGHTMODEL_AMBIENT.rgb +  (lerp( diffuse,cubemapColor,_RefractivePower) + specular) * max(atten,_ShadowPower);
                return fixed4( color,1);
            }
            ENDCG
        }
    }
    Fallback"Reflective/VertexLit"
}
