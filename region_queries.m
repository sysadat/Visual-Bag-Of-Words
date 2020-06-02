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
frames = [212, 162, 400];%changed frames

% Find the histogram and the distance and then sort them by finding minimum 
% distance
D = [];
fnamesLength = length(fnames);
for i=1:fnamesLength
    fnamesIndex = fnames(i);
    fname = [siftdir '/' fnamesIndex.name];
    load(fname, 'descriptors'); 
    transposeDescriptors = descriptors';
    transposeMeans = kMeans';
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

%MY PART

for j = 1:length(frames)  
    %load query frames image
    siftName = fnames(frames(j)).name;
    t=[siftdir '/' siftName];
    load(t);
    imname = [framesdir '/' imname];
    im = imread(imname);
    %select regions
    oninds = selectRegion(im,positions);
    [r,~] = size(oninds);
    
    %question--------how to display the region as polygons in the picture?
    
    % find smilarity
    frames_bagWords = bag_words(frames(j),:); % found histogram of the frames's bag_words
    %find oninds similarity
    descriptors_oninds = [];
    for k = 1:r
        index = oninds(k);
        
        descriptors_oninds = [descriptors_oninds; descriptors(index,:)];
    end
    B = dist2(descriptors_oninds, kMeans);
    [~,minIB] = min(B,[],2);
    bag_words_oninds = histcounts(minIB,1:75);
    oninds_bagWord_matrix = repmat(bag_words_oninds', 1, length(bag_words));
    sim = corr(bag_words',oninds_bagWord_matrix);
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
       imname = [framesdir '/' imname];
       image = imread(imname);
       subplot(2,3,i);    
       imshow(image);
       currentIndex = i - 1;
       stringCurrentIndex = num2str(currentIndex);
       resultTitle = strcat('Result Number: ', stringCurrentIndex);
       stringDistance = num2str(sortedDis(i));
       distanceTitle = strcat('Total Distance: ', stringDistance);
       titleName = strcat(resultTitle, imname, distanceTitle);
       title(titleName);
    end

   userPrompt = 'Press enter: ';
   [~] = input(userPrompt);
   close all;
end