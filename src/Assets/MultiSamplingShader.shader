Shader "Unlit/MultiSamplingShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_OutlineColor("Outline color", Color) = (1,0,0,1)
		_OutlineSize("Outline Size", Range(0.00, 0.1)) = 0.01
	}
    SubShader
    {
		Tags { "RenderType" = "Transparent"  "Queue" = "Transparent" }
		LOD 100

		Blend  One OneMinusSrcAlpha
		ZTest Less

		Pass
        {
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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			float4 _MainTex_TexelSize;
			uniform fixed4	_OutlineColor;
			uniform fixed   _OutlineSize;
			uniform fixed _Cutoff;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			float sample_alpha(float2 uv, float2 offset)
			{
				return tex2D(_MainTex, uv + offset).a;
			}

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col0 = tex2D(_MainTex, i.uv);

				float a =
					max(sample_alpha(i.uv, float2(-_OutlineSize, 0)),
					max(sample_alpha(i.uv, float2(+_OutlineSize, 0)),
					max(sample_alpha(i.uv, float2(0, -_OutlineSize)),
					max(sample_alpha(i.uv, float2(0, +_OutlineSize)),
					col0.a)))) * _OutlineColor.a;
				fixed4 col;
				col.a = 1.0 - (1.0 - a) * (1.0 - col0.a);
				if(col.a < 0.005) discard;
				col.rgb = col0.a * col0.rgb + (1 - col0.a) * a * _OutlineColor.rgb;
				return col;
            }
            ENDCG
        }
    }
}

// a s + (1 - a) d
// a0 c0 + (1 - a0) (A C + (1 - A) d)
// a0 c0 + (1 - a0) A C + (1 - a0)(1 - A) d


