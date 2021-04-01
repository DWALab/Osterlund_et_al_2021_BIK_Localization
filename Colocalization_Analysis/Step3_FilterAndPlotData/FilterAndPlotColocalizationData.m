clear all;
close all;


%input path to coloclaization data and colocalization excel sheet
path_to_data = 'E:\Projects\Unpublished data\2020_Bik localization Paper\Organize results\Colocalization\mCherryLandmark Project\20190321_Rep3_plate2';
colocalization_filename ='Colocalization.xlsx'; 

%Read numberial and text value (xlsread is not recommended but works with all MatLab Versions)
[colocalization_num,colocalization_txt] = xlsread(fullfile(path_to_data,colocalization_filename),'Colocalization'); 

%Specify Column Indecies For the Different Channels
MedianIntensity_Red_col = 10;
MedianIntensity_Green_col = 11; 
MedianIntensity_mC3_col = 12; 
%Specify 
ROI_size_col = 3;
%Filter data using custom filters
good_data = find(colocalization_num(:,MedianIntensity_Red_col) > 0.001 & ...
    colocalization_num(:,MedianIntensity_Green_col) > 0.001 ); 


filtered_data = colocalization_num(good_data,:);  




% Provide path and filename for platmmap
platemap_excel_path = 'E:\Projects\Unpublished data\2020_Bik localization Paper\Organize results\Colocalization\mCherryLandmark Project\20190321_Rep3_plate2\FilterAndPlotColocalization';
excel_filename = 'MasterPlatemap.xlsx'; 
full_excel_path = fullfile(platemap_excel_path,excel_filename); 
sheet_name = 'Rep3-Plate2'; 
[num, txt] = xlsread(full_excel_path, sheet_name);

%Specify Columns for Cell type, red_channel, cyan_channel,green_channel
cell_col = 4;
red_channel_col = 8;
cyan_channel_col = 6; 
green_channel_col = 7; 

% Create a list cell lines used
cell_lines = txt(2:end,cell_col);
unique_cell_line = unique(cell_lines);

% Create a list of transfections 
red_channel = txt(2:end,red_channel_col); 
unique_red_channel = unique(red_channel); 

%Specify Columns where the colocalization data is stored for different combinations
GR_colocalization_col = 4 ; 
BR_colocalization_col = 5; 
BG_colocalization_col = 6;


%Run through Cell line and transfection lists identified
for i = 1:length(unique_cell_line)
    %set cell line to cell
    cell = unique_cell_line(i); 
    for j = 1:length(unique_red_channel)
        % transfection conditions to red_ch
        red_ch = unique_red_channel(j);
        disp([cell,'_',red_ch]); 
        
        sub_data_index = find( strcmp(txt(:,cell_col),cell) & strcmp(txt(:,red_channel_col),red_ch));

        col_row_indecies = num(sub_data_index-1,1:2); 
        transfection_conditions =txt(sub_data_index,7);
        cyan_channel = unique(txt(sub_data_index,cyan_channel_col));
        
        %%% Generate Boxplot for GREEN-RED Coloclization
        [X,sX,Y,correlation_medians,correlation_modes,num_datapoints] = GetColocalizationData(filtered_data,col_row_indecies,GR_colocalization_col);
        figure; hold on; 
        plot(X,Y,'k.','markerfacecolor',[0.6 0.6 0.6],'markeredgecolor',[0.6 0.6 0.6]);
        for k = 1:length(transfection_conditions)
            
        xx = X(sX==k); yy = Y(sX==k);
        plotonebox(yy,k,0.4,0.5)
    
        end
        plot(1:length(transfection_conditions),correlation_modes,'r+','MarkerSize',6,'LineWidth',2);
                
        set(gca,'xtick',[1:length(transfection_conditions)], 'xticklabel', transfection_conditions)
        xtickangle(45)
        ylabel( "Pearson's R Value");
        ylim([-1,1]); 
        gca.FontSize=40; 

        base_output_name = char(strcat(cell,'_',red_ch,'_','GreenRed'));
        set(gcf, 'Renderer', 'Painters');
        saveas(gcf,base_output_name,'epsc');
        saveas(gcf,base_output_name,'jpg'); 
        
        results_output_name = strcat(base_output_name,'.xls');
        results = [transfection_conditions num2cell(correlation_medians) num2cell(correlation_modes) num2cell(num_datapoints)];
        results = xlswrite(results_output_name,results); 
        
        close all;
        clear gca; 
        clear X sX Y ;
        

        
        if ~strcmp(cyan_channel,'none')

            %%% Generate Boxplot for BLUE-RED Coloclization
            [X,sX,Y,correlation_medians,correlation_modes,num_datapoints] = GetColocalizationData(filtered_data,col_row_indecies,BR_colocalization_col);
            figure; hold on; 
            plot(X,Y,'k.','markerfacecolor',[0.6 0.6 0.6],'markeredgecolor',[0.6 0.6 0.6]);
            for k = 1:length(transfection_conditions)

            xx = X(sX==k); yy = Y(sX==k);
            plotonebox(yy,k,0.4,0.5)

            end
            plot(1:length(transfection_conditions),correlation_modes,'r+','MarkerSize',6,'LineWidth',2);
        

            set(gca,'xtick',[1:length(transfection_conditions)], 'xticklabel', transfection_conditions)
            xtickangle(45)
            ylabel( "Pearson's R Value");
            ylim([-1,1]); 
            gca.FontSize=40; 

            base_output_name = char(strcat(cell,'_',red_ch,'_','BlueRed'));
            set(gcf, 'Renderer', 'Painters');
            saveas(gcf,base_output_name,'epsc');
            saveas(gcf,base_output_name,'jpg'); 

            results_output_name = strcat(base_output_name,'.xls');
            results = [transfection_conditions num2cell(correlation_medians) num2cell(correlation_modes) num2cell(num_datapoints)];
            results = xlswrite(results_output_name,results); 

            close all;
            clear gca; 
            clear X sX Y ;
          


            %%% Generate Boxplot for BLUE-Green Coloclization
            [X,sX,Y,correlation_medians,correlation_modes,num_datapoints] = GetColocalizationData(filtered_data,col_row_indecies,BG_colocalization_col);
            figure; hold on; 
            plot(X,Y,'k.','markerfacecolor',[0.6 0.6 0.6],'markeredgecolor',[0.6 0.6 0.6]);
            for k = 1:length(transfection_conditions)

            xx = X(sX==k); yy = Y(sX==k);
            plotonebox(yy,k,0.4,0.5)

            end
            plot(1:length(transfection_conditions),correlation_modes,'r+','MarkerSize',6,'LineWidth',2);
        
            set(gca,'xtick',[1:length(transfection_conditions)], 'xticklabel', transfection_conditions)
            xtickangle(45)
            ylabel( "Pearson's R Value");
            ylim([-1,1]); 
            gca.FontSize=40; 

            base_output_name = char(strcat(cell,'_',red_ch,'_','BlueGreen'));
            set(gcf, 'Renderer', 'Painters');
            saveas(gcf,base_output_name,'epsc');
            saveas(gcf,base_output_name,'jpg'); 

            results_output_name = strcat(base_output_name,'.xls');
            results = [transfection_conditions num2cell(correlation_medians) num2cell(correlation_modes) num2cell(num_datapoints)];
            results = xlswrite(results_output_name,results); 

            close all;
            clear gca; 
            clear X sX Y ;
         

        end
        
        
    end
end

        
        

















