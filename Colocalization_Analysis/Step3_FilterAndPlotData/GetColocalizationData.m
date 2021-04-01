function [X,sX,Y,correlation_medians,mode_correlations,num_datapoints] = GetColocalizationData(subdata,col_row_indecies,colocalization_column_index)
sX = []; 
X = [] ; 
Y = []; 
[r,c] = size(col_row_indecies); 
well_numbers = r; 
correlation_medians=zeros(well_numbers,1);
mode_correlations=zeros(well_numbers,1);
num_datapoints=zeros(well_numbers,1);
for i = 1:well_numbers
    row = col_row_indecies(i,1); 
    col = col_row_indecies(i,2); 
    
    data_rows = find(subdata(:,1) == row & subdata(:,2) == col); 
    colocalization_data = subdata(data_rows,colocalization_column_index); 
    correlation_medians(i,1) = median(colocalization_data); 
    
   
    %add this data to our X,Y for boxplotting
    transfection_indicies = ones(size(colocalization_data))*i; 
    [XX,YY,most_frequent] = GetSwarmSpread(transfection_indicies,colocalization_data); 
    mode_correlations(i,1) = most_frequent; 
    num_datapoints(i,1) = length(transfection_indicies); 
    
    sX = vertcat(sX,transfection_indicies); 
    Y = vertcat(Y,YY); 
    X = vertcat(X,XX); 

end