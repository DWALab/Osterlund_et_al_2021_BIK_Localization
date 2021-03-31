function [G_array, S_array] = CalculatePhasorGSForDecayMatrix(roi_decays)

[r,c] = size(roi_decays);
    G_array = zeros(1,r); 
    S_array = zeros(1,r); 
    
    for i = 1:r
        decay =roi_decays(i,:)';
        %Estimate offset from last 10 time bins
        decay_noise = mean(decay(end-10:end)) ;
        %Subtract Offset from 
        decay = decay - decay_noise; 
        decay(decay < 0 ) = 0 ;
        [G,S] = GetINOPhasor(decay); 
        G_array(1,i) = G; 
        S_array(1,i) = S; 
    end

end