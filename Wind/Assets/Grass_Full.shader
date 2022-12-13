Shader "DLDL/GrassExperimental/Grass_Full"
{
    Properties
    {
        _Cutoff("Cutoff", Range(0, 1)) = 0.5
        _Color("Color", Color) = (1,1,1,1)
        _MainTex ("MainTex", 2D) = "white" {}
        _SmoothnessStrength("SmoothnessStrength", Float) = 1.0
        _TranslucencyStrength("TranslucencyStrength", Float) = 1.0
        _TranslucencyPower("TranslucencyPower", Float) = 6.0

        [Space(5)]
        _WindMultiplier("Strength Main (X) Jitter (Y)", Vector) = (1, 0.5, 0, 0)
    }
    SubShader
    {
        Tags { "RenderType"="TransparentCutout" "Queue"="AlphaTest"}

        Pass
        {
            Stencil
            {
                Comp Always
                Pass Replace
                Fail Keep
            }
            Cull Off

            HLSLPROGRAM
            #pragma vertex GrassVert
            #pragma fragment GrassFragment
            #include "UnityCG.cginc"
            #include "UnityPBSLighting.cginc"
            #include "Wind.hlsl"

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float3 normalOS     : NORMAL;
                float2 texcoord     : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS   : SV_POSITION;
                float2 texcoord     : TEXCOORD0;
                float3 positionWS   : TEXCOORD1;
                float3 normalWS     : TEXCOORD2;
                float3 originNormalWS   : TEXCOORD4;
                float4 test   : TEXCOORD5;               
            };

          
            sampler2D _MainTex; float4 _MainTex_ST;
           // sampler2D _WindRT; 

            CBUFFER_START(UnityPerMaterial)
            half4 _Color;
            half _Cutoff;
            half _TranslucencyStrength;
            half _TranslucencyPower;
            half _SmoothnessStrength;
            half2 _WindMultiplier;
            CBUFFER_END

          

            Varyings GrassVert(Attributes input)
            {
                Varyings output;
                WindResult windResult = GetWind(input.positionOS.y , _WindMultiplier,input.positionOS,input.normalOS);
                output.positionWS = windResult.positionWS;
                output.positionCS = windResult.positionCS;
                output.normalWS = windResult.normalWS;
                output.texcoord = input.texcoord;
                output.originNormalWS = UnityObjectToWorldNormal(input.normalOS);
                return output;
            }

            half4 GrassFragment(Varyings input) : SV_Target
            {
                half4 mainTexColor = tex2D(_MainTex,  input.texcoord);
                half3 albedo = mainTexColor.rgb * _Color.rgb;
                half alpha = mainTexColor.a;
                clip(alpha - _Cutoff);
                return half4(albedo,1);
            }
            ENDHLSL
        }
    }
}
