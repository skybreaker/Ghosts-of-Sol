Shader "Custom/WorldAlignedGridTriColor" 
{
	Properties 
	{
		_StrokeColorX ("StrokeColorX", Color) = (1,0,0,1)
		_StrokeColorY ("StrokeColorY", Color) = (0,1,0,1)
		_StrokeColorZ ("StrokeColorZ", Color) = (0,0,1,1)
		_FillColor ("FillColor", Color) = (1,1,1,1)
		_StrokeWidth ("StrokeWidth", Range(0,1)) = 0.1
		_StrokeStrength ("StrokeStrength", Range(0,4)) = 1.0
		_StrokeSolidity ("StrokeSolidity", Range(0,100)) = 10
		_GridScale ("GridScale", Range(0.1,10)) = 1.0
		//_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
	}
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		//sampler2D _MainTex;

		struct Input {
			//float2 uv_MainTex;
			float3 worldPos;
			float4 screenPos;
			float3 worldNormal;
		};

		half _Glossiness;
		half _Metallic;
		half _GridScale;
		half _StrokeWidth;
		half _StrokeStrength;
		half _StrokeSolidity;
		fixed4 _StrokeColorX;
		fixed4 _StrokeColorY;
		fixed4 _StrokeColorZ;
		fixed4 _FillColor;

		void surf (Input IN, inout SurfaceOutputStandard o) 
		{
			// Albedo comes from a texture tinted by color
			//fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _FillColor;

			half xPos = IN.worldPos.x*_GridScale;
			half xDistance = abs(xPos - round(xPos));
			half xAlpha = saturate(xDistance / (_StrokeWidth));
			xAlpha = 1-saturate(lerp(-1*_StrokeSolidity, 1, xAlpha));
			xAlpha *= 1-abs(dot (half3(1,0,0), IN.worldNormal));

			half yPos = IN.worldPos.y*_GridScale;
			half yDistance = abs(yPos - round(yPos));
			half yAlpha = saturate(yDistance / (_StrokeWidth));
			yAlpha = 1-saturate(lerp(-1*_StrokeSolidity, 1, yAlpha));
			yAlpha *= 1-abs(dot (half3(0,1,0), IN.worldNormal));

			half zPos = IN.worldPos.z*_GridScale;
			half zDistance = abs(zPos - round(zPos));
			half zAlpha = saturate(zDistance / (_StrokeWidth));
			zAlpha = 1-saturate(lerp(-1*_StrokeSolidity, 1, zAlpha));
			zAlpha *= 1-abs(dot (half3(0,0,1), IN.worldNormal));

			fixed4 c = _FillColor + _StrokeStrength * (xAlpha * _StrokeColorX + yAlpha * _StrokeColorY + zAlpha * _StrokeColorZ);
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Emission = _StrokeStrength * (xAlpha * _StrokeColorX + yAlpha * _StrokeColorY + zAlpha * _StrokeColorZ);
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
