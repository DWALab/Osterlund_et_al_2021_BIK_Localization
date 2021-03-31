function [bin_center, bin_y, std_err_y, points_per_bin, std_dev_x, std_dev_y]  = BinCurveData(x,y,bins)
%%% Function used to bin curve data 
%%% provided bins are used as the edges for binning. 
%%% each bin is centered around two edges 
%%% bins containing elemnents below a certain theeshold are ignored

    %%% USER DEFINED PARAMETERS%%%%%
    binning_threshold = 10;

    bin_center= nan(1,length(bins) - 1); 
    bin_y = nan(1,length(bins) -  1) ; 
    std_err_y = nan(1,length(bins) - 1); 
    points_per_bin = nan(1,length(bins) - 1); 
    std_dev_x = nan(1,length(bins)-1);
    std_dev_y = nan(1,length(bins)-1);
    
    for i = 2:length(bins)
        lower = bins(i-1);
        upper = bins(i);
        elements = find(x > lower & x <= upper);
        if(length(elements) > binning_threshold)
            bin_center(1,i) = median(x(elements));
            bin_y(1,i) = median(y(elements));
            std_err_y(1,i) = std(y(elements))/sqrt(length(elements));
            points_per_bin(1,i) = length(elements);
            std_dev_x(1,i)=std(x(elements));
            std_dev_y(1,i)= std(y(elements));
        end
    end
end