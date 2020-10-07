#pragma once
//keep in mind to always add lights. But multiply the sum to the final color. 
//This method applies ambient light from directional and lightprobes.
float4 applyLight(PIO process, float4 color) {
	float4 output = float4(0, 0, 0, 1);

	/************************
	* Brightness / toon edge:
	************************/
	//I supply the attenuation to the ToonDot, to be the constant muliplier with dotl calculation, 
	//Before the toon ramp is calculated.
	UNITY_LIGHT_ATTENUATION(attenuation, process, process.worldPosition);
#if defined(UNITY_PASS_FORWARDADD)
	//foward add lighting and details from pixel lights.
	float3 direction = normalize(_WorldSpaceLightPos0.xyz - process.worldPosition.xyz);
	#if defined(POINT_COOKIE) || defined(SPOT) 
		//let spotlights just be spotlights.
		float brightness = dot(direction,process.worldNormal) * attenuation;
	#else
		float brightness = ToonDot(direction, process.worldNormal, attenuation);
	#endif
#else
	#if !defined(LIGHTMAP_ON)

		//Calculate light probes from foward base.
		float3 ambientDirection = unity_SHAr.xyz + unity_SHAg.xyz + unity_SHAb.xyz; //do not normalize
		float brightness = ToonDot(ambientDirection, process.worldNormal.xyz, 1 );
		//brightness = brightness * 2 - 1; //only light probes get a potentionally negative value.
		//just add the directional light.
		float directBrightness = ToonDot(normalize(_WorldSpaceLightPos0.xyz), process.worldNormal.xyz, attenuation);
	#endif
#endif

	/************************
	* Color:
	************************/
#if defined(UNITY_PASS_FORWARDADD)
	//get directional color:
	float3 lightColor = _LightColor0.rgb * brightness;
	lightColor *= color.rgb;
	output.rgb += lightColor;
#else

	//Keep in mind color is added, and any time it's added it's +(basecolor * light)
	#if defined(LIGHTMAP_ON)
		float3 lightmapCol = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, process.lmuv));
		lightmapCol += _LMBrightness;
		output.rgb += color.rgb * lightmapCol;
	#else
		//ambient color (lightprobes): 
		float3 probeColor = ShadeSH9(float4(0, 0, 0, 1));
		probeColor *= brightness;
		output.rgb += color.rgb * probeColor;
	
		float3 directColor = _LightColor0.rgb;
		directColor *= directBrightness;
		directColor *= color.rgb;
		output.rgb += directColor;

		//vertex Lights
		#ifdef VERTEXLIGHT_ON
			float3 vcolor = process.vcolor * color.rgb;
			output.rgb += vcolor;
		#endif
	#endif

	//The final blend
	output.rgb *= (1 - _Height);//height brightness
#endif
	output.a = color.a;
	return output;
}
