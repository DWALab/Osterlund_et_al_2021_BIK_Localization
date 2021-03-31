function roi_decays = GetDecaysForROIMaps(flim_cube,roi_map)

max_roi_label =max(max(roi_map)); 

roi_decays = zeros(max_roi_label,512) ;
for i = 1:max_roi_label
    
[y,x] = find(roi_map == i); 
decay = zeros(1,512);
for j = 1:length(y);
curr_decay = squeeze(flim_cube(int64(y(j)),int64(x(j)),:));
decay = decay + double(curr_decay') ;
end
roi_decays(i,:) = decay; 
end




end
