close all;
clear;
clc;

% Gain access to the paths with the SIFTS, frames and provided code
siftDir = './sift/';
fNames = dir([siftDir '/*.mat']);
framesDir = './frames/';
addpath('./provided_code/');
load('kMeans.mat');

% Select 3 frames
frames = [600, 90, 220];

% Find the histogram and the distance and then sort them by finding minimum
% distance
D = [];
fNamesLength = length(fNames);
for i=1:fNamesLength
    fnamesIndex = fNames(i);
    fName = [siftDir '/' fnamesIndex.name];
    load(fName, 'descriptors');
    transposeDescriptors = descriptors';
    transposeMeans = kMeans';
    D = distSqr(transposeDescriptors, transposeMeans);
    sizeOfD = size(D);
    sizeOfDRows = sizeOfD(1);
    for j = 1:sizeOfDRows
        [~,minI] = min(D(j,:));
        A(j,1) = minI;
    end
    indicies = 1:75;
    bagOW(i,:) = histcounts(A, indicies);
end

for i = 1:length(frames)
    %load query frames image
    siftName = fNames(frames(i)).name;
    fullPath=[siftDir '/' siftName];
    load(fullPath);
    imname = [framesDir '/' imname];
    image = imread(imname);
    oninds = selectRegion(image, positions);
    onidsSize = size(oninds, 1);
    frameIndex = frames(i);
    frames_bagWords = bagOW(frameIndex, :);
    onindDescriptors = [];
    for j = 1:onidsSize
        index = oninds(j);
        onindDescriptors = [onindDescriptors; descriptors(index, :)];
    end
    B = dist2(onindDescriptors, kMeans);
    [~, minBVal] = min(B, [], 2);
    indicies = 1:75;
    bagOWOninds = histcounts(minBVal, indicies);
    bagOWLength = length(bagOW);
    transposeBagWordsOninds = bagOWOninds';
    bagOWMatrixOninds = repmat(transposeBagWordsOninds, 1, bagOWLength);
    bagOWTranspose = bagOW';
    correlation = corr(bagOWTranspose, bagOWMatrixOninds);
    notNumCheck = isnan(correlation);
    correlation(notNumCheck) = 0;
    [sDistance, simIm] = sort(correlation, 'descend');

    % We want to display a certain amount of similar frames. In this instance,
    % we want to do the 5 most similar frames.
    startIndex = 2;
    endIndex = 6;
    for k = startIndex:endIndex
       simImage = fNames(simIm(k));
       fName = [siftDir '/' simImage.name];
       load(fName);
       imname = [framesDir '/' imname];
       image = imread(imname);
       subplot(2,3,k);
       imshow(image);
       currentIndex = k - 1;
       stringCurrentIndex = num2str(currentIndex);
       resultTitle = strcat('Result Number: ', stringCurrentIndex);
       stringDistance = num2str(sDistance(k));
       distanceTitle = strcat('Total Distance: ', stringDistance);
       titleName = strcat(resultTitle, imname, distanceTitle);
       title(titleName);
    end

   userPrompt = 'Press enter: ';
   [~] = input(userPrompt);
   close all;
end