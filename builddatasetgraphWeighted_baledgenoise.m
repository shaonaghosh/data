function [Aout,D,L,edgesnotingraph, MSTedges] = builddatasetgraphWeighted_baledgenoise(n,data, distancemat1, K)

%Function to compute the graph corresponding to the dataset
%Author: Shaona Ghosh
%Date: 10.01.2014

%Check for number of arguments

if nargin < 4
    K = 5;
end


%Adjacency matrix 
A = sparse(n,n);
Adj = sparse(n,n);
Aout = sparse(n,n);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Test code with shorter data set n = 10 or 20 TEST CODE
% datatrim = data(:,1:10);
% distancetest = distances(datatrim,n,10)


%Method 2 using library slower than method 1 below
% function buildgraph(newK,numele,allrows,allcols,rows,cols, distancemat1)
%         tic
%         for i = 1:n
%             nodei = data(i,3:end); %first two columns for labels
%             %nodei = data(i,3:10);%test Code
%             [idx] = nearestneighbour(nodei',data(:,3:end)','NumberOfNeighbours',newK+1 ); %+1 as first closest neighbour is usually itself so ignored
%            
%           
%             %Ignore the index that is because it is nearest to itself
%             idx(idx==i) = [];
%                        
%             %Commented out for better sparse access alternative below
%             for j = 1:K %Shorter loop
%                 A(i,idx(j)) = distancemat1(i,idx(j));  %Replaced with
%                                                          
%                 A(idx(j),i) = distancemat1(i,idx(j));
%             end
%         end
% end
%             
% 
% 
% 
% 
% %Save the weighted graph to file
% %filesavepth = fullfile('C:\Users\','graphnearest.mat');
% csvwrite(fullfile(pwd,'graphnearest.mat'),full(A));
% fprintf( 'Nearest Neighbours Graph saved\n');
% 
% 
% 
% 
% A = spones(A);
% 
% 
% 
% 
%Minimum spanning tree

distsparse = sparse(distancemat1);
[tree,pred] = graphminspantree(distsparse,1);
%change the root node from 0 to root node called in graphminspantree
pred(1) = 1;

% mstmat = zeros(length(pred)-1,2);
% mstmat(:,1) = pred(1:length(pred)-1);
% mstmat(:,2) = pred(2:length(pred));

[rwmst, colmst, logind] = find(tree);
totrws = vertcat(rwmst, colmst);
totcols = vertcat(colmst, rwmst);
MSTedges = horzcat(totrws,totcols);
lintrreind = sub2ind(size(tree),totrws,totcols);
tree(lintrreind)  = 1;

%names = {'Node:1Label:1','Node:2Label:1','Node:3Label:1','Node:4Label:1','Node:5Label:1','Node:6Label:2','Node:7Label:2','Node:8Label:2','Node:9Label:2','Node:10Label:2'};
% view(biograph(distsparse,names,'ShowArrows','off','ShowWeights','off'))
% view(biograph(tree,names,'ShowArrows','off','ShowWeights','on'))



edgesnotingraph = zeros(1400,2);
cntedgenotin = 1;
% Nearest neighbour method 1 :Faster than 2 
for i = 1:n
    %for every node, connect to its k most nearest neighbours
    nodei = data(i,:);
    [weight, idx] = sort(distancemat1(i,:),2,'ascend');
    %[weight, idx] = sort(distancemat1(i,:),'ascend')%TEST CODE
    %Ignore the first index
    idx(1) = [];
    
    %Keep track of the edges that will never be a part of the graph
    for jj = K+1:length(idx)
        edge = horzcat(i,idx(jj));
        if ~ismember(edge,MSTedges)
            edgesnotingraph(cntedgenotin,:) = edge;
            cntedgenotin = cntedgenotin + 1;
        end
        
    end
    
    idx(K+1:end) = [];
    %idx
    for j = 1:K  %Short loop 
         Adj(i,idx(j)) = distancemat1(i,idx(j));
         Adj(idx(j),i) = distancemat1(i,idx(j));
         Aout(i,idx(j)) = distancemat1(i,idx(j));
         Aout(idx(j),i) = distancemat1(i,idx(j));
    end
end



% datasetname = sprintf('dsgraphStep%d%d.csv', num,run);
% graphname = sprintf('datasetgraph%d%d.csv',nofsets(c),run);
%dlmwrite,edgelistmat, '\t')
cd ('C:\Users\Shaona\Documents\MATLAB\');  



% A


Adj = spones(Adj);


%Add two edge sets together from MST and KNN
Adj(lintrreind) = Adj(lintrreind)+1;
[dupedg] = find(Adj > 1);
Adj(dupedg) = 1;



% Adj(mstmat(:,1),mstmat(:,2)) = Adj(mstmat(:,1),mstmat(:,2)) + 1;
% Adj(mstmat(:,2),mstmat(:,1)) = Adj(mstmat(:,2),mstmat(:,1)) + 1;
% 
% %remove duplicate edges
% [dupedg] = find(Adj > 1);
% Adj(dupedg) = 1;




A = Adj;

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


end