Shader "Unlit/FOG"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        //_FOGEnd("FOG End",Float) = 1
        //_FOGStart("FOG Start",Float) = 1
        _FOGColor("FOG Color",Color) = (1,1,1,1)
        _FOGDensity("FOG Density",Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        ZWrite Off
        Cull Off
        ZTest Always
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 ray : TEXCOORD1;
                float3 wCameraPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _CameraDepthTexture;
            float3 _RayTL;
            float3 _RayTR;
            float3 _RayBL;
            float3 _RayBR;
            //float _FOGEnd;
            //float _FOGStart;
            fixed4 _FOGColor;
            float _FOGDensity;

            v2f vert (appdata_img v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                o.wCameraPos = _WorldSpaceCameraPos;
                float3 rayT = lerp( _RayTL,_RayTR,o.uv.x);
                float3 rayB = lerp( _RayBL,_RayBR,o.uv.x);
                o.ray = lerp(rayB,rayT,o.uv.y);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv);
                depth = LinearEyeDepth(depth);
                float3 wPos = i.wCameraPos + i.ray * depth;
                float d = distance(wPos,i.wCameraPos);
                //float f = (_FOGEnd - abs(d))/(_FOGEnd - _FOGStart);
                float f = 1- pow(2.71828,-(_FOGDensity*d));
                fixed4 renderColor = tex2D( _MainTex,i.uv);
                fixed3 color = lerp( renderColor,_FOGColor,f);
                return fixed4(color,1);
            }
            ENDCG
        }
    }
    Fallback Off
}
