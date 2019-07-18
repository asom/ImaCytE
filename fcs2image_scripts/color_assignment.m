function color_assignment( handles,thres_value)

%   Copyright 2019 Antonios Somarakis (LUMC) ImaCytE toolbox

global n_data
if nargin <2
    thres_value=0.3;
end

clustMembsCell=getappdata(handles.figure1, 'clustMembsCell');
cluster_names=getappdata(handles.figure1, 'cluster_names');
markerlist=getappdata(handles.figure1,'selected_markers');

colors=[23 118 182 ;...
    255 127 0 ; ...
    36 161 33; ...
    216 36 31 ; ...
    141 86 73 ; ...
    229 116 195;...
    149 100 191; ...
    0 190 208;...
    188 191 0;...
    127 127 127];

hsv_colors=rgb2hsv(colors/255);

numClust=length(clustMembsCell);
fin_mat=zeros(length(markerlist),numClust);
for i=1:numClust
    temp=median(n_data(clustMembsCell{i},markerlist))';
    fin_mat(:,i)=temp;
end

n=my_normalize(fin_mat,'row'); %standardize per row


% n=norm_single_column( fin_mat,0,1);
[tree,leafOrder]=dendro_calculator(n);

T = my_cluster(tree,'cutoff',thres_value,'depth',8);
if max(T)>10
    T = cluster(tree,'maxClust',10);
end

cmap=zeros(length(T),3);
for i=1:max(T)
    idxs=find(T==i);
    if length(idxs)==1
            temp=hsv_colors(i,:);
    else
%     [~,c]=kmeans(nchoosek([0.4:0.01:1],2),length(idxs));
%     temp=[repmat(hsv_colors(i,1),length(idxs),1) c(:,1)  c(:,2)];
        [~,c]=kmeans([0:0.001:1]',length(idxs));
        temp=[repmat(hsv_colors(i,1),length(idxs),1) c  repmat(hsv_colors(i,3),length(idxs),1)];
    end
    cmap(idxs,:)=temp;
end
cmap=hsv2rgb(cmap);

clustMembsCell=clustMembsCell(leafOrder);
cluster_names=cluster_names(leafOrder);
cmap=cmap(leafOrder,:);
T=T(leafOrder);
% 
setappdata(handles.figure1, 'h_cluster', T);
setappdata(handles.figure1, 'clustMembsCell', clustMembsCell);
setappdata(handles.figure1, 'cluster_names', cluster_names);
setappdata(handles.figure1, 'cmap', cmap);
end

