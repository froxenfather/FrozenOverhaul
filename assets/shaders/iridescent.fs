#if defined(VERTEX) || __VERSION__ > 100 || defined(GL_FRAGMENT_PRECISION_HIGH)
	#define MY_HIGHP_OR_MEDIUMP highp
#else
	#define MY_HIGHP_OR_MEDIUMP mediump
#endif

extern MY_HIGHP_OR_MEDIUMP vec2 iridescent;
extern MY_HIGHP_OR_MEDIUMP float dissolve;
extern MY_HIGHP_OR_MEDIUMP float time;
extern MY_HIGHP_OR_MEDIUMP vec4 texture_details;
extern MY_HIGHP_OR_MEDIUMP vec2 image_details;
extern bool shadow;
extern MY_HIGHP_OR_MEDIUMP vec4 burn_colour_1;
extern MY_HIGHP_OR_MEDIUMP vec4 burn_colour_2;

vec4 dissolve_mask(vec4 tex, vec2 texture_coords, vec2 uv)
{
    if (dissolve < 0.001) {
        return vec4(shadow ? vec3(0.,0.,0.) : tex.xyz, shadow ? tex.a*0.3: tex.a);
    }

    float adjusted_dissolve = (dissolve*dissolve*(3.-2.*dissolve))*1.02 - 0.01; //Adjusting 0.0-1.0 to fall to -0.1 - 1.1 scale so the mask does not pause at extreme values

	float t = time * 10.0 + 2003.;
	vec2 floored_uv = (floor((uv*texture_details.ba)))/max(texture_details.b, texture_details.a);
    vec2 uv_scaled_centered = (floored_uv - 0.5) * 2.3 * max(texture_details.b, texture_details.a);
	
	vec2 field_part1 = uv_scaled_centered + 50.*vec2(sin(-t / 143.6340), cos(-t / 99.4324));
	vec2 field_part2 = uv_scaled_centered + 50.*vec2(cos( t / 53.1532),  cos( t / 61.4532));
	vec2 field_part3 = uv_scaled_centered + 50.*vec2(sin(-t / 87.53218), sin(-t / 49.0000));

    float field = (1.+ (
        cos(length(field_part1) / 19.483) + sin(length(field_part2) / 33.155) * cos(field_part2.y / 15.73) +
        cos(length(field_part3) / 27.193) * sin(field_part3.x / 21.92) ))/2.;
    vec2 borders = vec2(0.2, 0.8);

    float res = (.5 + .5* cos( (adjusted_dissolve) / 82.612 + ( field + -.5 ) *3.14))
    - (floored_uv.x > borders.y ? (floored_uv.x - borders.y)*(5. + 5.*dissolve) : 0.)*(dissolve)
    - (floored_uv.y > borders.y ? (floored_uv.y - borders.y)*(5. + 5.*dissolve) : 0.)*(dissolve)
    - (floored_uv.x < borders.x ? (borders.x - floored_uv.x)*(5. + 5.*dissolve) : 0.)*(dissolve)
    - (floored_uv.y < borders.x ? (borders.x - floored_uv.y)*(5. + 5.*dissolve) : 0.)*(dissolve);

    if (tex.a > 0.01 && burn_colour_1.a > 0.01 && !shadow && res < adjusted_dissolve + 0.8*(0.5-abs(adjusted_dissolve-0.5)) && res > adjusted_dissolve) {
        if (!shadow && res < adjusted_dissolve + 0.5*(0.5-abs(adjusted_dissolve-0.5)) && res > adjusted_dissolve) {
            tex.rgba = burn_colour_1.rgba;
        } else if (burn_colour_2.a > 0.01) {
            tex.rgba = burn_colour_2.rgba;
        }
    }

    return vec4(shadow ? vec3(0.,0.,0.) : tex.xyz, res > adjusted_dissolve ? (shadow ? tex.a*0.3: tex.a) : .0);
}

float hue(float s, float t, float h)
{
	float hs = mod(h, 1.)*6.;
	if (hs < 1.) return (t-s) * hs + s;
	if (hs < 3.) return t;
	if (hs < 4.) return (t-s) * (4.-hs) + s;
	return s;
}

vec4 RGB(vec4 c)
{
	if (c.y < 0.0001)
		return vec4(vec3(c.z), c.a);

	float t = (c.z < .5) ? c.y*c.z + c.z : -c.y*c.z + (c.y+c.z);
	float s = 2.0 * c.z - t;
	return vec4(hue(s,t,c.x + 1./3.), hue(s,t,c.x), hue(s,t,c.x - 1./3.), c.w);
}

