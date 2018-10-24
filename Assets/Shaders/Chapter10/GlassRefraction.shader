Shader "Unity Shaders Book/Chapter 10/Glass Refraction" {
    Properties {
        _MainTex ("Main Tex", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _CubeMap ("Environment CubeMap", Cube) = "_Skybox" {}
        _Distortion ("Distortion", Range(0, 100)) = 10
        _RefractAmount ("Refract Amount", Range(0, 1)) = 1
    }

    SubShader {
        // We Must be transparent, so other objects are drawn before this one
        Tags { "Queue"="Transparent" "RenderType"="Opaque" }

        // This pass grabs the screen behind the object into a texture.
        // We can access the result in the next pass as _RefractionTex
        GrabPass { "_RefractionTex" }

        Pass {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            samplerCUBE _CubeMap;
            float _Distortion;
            fixed _RefractAmount;
            sampler2D _RefractionTex;
            float4 _RefractionTex_TexelSize;;

            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float4 screenPos : TEXCOORD0;
                float4 uv : TEXCOORD1;
                float4 T2W0 : TEXCOORD2;
                float4 T2W1 : TEXCOORD3;
                float4 T2W2 : TEXCOORD4;
            };

            v2f vert(a2v v) {
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeGrabScreenPos(o.pos);
                
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                float3 worldBitangent = cross(worldNormal, worldTangent) * v.tangent.w;

                o.T2W0 = float4(worldTangent.x, worldBitangent.x, worldNormal.x, worldPos.x);
                o.T2W1 = float4(worldTangent.y, worldBitangent.y, worldNormal.y, worldPos.y);
                o.T2W2 = float4(worldTangent.z, worldBitangent.z, worldNormal.z, worldPos.z);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                float3 worldPos = float3(i.T2W0.w, i.T2W1.w, i.T2W2.w);
                float3 worldViewDir = UnityWorldSpaceViewDir(worldPos);

                // Get the normal in tangent space
                fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));

                // Compute the offset in tangent sapce
                float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
                i.screenPos.xy = offset * i.screenPos.z + i.screenPos.xy;
                fixed3 refractionColor = tex2D(_RefractionTex, i.screenPos.xy / i.screenPos.w).rgb;

                // Convert the normal to world space
                bump = normalize(half3(dot(i.T2W0.xyz, bump), dot(i.T2W1.xyz, bump), dot(i.T2W2.xyz, bump)));
                fixed3 reflectionDir = reflect(-worldViewDir, bump);
                fixed3 texColor = tex2D(_MainTex, i.uv.xy);
                fixed3 reflectionColor = texCUBE(_CubeMap, reflectionDir).rgb * texColor.rgb;

                fixed3 finalColor = reflectionColor * (1 - _RefractAmount) + refractionColor  * _RefractAmount;
            
                return fixed4(finalColor, 1.0);
            }

            ENDCG
        }
    }

    Fallback "Diffuse"

    // CustomEditor "Glass Refraction Editor Script Name"
}
