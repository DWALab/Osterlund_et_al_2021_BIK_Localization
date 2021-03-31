
# INO Multichannel Watershed Segmentation and Binding Analysis
The INO is a FLIM Hyperspectral (FLIM-HS) system capable of collecting confocal images from multiple fluorescent proteins simultaneously. <br> 
This analysis generated protein-protein binding curves using FLIM-HS data collected on the INO.
FRET changes as function of Acceptor:Donor ratio can be extracted using TCSPC histograms and intensity images. 
Unlike the ISS analysis where the pixel TCSPC histograms are binned using Nearest Neighbour binning. We use Laplacian of Gaussian (LoG) kernel filtering to segment the structures in the intensity images and identify non-background pixels. These pixels are grouped into ROIs using multiseed watershed segmentation.<br>
The script is very verstile and can be adjusted for different imaging conditions. 
For the experiments presented in this paper, the optical configratoin of the INO is set such: <br>
Configuration 1
  - Venus is collected in the FLIM channel
  - DRAQ5 and MitoTracker Red signals are collected in the Hyperspectral channel.<br>

Configuration 2 <br>
  - mCerulean3 is collected in the FLIM channel
  - Venus is collected in the Hyperspectral channel.

<br><br>
Binding curves can be constructed by examining pixel that belong to different organelles in the cells.<br>
We use can use an of the protein images to construct maps for which pixels to be analyzed.<br>
In this script, the mCerulean3, MitoTracker, and DRAQ5 images are used to generate 3 different segmentation maps. Similar to the ISS analysis, these maps are used to measure ROI level binding information. Specifically how the FRET efficiency changes as a function of Acceptor:Donor. A secondary script is then run to bin ROI measurments and construct protein-protein binding curves.
<br> 
<br>
## Step1_Multimodal_Image_Segmentation
Open script ProcessScanFolder.m located in Step1_Multimodal_Image_Segmentation.<br>
Updated the following parameters:
- Path to where the FLIM scans are generated (myFolder)
- Path to wehre you want to save the tabulated ROI measurements (results_output_path)
- Path to where you want the segmentation maps and images to be saved (maps_output_path)
- File used to determine the untransfected lifetime (donor_filename)<br> 
In our case, we provide the filename for untransfected well collected using Configuration 2. 
<br> 
**CRITICAL** the script expects the data to be all stored in a single folder. The file time stamp is used to ensure that Configuration1 and Configuration2 scans are ordered consectively. 
Run the scripts

### Script Optimization
Multimodal imaging is very verstile and can be carried using different configurations. 
The script has been designed to be match the versatility of the acquisition configurations.<br>

#### Opitmization Sigmentation Parameters
For each channel we provide the segmentation algorithm with a set of parmeters to account for different protein/dye distributions.<br>
These are optimized for our experimental conditions but can be easily modified, by experimenting with the script AnalyzeTwoConfigurationScans.m <br>
We first provide the script with how the different configurations are related to our extracted intensity images <br> 
```
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
```
For each intensity image generated, we provide the script with:
- Configuration number used to extract the intensity image
- Whether to use 'FLIM' or 'HS' to sum bins and generated intensity maps 
if you don't have DRAQ5 just set this parameter to any other string ('None' is a good option).
- Which TCSPC/Spectral bins to sum to generate images
<br><br> 

We can also provde the segmentation parameters used for each channel
```
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
    %We also apply median filter to our nuclear channel
    filtered_draq5_img = medfilt2(draq5_img,[5 5]);
    draq5map = LogWatershedSegmentation(filtered_draq5_img,draq5_segmentation_parameters);
```
- segmentation_parameters.bg_threshold is the noise level expected in the channel
- segmentation_parameters.kernel_size is the Laplacian of Gaussian Kernel size
- segmentation_parameters.sigma is the width of Gaussian in the kernel smaller leads to extracts sharper blob like features inthe image
- segmentation_parameters.structural_element_size structural element used to find local maxima in the images
These serve as seeds for the watershed algorithm. Larger elements lead to larger sepertion between seeds and larger ROIs
- segmentation_parameters.min_roi_size is the size of the smallest binary object in the segmentatin map
-  segmentation_parameters.erode (mainly used for DRAQ5 to make sure that we are not too close to other organelle borders).

   
