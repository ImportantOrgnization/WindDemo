Shader "DLDL/GrassExperimental/GrassExperimental"
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
            sampler2D _WindRT; 

            CBUFFER_START(UnityPerMaterial)
            half4 _Color;
            half _Cutoff;
            half _TranslucencyStrength;
            half _TranslucencyPower;
            half _SmoothnessStrength;
            half2 _WindMultiplier;
            CBUFFER_END

            CBUFFER_START(GRASS)
            half4 _WindDirSize;
            half4 _WindStrengthMultipliers;
            half4 _WindSinTime;
            CBUFFER_END

            Varyings GrassVert(Attributes input)
            {
                Varyings output;

                output.positionWS =  mul( unity_ObjectToWorld,input.positionOS.xyzw) ;

                float bendScale = input.texcoord.y;
                float4 windUV = float4( output.positionWS.xz * _WindDirSize.w,0,0) ;
                half4 wind = tex2Dlod(_WindRT, windUV);
                output.test = wind;

                wind.r = wind.r * (wind.g * 2.0f - 0.24376f);

                float windStrength = wind.r * _WindStrengthMultipliers.x * _WindMultiplier.x * bendScale;

                float2 windBend = UnityWorldToObjectDir(_WindDirSize.xyz).xz * windStrength;
                
                input.positionOS.xz -= windBend;
                float2 jitter = lerp(float2(_WindSinTime.x, 0), _WindSinTime.yz, float2(0.5, windStrength));
                input.positionOS += (jitter.x + jitter.y * _WindMultiplier.y) * (0.075 + _WindSinTime.w) * saturate(windStrength);
                output.positionWS =  mul( unity_ObjectToWorld,input.positionOS.xyz) ;

                output.positionCS = UnityObjectToClipPos(output.positionWS);
                output.texcoord = input.texcoord;

                float3 normalOS = input.normalOS;
                normalOS.xz -= windBend * 3.1415926;
                
                output.normalWS = UnityObjectToWorldNormal(normalOS);
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
