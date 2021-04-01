clear all; 
%specify file name
filename = 'Colocalization.csv';

%use csv_swallow to efficiently read txt file data

% sep = '\t'; %CSV files are separated by commas
% quote = '"';
% %Data seperated into numerical and text
% [num_data, text_data] = swallow_csv(filename, quote, sep);


fid = fopen(filename, 'r');


formatSpec = '%s';
N = 14; %number of columns in excels
col_title = textscan(fid,formatSpec,N,'Delimiter',',', 'Headerlines', 1);

%%%%%% CRITICAL %%%%%
% the script uses textscan to load large CSV data.
% you must provide the script with format of the data for each row 
% d = digit (integer), f = float (decimal), s =string (text)
fmt = '%d %d %d %f %f %f %f %f %f %f %f %f %f %f ';

data = textscan(fid,fmt, 'Delimiter',',','Headerlines', 1, 'treatAsEmpty','NULL', 'EmptyValue',NaN );

keep_col_title  = {'ImageNumber',	
    'ObjectNumber',
    'AreaShape_Area'
    'Correlation_Correlation_VenusNoBG_MitoTrackerNoBg'
    'Correlation_Correlation_mC3NoBG_MitoTrackerNoBg',
    'Correlation_Correlation_mC3NoBG_VenusNoBG',
    'Intensity_MeanIntensity_MitoTrackerNoBg',
    'Intensity_MeanIntensity_VenusNoBG',
    'Intensity_MeanIntensity_mC3NoBG',
    'Intensity_MedianIntensity_MitoTrackerNoBg',
    'Intensity_MedianIntensity_VenusNoBG',
    'Intensity_MedianIntensity_mC3NoBG',
    'Location_Center_X',
    'Location_Center_Y',
    
     };

filename2 = 'filename.csv';

fid2 = fopen(filename2, 'r');

N2 = 2; %number of columns in excels
col_title2 = textscan(fid2,formatSpec,N2,'Delimiter',',', 'Headerlines', 1);

fmt2 = '%s %d ';

data2 = textscan(fid2,fmt2, 'Delimiter',',','Headerlines', 1, 'treatAsEmpty','NULL', 'EmptyValue',NaN );


keep_col_title2 = {'FileName_MitoTracker',
    'ImageNumber'}; 



test = cell(length(data{1}(:)),1); 
for i = 1: length(data2{2}(:))
    val = data2{2}(i);
    filename = data2{1}(i); 
    indecies = find([data{1}==val]);
    for  j = 1:length(indecies)
        test{indecies(j)} = filename;
    end
end


