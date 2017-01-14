function [A,D,L] = builddatasetgraphWeighted(n,data, distancemat1, K)

%Function to compute the graph corresponding to the dataset
%Author: Shaona Ghosh
%Date: 10.01.2014

%Check for number of arguments
%error(nargchk(1, 3, nargin'));

if nargin < 4
    K = 5;
end


%Adjacency matrix 
Adj = sparse(n,n);

% Nearest neighbour method 1 :Faster than 2 but bug in construcing A Todo
for i = 1:n
    %for every node, connect to its k most nearest neighbours
    nodei = data(i,:);
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
%Create the Degree matrix
degrees = sum(A,2);

%Create degree sparse matrix
D = sparse(1:size(A,1), 1:size(A,2), degrees);
%D  = full(D);  %Redundant as had made sparse before ToDo Check to see exploiting sparsity

%Calculate laplacian
L = D - A;

%Check to see all the eigenvalues nonnegative for positive definiteness
%eigvals = eigs((L+L')/2);
eigvals = eigs(L);
ids = find(not(eigvals));
if ~isempty(ids)
    warning(1,'L not PSD');
end



Adj = spones(Adj)


end