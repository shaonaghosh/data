%function[] = parseDatasetGenDistance()

clear all;
close all;


cd ('C:\Users\Shaona\Documents\MATLAB\');
%parse the file 
%[data, labels, N, d] = parsedata('dtrain123.dat');
% [data, labels, N, d] = parsedata('ziptrain.dat');
%[data, labels, N, d] = processisolet();%Isolet does not have more than 300 per letter
[data, labels, N, d] = parseNewsgroupData();

%Calculate the distance matrix one off
% [distancematrixfull] = distancesOneOff(data, N, d);
[distancematrixfull] = distancematfornewsGrp(data, N, d);

distancematrixfull(1:10,1:10);
data(1:10,1:10);
labels(1:10);

%Save the distancematrix to file one offexppath = fullfile(pwd,'6vs7MSTTest');
distpath = fullfile(pwd,'datasetdistances');
if ~exist(distpath, 'dir')
   mkdir(distpath);
end

%datasetname = sprintf('%s-%s', 'dtrain123', 'distance.mat');
% datasetname = sprintf('%s-%s', 'ziptrain', 'distance.mat');
datasetname = sprintf('%s-%s', '20newsgroup', 'distance.mat');
distpath = fullfile(distpath,datasetname);
save(distpath, 'distancematrixfull');



%end