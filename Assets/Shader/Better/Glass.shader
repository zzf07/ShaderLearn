Shader "Unlit/Glass"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _DiffuseColor("Diffuse Color",Color) = (1,1,1,1)
        _SpecularColor("Specular Color",Color) = (1,1,1,1)
        _SpecularNum("Specular Num",Range(1,500)) = 100
        _SpecularPower("Specular Power",Range(0,1)) = 1
        _RefractiveIndexA("Refractive Index A",Range(1,2)) = 1
        _RefractiveIndexB("Refractive Index B",Range(1,2)) = 1.3
        _CubemapTex("Cubemap Texture",Cube) = "white" {}
        _Reflectivity("Reflectivit",Range(0,1))=1
        _OffsetStrength("Offset Strength",Range(0,0.05)) = 0.02
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent" }
        GrabPass{}
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"


            struct v2f
            {
                //float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 wNormal : NORMAL;
                float4 screenPos : TEXCOORD1;
                float4 wReflectDir_R : TEXCOORD2;
                float3 wRefractDir : TEXCOORD3;
                float4 wViewDir_uvX : TEXCOORD4;
                float4 wPos_uvY :TEXCOORD5;
                SHADOW_COORDS(6)
                //float R : TEXCOORD4;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _GrabTexture;
            samplerCUBE _CubemapTex;
            float _RefractiveIndexA;
            float _RefractiveIndexB;
            float _Reflectivity;
            float _OffsetStrength;
            fixed4 _DiffuseColor;
            fixed4 _SpecularColor;
            float _SpecularNum;
            float _SpecularPower;

            v2f vert (appdata_full v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                float2 uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.screenPos = ComputeScreenPos(o.pos);
                float3 wNormal = UnityObjectToWorldNormal(v.normal);
                float3 wPos = mul(unity_ObjectToWorld,v.vertex);
                float3 wViewDir = UnityWorldSpaceViewDir(wPos);
                o.wReflectDir_R.xyz = reflect(- wViewDir , wNormal);
                o.wRefractDir = refract(-wViewDir,wNormal,_RefractiveIndexA/_RefractiveIndexB);
                o.wReflectDir_R.w = _Reflectivity + (1 - _Reflectivity) * pow(1-dot(normalize(wViewDir),normalize(wNormal)),5);
                TRANSFER_SHADOW(o);
                o.wNormal = wNormal;
                o.wViewDir_uvX = float4( wViewDir,uv.x);
                o.wPos_uvY = float4( wPos,uv.y);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv =float2(i.wViewDir_uvX.w,i.wPos_uvY.w);
                float3 wViewDir = i.wViewDir_uvX.xyz;
                float3 wPos = i.wPos_uvY.xyz;
                float3 wNormal = normalize(i.wNormal);
                float3 wLightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 halfDir = normalize(wViewDir+wLightDir);

                float R = i.wReflectDir_R.w;
                float3 screenRefractDir = mul((float3x3)unity_WorldToCamera,i.wRefractDir);
                fixed4 mainColor = tex2D(_MainTex, uv);
                float2 screenUV = i.screenPos.xy/i.screenPos.w;
                screenUV -= screenRefractDir.xy * _OffsetStrength * (1-R);
                 
                fixed4 reflectColor = texCUBE(_CubemapTex,i.wReflectDir_R.xyz) * mainColor;
                fixed4 grabColor = tex2D(_GrabTexture,screenUV);
                //fixed3 diffuse = _LightColor0.rgb * reflectColor.rgb * (dot( wNormal,wLightDir)*0.5+0.5);
                fixed3 specular = _LightColor0.rgb * _SpecularColor.rgb * pow(max(0,dot(halfDir,wNormal)),_SpecularNum);
                specular *= _SpecularPower;
                UNITY_LIGHT_ATTENUATION(atten, i, wPos);
                fixed4 color = (lerp( grabColor,reflectColor,R) + float4( specular,1)) * atten;
                return color;
            }
            ENDCG
        }
    }
    //Fallback"Reflective/VertexLit"
}
