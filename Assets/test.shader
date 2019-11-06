// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/test"
{
    Properties {
      _MainTex ("Texture", 2D) = "white" {}
      _RenderTex ("RenderTex", 2D) = "black" {}
      _GrassHeight ("GrassHeight", float ) = 1
    }
    SubShader {
      Tags { "RenderType" = "Opaque" }
      CGPROGRAM
      #pragma surface surf Lambert vertex:vert

      struct Input {
          float2 uv_MainTex;
          float4 pos;
          float4 vertex;
      };

      float3 G_RTCameraPosition;
      float G_RTCameraSize;
      
      sampler2D _MainTex;
      sampler2D _RenderTex;
      float _GrassHeight;

      void vert (inout appdata_full v, out Input o) {
          UNITY_INITIALIZE_OUTPUT(Input,o);
          float4 worldPos = mul( unity_ObjectToWorld, v.vertex );
          o.pos = worldPos;
          o.vertex = v.vertex;
          // float2 rtUVs    = ( worldPos.xz - G_RTCameraPosition.xz ) / ( 2 * G_RTCameraSize ) + float2( .5f, .5f );
          // float2 tmp      = tex2Dlod( _RenderTex, float4( rtUVs, 0, 0 ) );
          // float3 bendDir  = float3( tmp.x, 0.00001, tmp.y );
          // float bendStrength = length( bendDir ) * 2.12;
          // bendDir         = normalize( bendDir );
          // bendDir         = mul( unity_WorldToObject, float4( bendDir, 0 ) ).xyz; // maaaaaybe inv(transpose(4x4 mat));
          // bendDir         = normalize( bendDir );
          // float normalizedHeight = v.vertex.y / _GrassHeight;
          //  // can do texture lookup for non-linear bend angle
          // 
          // float bendAngle = bendStrength * normalizedHeight;
          // o.color   = float4( 0, 0, 0, 0 );
          // o.color.r = length( bendStrength );
      }


      void surf (Input IN, inout SurfaceOutput o) {
          // o.Albedo = tex2D( _MainTex, IN.uv_MainTex ).rgb * IN.color.rgb;
          // o.Albedo = IN.color.rgb;

          float2 rtUVs    = ( IN.pos.xz - G_RTCameraPosition.xz ) / ( 2 * G_RTCameraSize ) + float2( .5f, .5f );
          float4 tmp      = tex2D( _RenderTex, rtUVs );
          float3 bendDir  = float3( tmp.x, 0.00001, tmp.y );
          fixed bendStrength = tmp.a;
          bendDir         = normalize( bendDir );
          bendDir         = mul( unity_WorldToObject, float4( bendDir, 0 ) ).xyz; // maaaaaybe inv(transpose(4x4 mat));
          bendDir         = normalize( bendDir );
          float normalizedHeight = IN.vertex.y / _GrassHeight;
          //  // can do texture lookup for non-linear bend angle

          float bendAngle = bendStrength * normalizedHeight;
          //o.Albedo = float3( bendAngle, 0, 0 );
          o.Albedo = float3( bendStrength, 0, 0 );
      }
      ENDCG
    } 
    Fallback "Diffuse"
}
