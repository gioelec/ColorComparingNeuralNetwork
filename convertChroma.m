function [lchConverted] = convertChroma(lch)
%converts chroma to percentage chroma through maxchroma function
%from lchconversions package, that computes the maximum Chroma 
%within the sRGB gamut
lchConverted=lch;
for i=1:length(lch)
    Cmax = maxchroma('lab','lightness',lch(1,i),'hue',lch(3,i));
    lchConverted(2,i) = lch(2,i)*100/Cmax;
end


