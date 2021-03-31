function [final_mito_map, mito_mask]  = LogWatershedSegmentation(mito_img, segmentation_parameters)
bg_thresh = segmentation_parameters.bg_thrshold  ;
kernel_size = segmentation_parameters.kernel_size ; 
sigma = segmentation_parameters.sigma; 
se_size = segmentation_parameters.structural_element_size ; 
min_area_size = segmentation_parameters.min_roi_size; 

%Use Laplacian of Gaussian Filtering to get Mitochonrdial mask 
log = fspecial('log',kernel_size,sigma);
fmito_img = imfilter(double(mito_img),log); 
mito_mask = zeros(size(fmito_img)); 
mito_mask(fmito_img < 0) = 1; 
mito_mask(mito_img < bg_thresh) = 0 ;
mito_mask = bwareaopen(mito_mask,min_area_size);


%Filter image before finding local maximum
se =strel('rectangle',[se_size,se_size]);
dilated_mito_img = imdilate(mito_img,se); 

%Find local maxima in filtered image
mito_loc_max = dilated_mito_img == mito_img; 

%use the local maximum map to calculate distance transform
mito_dist = bwdist(mito_loc_max); 
%use watershed to segment the local maximum
watershed_loc_mito = watershed(mito_dist); 
initial_mito_map = watershed_loc_mito .* uint16(mito_mask) ;
border_maps = initial_mito_map ==0;
border_maps(mito_mask ~=1 ) =0 ;

[by,bx ]  = find(border_maps ==1) ; 

bw = zeros(size(initial_mito_map)) ;
bw(initial_mito_map ~= 0) = 1; 
bw = bwareaopen(bw,min_area_size); 



relabelled_bw = bwlabel(bw,4); 
border_width = 3;


final_mito_map = relabelled_bw; 
for i = 1:length(bx)
    if bx(i) - border_width < 1 || bx(i) + border_width >600 || by(i) - border_width < 1 || by(i) + border_width >600
       continue
    end
    
    array = relabelled_bw(by(i) - border_width: by(i)+(border_width-1),bx(i) - border_width: bx(i)+(border_width-1));
    
    nonzero_array = array(array>0); 
    final_mito_map(by(i),bx(i)) = mode(nonzero_array); 
    
end

if segmentation_parameters.erode 
    mask = zeros(size(final_mito_map));
    mask(final_mito_map > 0) = 1; 
    disk_se = strel('disk', 2); 
    mask = imerode(mask,disk_se); 
    final_mito_map = final_mito_map .* mask; 
end




end