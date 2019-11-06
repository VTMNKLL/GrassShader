Shader "Custom/BestGrassShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members _MainTex_ST)
#pragma exclude_renderers d3d11
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;


		/*struct appdata
		{
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			float4 uv_MainTex : TEXCOORD0;
		};*/

       /* struct v2f
        {
			float4 pos : SV_POSITION;
            float2 uv_MainTex : TEXCOORD0;

        };*/

		struct Input
		{
			float4 vertex;
			float2 uv_MainTex;
			//float4 color;
		};


        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
		float4 _MainTex_ST;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)


		void vert(inout appdata_full v, out Input v2f)
		{
			UNITY_INITIALIZE_OUTPUT(Input, v2f);

			v2f.vertex = UnityObjectToClipPos(v.vertex);
			
			float2 tex = TRANSFORM_TEX(v.texcoord, _MainTex);
			v2f.uv_MainTex = tex;
			//o.color = v.color;
			//UNITY_TRANSFER_FOG(o,o.vertex);
			//return o;
		}

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
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
