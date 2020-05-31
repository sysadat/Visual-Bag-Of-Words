addpath('./provided_code/');
framesdir = './frames/';
siftdir = './sift/';
fnames = dir([siftdir '/*.mat']);

randomImageLength = 500;
fnamesLength = length(fnames);
r = randi(fnamesLength, randomImageLength, 1);

voc=[];
vocPositions=[];
vocScales=[];
vocOrients=[];
vocFile=[];

for i = 1:randomImageLength
    t =[siftdir '/' fnames(r(i)).name];
    load(t, 'imname', 'descriptors', 'positions', 'scales', 'orients');
    descriptorsSize = size(descriptors,1);
    voc=[voc ; descriptors];
    vocPositions=[vocPositions;positions];
    vocScales=[vocScales;scales];
    vocOrients=[vocOrients;orients];
    vocFile=[vocFile; ones(descriptorsSize,1).*i];

end

% CHANGE LATER
kValue = 1000;
transposeVocabDescriptor = voc';
[membership, means1, rms] = kmeansML(kValue, transposeVocabDescriptor);
tranposeMeans = means1';
means = tranposeMeans;
save('kMeans.mat', 'means');

[s1, membershipCols] = size(membership);
wordLen = 1000;
obj = zeros(wordLen, 1);
for i=1:s1
    obj(membership(i)) = obj(membership(i))+1;
end

numbersToPick = 2;
membershipLength = length(membership);
randWords = randperm(membershipLength, numbersToPick);

for i = 1:randWords(1)
  [~, index1] = max(obj);
   obj(index1) = 0;
end

for i = 1:randWords(2)
   [~, index2] = max(obj);
   obj(index2) = 0;
end

word1 = means(index1, :);
word2 = means(index2, :);
search1 = find(membership == index1);
search2 = find(membership == index2);

firstSearchSize = size(search1,1);
A = zeros(firstSearchSize, 1);
for i=1:firstSearchSize
    firstWordTranspose = word1';
    z = distSqr(firstWordTranspose,voc(search1(i,1),:)');
    A(i,1) = z;
end
figure;

matchesToPlot = 25;
for i=1:matchesToPlot
    newA = A';
    [~, index] = min(newA);
    A(index, 1) = 1;
    index = search1(index);
    t = [siftdir '/' fnames(r(vocFile(index))).name];
    load(t,'imname');
    gray = rgb2gray(imread([framesdir '/' imname]));
    patch = getPatchFromSIFTParameters(vocPositions(index,:),vocScales(index,:),vocOrients(index,:),gray);
    subplot(5,5,i);
    imshow(patch);
end

word1 = means(index1, :);
word2 = means(index2, :);
search1 = find(membership == index1);
search2 = find(membership == index2);

secondSearchSize = size(search2,1);
A = zeros(secondSearchSize, 1);
for i=1:secondSearchSize
    secondWordTranspose = word2';
    z = distSqr(secondWordTranspose,voc(search2(i,1),:)');
    A(i,1) = z;
end
figure;

matchesToPlot = 25;
for i=1:matchesToPlot
    newA = A';
    [~, index] = min(newA);
    A(index, 1) = 1;
    index = search2(index);
    t = [siftdir '/' fnames(r(vocFile(index))).name];
    load(t,'imname');
    gray = rgb2gray(imread([framesdir '/' imname]));
    patch = getPatchFromSIFTParameters(vocPositions(index,:),vocScales(index,:),vocOrients(index,:),gray);
    subplot(5,5,i);
    imshow(patch);
end
