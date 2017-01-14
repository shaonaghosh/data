function[tree, parent] = findRST(Adj,num)

tree = zeros(num,num);
treerst = zeros(num,1);
nodesintree = zeros(num,1);
parent = -1*ones(num,1);
addednodes = 0;
currnode = randi(num,1);
rootnode = currnode;
prevnode = -1;

while(addednodes ~= num)
   if ~ismember(currnode,nodesintree)
    addednodes = addednodes + 1;
    nodesintree(addednodes) = currnode;
    treerst(currnode) = 1;
    if prevnode ~= -1
        parent(prevnode) = currnode;
        tree(prevnode,currnode) = 1;
        tree(currnode,prevnode) = 1;
    end
   end
   prevnode = currnode;
   %Need to choose the next vertex at random
   neigh = Adj(prevnode,:);
   idsneigh = find(neigh);
   randdraw = randi(length(idsneigh),1);
   currnode = idsneigh(randdraw);
   
end



end