Shader "Custom/WorldAlignedGrid" 
{
	Properties 
	{
		_StrokeColor ("StrokeColor", Color) = (1,1,1,1)
		_FillColor ("FillColor", Color) = (1,1,1,1)
		_StrokeWidth ("StrokeWidth", Range(0,1)) = 0.1
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
		};

		half _Glossiness;
		half _Metallic;
		half _GridScale;
		half _StrokeWidth;
		fixed4 _StrokeColor;
		fixed4 _FillColor;

		void surf (Input IN, inout SurfaceOutputStandard o) 
		{
			// Albedo comes from a texture tinted by color
			//fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _FillColor;
			half minDist = min(abs(IN.worldPos.x - round(IN.worldPos.x)), abs(IN.worldPos.z - round(IN.worldPos.z)));
			minDist = min(minDist, abs(IN.worldPos.y - round(IN.worldPos.y)));

			half alpha = saturate(minDist / (_StrokeWidth*_GridScale));

			//float depth = 1.0 - saturate(IN.screenPos.z/10);  

			alpha = saturate(lerp(-10, 1, alpha));

			fixed4 c = lerp( _StrokeColor, _FillColor, alpha );
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