vec4 HSL(vec4 c)
{
	float low = min(c.r, min(c.g, c.b));
	float high = max(c.r, max(c.g, c.b));
	float delta = high - low;
	float sum = high+low;

	vec4 hsl = vec4(.0, .0, .5 * sum, c.a);
	if (delta == .0)
		return hsl;

	hsl.y = (hsl.z < .5) ? delta / sum : delta / (2.0 - sum);

	if (high == c.r)
		hsl.x = (c.g - c.b) / delta;
	else if (high == c.g)
		hsl.x = (c.b - c.r) / delta + 2.0;
	else
		hsl.x = (c.r - c.g) / delta + 4.0;

	hsl.x = mod(hsl.x / 6., 1.);
	return hsl;
}

// Diamond Holographic Shader
vec4 runDiamondShader(vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec4 tex = Texel(texture, texture_coords);
    vec2 uv = ((texture_coords * image_details) - texture_details.xy * texture_details.ba) / texture_details.ba;
    vec4 hsl = HSL(0.5 * tex + 0.5 * vec4(0., 0., 1., tex.a));

    float t = iridescent.y * 7.221 + time;
    vec2 floored_uv = floor(uv * texture_details.ba) / texture_details.ba;
    vec2 uv_scaled_centered = (floored_uv - 0.5) * 250.0;

    vec2 field_part1 = uv_scaled_centered + 50. * vec2(sin(-t / 143.6340), cos(-t / 99.4324));
    vec2 field_part2 = uv_scaled_centered + 50. * vec2(cos(t / 53.1532), cos(t / 61.4532));
    vec2 field_part3 = uv_scaled_centered + 50. * vec2(sin(-t / 87.53218), sin(-t / 49.0000));

    float field = (1. + (
        cos(length(field_part1) / 19.483) + sin(length(field_part2) / 33.155) * cos(field_part2.y / 15.73) +
        cos(length(field_part3) / 27.193) * sin(field_part3.x / 21.92))) / 2.;

    float res = 0.5 + 0.5 * cos(iridescent.x * 2.612 + (field - 0.5) * 3.14);

    float low = min(tex.b, min(tex.g, tex.r));
    float high = max(tex.b, max(tex.g, tex.r));
    float delta = 0.2 + 0.3 * (high - low) + 0.1 * high;

    float gridsize = 0.6;
    mat2 rotate45 = mat2(0.7071, -0.7071, 0.7071, 0.7071);
    vec2 diamond_uv = rotate45 * uv;

    float fac = max(max(0., 7. * abs(cos(diamond_uv.x * gridsize * 20.)) - 6.), max(0., 7. * cos(diamond_uv.y * gridsize * 45.) - 6.));

    hsl.x += res + fac;
    hsl.y *= 1.3;
    hsl.z = hsl.z * 0.6 + 0.4;

    tex = (1. - delta) * tex + delta * RGB(hsl) * vec4(0.4, 0.6, 1.8, tex.a);

    return dissolve_mask(tex * colour, texture_coords, uv);
}

// Iridescent Shader
vec4 runIridescentShader(vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec4 tex = Texel(texture, texture_coords);
    vec2 uv = (((texture_coords)*(image_details)) - texture_details.xy*texture_details.ba)/texture_details.ba;

    // Adjust the range for low and high to enhance the contrast
    float low = min(tex.r, min(tex.g, tex.b));
    float high = max(tex.r, max(tex.g, tex.b));
    float delta = high - low;

    // Increase saturation factor to make the color more intense
    float saturation_fac = 1. - max(0., 0.05*(1.1-delta));

    // Apply the new saturation factor
    vec4 hsl = HSL(vec4(tex.r*saturation_fac, tex.g*saturation_fac, tex.b, tex.a));

    // Increase the shimmer field intensity
    float t = iridescent.y*3.221 + time; // Increased multiplier to make shimmer faster
    vec2 floored_uv = (floor((uv*texture_details.ba)))/texture_details.ba;
    vec2 uv_scaled_centered = (floored_uv - 0.5) * 70.;  // Increased scaling for more dramatic effect

    vec2 field_part1 = uv_scaled_centered + 70.*vec2(sin(-t / 113.6340), cos(-t / 79.4324));
    vec2 field_part2 = uv_scaled_centered + 70.*vec2(cos( t / 33.1532),  cos( t / 43.4532));
    vec2 field_part3 = uv_scaled_centered + 70.*vec2(sin(-t / 57.53218), sin(-t / 39.0000));

    // Enhance field complexity and intensity
    float field = (1. + (
        cos(length(field_part1) / 15.483) +
        sin(length(field_part2) / 27.155) * cos(field_part2.y / 10.73) +
        cos(length(field_part3) / 22.193) * sin(field_part3.x / 14.92)
    )) / 2.;

    // Make the iridescent color effect more prominent by adjusting the res calculation
    float res = (.5 + .5 * cos((iridescent.x) * 4.612 + (field - 0.5) * 4.14));
    res = pow(res, 0.8); // favor lower hues (greenish)
    hsl.x = 0.35 + res * 0.35;

    hsl.y = min(1.0, hsl.y + 0.7); // Boost saturation to full intensity for vibrant colors
    hsl.z = min(1.0, hsl.z + 0.2 * res); // Increase vibrancy with more brightness control

    tex.rgb = RGB(hsl).rgb;

    // Preserve transparency and adjust for intensity on low alpha
    if (tex.a < 0.7)
        tex.a = tex.a / 2.0; // Reduce alpha adjustment for more intensity

    return dissolve_mask(tex * colour, texture_coords, uv);
}


