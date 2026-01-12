Shader "Unlit/TestShader"
{
    Properties
    {
        _MainTexture ("Texture", 2D) = "white" { }
        _LambertColor ("LambertColor", Color) = (1, 1, 1, 1)
        _BlinnColor ("BlinnColor", Color) = (1, 1, 1, 1)
        _SpecularNum ("SpecularNum", Range(0, 20)) = 5
    }
    SubShader
    {
        Tags { "LightMode" = "ForwardBase" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            sampler2D _MainTexture;
            float4 _MainTexture_ST;
            fixed4 _LambertColor;
            fixed4 _BlinnColor;
            float _SpecularNum;
            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 normal : NORMAL;
                float3 wPos : TEXCOORD1;
                float2 uv : TEXCOORD0;

            };
            fixed3 Lambert(in fixed3 normal,in fixed3 texColor)
            {
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                return _LightColor0.rgb * _LambertColor.rgb * texColor.rgb * (dot(normal, lightDir) * 0.5 + 0.5);
            }
            fixed3 Blinne(in fixed3 normal ,in fixed3 wPos)
            {
                fixed3 lightDir =normalize( UnityWorldSpaceLightDir(wPos).xyz);
                fixed3 viewDir= normalize( UnityWorldSpaceViewDir(wPos).xyz );
                fixed3 halfDir= normalize( lightDir+viewDir);
                return _LightColor0 *_BlinnColor * pow(max(0,dot( halfDir , normal)),_SpecularNum);
            }
            v2f vert(appdata_base v) 
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normal = normalize( UnityObjectToWorldNormal(v.normal).xyz);
                o.wPos = mul(unity_ObjectToWorld, v.vertex);
                o.uv= v.texcoord.xy*_MainTexture_ST.xy+ _MainTexture_ST.zw;
                return o;
            }
            float4 frag(v2f i) : SV_Target
            {
                float4 texColor=tex2D(_MainTexture,i.uv);
                fixed3 color= UNITY_LIGHTMODEL_AMBIENT*_LambertColor*texColor+Lambert(i.normal,texColor.xyz)+Blinne(i.normal,i.wPos.xyz);
                return fixed4(color,1);
            }
            ENDCG
        }
    }
}
