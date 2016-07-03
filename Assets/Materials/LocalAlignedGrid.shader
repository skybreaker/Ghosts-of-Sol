Shader "Custom/LocalAlignedGrid" 
{
	Properties 
	{
		_StrokeColor ("Stroke Color", Color) = (1,0,0,1)
		_FillColor ("Fill Color", Color) = (1,1,1,1)
		_StrokeWidth ("Stroke Width", Range(0,1)) = 0.1
		_StrokeDiffuseStrength ("Stroke DiffuseStrength", Range(0,4)) = 1.0
		_StrokeEmissionStrength ("Stroke EmissionStrength", Range(0,4)) = 1.0
		_StrokeSolidity ("Stroke Solidity", Range(0,100)) = 10
		_GridScale ("Grid Scale", Range(0.1,10)) = 1.0
		//_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
	}
	SubShader 
	{
		Tags { "RenderType"="Opaque" "DisableBatching" = "True"}
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows vertex:vert

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		//sampler2D _MainTex;
 
		

		struct Input {
			//float2 uv_MainTex;
			float3 worldPos;
			float3 localPos;
			float3 localNormal;
		};

		void vert (inout appdata_full v, out Input o) 
		{
	         UNITY_INITIALIZE_OUTPUT(Input,o);
  			 o.localPos = v.vertex.xyz;
  			 o.localNormal = v.normal;
	    }

		half _Glossiness;
		half _Metallic;
		half _GridScale;
		half _StrokeWidth;
		half _StrokeDiffuseStrength;
		half _StrokeEmissionStrength;
		half _StrokeSolidity;
		fixed4 _StrokeColor;
		fixed4 _FillColor;

		void surf (Input IN, inout SurfaceOutputStandard o) 
		{
			float4 modelX = float4(1.0, 0.0, 0.0, 0.0);
			float4 modelY = float4(0.0, 1.0, 0.0, 0.0);
			float4 modelZ = float4(0.0, 0.0, 1.0, 0.0);
			 
			float4 modelXInWorld = mul(_Object2World, modelX);
			float4 modelYInWorld = mul(_Object2World, modelY);
			float4 modelZInWorld = mul(_Object2World, modelZ);
			 
			float scaleX = length(modelXInWorld);
			float scaleY = length(modelYInWorld);
			float scaleZ = length(modelZInWorld);

			// Albedo comes from a texture tinted by color
			//fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _FillColor;

			half xPos = IN.localPos.x*_GridScale*scaleX + 0.5*scaleX;
			half xDistance = abs(xPos - round(xPos));
			half xAlpha = saturate(xDistance / (_StrokeWidth));
			xAlpha = 1-saturate(lerp(-1*_StrokeSolidity, 1, xAlpha));
			xAlpha *= 1-abs(dot (half3(1,0,0), IN.localNormal));

			half yPos = IN.localPos.y*_GridScale*scaleY + 0.5*scaleY;
			half yDistance = abs(yPos - round(yPos));
			half yAlpha = saturate(yDistance / (_StrokeWidth));
			yAlpha = 1-saturate(lerp(-1*_StrokeSolidity, 1, yAlpha));
			yAlpha *= 1-abs(dot (half3(0,1,0), IN.localNormal));

			half zPos = IN.localPos.z*_GridScale*scaleZ + 0.5*scaleZ;
			half zDistance = abs(zPos - round(zPos));
			half zAlpha = saturate(zDistance / (_StrokeWidth));
			zAlpha = 1-saturate(lerp(-1*_StrokeSolidity, 1, zAlpha));
			zAlpha *= 1-abs(dot (half3(0,0,1), IN.localNormal));

			//half3 vPos = IN.vertex;

			fixed4 c = _FillColor + _StrokeDiffuseStrength * max(max(xAlpha, yAlpha), zAlpha)*_StrokeColor;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Emission = _StrokeEmissionStrength * max(max(xAlpha, yAlpha), zAlpha)*_StrokeColor;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
