close all;
clear;
clc;

% Gain access to the paths with the SIFTS, frames and provided code
siftdir = './sift/';
fnames = dir([siftdir '/*.mat']);
framesdir = './frames/';
addpath('./provided_code/');
load('kMeans.mat');

% Select 3 frames 
frames = [600,50,90];

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


    % We want to display a certain amount of similar frames. In this instance,
    % we want to do the 5 most similar frames. 
    startIndex = 2;
    endIndex = 6;
    for i = startIndex:endIndex
       simImage = fnames(simIm(i));
       fname = [siftdir '/' simImage.name];
       load(fname);
       imageName = [framesdir '/' imageName];
       image = imread(imageName);
       subplot(2,3,i);    
       imshow(image);
       currentIndex = i - 1;
       stringCurrentIndex = num2str(currentIndex);
       resultTitle = strcat('Result Number: ', stringCurrentIndex);
       stringDistance = num2str(sortedDis(i));
       distanceTitle = strcat('Total Distance: ', stringDistance);
       titleName = srtcat(resultTitle, imageName, distanceTitle);
       title(titleName);
    end

   userPrompt = 'Press enter: ';
   [~] = input(userPrompt);
   close all;
end