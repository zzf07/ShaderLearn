Shader "Unlit/GradientBase"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _GradientTex ("GradientTex", 2D) = "white" { }
        _LambertColor ("LambertColor", Color) = (1, 1, 1, 1)
        _BlinnColor ("BlinnColor", Color) = (1, 1, 1, 1)
        _Num ("Num", Range(0, 200)) = 20
    }
    SubShader
    {
        Tags { "LightMode"="ForwardBase" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _GradientTex;
            float4 _GradientTex_ST;
            fixed3 _LambertColor;
            fixed3 _BlinnColor;
            float _Num;

            struct v2f
            {
                float4 vertex:SV_POSITION;
                float4 wPos : TEXCOORD0;
                float3 normal : NORMAL;
            };
            float3 Blinn(in float3 normal,in float3 wPos)
            {
                float3 lightDir= normalize( _WorldSpaceLightPos0.xyz);
                float3 viewDir = normalize( UnityWorldSpaceViewDir(wPos).xyz);
                float3 halfDir = normalize(lightDir + viewDir);
                fixed3 blinn= _LightColor0*_BlinnColor*pow(max(0,dot(halfDir,normalize(normal))),_Num);
                return blinn;
            }
            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.wPos = mul(unity_ObjectToWorld, v.vertex);
                o.normal = normalize( UnityObjectToWorldNormal(v.normal));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 lightDir= normalize( _WorldSpaceLightPos0.xyz);
                fixed halfLambertNum=dot(normalize(i.normal),lightDir)*0.5+0.5;
                fixed3 gradientColor = tex2D( _GradientTex,float2( halfLambertNum, halfLambertNum) )*_LightColor0*_LambertColor;
                fixed3 color= UNITY_LIGHTMODEL_AMBIENT.rgb + gradientColor.rgb +Blinn(i.normal,i.wPos);
                return float4( color,0);
            }
            ENDCG
        }
    }
}
