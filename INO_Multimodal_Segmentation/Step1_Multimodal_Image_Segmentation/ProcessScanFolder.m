%%%%%%%%%% USER DEFINED Parameters %%%%%%%
%Provide path to data
myFolder = 'D:\REPS_qF3 FLIM-FRET + DRAQ5 and Mitotracker RED\20190705_Fun for Nehad rep2 compressed\rename';

%Path where tabular results are saved
results_output_path = 'C:\Users\Nehad Hirmiz\Documents\Programming\MatLab\Nehad_Nuclear segmentation_ConcentrationImages\Nehad_Nuclear segmentation_ConcentrationImages\results';
%Path where segmentation maps and intensity images are saved
maps_output_path = 'C:\Users\Nehad Hirmiz\Documents\Programming\MatLab\Nehad_Nuclear segmentation_ConcentrationImages\Nehad_Nuclear segmentation_ConcentrationImages\maps' ;

ven_spectral_start_index = 13;
ven_spectral_end_index = 19;

%With phasor analysis we take part of the decay beyong the IRF 
tcspc_decay_start_index = 62;
tcspc_decay_end_index = 462;

%Well that includes untransfected mCerulean3-protein cells to extract
%unbound lifetime and bleed through slope
%provide filename acquired using Configuration 2
donor_filename = 'WellID_D2-20190705T144104.899-vol0.tif'; 
donor_fullpath = fullfile(myFolder,donor_filename); 
mc3_noise_level = 20; %For untransfected well. 
%Get FLIM and Spectral Cubes 
donor_flim  = imread(donor_fullpath,1); 
donor_spec = imread(donor_fullpath,2); 
donor_ven_img = squeeze(sum(donor_spec(:,:,ven_spectral_start_index:ven_spectral_end_index),3));
donor_img = sum(donor_flim,3); 
%Pass segmentation parameters % these should be tested for different
%datasets 
donor_segmentation_parameters.bg_thrshold = 10 ;
donor_segmentation_parameters.kernel_size = 51; 
donor_segmentation_parameters.sigma = 0.25; 
donor_segmentation_parameters.structural_element_size = 15; 
donor_segmentation_parameters.min_roi_size = 30; 
donor_segmentation_parameters.erode =0;
[donormap,donormask] = LogWatershedSegmentation(donor_img,donor_segmentation_parameters);

[~,donor_mc3_measurements] = GetMeanMeasurementsUsingMaps(donormap,donor_img); 
[~,donor_ven_measurements] = GetMeanMeasurementsUsingMaps(donormap, donor_ven_img); 
xx = donor_mc3_measurements; 
yy = donor_ven_measurements; 

yy=yy(xx > mc3_noise_level);
xx=xx(xx>mc3_noise_level);
f= fit(xx,yy,'m*x'); 

bleedthrough_slope = f.m; 
%Let's get decays and estiate the position of untransfected cells in the
%phasor space
donor_roi_decays = GetDecaysForROIMaps(donor_flim,donormap);
global_donor_decay = squeeze(sum(donor_roi_decays,1));
global_donor_decay = global_donor_decay(:,tcspc_decay_start_index:tcspc_decay_end_index); 
[G_donor,S_donor]= GetINOPhasor(global_donor_decay');


%We are going to get a list of tif files in the folder 
% Check to make sure that folder actually exists.  Warn user if it doesn't.
if ~isfolder(myFolder)
    errorMessage = sprintf('Error: The following folder does not exist:\n%s\nPlease specify a new folder.', myFolder);
    uiwait(warndlg(errorMessage));
    myFolder = uigetdir(); % Ask for a new one.
    if myFolder == 0
         % User clicked Cancel
         return;
    end
end
% Get a list of all files in the folder with the desired file name pattern.
filePattern = fullfile(myFolder, '*.tif'); % Change to whatever pattern you need.
theFiles = dir(filePattern);

%
if mod(length(theFiles),2)
    error('THE NUMBER OF FILES IN THE DATA FOLDER MUST BE EVEN');
    quit;
end

for k = 1:2:length(theFiles)
    baseFileName1 = theFiles(k).name;
    baseFileName2 = theFiles(k+1).name; 
    AnalyzeTwoConfigurationScans(myFolder,baseFileName1,baseFileName2,results_output_path,maps_output_path,bleedthrough_slope,G_donor,S_donor); 
    
end
