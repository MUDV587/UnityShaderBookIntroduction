Shader "Unity Shaders Book/Chapter 10/Fresnel Schlick" {
    Properties {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _FresnelScale ("Fresnel Scale", Range(0, 1)) = 0.5
        _Cubemap("Reflection Cubemap", Cube) = "_Skybox" {}
    }

    SubShader {
        Tags { "Queue"="Geometry" "RenderType"="Opaque" }

        Pass {
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM
            
            #pragma multi_compile_fwdbase

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            fixed4 _Color;
            fixed _FresnelScale;
            samplerCUBE _Cubemap;

            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 worldViewDir : TEXCOORD2;
                float3 worldReflectionDir : TEXCOORD3;
                SHADOW_COORDS(4)
            };

            v2f vert(a2v v) {
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
                o.worldReflectionDir = reflect(-o.worldViewDir, o.worldNormal);

                TRANSFER_SHADOW(o);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 worldViewDir = normalize(i.worldViewDir);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0, dot(worldNormal, worldLightDir));
                
                fixed3 reflection = texCUBE(_Cubemap, i.worldReflectionDir).rgb;
                fixed3 fresnel = _FresnelScale + (1 - _FresnelScale) * pow(1 - dot(worldViewDir, worldNormal), 5);

                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

                fixed3 color = ambient + lerp(diffuse, reflection, saturate(fresnel)) * atten;

                return fixed4(color, 1.0);
            }

            ENDCG
        }
    }

    Fallback "Reflective/VertexLit"

    // CustomEditor "Fresnel Schlick Editor Script Name"
}
