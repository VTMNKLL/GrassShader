// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/test"
{
    Properties {
      _MainTex ("Texture", 2D) = "white" {}
      _RenderTex ("RenderTex", 2D) = "black" {}
      _GrassHeight ("GrassHeight", float ) = 1
      _BendStrength ("GrassHeight", float ) = 1
      _Color ("Color", Color) = (1,1,1,1)
      _Glossiness ("Smoothness", Range(0,1)) = 0.5
      _Metallic ("Metallic", Range(0,1)) = 0.0

	  _Speed("MoveSpeed", Range(20,50)) = 25 // speed of the swaying
	  _Rigidness("Rigidness", Range(.001,50)) = 25 // lower makes it look more "liquid" higher makes it look rigid
	  _Scale("Scale", Range(0, 10)) = 1 // how far the swaying goes
    }
    SubShader {
      Cull off
      Tags { "RenderType" = "Opaque" }
      CGPROGRAM
      #pragma surface surf Standard vertex:vert addshadow fullforwardshadows

      struct Input
      {
          float2 uv_MainTex;
          float4 pos;
          // float4 vertex;
          float4 color;
      };

      float3 G_RTCameraPosition;
      float G_RTCameraSize;
      
      half _Glossiness;
      half _Metallic;
      fixed4 _Color;
      sampler2D _MainTex;
      sampler2D _RenderTex;
      float _GrassHeight;
      float _BendStrength;

	  float _Speed;
	  float _Rigidness;
	  float _Scale;

      float3 RotateAboutAxis( float3 p, float3 u, float angle )
      {
            float c = cos( angle );
            float s = sin( angle );
            float cr = 1-c;
            float sr = 1-s;
            float3x3 tm = float3x3(
                 float3( c + u.x*u.x*cr,     u.x*u.y*cr - u.z*s, u.x*u.z*cr + u.y*s ),
                 float3( u.y*u.x*cr + u.z*s, c + u.y*u.y*cr,     u.y*u.z*cr - u.x*s ),
                 float3( u.z*u.x*cr - u.y*s, u.z*u.y*cr + u.x*s, c + u.z*u.z*cr )
             );

             return mul( tm, p );
      }

      float3 RotateAroundYInDegrees(float3 vertex, float degrees)
      {
          float alpha = degrees;// *UNITY_PI / 180.0;
          float sina, cosa;
          sincos(alpha, sina, cosa);
          float2x2 m = float2x2(cosa, sina, -sina, cosa);
          //return float3(mul(m, vertex.xz), vertex.y).xzy;
          return float3(mul(m, vertex.xz), vertex.y).xzy;
      }

      void vert( inout appdata_base v, out Input o )
      {
          UNITY_INITIALIZE_OUTPUT(Input,o);
          float4 worldPos = mul( unity_ObjectToWorld, v.vertex );
          o.pos = worldPos;

          float2 camToWorldPosDir = -normalize( worldPos.xz - _WorldSpaceCameraPos.xz );
          float billboardAngle    = atan2( camToWorldPosDir.x, camToWorldPosDir.y ) + 3.14159;
		  //billboardAngle = 0;
          v.vertex.xyz = RotateAroundYInDegrees( v.vertex.xyz, billboardAngle );
          worldPos = mul( unity_ObjectToWorld, v.vertex );

          // o.vertex = v.vertex;
          float2 rtUVs    = ( worldPos.xz - G_RTCameraPosition.xz ) / ( 2 * G_RTCameraSize ) + float2( .5f, .5f );
          float4 tmp      = tex2Dlod( _RenderTex, float4( rtUVs, 0, 0 ) );
          float3 bendDir  = float3( tmp.x, 0, tmp.y );
          float bendStrength = tmp.a * _BendStrength;
          //bendDir         = normalize( bendDir );
          //bendDir         = normalize( bendDir );
          float normalizedHeight = v.vertex.y / _GrassHeight;
          // can do texture lookup for non-linear bend angle

		  float x = sin(worldPos.x / _Rigidness + (_Time.x * _Speed));
		  float z = sin(worldPos.z / _Rigidness + (_Time.x * _Speed));
		  //float3 windBendDir = float3(_Scale * x, 0, _Scale * z);

		  bendDir = normalize(bendDir);
		  //bendDir += windBendDir;
		  //bendStrength += length(windBendDir);
		  float bendAngle = bendStrength * normalizedHeight;

          //bendAxis = float3( 1, 0, 0 );

          //bendAngle = 3.14159 / 4;

		  bendDir = normalize(bendDir);
		  bendDir = mul(unity_WorldToObject, float4(bendDir, 0)).xyz; // maaaaaybe inv(transpose(4x4 mat));
		  float3 bendAxis = normalize(cross(float3(0, 1, 0), bendDir));

		  if (bendDir.y < .5 ) {
		  //if (length(float2(bendDir.x, bendDir.z)) > 0) {
			  v.vertex.xyz = RotateAboutAxis(v.vertex.xyz, bendAxis, bendAngle);
		  }
          //v.vertex.xyz += bendDir;
          //v.vertex.w = 1;
          //o.color.rgb  = float3( bendStrength, 0, 0 );
          //o.color.rgb = 5.*bendAxis + float3(.5,.5,.5);
		  o.color = _Color;
      }


      void surf( Input IN, inout SurfaceOutputStandard o )
      {
          o.Albedo = tex2D( _MainTex, IN.uv_MainTex ).rgb * IN.color.rgb;
          //o.Albedo = float3( 0, 1, 0 );
          o.Metallic = _Metallic;
          o.Smoothness = _Glossiness;
          o.Alpha = 1;
      }
      ENDCG
    }
    Fallback "Diffuse"
}
