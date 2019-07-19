Shader "Unlit/4TimesShader"
{
    Properties
    {
		_MainTex("Texture", 2D) = "white" {}
		_OutlineColor("Outline color", Color) = (1,0,0,1)
		_OutlineSize("Outline Size", Range(0.00, 0.1)) = 0.01
	}
	CGINCLUDE
	#include "UnityCG.cginc"

	struct appdata
	{
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
	};

	struct v2f
	{
		float2 uv : TEXCOORD0;
		float4 vertex : SV_POSITION;
	};

	sampler2D _MainTex;
	float4 _MainTex_ST;
	uniform fixed4	_OutlineColor;
	uniform fixed   _OutlineSize;
	uniform fixed _Cutoff;

	v2f vert_sub(appdata v, float2 offset) {
		v2f o;
		float depth = UnityObjectToViewPos(v.vertex).z;
		o.vertex = UnityObjectToClipPos(v.vertex.xyzw + depth * float4(offset.x, 0, offset.y, 0));
		o.uv = TRANSFORM_TEX(v.uv, _MainTex);
		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{
		return fixed4(_OutlineColor.xyz, tex2D(_MainTex, i.uv).a * _OutlineColor.a);
	}
	ENDCG

		
	SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent-1"  }
        LOD 100

		Blend  SrcAlpha OneMinusSrcAlpha
		ZWrite Off
		ZTest Less

		Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            v2f vert (appdata v)
            {
				return vert_sub(v, float2(-_OutlineSize, 0));
			}
            ENDCG
        }

		Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            v2f vert (appdata v)
            {
				return vert_sub(v, float2(+_OutlineSize, 0));
			}
            ENDCG
        }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			v2f vert(appdata v)
			{
				return vert_sub(v, float2(0, -_OutlineSize));
			}
			ENDCG
		}


		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			v2f vert(appdata v)
			{
				return vert_sub(v, float2(0, +_OutlineSize));
			}
			ENDCG
		}
	}
}
