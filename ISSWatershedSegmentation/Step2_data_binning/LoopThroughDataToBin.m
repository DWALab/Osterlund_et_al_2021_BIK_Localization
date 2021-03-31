function LoopThroughDataToBin ()
%Created by Nehad Hirmiz 20201111
%Run this code after running "LoopThroughMultipleDataFolders"
%User inputs path to untransfected data 
untransfected_path= 'E:\ISS data\Time Domain\BMK-D3\mCerulean3-BclXL-ActA\20160520\A8_Untransfected' ;

untransfected_measures = fullfile(untransfected_path,'Raw_Measurements.csv'); 
[untransfected_lifetime,untransfected_ratio,ch2_lower_thresh,ch2_upper_thresh] = CalculateUntransfectedLifetime(untransfected_measures) ;

%User inputs all folders to run the ROI analysis and export raw binding curve data

list_of_paths = {
    'E:\ISS data\Time Domain\BMK-D3\mCerulean3-BclXL-ActA\20160520\A1_Venus-ActA',...
    'E:\ISS data\Time Domain\BMK-D3\mCerulean3-BclXL-ActA\20160520\A2_Venus-BIK',...
    'E:\ISS data\Time Domain\BMK-D3\mCerulean3-BclXL-ActA\20160520\A3_Venus-BIKL61G',...
    'E:\ISS data\Time Domain\BMK-D3\mCerulean3-BclXL-ActA\20160520\A4_Venus-BIK-ActA',...
    'E:\ISS data\Time Domain\BMK-D3\mCerulean3-BclXL-ActA\20160520\A5_Venus-BIK-cb5',...
    'E:\ISS data\Time Domain\BMK-D3\mCerulean3-BclXL-ActA\20160520\A6_Venus-Beclin1',...
    'E:\ISS data\Time Domain\BMK-D3\mCerulean3-BclXL-ActA\20160520\A7_Venus-cb5'};



for i = 1:numel(list_of_paths)
    measurement_path = list_of_paths{i};
    measurement_file = fullfile(measurement_path,'Raw_Measurements.csv'); 
    output_file = fullfile(measurement_path,'Binned_Results.csv');
    BinISSData(measurement_file,output_file,untransfected_lifetime,untransfected_ratio,ch2_lower_thresh,ch2_upper_thresh); 

end

fprintf('The "LoopThroughDataToBin" Analysis is complete');
end