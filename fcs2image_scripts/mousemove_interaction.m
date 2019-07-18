function mousemove_interaction(src,~,handles)

%   Copyright 2019 Antonios Somarakis (LUMC) ImaCytE toolbox

persistent pre_point_hor
persistent pre_point_ver
persistent pre_point2
persistent rect
persistent text_

ver_axes=getappdata(handles.figure1,'h_i_ver');
hor_axes=getappdata(handles.figure1,'h_i_hor');
motif_axes=getappdata(handles.figure1,'motif_axes');
size_axes=getappdata(handles.figure1,'cell_sizes');

f=src;
obj=hittest(f);

if isequal(obj.Tag,'H_i')
    a=get(obj,'parent');
    point=get(a,'currentpoint');
    point2=round(point(1,1:2));  
    hi_points=getappdata(handles.figure1,'points_hi');

    if ~isequal(point2,[pre_point_hor pre_point_ver])
%         h_i_per_cell=getappdata(handles.figure1,'mat_interactions');
%         xoffset=0.05;
%         yoffset=0.02;
        delete(rect); %delete last tool tip
        delete(text_); %delete last tool tip
        set(hor_axes(pre_point_hor),'Linewidth',1)
        set(ver_axes(pre_point_ver),'LineWidth',1)

        set(ver_axes(point2(2)),'LineWidth',4)
        set(hor_axes(point2(1)),'Linewidth',4)
        pre_point_hor=point2(1);
        pre_point_ver=point2(2);
%         Show_Tissue_Selection(h_i_per_cell{point2(1,1),point2(1,2)},handles);
    end
elseif find(obj ==ver_axes, 1)
    num=find(obj == ver_axes);
    if ~isequal(pre_point_ver,num)
        h_i=getappdata(handles.figure1,'h_i');
        a=get(h_i,'parent');
        
        delete(rect); %delete last tool tip
        delete(text_); %delete last tool tip
        set(hor_axes(pre_point_hor),'Linewidth',1)
        set(ver_axes(pre_point_ver),'LineWidth',1)
        
        set(ver_axes(num),'Linewidth',4);
        rect=rectangle(a,'Position',[0 num-0.5 size(h_i.CData,2)+0.5 1],'EdgeColor','r');
        set(rect,'Tag','Rect');
        pre_point_ver=num;
%     bwmask=ones(length(ver_axes))*0.5;
%     bwmask(pre_point_ver,:)=1;
%     set(h_i,'AlphaData',bwmask);
    end
elseif find(obj ==hor_axes, 1)
    num=find(obj == hor_axes);
    if ~isequal(pre_point_hor,num)
        h_i=getappdata(handles.figure1,'h_i');
        a=get(h_i,'parent');
    
        delete(rect); %delete last tool tip
        delete(text_); %delete last tool tip
        set(hor_axes(pre_point_hor),'Linewidth',1)
        set(ver_axes(pre_point_ver),'LineWidth',1)
       
        set(hor_axes(num),'Linewidth',4);
        rect=rectangle(a,'Position',[num-0.5 0 1 size(h_i.CData,1)+0.5],'EdgeColor','r');
        set(rect,'Tag','Rect');
    
        pre_point_hor=num;
%     bwmask=ones(length(hor_axes))*0.1;
%     bwmask(:,pre_point)=1;
%     set(h_i,'AlphaData',bwmask*0.7);
%     Show_Tissue_Selection(clustMembsCell{pre_point},handles);
    end
elseif find(obj == size_axes,1)
%     if ~isequal(pre_point,find(obj == size_axes))
    pre_point=find(obj == size_axes) ;
        delete(rect); %delete last tool tip
        delete(text_); %delete last tool tip
        text_=text(get(obj,'Parent'),pre_point,obj.YData,['Cells:' num2str(obj.YData)],...
            'backgroundcolor',[1 1 1],'tag','mytooltip','edgecolor',[1 1 1],...
            'hittest','off','Fontsize',8);   
%     end
elseif find( get(obj,'Parent') == motif_axes)
    temp=get(obj,'Tag');
    ax=get(obj,'Parent');
    L=getappdata(handles.figure1,'t_idx_motif_cells');
    cmap=getappdata(handles.figure1,'cmap');
    [~,ind,~]=intersect(cmap,obj.EdgeColor,'rows');
    cluster_names=getappdata(handles.figure1,'cluster_names');

    mean_val=getappdata(handles.figure1,'t_mean_val');
    std_val=getappdata(handles.figure1,'t_std');
    fr=getappdata(handles.figure1,'t_fr');
    z=getappdata(handles.figure1,'t_z');
    if isequal(pre_point2,str2num(temp)) 
        handlers=getappdata(handles.figure1,'motif_handlers');
        pre_point2=str2num(temp);
        temp4=handlers{pre_point2};
        temp2=find(temp4 ==obj);
        switch temp2
                case 1
                    delete(findobj(motif_axes,'tag','mytooltip'));
%                     delete(text_);
                    text_=text(ax,0.2,0,['Cells: '    num2str(length(L{pre_point2})) char(10) 'Freq.: ' num2str(fr(pre_point2)*100) '%'  char(10) cluster_names{ind} ],...
                    'backgroundcolor',[1 1 1],'tag','mytooltip','edgecolor',[0 0 0],...
                    'hittest','off','Fontsize',8,'Interpreter', 'none');
                case 2
                    delete(findobj(f,'tag','mytooltip'));
                otherwise
                    if temp2== length(temp4)
                        delete(findobj(motif_axes,'tag','mytooltip'));
                        text_=text(ax,0,0,['Z: ' num2str(z(pre_point2)) ],...
                        'backgroundcolor',[1 1 1],'tag','mytooltip','edgecolor',[0 0 0],...
                        'hittest','off','Fontsize',8,'Interpreter', 'none');
                    elseif mod(temp2,2)==1
                        delete(findobj(motif_axes,'tag','mytooltip'));
                        text_=text(ax,0,0,['Std: ' num2str(std_val{pre_point2}(floor(temp2/2))) ],...
                        'backgroundcolor',[1 1 1],'tag','mytooltip','edgecolor',[0 0 0],...
                        'hittest','off','Fontsize',8,'Interpreter', 'none');
                    else
                        delete(findobj(motif_axes,'tag','mytooltip'));
                        text_=text(ax,0,0,['Mean: ' num2str(mean_val{pre_point2}(floor(temp2/2-1))) char(10) cluster_names{ind} ],...
                        'backgroundcolor',[1 1 1],'tag','mytooltip','edgecolor',[0 0 0],...
                        'hittest','off','Fontsize',8,'Interpreter', 'none');
                    end
        end
    else
        pre_point2=str2num(temp);
        delete(findobj(f,'tag','mytooltip'));
    end
else
   
%    delete(findobj(f,'tag','mytooltip')); %delete last tool tip 
   delete(text_)
%  delete(findobj(f,'tag','Rect')); %delete last tool tip
    delete(rect)

    try 
        set(hor_axes(pre_point_hor),'Linewidth',1)
        set(ver_axes(pre_point_ver),'LineWidth',1)
    catch
        pre_point_hor=[];
        pre_point_ver=[];
    end
end
