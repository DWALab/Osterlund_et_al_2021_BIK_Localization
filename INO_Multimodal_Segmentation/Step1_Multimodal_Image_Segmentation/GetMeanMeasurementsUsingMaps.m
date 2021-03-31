function[roi_size, measurements] = GetMeanMeasurementsUsingMaps(segmentation_map, measurement_img)
    max_label = max(segmentation_map(:));
    measurements = zeros(max_label,1); 
    roi_size = zeros(max_label,1); 
    measurement_flat = measurement_img(:); 

    for i = 1:max_label
        idx = find(segmentation_map == i); 
        measurements(i,1) = mean(measurement_flat(idx)); 
        roi_size(i,1) = length(idx); 
    end
end


