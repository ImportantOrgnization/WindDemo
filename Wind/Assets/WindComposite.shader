Shader "Hidden/GrassExperimental/WindComposite"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float3 _WindDir;
            float2 _WindUVs;
            float2 _WindUVs1;
            float2 _WindUVs2;
            float2 _WindUVs3;
            float2 _Gust;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                half4 n1 = tex2D(_MainTex, i.uv + _WindUVs);
                half4 n2 = tex2D(_MainTex, i.uv + _WindUVs1);
                half4 n3 = tex2D(_MainTex, i.uv + _WindUVs2);
                half4 n4 = tex2D(_MainTex, i.uv * _Gust.x + _WindUVs3);

                half4 sum = half4(n1.r, n1.g + n2.g, n1.b + n2.b + n3.b, n1.a + n2.a + n3.a + n4.a);
                half4 weights = half4(0.5, 0.25, 0.125, 0.0625);

                half2 windStrengthGustNoise;
                windStrengthGustNoise.x = dot(sum, weights);
                windStrengthGustNoise.y = (n4.a + n2.a) * 0.5f;

                windStrengthGustNoise = (windStrengthGustNoise - 0.5) * _Gust.y + 0.5;

                return half4(windStrengthGustNoise, 1, 0);
            }
            ENDCG
        }
    }
}
