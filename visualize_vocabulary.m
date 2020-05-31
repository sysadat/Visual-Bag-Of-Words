% Get access to all the paths and directories
framesdir = './frames/';
addpath('./provided_code/');
siftdir = './sift/';
fnames = dir([siftdir '/*.mat']);

% Variable to hold the amount of images we want to go through, like say 500
randomImageLength = 500;
fnamesLength = length(fnames);
randInt = randi(fnamesLength, randomImageLength, 1);

vocabFile = [];
vocabScales = [];
vocabIndicies = [];
vocabDescriptor = [];
vocabOrientations = [];

for i = 1:randomImageLength
    fileName =[siftdir '/' fnames(randInt(i)).name];
    load(fileName, 'imname', 'descriptors', 'positions', 'scales', 'orients');
    descriptorsSize = size(descriptors,1);
    vocabFile = [vocabFile; ones(descriptorsSize, 1).*i];
    vocabOrientations = [vocabOrientations; orients];
    vocabDescriptor = [vocabDescriptor ; descriptors];
    vocabIndicies = [vocabIndicies; positions];
    vocabScales = [vocabScales; scales];

end

kVal = 1500;
transposeVocabDescriptor = vocabDescriptor';
[membership, origMeans, rms] = kmeansML(kVal, transposeVocabDescriptor);
tranposeMeans = origMeans';
means = tranposeMeans;
save('kMeans.mat', 'means');

[membershipRows, membershipCols] = size(membership);
wordLen = 1000;
o = zeros(wordLen, 1);
for j=1:membershipRows
    o(membership(j)) = o(membership(j))+1; 
end

% Want to pick two random numbers and find the max 
numbersToPick = 2;
membershipLength = length(membership);
randWords = randperm(membershipLength, numbersToPick);

for i = 1:randWords(1)
   [~, firstWord] = max(o);
   o(firstWord) = 0;
end

for i = 1:randWords(2)
   [~, secondWord] = max(o);
   o(secondWord) = 0;
end

word1 = means(firstWord, :);
word2 = means(secondWord, :);
firstSearch = find(firstWord == membership);
secondSearch = find(secindWord == membership);


