// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter 05/Simple_02" {
    Properties {
        //
    }

    SubShader {
        Pass {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            float4 vert(a2v v) : SV_POSITION {
                return UnityObjectToClipPos (v.vertex);
            }

            fixed4 frag() : SV_TARGET {
                return fixed4(1.0, 1.0, 1.0, 1.0);
            }

            ENDCG
        }
    }

    // Fallback "Diffuse"

    // CustomEditor "CustomShaderGUI"
}
