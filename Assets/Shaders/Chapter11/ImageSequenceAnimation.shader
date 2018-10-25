Shader "Unity Shaders Book/Chapter 11/Image Sequence Animation" {
    Properties {
        _MainTex ("Main Tex", 2D) = "white" {}
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _HorizontalAmount ("Horizontal Amount", Float) = 4
        _VerticalAmount ("Vertical Amount", Float) = 4
        _Speed ("Speed", Range(1, 100)) = 30
    }

    SubShader {
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }

        Pass {
            Tags { "LightMode"="Always" }

            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            float _HorizontalAmount;
            float _VerticalAmount;
            float _Speed;

            struct a2v {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(a2v v) {
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

                // float time = floor(_Time.y * _Speed);
                // float row = floor(time / _HorizontalAmount);
                // float column = time - row * _VerticalAmount;

                // // half2 uv = float2(i.uv.x / _HorizontalAmount, i.uv.y / _VerticalAmount);
                // // uv.x += column / _HorizontalAmount;
                // // uv.y -= row / _VerticalAmount;

                // half2 uv = o.uv + half2(column, -row);
                // uv.x /= _HorizontalAmount;
                // uv.y /= _VerticalAmount;

                // o.uv = uv;

                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                float time = floor(_Time.y * _Speed);
                float row = floor(time / _HorizontalAmount);
                float column = time - row * _VerticalAmount;

                // half2 uv = float2(i.uv.x / _HorizontalAmount, i.uv.y / _VerticalAmount);
                // uv.x += column / _HorizontalAmount;
                // uv.y -= row / _VerticalAmount;

                half2 uv = i.uv + half2(column, -row);
                uv.x /= _HorizontalAmount;
                uv.y /= _VerticalAmount;

                fixed4 color = tex2D(_MainTex, uv);
                color.rgb *= _Color;

                return color;
            }

            ENDCG
        }
    }

    // Fallback "Transparent/VertexLit"

    // CustomEditor "Image Sequence Animation Editor Script Name"
}