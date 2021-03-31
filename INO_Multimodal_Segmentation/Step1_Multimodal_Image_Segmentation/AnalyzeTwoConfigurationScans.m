function AnalyzeTwoConfigurationScans(Path,filename,filename2,results_output_path,maps_output_path,bleedthrough_slope,G_donor,S_donor)

    disp(['NOW PROCESSING: ',filename,' and ',filename2]); 
    fullpath= fullfile(Path, filename);
    fullpath2 = fullfile(Path,filename2); 
    flim = {};
    spec = {};
    %Read FLIM cubes
    flim{1} = imread(fullpath,1); 
    flim{2} = imread(fullpath2,1);

    %Read Spectral cubes
    spec{1} = imread(fullpath,2); 
    spec{2} = imread(fullpath2,2); 
    %this is reading the cubes from the tiff files, a lifetime and spectral
    %cube see the images dimensions on the workspace
    % wavelengths = [441.973873	448.813351	455.652828	462.492306	469.331783	476.171261	483.010738	489.850215	496.689693	503.52917	510.368648	517.208125	524.047603	530.88708	537.726558	544.566035	551.405513	558.24499	565.084468	571.923945	578.763422	585.6029	592.442377	599.281855	606.121332	612.96081	619.800287	626.639765	633.479242	640.31872	647.211152	653.92318	660.433265	667.017844	673.602423	680.187002	686.771581	693.35616	699.940739	706.525318	713.109897	719.694476	726.279054	732.863633	739.448212	746.032791	752.61737	759.201949	765.786528	772.371107	778.955686	785.540265	792.124844	798.709423	805.294001	811.87858	818.463159	825.047738	831.632317	838.216896	844.801475	851.386054	0	0]; 

    tcspc_decay_start_index = 62;
    tcspc_decay_end_index = 462;

    %%%%% CRITICAL PARAMETER
    DECAYS_EXTRACTED_FROM_CUBE = 2;

    %we specify the image index and the channel index for each fluorophore
    %fluorophore = {image_number, channel_number}
    %mCerulean3
    experiment_parameters.mc3_configuration_number = 2;
    experiment_parameters.mc3_channel = 'FLIM'; 
    experiment_parameters.mc3_start_index = 1;
    experiment_parameters.mc3_end_index = 512;

    %Venus
    experiment_parameters.ven_configuration_number = 2; 
    experiment_parameters.ven_channel = 'HS'; 
    experiment_parameters.ven_start_index = 13;
    experiment_parameters.ven_end_index = 19;

    %DRAQ5
    experiment_parameters.draq5_configuration_number = 1; 
    experiment_parameters.draq5_channel = 'HS'; 
    experiment_parameters.draq5_start_index = 35;
    experiment_parameters.draq5_end_index = 55;

    %MitoTracker
    experiment_parameters.mitotracker_configuration_number = 1; 
    experiment_parameters.mitotracker_channel = 'HS'; 
    experiment_parameters.mitotracker_start_index = 22;
    experiment_parameters.mitotracker_end_index = 30;

    [mc3_img,ven_img,mitotracker_img,draq5_img] = GetIntensityProjectionsFromCubes(flim,spec,experiment_parameters); 




    mc3_segmentation_parameters.bg_thrshold = 5  ;
    mc3_segmentation_parameters.kernel_size = 51; 
    mc3_segmentation_parameters.sigma = 0.25; 
    mc3_segmentation_parameters.structural_element_size =15 ; 
    mc3_segmentation_parameters.min_roi_size = 30; 
    mc3_segmentation_parameters.erode = 0; 

    [mc3map,mc3mask] = LogWatershedSegmentation(mc3_img,mc3_segmentation_parameters);

    %mito tracker is in the spectral channel max emission at 599; 
    mito_segmentation_parameters.bg_thrshold = 300  ;
    mito_segmentation_parameters.kernel_size = 51; 
    mito_segmentation_parameters.sigma = 0.25; 
    mito_segmentation_parameters.structural_element_size =15 ; 
    mito_segmentation_parameters.min_roi_size = 30; 
    mito_segmentation_parameters.erode = 0; 
    [mitomap,mitomask] = LogWatershedSegmentation(mitotracker_img,mito_segmentation_parameters);


    draq5_segmentation_parameters.bg_thrshold = 300  ;
    draq5_segmentation_parameters.kernel_size = 51; 
    draq5_segmentation_parameters.sigma = 0.25; 
    draq5_segmentation_parameters.structural_element_size =15 ; 
    draq5_segmentation_parameters.min_roi_size = 30; 
    draq5_segmentation_parameters.erode = 1; 

    %first filter median filter draq5 image then we segment
    filtered_draq5_img = medfilt2(draq5_img,[5 5]);
    draq5map = LogWatershedSegmentation(filtered_draq5_img,draq5_segmentation_parameters);


    %Remove bleedthrough from venus image
    ven_img = ven_img - (bleedthrough_slope * mc3_img); 
    ven_img(ven_img < 0) = 0 ; 



    %Extract decays using mitochondrial segmentation map
    mitomap_roi_decays = GetDecaysForROIMaps(flim{DECAYS_EXTRACTED_FROM_CUBE},mitomap); 
    %Extract decays using mc3_img segmentation map
    mc3map_roi_decays = GetDecaysForROIMaps(flim{DECAYS_EXTRACTED_FROM_CUBE},mc3map); 
    %Extract decays using draq5 segmentation map
    draq5_roi_decays = GetDecaysForROIMaps(flim{DECAYS_EXTRACTED_FROM_CUBE},draq5map); 
    sub_mitomap_roi_decays = mitomap_roi_decays(:,tcspc_decay_start_index:tcspc_decay_end_index); 
    sub_mc3map_roi_decays = mc3map_roi_decays(:,tcspc_decay_start_index:tcspc_decay_end_index); 
    sub_draq5_roi_decays = draq5_roi_decays(:,tcspc_decay_start_index:tcspc_decay_end_index); 

    [mito_G,mito_S] = CalculatePhasorGSForDecayMatrix(sub_mitomap_roi_decays); 
    [mc3_G,mc3_S] = CalculatePhasorGSForDecayMatrix(sub_mc3map_roi_decays); 
    [draq5_G, draq5_S] = CalculatePhasorGSForDecayMatrix(sub_draq5_roi_decays); 

    
    %TCSPC SAMPLING PARAMETERS 
    freq0 = 30.51757e6;                   % laser frequency, here 80 MHz
    delta_t = 6.4e-11;           % width of one time channel

    harmonic = 1;    
    freq = harmonic * freq0;        % virtual frequency for higher harmonics
    w = 2 * pi * freq ; 

    unbound_lifetime = (1/w) * S_donor/G_donor * 1e9; 
    mito_lifetime = (1/w) * mito_S./mito_G * 1e9; 
    mc3_lifetime = (1/w) * mc3_S ./ mc3_G * 1e9; 
    draq5_lifetime = (1/w) * draq5_S ./ draq5_G * 1e9; 


    mito_fret = CalculateFRET(mito_lifetime,unbound_lifetime); 
    mc3_fret = CalculateFRET(mc3_lifetime,unbound_lifetime); 
    draq5_fret = CalculateFRET(draq5_lifetime,unbound_lifetime);




    
    [mito_roi_size, mito_donor] =  GetMeanMeasurementsUsingMaps(mitomap, mc3_img); 
    [ ~           , mito_acceptor] =  GetMeanMeasurementsUsingMaps(mitomap, ven_img); 
    
    [mc3_roi_size, mc3_donor] =  GetMeanMeasurementsUsingMaps(mc3map, mc3_img); 
    [ ~           , mc3_acceptor] =  GetMeanMeasurementsUsingMaps(mc3map, ven_img); 
    
    [draq5_roi_size, draq5_donor] =  GetMeanMeasurementsUsingMaps(draq5map, mc3_img); 
    [ ~           , draq5_acceptor] =  GetMeanMeasurementsUsingMaps(draq5map, ven_img);
    
    mito_roi_ids = 1:max(mitomap(:)); 
    draq5_roi_ids = 1:max(draq5map(:)); 
    mc3_roi_ids = 1:max(mc3map(:));


    filename_parts = split(filename,'.t'); 
    filename_base = char(filename_parts{1}); 


   

    %Generate Results paths 
    mito_results_path = fullfile(results_output_path,strcat(filename_base,'_mitotracker_curves.xlsx')); 
    mc3_results_path = fullfile(results_output_path,strcat(filename_base,'_mc3_curves.xlsx')); 
    draq5_results_path = fullfile(results_output_path,strcat(filename_base,'_draq5_curves.xlsx')); 


    %Save binding curves results
    WriteResultsToExcel(mito_results_path,mito_roi_ids,mito_roi_size',mito_donor,mito_acceptor,mito_lifetime,mito_fret);
    WriteResultsToExcel(mc3_results_path,mc3_roi_ids,mc3_roi_size',mc3_donor,mc3_acceptor,mc3_lifetime,mc3_fret);
    WriteResultsToExcel(draq5_results_path,draq5_roi_ids,draq5_roi_size',draq5_donor,draq5_acceptor,draq5_lifetime,draq5_fret);



    %Generate images path
    mito_img_path = fullfile(maps_output_path,strcat(filename_base,'_mitotracker_img.tif')); 
    mc3_img_path = fullfile(maps_output_path,strcat(filename_base,'_mc3_img.tif')); 
    draq5_img_path = fullfile(maps_output_path,strcat(filename_base,'_draq5_img.tif')); 
    ven_img_path = fullfile(maps_output_path,strcat(filename_base,'_ven_img.tif')); 
    mito_map_path = fullfile(maps_output_path,strcat(filename_base,'_mitotracker_segmap.tif')); 
    mc3_map_path = fullfile(maps_output_path,strcat(filename_base,'_mc3_segmap.tif')); 
    draq5_map_path = fullfile(maps_output_path,strcat(filename_base,'_draq5_segmap.tif')); 


    imwrite(uint16(mitotracker_img),mito_img_path) ; 
    imwrite(uint16(mc3_img), mc3_img_path); 
    imwrite(uint16(ven_img), ven_img_path);
    imwrite(uint16(draq_img), draq5_img_path);
    
    imwrite(uint16(draq5map),draq5_map_path);
    imwrite(uint16(mitomap),mito_map_path);
    imwrite(uint16(mc3map),mc3_map_path);

    disp('TWO SCAN PROCESSING COMPLETE');
end