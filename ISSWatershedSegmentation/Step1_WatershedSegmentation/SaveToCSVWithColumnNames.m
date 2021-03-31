function SaveToCSVWithColumnNames(filepath,data,cHeader)
%this function is used to write matrix data into a csv file
%this is done by first creating the row with the column names
%Then the matrix data is appended into the created file

%     cHeader = {'ab' 'bcd' 'cdef' 'dav'}; %dummy header
    commaHeader = [cHeader;repmat({','},1,numel(cHeader))]; %insert commaas
    commaHeader = commaHeader(:)';
    textHeader = cell2mat(commaHeader); %cHeader in text with commas
    %write header to file
    fid = fopen(filepath,'w'); 
    fprintf(fid,'%s\n',textHeader)
    fclose(fid)
    %write data to end of file
    dlmwrite(filepath,data,'-append');

end