% Gain access to the paths with the SIFTS, frames and provided code
siftdir = './sift/';
fnames = dir([siftdir '/*.mat']);
framesdir = './frames/';
addpath('./provided_code/');

% Get a random index out of a certain amount of images
randomImageLength = 500;
fnamesLength = length(fnames);
randInt = randi(fnamesLength, randomImageLength, 1);

% Our vocabulary for our patches
vocabFile = [];
vocabDescriptor = [];
vocabOrientations = [];
vocabPositions = [];
vocabScales = [];

% Build and save our vocabulary from the images
for i = 1:randomImageLength
    randomFrame = fnames(randInt(i));
    siftImage = [siftdir '/' randomFrame.name];
    load(siftImage, 'descriptors', 'orients', 'positions', 'scales', 'imname');
    descriptorsSize = size(descriptors, 1);
    vocabFile = [vocabFile; ones(descriptorsSize, 1).*i];
    vocabDescriptor = [vocabDescriptor ; descriptors];
    vocabOrientations = [vocabOrientations; orients];
    vocabPositions = [vocabPositions; positions];
    vocabScales = [vocabScales; scales];
end

% How many kmeans we want to find
kValue = 1000;
transposeVocabDescriptor = vocabDescriptor';
[membership, origMeans, rms] = kmeansML(kValue, transposeVocabDescriptor);
kMeans = origMeans';
save('kMeans.mat', 'kMeans');

% Keep track of how many times a certain amount of words appear in patches
[membershipRows, membershipCols] = size(membership);
wordLen = 1000;
words = zeros(wordLen, 1);
for i=1:membershipRows
    words(membership(i)) = words(membership(i)) + 1;
end

% Pick a random amount of frames and decide the frequency of words you want
% to see 
numbersToPick = 2;
wordFrequency = 10;
randWords = randperm(wordFrequency, numbersToPick);
% So we keep track of what values we picked
holdFirstWord = randWords(1);
holdSecondWord = randWords(2);

% Store the most common words
for i = 1:randWords(1)
  [~, firstIndex] = max(words);
  words(firstIndex) = 0;
end

for i = 1:randWords(2);
    [~, secondIndex] = max(words);
    if (i ~= 6)
       words(secondIndex) = 0;
   end
end

% Find and search for the words in the patches
firstWord = kMeans(firstIndex, :);
secondWord = kMeans(secondIndex, :);
firstSearch = find(membership == firstIndex);
secondSearch = find(membership == secondIndex);

% Store the distance of the vocab patches
firstSearchSize = size(firstSearch, 1);
storeDistance = zeros(firstSearchSize, 1);
for i=1:firstSearchSize
    firstWordTranspose = firstWord';
    squareDist = distSqr(firstWordTranspose, vocabDescriptor(firstSearch(i,1), :)');
    storeDistance(i, 1) = squareDist;
end
figure;

% Plot a certain amount of patches
matchesToPlot = 25;
for i=1:matchesToPlot
    tranposeDistance = storeDistance';
    [~, index] = min(tranposeDistance);
    storeDistance(index, 1) = 1;
    index = firstSearch(index);
    randomFileIndex = randInt(vocabFile(index));
    siftImage = [siftdir '/' fnames(randomFileIndex).name];
    load(siftImage, 'imname');
    itemToGray = imread([framesdir '/' imname]);
    grayImage = rgb2gray(itemToGray);
    patch = getPatchFromSIFTParameters(vocabPositions(index,:), vocabScales(index,:), vocabOrientations(index,:), grayImage);
    numRows = 5;
    numCols = 5;
    subplot(numRows, numCols, i);
    imshow(patch);
end

% Repeat the process for the second word

secondSearchSize = size(secondSearch, 1);
storeDistance = zeros(secondSearchSize, 1);
for i=1:secondSearchSize
    secondWordTranspose = secondWord';
    squareDist = distSqr(secondWordTranspose, vocabDescriptor(secondSearch(i,1), :)');
    storeDistance(i, 1) = squareDist;
end
figure;

matchesToPlot = 25;
for i=1:matchesToPlot
    tranposeDistance = storeDistance';
    [~, index] = min(tranposeDistance);
    storeDistance(index, 1) = 1;
    index = secondSearch(index);
    randomFileIndex = randInt(vocabFile(index));
    siftImage = [siftdir '/' fnames(randomFileIndex).name];
    load(siftImage, 'imname');
    itemToGray = imread([framesdir '/' imname]);
    grayImage = rgb2gray(itemToGray);
    patch = getPatchFromSIFTParameters(vocabPositions(index,:), vocabScales(index,:), vocabOrientations(index,:), grayImage);
    numRows = 5;
    numCols = 5;
    subplot(numRows, numCols, i);
    imshow(patch);
end
