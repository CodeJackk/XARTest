Shader"Custom/ObjectAShader"
{
    Properties
    {
        _MainTex ("Base Texture", 2D) = "white" {}
        _DeformStrength ("Deformation Strength", Float) = 0.1
        _NoiseScale ("Noise Scale", Float) = 1.0
        _TimeSpeed ("Time Speed", Float) = 1.0
        _TargetObject ("Target Object", Vector) = (0, 0, 0, 0)
        _RedColor ("Red Color", Color) = (1, 0, 0, 1)
        _BlueColor ("Blue Color", Color) = (0, 0, 1, 1)
        _Metallic ("Metallic", Range(0, 1)) = 0.5
        _Smoothness ("Smoothness", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
#include "UnityCG.cginc"

struct appdata
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
};

struct v2f
{
    float4 pos : SV_POSITION;
    float3 worldPos : TEXCOORD0;
    float3 normal : TEXCOORD1;
};

            // Properties
float _DeformStrength;
float _NoiseScale;
float _TimeSpeed;
float4 _TargetObject;
float4 _RedColor;
float4 _BlueColor;
float _Metallic;
float _Smoothness;

float3 mod289(float3 x)
{
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float4 mod289(float4 x)
{
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float4 permute(float4 x)
{
    return mod289(((x * 34.0) + 1.0) * x);
}

float4 taylorInvSqrt(float4 r)
{
    return 1.79284291400159 - 0.85373472095314 * r;
}

float3 fade(float3 t)
{
    return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}

float cnoise(float3 position)
{
    float3 gridCorner0 = floor(position);
    float3 gridCorner1 = gridCorner0 + float3(1.0, 1.0, 1.0);
    gridCorner0 = mod289(gridCorner0);
    gridCorner1 = mod289(gridCorner1);
    float3 localPosition0 = frac(position);
    float3 localPosition1 = localPosition0 - float3(1.0, 1.0, 1.0);

    float4 xCorners = float4(gridCorner0.x, gridCorner1.x, gridCorner0.x, gridCorner1.x);
    float4 yCorners = float4(gridCorner0.yy, gridCorner1.yy);
    float4 zCorner0 = gridCorner0.zzzz;
    float4 zCorner1 = gridCorner1.zzzz;

    float4 permutedXY = permute(permute(xCorners) + yCorners);
    float4 permutedXY0 = permute(permutedXY + zCorner0);
    float4 permutedXY1 = permute(permutedXY + zCorner1);

    float4 gradientX0 = permutedXY0 * (1.0 / 7.0);
    float4 gradientY0 = frac(floor(gradientX0) * (1.0 / 7.0)) - 0.5;
    gradientX0 = frac(gradientX0);
    float4 gradientZ0 = float4(0.5, 0.5, 0.5, 0.5) - abs(gradientX0) - abs(gradientY0);
    float4 stepZ0 = step(gradientZ0, float4(0.0, 0.0, 0.0, 0.0));
    gradientX0 -= stepZ0 * (step(0.0, gradientX0) - 0.5);
    gradientY0 -= stepZ0 * (step(0.0, gradientY0) - 0.5);

    float4 gradientX1 = permutedXY1 * (1.0 / 7.0);
    float4 gradientY1 = frac(floor(gradientX1) * (1.0 / 7.0)) - 0.5;
    gradientX1 = frac(gradientX1);
    float4 gradientZ1 = float4(0.5, 0.5, 0.5, 0.5) - abs(gradientX1) - abs(gradientY1);
    float4 stepZ1 = step(gradientZ1, float4(0.0, 0.0, 0.0, 0.0));
    gradientX1 -= stepZ1 * (step(0.0, gradientX1) - 0.5);
    gradientY1 -= stepZ1 * (step(0.0, gradientY1) - 0.5);

    float3 gradient000 = float3(gradientX0.x, gradientY0.x, gradientZ0.x);
    float3 gradient100 = float3(gradientX0.y, gradientY0.y, gradientZ0.y);
    float3 gradient010 = float3(gradientX0.z, gradientY0.z, gradientZ0.z);
    float3 gradient110 = float3(gradientX0.w, gradientY0.w, gradientZ0.w);
    float3 gradient001 = float3(gradientX1.x, gradientY1.x, gradientZ1.x);
    float3 gradient101 = float3(gradientX1.y, gradientY1.y, gradientZ1.y);
    float3 gradient011 = float3(gradientX1.z, gradientY1.z, gradientZ1.z);
    float3 gradient111 = float3(gradientX1.w, gradientY1.w, gradientZ1.w);

    float4 normalization0 = taylorInvSqrt(float4(dot(gradient000, gradient000), dot(gradient010, gradient010), dot(gradient100, gradient100), dot(gradient110, gradient110)));
    gradient000 *= normalization0.x;
    gradient010 *= normalization0.y;
    gradient100 *= normalization0.z;
    gradient110 *= normalization0.w;

    float4 normalization1 = taylorInvSqrt(float4(dot(gradient001, gradient001), dot(gradient011, gradient011), dot(gradient101, gradient101), dot(gradient111, gradient111)));
    gradient001 *= normalization1.x;
    gradient011 *= normalization1.y;
    gradient101 *= normalization1.z;
    gradient111 *= normalization1.w;

    float dot000 = dot(gradient000, localPosition0);
    float dot100 = dot(gradient100, float3(localPosition1.x, localPosition0.yz));
    float dot010 = dot(gradient010, float3(localPosition0.x, localPosition1.y, localPosition0.z));
    float dot110 = dot(gradient110, float3(localPosition1.xy, localPosition0.z));
    float dot001 = dot(gradient001, float3(localPosition0.xy, localPosition1.z));
    float dot101 = dot(gradient101, float3(localPosition1.x, localPosition0.y, localPosition1.z));
    float dot011 = dot(gradient011, float3(localPosition0.x, localPosition1.yz));
    float dot111 = dot(gradient111, localPosition1);

    float3 fadePosition = fade(localPosition0);
    float4 lerpZ = lerp(float4(dot000, dot100, dot010, dot110), float4(dot001, dot101, dot011, dot111), fadePosition.z);
    float2 lerpYZ = lerp(lerpZ.xy, lerpZ.zw, fadePosition.y);
    float finalValue = lerp(lerpYZ.x, lerpYZ.y, fadePosition.x);

    return 2.2 * finalValue;
}




v2f vert(appdata v)
{
    v2f o;

    // Calculate local Perlin noise
    float noise = cnoise(v.vertex.xyz * _NoiseScale + _TimeSpeed * _Time.y);
    float3 localOffset = v.normal * noise * _DeformStrength;

    // Calculate the average displacement for the entire object (approximation)
    // This ensures the deformation doesn't move the object's origin
    float3 offsetCorrection = float3(0.0, 0.0, 0.0);

    // Apply local deformation to the vertex
    float3 deformedPos = v.vertex.xyz + localOffset - offsetCorrection;

    // Transform to clip space
    o.pos = UnityObjectToClipPos(float4(deformedPos, 1.0));
    o.worldPos = mul(unity_ObjectToWorld, float4(deformedPos, 1.0)).xyz;
    o.normal = normalize(mul((float3x3) unity_ObjectToWorld, v.normal));
    return o;
}

half4 frag(v2f i) : SV_Target
{
    // Calculate direction to the target
    float3 toTarget = normalize(_TargetObject.xyz - i.worldPos);

    // Object's forward direction (Z-axis)
    float3 objectForward = normalize(mul((float3x3) unity_ObjectToWorld, float3(0, 0, 1)));

    // Dot product for color blending
    float dotProd = dot(objectForward, toTarget);
    half4 baseColor = lerp(_BlueColor, _RedColor, (dotProd + 1.0) * 0.5);

    // Calculate view direction and reflection
    float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
    float3 reflectDir = reflect(-viewDir, i.normal);

    // Specular highlight
    float3 halfDir = normalize(viewDir + toTarget);
    float spec = pow(max(dot(i.normal, halfDir), 0.0), 32.0);

    // Combine base color with metallic and specular
    half3 metallicColor = lerp(baseColor.rgb, float3(0.04, 0.04, 0.04), _Metallic); // Fresnel effect
    half3 finalColor = metallicColor + spec * _Smoothness;

    return half4(finalColor, 1.0);
}
            ENDCG
        }
    }
Fallback"Diffuse"
}
