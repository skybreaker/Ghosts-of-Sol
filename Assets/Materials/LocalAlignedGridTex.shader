Shader "Custom/LocalAlignedGridTex"  {
  Properties {
		_MainTex("Grid Texture (Grayscale)", 2D) = "white" {}
		_StrokeColor ("Stroke Color", Color) = (1,1,1,1)
		_FillColor ("Fill Color", Color) = (0,0,0,1)
		_StrokeDiffuseStrength ("Stroke Diffuse Strength", Range(0,1)) = 1.0
		_StrokeEmissionStrength ("Stroke Emission Strength", Range(0,8)) = 1.0
		_StrokeSlopeExponent ("Stroke Slope Exponent", Range(0,64)) = 1.0
		_GridScale ("Grid Scale", Range(0.1,10)) = 1.0
	}
	
	SubShader {
		
		Tags { "RenderType"="Opaque" "DisableBatching" = "True"}
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows vertex:vert

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		//uniform float4 _MainTex_ST;
		fixed4 _StrokeColor;
		fixed4 _FillColor;
		half _StrokeDiffuseStrength;
		half _StrokeEmissionStrength;
		half _StrokeSlopeExponent;
		half _GridScale;
		
		struct Input {
			half3 localPos;
			half3 localNormal;
		};

		void vert (inout appdata_full v, out Input o) 
		{
	         UNITY_INITIALIZE_OUTPUT(Input,o);
  			 o.localPos = v.vertex.xyz;
  			 o.localNormal = v.normal;
	    }
			
		void surf (Input IN, inout SurfaceOutputStandard o) 
		{
			half4 modelX = half4(_GridScale, 0.0, 0.0, 0.0);
			half4 modelY = half4(0.0, _GridScale, 0.0, 0.0);
			half4 modelZ = half4(0.0, 0.0, _GridScale, 0.0);
			 
			half4 modelXInWorld = mul(_Object2World, modelX);
			half4 modelYInWorld = mul(_Object2World, modelY);
			half4 modelZInWorld = mul(_Object2World, modelZ);
			 
			half scaleX = length(modelXInWorld);
			half scaleY = length(modelYInWorld);
			half scaleZ = length(modelZInWorld);

			half3 projNormal = saturate(pow(IN.localNormal * 1.4, 4));
			
			// SIDE X
			half x = tex2D(_MainTex, IN.localPos.zy * half2(scaleZ, scaleY) + 0.5*half2(scaleZ, scaleY) ) * abs(IN.localNormal.x).r;
			
			// SIDE Y
			half y = tex2D(_MainTex, IN.localPos.zx * half2(scaleZ, scaleX) + 0.5*half2(scaleZ, scaleX) ) * abs(IN.localNormal.y).r;
						
			// SIDE Z	
			half z = tex2D(_MainTex, IN.localPos.xy * half2(scaleX, scaleY) + 0.5*half2(scaleX, scaleY)) * abs(IN.localNormal.z).r;

			projNormal = pow(normalize(projNormal), _StrokeSlopeExponent);
			half alpha = max(x*projNormal.x, max(y*projNormal.y, z*projNormal.z));
			o.Albedo = lerp(_FillColor, _StrokeColor, alpha*_StrokeDiffuseStrength);
			o.Emission = lerp(0, _StrokeColor, alpha*_StrokeEmissionStrength);
		} 
		ENDCG
	}
	Fallback "Diffuse"
}