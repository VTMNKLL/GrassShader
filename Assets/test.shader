// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/test"
{
    Properties {
      _MainTex ("Texture", 2D) = "white" {}
      _RenderTex ("RenderTex", 2D) = "black" {}
      _GrassHeight ("GrassHeight", float ) = 1
      _BendStrength ("GrassHeight", float ) = 1
    }
    SubShader {
Cull off
      Tags { "RenderType" = "Opaque" }
      CGPROGRAM
      #pragma surface surf Lambert vertex:vert addshadow fullforwardshadows

      
      
     

      struct Input {
          float2 uv_MainTex;
          float4 pos;
          // float4 vertex;
          float4 color;
      };

      float3 G_RTCameraPosition;
      float G_RTCameraSize;
      
      sampler2D _MainTex;
      sampler2D _RenderTex;
      float _GrassHeight;
      float _BendStrength;

      float3 RotateAboutAxis(float3 p, float3 u, float angle) {
            float c = cos(angle);
            float s = sin(angle);
            float cr = 1-c;
            float sr = 1-s;
            float3x3 tm = float3x3(
                 float3(c + u.x*u.x*cr,     u.x*u.y*cr - u.z*s,  u.x*u.z*cr + u.y*s),
                 float3(u.y*u.x*cr + u.z*s,   c + u.y*u.y*cr,    u.y*u.z*cr - u.x*s),
                 float3(u.z*u.x*cr - u.y*s,   u.z*u.y*cr + u.x*s,  c + u.z*u.z*cr)
             );

             return mul(tm, p);
        }

      void vert (inout appdata_base v, out Input o) {
          UNITY_INITIALIZE_OUTPUT(Input,o);
          float4 worldPos = mul( unity_ObjectToWorld, v.vertex );
          o.pos = worldPos;
          // o.vertex = v.vertex;
          float2 rtUVs    = ( worldPos.xz - G_RTCameraPosition.xz ) / ( 2 * G_RTCameraSize ) + float2( .5f, .5f );
          float4 tmp      = tex2Dlod( _RenderTex, float4( rtUVs, 0, 0 ) );
          float3 bendDir  = float3( tmp.x + 0.0001, 0.0001, tmp.y );
          float bendStrength = tmp.a * _BendStrength;
          bendDir         = normalize( bendDir );
          bendDir         = mul( unity_WorldToObject, float4( bendDir, 0 ) ).xyz; // maaaaaybe inv(transpose(4x4 mat));
          bendDir         = normalize( bendDir );
          float normalizedHeight = v.vertex.y / _GrassHeight;
          // can do texture lookup for non-linear bend angle
          
          float bendAngle = bendStrength * normalizedHeight;

          float3 bendAxis = normalize( cross( float3( 0, 1, 0 ), bendDir ) );
          //bendAxis = float3( 1, 0, 0 );

          //bendAngle = 3.14159 / 4;
          if (bendDir.y < .4 )
            v.vertex.xyz = RotateAboutAxis( v.vertex.xyz, bendAxis, bendAngle );
          //v.vertex.xyz += bendDir;
          //v.vertex.w = 1;
          //o.color.rgb  = float3( bendStrength, 0, 0 );
          o.color.rgb = 5.*bendAxis + float3(.5,.5,.5);
      }


      void surf (Input IN, inout SurfaceOutput o) {
          o.Albedo = tex2D( _MainTex, IN.uv_MainTex ).rgb * IN.color.rgb;
          o.Albedo = float3( 0, 1, 0 );

          // float2 rtUVs    = ( IN.pos.xz - G_RTCameraPosition.xz ) / ( 2 * G_RTCameraSize ) + float2( .5f, .5f );
          // float4 tmp      = tex2D( _RenderTex, rtUVs );
          // float3 bendDir  = float3( tmp.x, 0.00001, tmp.y );
          // fixed bendStrength = tmp.a;
          // bendDir         = normalize( bendDir );
          // bendDir         = mul( unity_WorldToObject, float4( bendDir, 0 ) ).xyz; // maaaaaybe inv(transpose(4x4 mat));
          // bendDir         = normalize( bendDir );
          // float normalizedHeight = IN.vertex.y / _GrassHeight;
          // 
          // float bendAngle = bendStrength * normalizedHeight;
          //o.Albedo = float3( bendAngle, 0, 0 );
          // o.Albedo = float3( bendStrength, 0, 0 );
      }
      ENDCG
    }
    Fallback "Diffuse"
}
