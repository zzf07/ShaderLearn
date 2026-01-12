Shader "Unlit/PageTurning"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BackTex("Back Texture",2D) = "white"{}
        _Angle("Angle",Range(0,180)) = 0
        _Speed("Speed",Float) = 1
        _Axis("Axis",Range(0,2)) = 1//0XÖá£¬1YÖá£¬2ZÖá
        _Translation("Translation",Float) = 1
        _WaveLength("Wave Length",Float) = 0
        _YAmplitude("Y Amplitude",Float) = 1
        _XScale("X Scale",Range(0,1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        

        Pass
        {
            Cull Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 4.0

            #include "UnityCG.cginc"

            struct v2f
            {
                float4 uv : TEXCOORD0;//xyÎª_MainTex,zwÎª_BackTex
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BackTex;
            float4 _BackTex_ST;
            float _Speed;
            int _Axis;
            float _Translation;
            float _WaveLength;
            float _YAmplitude;
            float _XScale;
            float _Angle;

            v2f vert (appdata_base v)
            {
                v2f o;
                //float angle = _Time.y * _Speed % 180;
                float weight = 1- abs(90 - _Angle)/90;
                float angle = radians(_Angle);
                float4x4 rotationMatrix ;
                switch(_Axis)
                {
                    case 0 :
                        rotationMatrix = float4x4(1,0,0,0,
                                                  0,cos(angle),-sin(angle),0,
                                                  0,sin(angle),cos(angle),0,
                                                  0,0,0,1);
                        
                        v.vertex.z += _Translation;
                        v.vertex.y += sin(v.vertex.z * _WaveLength) * weight * _YAmplitude;
                        v.vertex.z -= v.vertex.z * weight * _XScale;
                    break;
                    case 1 :
                        rotationMatrix = float4x4(cos(angle),0,sin(angle),0,
                                                  0,1,0,0,
                                                  -sin(angle),0,cos(angle),0,
                                                  0,0,0,1);
                       
                        v.vertex.x += _Translation;
                        v.vertex.z += sin(v.vertex.x * _WaveLength) * weight * _YAmplitude;
                        v.vertex.x -= v.vertex.x * weight * _XScale;
                    break;
                    case 2 :
                        rotationMatrix = float4x4(cos(angle),-sin(angle),0,0,
                                                  sin(angle),cos(angle),0,0,
                                                  0,0,1,0,
                                                  0,0,0,1);
                        
                        v.vertex.x += _Translation;
                        v.vertex.y += sin(v.vertex.x * _WaveLength) * weight * _YAmplitude;
                        v.vertex.x -= v.vertex.x * weight * _XScale;
                    break;
                }
                v.vertex = mul(rotationMatrix,v.vertex);
                switch(_Axis)
                {
                    case 0:
                         v.vertex.z -= _Translation;
                    break;
                    case 1:
                         v.vertex.x -= _Translation;
                    break;
                    case 2:
                         v.vertex.x -= _Translation;
                    break;
                }
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _BackTex);
                return o;
            }

            fixed4 frag (v2f i,half face:VFACE) : SV_Target
            {
                fixed4 col = face > 0 ? tex2D(_MainTex, i.uv.xy) : tex2D(_BackTex,i.uv.zw);
                return col;
            }
            ENDCG
        }
    }
}
