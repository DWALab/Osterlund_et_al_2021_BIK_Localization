function WriteResultsToExcel(output_path,roi_ids,roi_size,donor,acceptor,lifetime,fret)


    array = [roi_ids' roi_size' acceptor donor lifetime' fret'];
    res = array2table(array, 'VariableNames',{'ROI_ID','ROI_SIZE_PIXEL','DONOR_INTENSITY','ACCEPTOR_INTENSITY','LIFETIME_NM','FRET'});
    writetable(res , output_path);


end