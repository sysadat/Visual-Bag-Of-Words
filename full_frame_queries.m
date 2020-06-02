close all;
clear;
clc;

load kMeans.mat;
framesdir = './frames/';
siftdir = './sift/';
addpath('./provided_code/');
fnames = dir([siftdir '/*.mat']);

% Find the histogram and the distance and then sort them by finding minimum 
% distance
D = [];
fnamesLength = length(fnames);
for i=1:fnamesLength
    fnamesIndex = fnames(i);
    fname = [siftdir '/' fnamesIndex.name];
    load(fname, 'descriptors'); 
    transposeDescriptors = descriptors';
    transposeMeans = means';
    D = distSqr(transposeDescriptors, transposeMeans);
    sizeOfD = size(D);
    sizeOfDRows = sizeOfD(1);
    for k = 1:sizeOfDRows
        [~,minI] = min(D(k,:));
        A(k,1) = minI;
    end
    indicies = 1:75;
    bag_words(i,:) = histcounts(A, indicies);   
end

%choose 3 frames from the video dataset
%MY PART MY PART MY PART MY PART MY PART MY PART  MY PART MY PART MY PART  
frames = [212,162,91];%changed frames

for j = 1:length(frames)   
    %load query frames image
    siftName = fnames(frames(j)).name;
    t=[siftdir '/' siftName];
    load(t);
    
    imname = [framesdir '/' imname];
    im = imread(imname);
    figure;
    subplot(2,3,1);
    imshow(im);
    queryTitle = strcat('Query Image: ', imname);
    title(queryTitle);
    % find smilarity
    frameIndex = frames(j);
    frame_bagWord = bag_words(frameIndex, :);
    bag_wordsLength = length(bag_words);
    frame_bagWordTranspose = frame_bagWord';
    frame_bagWord_matrix = repmat(frame_bagWordTranspose, 1, bag_wordsLength);
    bag_wordsTranspose = bag_words';
    sim = corr(bag_wordsTranspose, frame_bagWord_matrix);
    isnanCheck = isnan(sim);
    sim(isnanCheck) = 0;
    [sortedDis, simIm] = sort(sim, 'descend');
    %display the first five
    startIndex = 2;
    endIndex = 6;
    for i = startIndex:endIndex
       simImage = fnames(simIm(i)).name;
       fname = [siftdir '/' simImage];
       load(fname);
       imname = [framesdir '/' imname];
       image = imread(imname);
       subplot(2,3,i);    
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