function [meanTau,meanRatio,ch2_lower_thresh,ch2_upper_thresh] = CalculateUntransfectedLifetime(csv_path) 



    
    
    data = csvread(csv_path,1); 
    tau_col = 6;
    ch2_col = 4; 
    ratio_col = 5;
  
    
    ch2 = data(:,ch2_col); 
    tau = data(:,tau_col); 
    ratio = data(:,ratio_col);
    
    
    ch2_lower_thresh = prctile(ch2,5);
    ch2_upper_thresh = prctile(ch2,95);
    
    

    tau = tau(ch2>ch2_lower_thresh & ch2<ch2_upper_thresh); 
    ratio = ratio(ch2>ch2_lower_thresh & ch2<ch2_upper_thresh);
%     ch2 =ch2(ch2>ch2_lower_thresh & ch2<ch2_upper_thresh);
    
    
    
    meanTau = mean(tau); 
    meanRatio = mean(ratio);
end