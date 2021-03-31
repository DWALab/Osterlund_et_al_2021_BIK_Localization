function BinISSData(csv_path,output_path,untransfected_lifetime,untransfected_ratio,ch2_lower_thresh,ch2_upper_thresh)
    
    bins = [0,0.02,0.04,0.06,0.08,0.1,0.2,0.3,0.4,0.6,0.8,1.0,1.25,1.5,2,2.5,3,3.5,4,4.5,5,6,7,8,9,10]; 

    
 

    
    data = csvread(csv_path,1); 
    ch2_col = 4; 
    ratio_col = 5;
    tau_col = 6; 

    ch2 = data(:,ch2_col); 
    ratio = data(:,ratio_col); 

    tau = data(:,tau_col); 

    
    ch2 = ch2(ratio >= 0);
    tau = tau(ratio >= 0 ) ;
    ratio = ratio(ratio >= 0);

    ratio=ratio(ch2 > ch2_lower_thresh & ch2 < ch2_upper_thresh) ;
    tau = tau(ch2 > ch2_lower_thresh & ch2 < ch2_upper_thresh); 
    untransfected_tau = tau(ratio <= untransfected_ratio);
    untransfected_ratioarray = ratio(ratio <= untransfected_ratio);
    
    tau = tau(ratio > untransfected_ratio);
    ratio = ratio(ratio > untransfected_ratio);
    
    %ch2 = ch2 (ch2 > ch2_lower_thresh & ch2 < ch2_upper_thresh) ; 
    untransfected_tau_well = mean(untransfected_tau);
    untransfected_fret = (1-(untransfected_tau/untransfected_tau_well))*100;
    untransfected_fret_stderr = std(untransfected_fret)/ sqrt(length(untransfected_fret));
    fret = (1 - (tau/untransfected_tau_well)) * 100 ; 
    

    [b, byy,bey,points_per_bin,ratio_std,fret_std] = BinCurveData(ratio,fret,bins); 
    b(1) = 0 ;
    byy(1) = 0 ;
    bey(1) = untransfected_fret_stderr ;
    points_per_bin(1) = length(untransfected_tau);
    ratio_std(1)= std(untransfected_ratioarray);
    fret_std(1) = std(untransfected_fret);
    results = [b' byy', bey',points_per_bin',ratio_std',fret_std'] ;



    col_names = {'AcceptorDonor_Intensity_Ratio','Binned_FRET','FRET_std_error','Points_Per_Bin','Ratio_std','FRET_std'};
    SaveToCSVWithColumnNames(output_path,results,col_names); 
    
end
    