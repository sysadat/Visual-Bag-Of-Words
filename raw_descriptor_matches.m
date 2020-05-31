clear
close all
load('twoFrameData.mat');
%addpath('./provided_code/'); %make folder for this 

imshow(im1); % new 
[oninds] = selectRegion(im1,positions1);

imGray = rgb2gray(im1);
im = rgb2gray(im2);
[r, ~] = size(oninds);
[m, ~] = size(descriptors2);

D = [];
for i = 1:r
    index = oninds(i,1);
    
    posPatch = positions1(index,:);
    scalePatch = scales1(index);
    orientPatch = orients1(index);
    
    patch1 = getPatchFromSIFTParameters(posPatch, scalePatch, orientPatch, imGray); %grab the first patch in oninds
    A = zeros(m,1);
    for j = 1:m
        xDistVal = descriptors1(index,:)';
        yDistVal = descriptors2(j,:)';
        z = distSqr(xDistVal, yDistVal);%distance from ith patch(im1) to jth in im2. VVV
       A(j,1) = z;                                            %|-> Transposed because distsqr needs it like that      
    end
    [var,ind] = mink(A',2); %transpose because A is column
    newThreshold = var(2)/var(1);
    
    if newThreshold > 1.4 % NEW AND IMPROVED threshold
        D = cat(2, D, ind(1));
    end    
end

[~,q]=size(D);
patchesParam = {zeros(q,2), zeros(q,1),zeros(q,1)};
[positionF, scaleF, orientF] = patchesParam{:}; 

for k = 1:q
    i=D(1,k);
    positionF(k,:) = positions2(i,:);
    scaleF(k,1) = scales2(i,1);
    orientF(k,1) = orients2(i,1);
end

imshow(im2);
displaySIFTPatches(positionF,scaleF,orientF,im2);