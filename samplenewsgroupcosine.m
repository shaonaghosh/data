
close all;


%Seed the random number generator
rng(555);

varL = [8,16,32,64,128];
notasks = 4;
labvsrest = [1]% [2,3,4];
K = 3;


datasetpath = fullfile(pwd,'20news_w100.mat');%check Dan Roy 'AClass: An online algorithm for generative classification' for description
wholegraph = load(datasetpath, 'documents');
wholegraph = wholegraph.documents;
wholegraph = sparse(wholegraph);

labelsdata = load(datasetpath, 'newsgroups');
labels = labelsdata.newsgroups;
labels = labels';
labels = sparse(labels);

num = length(wholegraph);

num = 500;

navgruns = 10;
for lab = 1:length(varL)
for class = 1:length(labvsrest)	

%sampling a smaller graph
findlabeltype1id1s = find(labels == class);
findlabeltypeid2s = find(labels ~= class);

permutelab1ids = randperm(length(findlabeltype1id1s));
permutelab2ids = randperm(length(findlabeltypeid2s));

minlenlabels = min(length(permutelab1ids),length(permutelab2ids));
if minlenlabels < num/2
    num = minlenlabels * 2;
end


samppermlab1s = labels(findlabeltype1id1s(permutelab1ids(1:num/2)));
samppermlab2s = labels(findlabeltypeid2s(permutelab2ids(1:num/2)));
combineids2 = vertcat(findlabeltype1id1s(permutelab1ids(1:num/2)),findlabeltypeid2s(permutelab2ids(1:num/2)));

samplegraphlabels = vertcat(samppermlab1s,samppermlab2s);
samplegraph = wholegraph(:,combineids2);

samplegraphlabels(samplegraphlabels == class) = 1;
samplegraphlabels(samplegraphlabels ~= class) = -1;

samplegraphlabels = full(samplegraphlabels);
samplegraph = full(samplegraph);

%create the distance matrix using cosine similarity
%calculate the distance matrix
%Distance matrix
distancemat1 = zeros(num,num);
tic
for i = 1:num
     nodei = samplegraph(:,i);
     for j = 1:num  
        nodej = samplegraph(:,j);
        %cosine simimlarity 
        prod = bsxfun(@times,nodei,nodej);
        simij = sum(prod,1);
        normi = sqrt(sum((nodei.^2),1));
        normj = sqrt(sum((nodej.^2),1));
        simij = simij/(normi*normj);
        %cosine distance
        distancemat1(i,j) = 1-simij;
    end
end
toc

%Adjacency matrix 
A = sparse(num,num);
Adj = sparse(num,num);



for i = 1:num
    %for every node, connect to its k most nearest neighbours
    %nodei = data(:,i);
    [weight, idx] = sort(distancemat1(i,:),2,'ascend');
    %[weight, idx] = sort(distancemat1(i,:),'ascend')%TEST CODE
    %Ignore the first index
    idx(1) = [];
    idx(K+1:end) = [];
    idx
    for j = 1:K  %Short loop 
         Adj(i,idx(j)) = distancemat1(i,idx(j));
         Adj(idx(j),i) = distancemat1(i,idx(j));
    end
end
A = Adj;


distsparse = sparse(distancemat1);
[tree,pred] = graphminspantree(distsparse,'Method','Kruskal');
%change the root node from 0 to root node called in graphminspantree
pred(1) = 1;

% mstmat = zeros(length(pred)-1,2);
% mstmat(:,1) = pred(1:length(pred)-1);
% mstmat(:,2) = pred(2:length(pred));

[rwmst, colmst, logind] = find(tree);
totrws = vertcat(rwmst, colmst);
totcols = vertcat(colmst, rwmst);
lintrreind = sub2ind(size(tree),totrws,totcols);
tree(lintrreind)  = 1;

Adj(lintrreind) = Adj(lintrreind)+1;
[dupedg] = find(Adj > 1);
Adj(dupedg) = 1;

%check connectivity
ifconn = isconnected(A);

%Create the Degree matrix
degrees = sum(A,2);

%Create degree sparse matrix
D = sparse(1:size(A,1), 1:size(A,2), degrees);
D(1:5,1:5)
%D  = full(D);  %Redundant as had made sparse before ToDo Check to see exploiting sparsity

%Calculate laplacian
L = D - A;
L(1:5,1:5)

%Check to see all the eigenvalues nonnegative for positive definiteness
%eigvals = eigs((L+L')/2);
eigvals = eigs(L);
ids = find(not(eigvals));
if ~isempty(ids)
    warning(1,'L not PSD');
end


for run = 1:navgruns
    
l = varL(lab);

findlabeltype1id1s = find(samplegraphlabels == labvsrest(class));
findlabeltypeid2s = find(samplegraphlabels ~= labvsrest(class));

permutelab1ids = randperm(length(findlabeltype1id1s));
permutelab2ids = randperm(length(findlabeltypeid2s));
    
label1idtosamp = samplegraphlabels(findlabeltype1id1s(permutelab1ids(1:l/2)));
label2idtosamp = samplegraphlabels(findlabeltypeid2s(permutelab2ids(1:l/2)));
nodeswithlabel1 = (findlabeltype1id1s(permutelab1ids(1:l/2)));
nodeswithlabel2 = (findlabeltypeid2s(permutelab2ids(1:l/2)));

label1idtosamp(label1idtosamp == class) = 1;
label2idtosamp(label2idtosamp == class) = -1;

trnodes = vertcat(nodeswithlabel1,nodeswithlabel2);
trlabels = vertcat(label1idtosamp,label2idtosamp);   
    
trnodes = full(trnodes);
trlabels = full(trlabels);


%write to file
classdir = sprintf('class%d',class);
labeldir = sprintf('label%d',varL(lab));
distpath2 = fullfile('..\20newsgroup\graphs\',classdir,labeldir);
if ~exist(distpath2, 'dir')
   mkdir(distpath2);
end


%Save the mapped nodes for the current graph
trdata = [trnodes,trlabels];
%run = 1;
trainingsetname = sprintf('trainingset%d%d.csv', num,run);
path = fullfile(distpath2,trainingsetname);
%trainsetname = sprintf('trainingset%d%d.csv',nofsets(c),run);
csvwrite(path,trdata);
    
    
%Save the sampled graph
[rw,cl] = find(A);
wts = ones(length(rw),1);
%wts = zeros(length(rw),1);
edgelistmat = [rw,cl,wts];
% fileID = fopen('simgraph.csv','w');
% fprintf(fileID,'%d\t%d\t0\n',edgelistmat);
% fclose(fileID);
datasetname = sprintf('datasetgraph%d%d.csv', num,run);
path = fullfile(distpath2,datasetname);
%graphname = sprintf('datasetgraph%d%d.csv',nofsets(c),run);
% cd(settingpath);
dlmwrite(path,edgelistmat, '\t')   

samplegraphlabels(samplegraphlabels == 1) = 1;
samplegraphlabels(samplegraphlabels == -1) = 0;
labsetname = sprintf('labset%d%d%d.csv', num, run,0);
path = fullfile(distpath2,labsetname);
labmat = [(1:1:num)',samplegraphlabels];
%end
csvwrite(path,labmat);
    
    
end
end
end




