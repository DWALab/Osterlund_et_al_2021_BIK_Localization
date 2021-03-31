function [mc3_img,ven_img,mito_img,draq5_img] = GetIntensityProjectionsFromCubes(flim,spectral,experiment_parameters)

    mc3_cube  = [];
    ven_cube = [];
    mito_cube = []; 
    draq_cube = []; 
    
    %Assign cubes for different fluorophores
    if strcmp(experiment_parameters.mc3_channel,'FLIM')
        mc3_cube = flim{experiment_parameters.mc3_configuration_number};
    elseif strcmp(experiment_parameters.mc3_channel, 'HS')
        mc3_cube = spectral{experiment_parameters.mc3_configuration_number};
    else
        mc3_cube = [];
    end

    if strcmp(experiment_parameters.ven_channel,'FLIM')
        ven_cube = flim{experiment_parameters.ven_configuration_number};
    elseif strcmp(experiment_parameters.ven_channel, 'HS')
        ven_cube = spectral{experiment_parameters.ven_configuration_number};
    else
        ven_cube = [];
    end
    
    
    if strcmp(experiment_parameters.draq5_channel,'FLIM')
        draq_cube = flim{experiment_parameters.draq5_configuration_number};
    elseif strcmp(experiment_parameters.draq5_channel, 'HS')
        draq_cube = spectral{experiment_parameters.draq5_configuration_number};
    else
        draq_cube = [];
    end

    if strcmp(experiment_parameters.mitotracker_channel,'FLIM')
        mito_cube = flim{experiment_parameters.mitotracker_configuration_number};
    elseif strcmp(experiment_parameters.mitotracker_channel, 'HS')
        mito_cube = spectral{experiment_parameters.mitotracker_configuration_number};
    else
        mito_cube = [];
    end


    %Sum cubes to get intensity images
    if ~isempty(mc3_cube)
        mc3_img = squeeze(sum(mc3_cube(:,:,experiment_parameters.mc3_start_index:experiment_parameters.mc3_end_index),3));
    else 
        mc3_img = [];  
    end 


    if ~isempty(mc3_cube)
        ven_img = squeeze(sum(ven_cube(:,:,experiment_parameters.ven_start_index:experiment_parameters.ven_end_index),3));
    else 
        ven_img = [];  
    end 


    if ~isempty(draq_cube)
        draq5_img = squeeze(sum(draq_cube(:,:,experiment_parameters.draq5_start_index:experiment_parameters.draq5_end_index),3));
    else 
        draq5_img = [];  
    end 

    
    if ~isempty(mito_cube)
        mito_img = squeeze(sum(mito_cube(:,:,experiment_parameters.mitotracker_start_index:experiment_parameters.mitotracker_end_index),3));
    else 
        draq5_img = [];  
    end 


end