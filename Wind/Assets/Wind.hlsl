#ifndef INCLUDE_WIND_HLSL
#define INCLUDE_WIND_HLSL

CBUFFER_START(GRASS)
half4 _WindDirSize;
half4 _WindStrengthMultipliers;
half4 _WindSinTime;
CBUFFER_END
sampler2D _WindRT; 

struct WindResult{
    float4 positionWS;
    float4 positionCS;
    half3 normalWS;
};

WindResult GetWind(float bendScale,float2 windMultiplier,float4 positionOS,float3 normalOS) 
{
    WindResult result = (WindResult) 0;
    //水平位移
    result.positionWS = mul( unity_ObjectToWorld,positionOS) ;
    float4 windUV = float4(result.positionWS.xz * _WindDirSize.w,0,0) ;
    half4 wind = tex2Dlod(_WindRT, windUV);
    wind.r = wind.r * (wind.g * 2.0f - 0.24376f);
    float windStrength = wind.r * _WindStrengthMultipliers.x * windMultiplier.x * bendScale;
    float2 windBend = UnityWorldToObjectDir(_WindDirSize.xyz).xz * windStrength;
    positionOS.xz -= windBend;
    //抖动
    float2 jitter = lerp(float2(_WindSinTime.x, 0), _WindSinTime.yz, float2(0.5, windStrength));
    positionOS += (jitter.x + jitter.y * windMultiplier.y) * (0.075 + _WindSinTime.w) * saturate(windStrength);
    result.positionWS = mul(unity_ObjectToWorld,float4(positionOS.xyz,1.0)) ;
    result.positionCS = mul(UNITY_MATRIX_VP, float4(result.positionWS.xyz,1.0));
    normalOS.xz -= windBend * 3.1415926;
    result.normalWS = UnityObjectToWorldNormal(normalOS);
    
    return result;
    
    
    
}


#endif