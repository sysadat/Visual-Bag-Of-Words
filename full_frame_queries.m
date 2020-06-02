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


frames = [600,61,200];

for j = 1:length(frames)   
    %load query frames image
    t=[siftdir '/' fnames(frames(j)).name];
    load(t);
    imname = [framesdir '/' imname];
    im = imread(imname);
    figure;
    subplot(2,3,1);
    imshow(im);
    title(strcat('Query Image: ',imname));
    % find smilarity
    frame_bagWord = bag_words(frames(j),:);
    frame_bagWord_matrix = repmat(frame_bagWord', 1, length(bag_words));
    sim = corr(bag_words',frame_bagWord_matrix);
    sim(isnan(sim)) = 0;
    [sortedDis,simIm] = sort(sim,'descend');
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
end