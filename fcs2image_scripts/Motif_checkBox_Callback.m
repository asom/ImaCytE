 function Motif_checkBox_Callback(hObject,~,idx_motif_cells,handles,motif_idx)

% Callback function that funcitons upon selection of a motif
%   - hObject: used as identifierof the selected motif
%   - list2: identifier of the figure object whehre the motif will be created
%   - handles: variable with all the handlers and saved variables of the
%   environment
%   - idx_motif_cells: a vector that saves the idxes of the cells that
%   are grouped under the selected motif.
%   -motif_idx: a scalar of the cluster of the cell of under the selected motif.

%   Copyright 2019 Antonios Somarakis (LUMC) ImaCytE toolbox

persistent chk
persistent points

set(handles.figure1,'windowbuttonmotionfcn',{@mousemove_interaction,handles});

if isempty(chk)
    chk = 1;
    pause(0.5); %Add a delay to distinguish single click from a double click
    if chk == 1
        if get(hObject,'Tag')== 0; return; end
        motif_num = str2num(get(hObject,'Tag'));
        idx_motif_cells=idx_motif_cells{motif_num};
              
        clusteri=getappdata(handles.figure1,'clusteri');
        x_=unique(clusteri(idx_motif_cells,:));
        list3=[idx_motif_cells; x_(2:end)];
        points=union(list3,points);
        Show_Tissue_Selection(unique(points),handles);
        
        norm_neigh=getappdata(handles.figure1,'norm_neigh_list');
        norm_neigh=norm_neigh(idx_motif_cells,:);
        Z = linkage(norm_neigh);
        T = my_cluster(Z,'cutoff',0.8,'depth',4);
        if max(T)>9
            T = cluster(Z,'maxClust',9);
        end

        hfig=figure('Name',['2nd level of Motif Nr.' num2str(motif_num)]);
        for i=1:length(unique(T))
            idx_motif_cells_2{i}=idx_motif_cells(T==i);
            ax1(i)=subplot(3,3,i,axes(hfig));
            fr(i)=length(idx_motif_cells_2{i})/length(T);
            [handlers{i},mean_val{i},std_val{i}]=my_pie(handles,norm_neigh(T == i,:),motif_idx,fr(i),ax1(i));
            set(handlers{i},'Tag',num2str(i));
            set(handlers{i},'ButtonDownFcn',{@Motif_callback,idx_motif_cells_2{i},handles});
        end
        chk=[];
        set(hfig,'windowbuttonmotionfcn',{@mousemove,idx_motif_cells_2,handles,handlers,mean_val,std_val,fr,ax1});
    end
else
    chk = [];
    points=[];
    Show_Tissue_Selection(points,handles);
end
        

function Motif_callback(~,~,list2,handles)

persistent chk

if isempty(chk)
    chk = 1;
    pause(0.5); %Add a delay to distinguish single click from a double click
    if chk == 1
        
        clusteri=getappdata(handles.figure1,'clusteri');
        x_=unique(clusteri(list2,:));
        list3=union(x_(2:end),list2);
        
        Show_Tissue_Selection(unique(list3),handles); 
        chk=[];
    end
else
    chk = [];
    Show_Tissue_Selection([],handles);
end

function mousemove(src,~,L,handles,handlers,mean_val,std_val,fr,ax)

persistent pre_point3

f=src;
obj=hittest(f); 
temp=get(obj,'Tag');


    
if ~isempty(temp) 
    if isequal(pre_point3,str2num(temp)) 
        cmap=getappdata(handles.figure1,'cmap');
        [~,ind,~]=intersect(cmap,obj.EdgeColor,'rows');
        cluster_names=getappdata(handles.figure1,'cluster_names');

        pre_point3=str2num(temp);
        temp2=handlers{pre_point3};
        temp2=find(temp2 ==obj);
        switch temp2
            case 1
                delete(findobj(f,'tag','mytooltip'));
                text(ax(pre_point3),0,0,['Number of cells: '    num2str(length(L{pre_point3})) char(10) 'Frequency: ' num2str(fr(pre_point3)*100) '%'  char(10)  cluster_names{ind}],...
                'backgroundcolor',[1 1 1],'tag','mytooltip','edgecolor',[0 0 0],...
                'hittest','off');
            case 2
                delete(findobj(f,'tag','mytooltip'));
            otherwise
                if mod(temp2,2)==1
                    delete(findobj(f,'tag','mytooltip'));
                    text(ax(pre_point3),0,0,['Std value: '    num2str(std_val{pre_point3}(floor(temp2/2)))],...
                    'backgroundcolor',[1 1 1],'tag','mytooltip','edgecolor',[0 0 0],...
                    'hittest','off');
                else
                    delete(findobj(f,'tag','mytooltip'));
                    text(ax(pre_point3),0,0,['Mean value: '    num2str(mean_val{pre_point3}(floor(temp2/2)-1))  char(10)  cluster_names{ind} ],...
                        'backgroundcolor',[1 1 1],'tag','mytooltip','edgecolor',[0 0 0],...
                        'hittest','off');
                end
        end
    else
        pre_point3=str2num(temp);
%         Show_Tissue_Selection(L{pre_point3},handles);
    end
else
delete(findobj(f,'tag','mytooltip'));
end