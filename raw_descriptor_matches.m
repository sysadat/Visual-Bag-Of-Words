clear
close all
load('twoFrameData.mat');
addpath('./provided_code/'); 

imshow(im1); 
[oninds] = selectRegion(im1,positions1);

imGrayscale = rgb2gray(im1);
[row, ~] = size(oninds);
[mVal, ~] = size(descriptors2);

D = [];

for i = 1:row
    index = oninds(i,1);
    
    posPatch = positions1(index,:);
    scalePatch = scales1(index);
    orientPatch = orients1(index);
    
    patchOne = getPatchFromSIFTParameters(posPatch, scalePatch, orientPatch, imGrayscale); 
    A = zeros(mVal,1);
    for j = 1:mVal
        xDistVal = descriptors1(index,:)';
        yDistVal = descriptors2(j,:)';
        zVal = distSqr(xDistVal, yDistVal);
       A(j,1) = zVal;                                                  
    end
    [variable,ind] = mink(A',2);
    newThreshold = variable(2)/variable(1);
    
    if newThreshold > 1.4 
        D = cat(2, D, ind(1));
    end    
end

[~,q]=size(D);
patchesParam = {zeros(q,2), zeros(q,1),zeros(q,1)};
[positionFinal, scaleFinal, orientFinal] = patchesParam{:}; 

for k = 1:q
    i=D(1,k);
    positionFinal(k,:) = positions2(i,:);
    scaleFinal(k,1) = scales2(i,1);
    orientFinal(k,1) = orients2(i,1);
end

imshow(im2);
displaySIFTPatches(positionFinal,scaleFinal,orientFinal,im2);