Shader "Unlit/KajiyaKay"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SpecularColor ("Specular Color", Color) = (1, 1, 1, 1)
        _SpecularNum ("Specular Exponent", Range(1, 500)) = 32
        _MainColor ("Main Color", Color) = (1, 1, 1, 1)
        _GradientMap("Gradient Map",2D)="white" {}
        _SpecularPower("Specular Power",Range(0,1)) = 1
        _SpecularShift("Specular Shift",Range(-1,1)) = 0

        _SecondSpecularColor("Second Specular Color",Color) = (1,1,1,1)
        _SecondSpecularNum("Second Specular Num",Range(1,500)) = 100
        _SecondSpecularPower("Second Specular Power",Range(0,1)) = 1
        _SecondSpecularShift("Second Specular Shift",Range(-1,1)) = 0
    }
    SubShader
    {
        

        Pass
        {
            Tags { "LightMode" = "ForwardBase"  }
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
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 tangent : TANGENT;
                float3 normal : NORMAL;
                float3 wPos :TEXCOORD1;
                float3 binormal : TEXCOORD2;
                SHADOW_COORDS(3)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _MainColor;
            sampler2D _GradientMap;

            float _SpecularPower;
            float _SpecularShift;
            float4 _SpecularColor;
            float _SpecularNum;

            fixed4 _SecondSpecularColor;
            float _SecondSpecularNum;
            float _SecondSpecularPower;
            float _SecondSpecularShift;


            //fixed3 SpecularBlinn(in float3 normal, in float3 wPos,in float3 lightDir)
            //{
            //    float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - wPos);
            //    float3 halfDir = normalize(lightDir + viewDir);
            //    fixed3 specular=_LightColor0.rgb *_SpecularColor.rgb * pow(max(0,dot(normalize(normal),halfDir)),_SpecNum);
            //    return specular;
            //}
            fixed3 KajiaKaySpecular(in float3 binormal,in float3 wPos,in float3 lightDir,in float num,in float power,in fixed3 Color)
            {
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - wPos);
                float3 halfDir = normalize(viewDir+lightDir);
                float TdotH = dot(binormal,halfDir);
                float TsinH = sqrt (1.0- TdotH * TdotH);
                fixed specular= _LightColor0.rgb* Color.rgb * pow(max(0,TsinH),num);
                return specular* power;
            }
            float3 ShiftTangent(in float3 T,in float3 N,in float shift)
            {
                float3 shiftedT = T + (shift*N);
                return normalize( shiftedT);
            }
            v2f vert (appdata_full v)
            {
                v2f o;
                o. pos = UnityObjectToClipPos(v.vertex);
                o.tangent = UnityObjectToWorldDir(v.tangent);
                o.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.binormal = cross(o.normal, o.tangent) * v.tangent.w;
                o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 N = normalize(i.normal);
                float3 T = normalize(i.tangent);
                float3 B = normalize(i.binormal);
                //float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.wPos);
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                //float3 halfDir = normalize(lightDir + viewDir);
                //float TdotH = dot(B, halfDir);
                //float TsinH = sqrt(1.0 - TdotH * TdotH);
                //float specular = pow(max(0,TsinH), _SpecNum);
                fixed3 mainColor = tex2D (_MainTex,i.uv)*_MainColor;
                fixed halfLambertNum = dot(N,lightDir)*0.5+0.5;
                fixed3 diffuse = _LightColor0.rgb * mainColor * tex2D(_GradientMap,float2(halfLambertNum,halfLambertNum));
                //fixed3 specular = SpecularBlinn(N,i.wPos,lightDir);
                fixed3 KaiyaKay = KajiaKaySpecular( ShiftTangent(B,N,_SpecularShift),i.wPos,lightDir,_SpecularNum,_SpecularPower,_SpecularColor.rgb)+
                                  KajiaKaySpecular(ShiftTangent(B,N, _SecondSpecularShift),i.wPos,lightDir,_SecondSpecularNum,_SecondSpecularPower,_SecondSpecularColor.rgb);
                UNITY_LIGHT_ATTENUATION(atten, i,i.wPos);
                //atten=0;
                float3 color =  ( KaiyaKay+ diffuse) * atten + UNITY_LIGHTMODEL_AMBIENT.rgb * mainColor;
                return fixed4(color, 1.0);
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
            #pragma multi_compile_fwdadd_fullshadows

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"


            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 tangent : TANGENT;
                float3 normal : NORMAL;
                float3 wPos :TEXCOORD1;
                float3 binormal : TEXCOORD2;
                SHADOW_COORDS(3)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _MainColor;
            sampler2D _GradientMap;

            float _SpecularPower;
            float _SpecularShift;
            float4 _SpecularColor;
            float _SpecularNum;

            fixed4 _SecondSpecularColor;
            float _SecondSpecularNum;
            float _SecondSpecularPower;
            float _SecondSpecularShift;
            //fixed3 SpecularBlinn(in float3 normal, in float3 wPos,in float3 lightDir)
            //{
            //    float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - wPos);
            //    float3 halfDir = normalize(lightDir + viewDir);
            //    fixed3 specular=_LightColor0.rgb *_SpecularColor.rgb * pow(max(0,dot(normalize(normal),halfDir)),_SpecNum);
            //    return specular;
            //}
            fixed3 KajiaKaySpecular(in float3 binormal,in float3 wPos,in float3 lightDir,in float num,in float power,in fixed3 Color)
            {
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - wPos);
                float3 halfDir = normalize(viewDir+lightDir);
                float TdotH = dot(binormal,halfDir);
                float TsinH = sqrt (1.0- TdotH * TdotH);
                fixed specular= _LightColor0.rgb* Color.rgb * pow(max(0,TsinH),num);
                return specular* power;
            }
            float3 ShiftTangent(in float3 T,in float3 N,in float shift)
            {
                float3 shiftedT = T + (shift*N);
                return normalize( shiftedT);
            }
            v2f vert (appdata_full v)
            {
                v2f o;
                o. pos = UnityObjectToClipPos(v.vertex);
                o.tangent = UnityObjectToWorldDir(v.tangent);
                o.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.binormal = cross(o.normal, o.tangent) * v.tangent.w;
                o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 N = normalize(i.normal);
                float3 T = normalize(i.tangent);
                float3 B = normalize(i.binormal);
                //float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.wPos);
                //float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                #ifdef USING_DIRECTIONAL_LIGHT
                    fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                #else
                    fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz - i.wPos);
                #endif
                //float3 halfDir = normalize(lightDir + viewDir);
                //float TdotH = dot(B, halfDir);
                //float TsinH = sqrt(1.0 - TdotH * TdotH);
                //float specular = pow(max(0,TsinH), _SpecNum);
                fixed3 mainColor = tex2D (_MainTex,i.uv)*_MainColor;
                fixed3 diffuse = _LightColor0.rgb * mainColor * (dot(N,lightDir)*0.5+0.5);
                fixed3 KaiyaKay =KajiaKaySpecular( ShiftTangent(B,N,_SpecularShift),i.wPos,lightDir,_SpecularNum,_SpecularPower,_SpecularColor.rgb)+
                                  KajiaKaySpecular(ShiftTangent(B,N, _SecondSpecularShift),i.wPos,lightDir,_SecondSpecularNum,_SecondSpecularPower,_SecondSpecularColor.rgb);
                UNITY_LIGHT_ATTENUATION(atten, i, i.wPos);
                float3 color = (KaiyaKay+  diffuse)* atten ;
                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
