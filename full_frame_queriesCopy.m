close all;
clear;
clc;

load kMeans.mat;
framesdir = './frames/';
siftdir = './sift/';
addpath('./provided_code/');
fnames = dir([siftdir '/*.mat']);

% We want to use kMeans to find histograms as bag of words and we want to
% choose 3 frames as our queries and display the M = 5 most similar
% frames in rank order
ourDistance = [];
fnamesLength = length(fnames);
for i = 1:fnamesLength
    fnamesIndex = fnames(i);
    fname = [siftdir '/' fnamesIndex.name];
    load(fname, 'descriptors');
    % Find and sort minimum distance
    transposeDescriptors = descriptors';
    transposeMeans = kMeans';
    ourDistance = distSqr(transposeDescriptors, transposeMeans);
    sizeOfDistance = size(ourDistance);
    sizeOfDistanceRows = sizeOfDistance(1);
    for k = 1:sizeOfDistanceRows
        [~, minIndex] = min(ourDistance(k, :));
        A(k, 1) = minIndex;
    end
    indicies = 1:75;
    bagOfWords(i, :) = histcounts(A, indicies);
end

% Choose 3 frames
frames = [212, 162, 91];

framesLength = length(frames);
for j = 1:framesLength
    framesIndex = frames(j);
    siftName = fnames(framesIndex).name;
    siftFrame = [siftdir '/' siftName];
    load(siftFrame);
    imname = [framesdir '/' imname];
    image = imread(imname);
    figure;
    subplot(2, 3, 1);
    imshow(image);
    queryTitle = strcat('Query Image: ', imname);
    title(queryTitle);
    frameIndex = frames(j);
    frameBagOfWords = bagOfWords(framesIndex, :);
    bagOfWordsLength = length(bagOfWords);
    frameBagOfWordsTranspose = frameBagOfWords';
    frameBagOfWordsMatrix = repmat(frameBagOfWordsTranspose, 1, bagOfWordsLength);
    bagOfWordsTranspose = bagOfWords';
    sim = corr(bagOfWordsTranspose, frameBagOfWordsMatrix);
    isnanCheck = isnan(sim);
    sim(isnanCheck) = 0;
    [sortedDis, simImage] = sort(sim, 'descend');

    % We want to display a certain amount of similar frames. In this instance,
    % we want to do the 5 most similar frames.
    M = 5;
    endIndex = M + 1;
    startIndex = (endIndex - M) + 1;
    for i = startIndex:endIndex
       simIndex = simImage(i);
       simImage = fnames(simIndex).name;
       fname = [siftdir '/' simImage];
       load(fname);
       imname = [framesdir '/' imname];
       image = imread(imname);
       subplot(2, 3, i);
       imshow(image);
       currentIndex = i - 1;
       stringCurrentIndex = num2str(currentIndex);
       resultTitle = strcat('Result Number: ', stringCurrentIndex);
       stringDistance = num2str(sortedDis(i));
       distanceTitle = strcat('Similarity Rank: ', stringDistance);
       titleName = strcat(resultTitle, imname, distanceTitle);
       title(titleName);
    end
end