float hue2rgb(float p, float q, float t) {
    if (t < 0.0) t += 1.0;
    if (t > 1.0) t -= 1.0;
    if (t < 1.0 / 6.0) return p + (q - p) * 6.0 * t;
    if (t < 1.0 / 2.0) return q;
    if (t < 2.0 / 3.0) return p + (q - p) * (2.0 / 3.0 - t) * 6.0;
    return p;
}

// Convert RGB to HSL
vec4 RGBtoHSL(vec4 color) {
    float r = color.r;
    float g = color.g;
    float b = color.b;
    float maxVal = max(r, max(g, b));
    float minVal = min(r, min(g, b));
    float delta = maxVal - minVal;
    float h = 0.0;
    float s = 0.0;
    float l = (maxVal + minVal) / 2.0;

    if (delta != 0.0) {
        if (maxVal == r) {
            h = mod((g - b) / delta, 6.0);
        } else if (maxVal == g) {
            h = (b - r) / delta + 2.0;
        } else {
            h = (r - g) / delta + 4.0;
        }
        s = delta / (1.0 - abs(2.0 * l - 1.0));
    }

    h = h / 6.0; // Normalize hue
    return vec4(h, s, l, color.a); // Return HSL value
}

// Convert HSL back to RGB
vec4 HSLtoRGB(vec4 hsl) {
    float h = hsl.r;
    float s = hsl.g;
    float l = hsl.b;
    float r, g, b;

    if (s == 0.0) {
        r = g = b = l; // Achromatic (gray)
    } else {
        float temp2 = (l < 0.5) ? (l * (1.0 + s)) : (l + s - l * s);
        float temp1 = 2.0 * l - temp2;

        r = hue2rgb(temp1, temp2, h + 1.0 / 3.0);
        g = hue2rgb(temp1, temp2, h);
        b = hue2rgb(temp1, temp2, h - 1.0 / 3.0);
    }

    return vec4(r, g, b, hsl.a); // Return RGB value
}

// Helper function for HSL to RGB conversion




// Combine the shaders
vec4 effect(vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    // Step 1: Get the result of both shaders
    vec4 shaderA = runDiamondShader(colour, texture, texture_coords, screen_coords); // Diamond holographic shader
    vec4 shaderB = runIridescentShader(colour, texture, texture_coords, screen_coords); // Iridescent shader

    // Step 2: Blend the results of both shaders
    vec4 finalColor = mix(shaderB, shaderA, 0.6);

    // Convert to HSL
    vec4 hsl = RGBtoHSL(finalColor);

    // Increase saturation
    hsl.y = min(hsl.y * 1.75, 1.0);  // Multiply saturation by 2, but clamp it at 1.0

    // Convert back to RGB
    finalColor = HSLtoRGB(hsl);



    // Step 3: Calculate UV
    vec2 uv = ((texture_coords * image_details) - texture_details.xy * texture_details.ba) / texture_details.ba;

    // Step 4: Apply dissolve mask to the final blended color
    return dissolve_mask(finalColor * colour, texture_coords, uv);
}





extern MY_HIGHP_OR_MEDIUMP vec2 mouse_screen_pos;
extern MY_HIGHP_OR_MEDIUMP float hovering;
extern MY_HIGHP_OR_MEDIUMP float screen_scale;

#ifdef VERTEX
vec4 position( mat4 transform_projection, vec4 vertex_position )
{
    if (hovering <= 0.){
        return transform_projection * vertex_position;
    }
    float mid_dist = length(vertex_position.xy - 0.5*love_ScreenSize.xy)/length(love_ScreenSize.xy);
    vec2 mouse_offset = (vertex_position.xy - mouse_screen_pos.xy)/screen_scale;
    float scale = 0.2*(-0.03 - 0.3*max(0., 0.3-mid_dist))
                *hovering*(length(mouse_offset)*length(mouse_offset))/(2. -mid_dist);

    return transform_projection * vertex_position + vec4(0,0,0,scale);
}
#endif