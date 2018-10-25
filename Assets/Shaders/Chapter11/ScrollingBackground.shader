Shader "Unity Shaders Book/Chapter 11/Scrolling Background" {
    Properties {
        _MainTex ("Main Tex", 2D) = "white" {}
        _DetailTex ("Detail Tex", 2D) = "white" {}
        _ScrollX ("Main Scroll Speed", Float) = 1
        _Scroll2X ("Detail Scroll Speed", Float) = 1
        _Multiplier ("Multiplier", Float) = 1 
    }

    SubShader {
        Tags { "Queue"="Geometry" "RenderType"="Opaque" }

        Pass {
            Tags { "LightMode"="Always" }

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _DetailTex;
            float4 _DetailTex_ST;
            float _ScrollX;
            float _Scroll2X;
            float _Multiplier;

            struct a2v {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
            };

            v2f vert(a2v v) {
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex) + frac(float2(_ScrollX, 0.0) * _Time.y);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _DetailTex) + frac(float2(_Scroll2X, 0.0) * _Time.y);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                fixed4 mainTexColor = tex2D(_MainTex, i.uv.xy);
                fixed4 detailTexColor = tex2D(_DetailTex, i.uv.zw);

                fixed4 color = lerp(mainTexColor, detailTexColor, detailTexColor.a);
                color.rgb *= _Multiplier;

                return color;
            }

            ENDCG
        }
    }

    // Fallback "VertexLit"

    // CustomEditor "Scrolling Background Editor Script Name"
}
