Shader "Unlit/NormalTangent"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap("BumpMap",2D)="white"{}
        _BumpScale("BumpScale",Range(0,1))=1
        _LambertColor("LambertColor",Color)=(1,1,1,1)
        _BlinnColor("BlinnColor",Color)=(1,1,1,1)
        _Num("Num",Range(0,200))=20
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
            fixed3 _LambertColor;
            fixed3 _BlinnColor;
            float _Num;
            float _BumpScale;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            struct v2f
            {
                float4 uv : TEXCOORD0;//合二为一
                float4 vertex : SV_POSITION;
                float3 viewDir:TEXCOORD1;
                float3 lightDir:TEXCOORD2;
            };

            v2f vert (appdata_full v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
                float3 binormal = cross(normalize( v.normal),normalize( v.tangent.xyz)) * v.tangent.w;
                float3x3 change =  float3x3(v.tangent.xyz, binormal, v.normal);
                o.viewDir = mul(change, ObjSpaceViewDir(v.vertex));
                o.lightDir = mul(change, ObjSpaceLightDir(v.vertex));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 packedNormal = tex2D(_BumpMap, i.uv.zw);
                float3 tangentNormal = UnpackNormal(packedNormal);
                tangentNormal *= _BumpScale;
                float3 texColor = tex2D(_MainTex, i.uv.xy).rgb * _LambertColor;
                fixed3 Lambert = _LightColor0.rgb * texColor * max(dot(tangentNormal, normalize(i.lightDir)),0 );
                float3 halfDir = normalize(normalize(i.lightDir) + normalize(i.viewDir));
                fixed3 Blinn = _LightColor0.rgb * _BlinnColor.rgb * pow(max(0, dot(halfDir,tangentNormal)), _Num);
                fixed3 color = UNITY_LIGHTMODEL_AMBIENT.rgb * texColor + Lambert+Blinn ;
                return fixed4(color, 1);
            }
            ENDCG
        }
    }
}
