function [features] = extractFeatures(k,sampleM,sampleC,fun)
%divides the the wavelength range in 5 different ranges and per each
%middlepoint computes feature(fun) for that range
%is done for both master and copy
    features = zeros([1 10],'double');
    len = length(sampleM);
    slice = floor (len/k);
    for i=1:k
        start = (i-1)*slice+1;
        if i ~= k
            last = i*slice;
        else
            last = len;
        end
        features(1,i) =  fun(sampleM(start:last));
        features(1,i+k) = fun(sampleC(start:last));
        %features(2,i) = (start+last)/2;
    end
end
