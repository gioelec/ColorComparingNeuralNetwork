%initialization of variables
disp("INITIALIZATION");
clear; clc;
load IS.mat;
addpath(genpath('optprop'));
addpath(genpath('lchconversions'));

ncopies = 10;
seed = 1;
dim = size(spectra);
nwavelengths = dim(1);
nsamples = dim(2);
spectraRescaled = repmat(spectra*100,1,ncopies);
copy = zeros([nwavelengths nsamples*ncopies], 'double');
rng(seed);
diff = zeros([nsamples*ncopies 1],'double');
rgbM = zeros([nsamples*ncopies 3],'double').';
rgbC = rgbM;
lchM = rgbM;
wlRange = 380:1:800;
k = 5;
nfeatures = 7;
features = zeros([2*nfeatures*k nsamples*ncopies], 'double');

%creating the noisy copies
disp("CREATING NOISY COPIES");
for i=1:ncopies
    start = (i-1)*nsamples+1;
    last =  i*nsamples;
    noise = random ('unif ' ,1.0 ,1.25);
    copy(1:nwavelengths,start:last) = spectraRescaled(1:nwavelengths,start:last)*noise;
end

%for each master and copy samples we are computing:
%1)lab coordinates to compute deltaE
%2)rgb values to print colors
%3)lch coordinates to feed the FIS
disp("COMPUTING COORDINATES");
for i = 1 : nsamples*ncopies
    val1 = spectraRescaled(1:nwavelengths,i);
    val2 = copy(1:nwavelengths,i);
    lab1 = roo2lab(val1',[],wlRange);
    lab2 = roo2lab(val2',[],wlRange);
    rgbM(1:3,i) = lab2rgb(lab1);
    rgbC(1:3,i) = lab2rgb(lab2);
    lchM(1:3,i) = lab2lch(lab1);
    diff(i) = de(lab1,lab2);
end
%extract 7 features  
disp("EXTRACTING FEATURES");
for i = 1:nsamples*ncopies
    [tmp] = extractFeatures(k,spectraRescaled(1:421,i),copy(1:421,i),@mean);
    features(1:10,i) = tmp;
    [tmp] = extractFeatures(k,spectraRescaled(1:421,i),copy(1:421,i),@std);
    features(11:20,i) = tmp;
    [tmp] = extractFeatures(k,spectraRescaled(1:421,i),copy(1:421,i),@mode);
    features(21:30,i) = tmp;
    [tmp] = extractFeatures(k,spectraRescaled(1:421,i),copy(1:421,i),@median);
    features(31:40,i) = tmp;
    [tmp] = extractFeatures(k,spectraRescaled(1:421,i),copy(1:421,i),@skewness);
    features(41:50,i) = tmp;
    [tmp] = extractFeatures(k,spectraRescaled(1:421,i),copy(1:421,i),@max);
    features(51:60,i) = tmp;
    [tmp] = extractFeatures(k,spectraRescaled(1:421,i),copy(1:421,i),@min);
    features(61:70,i) = tmp;
end



%%%%%%%%%%%%%%II PART%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%COMMENT THIS PART TO EXECUTE ONLY PARTI%%%%
%Fuzzy inference system
disp("CONVERTING CHROMA");
[lchConverted] = convertChroma(lchM);  %convert Chroma to percentage Chroma
disp("FUZZY PART");
diff_transposed = diff';
fuzzyInputs = ([lchConverted; diff_transposed]); 
%Load FIS from file
FIS = readfis('fuzzy.fis');
%Deploy the FIS to correct differences
adjusted_de = evalfis(fuzzyInputs,FIS)';
adjusted_transposed = adjusted_de';  
disp("FIS EVALUATED");
diff = adjusted_transposed;

%%%%PART IN COMMON FOR PART I and II%

%%%%FEATURE SELECTION%%%%%%%%%%%%%%%%
disp("STARTED FEATURE SELECTION");
opt = statset('display','off');
[fs, history]= sequentialfs(@fs_net, features', diff, 'cv', 'none', 'opt', opt, 'nfeatures', k+1);
selectedFeatures = features(fs,:);
disp("FEATURE SELECTED");
%%%FITTING%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp("TRAINING PHASE");
fs_net(selectedFeatures',diff);
disp("TRAINING DONE");



        
