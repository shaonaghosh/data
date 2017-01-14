function[data,labels,N,d] = parseNewsgroupData()


%Function to load the dataset
%Author: Shaona Ghosh
%Date: 31.07.2014


%No of records and values per record
novals = 53975;


try
    distpath = fullfile(pwd,'20news-bydate', 'matlab');
    datafilepath = fullfile(distpath,'train.data');
    labelsfilepath = fullfile(distpath,'train.label');
    
    fid = fopen(datafilepath,'r+');
    fidlab = fopen(labelsfilepath,'r+');
   
    data = textscan(fid, repmat('%d',1,3),  'delimiter', '\t', 'CollectOutput', 1);
    labelsdata = textscan(fidlab, repmat('%d',1,1),  'delimiter', '\t', 'CollectOutput', 1);
    
    
    data = data{1};
    labels = labelsdata{1};
    
    [N,d] = size(data);
   
   
    fclose(fid);
    fclosE(fidlab);
catch
   if -1 == fid, error('Cannot open file for reading.'); end
   if -1 == fidlab, error('Cannot open file for reading.'); end 

end



end