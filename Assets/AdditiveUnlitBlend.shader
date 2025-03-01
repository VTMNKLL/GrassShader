﻿Shader "Unlit/AdditiveUnlitBlend"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _RenderTex ("RenderTex", 2D) = "black" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {

			Blend One One
            BlendOp Add, Max
		
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float4 color : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                //UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
				float4 color : COLOR;
            };

            sampler2D _MainTex;
            sampler2D _RenderTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.color = v.color;
                //UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                //float2 rtUVs = ( worldPos.xz - G_RTCameraPosition.xz ) / ( 2 * G_RTCameraSize ) + float2( .5f, .5f );
                //fixed4 currentBend = tex2D(_RenderTex, rtUVs);

				float2 vec = col.rg;
				vec -= float2(.5f,.5f);
				vec *= 2.0f * col.a * i.color.a;

                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);
                return fixed4(vec,0.0f,col.a);
            }
            ENDCG
        }
    }
}
