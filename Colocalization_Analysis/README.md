# Multichannel Colocalization Analysis
# STEP 1: Run cell profiler script on your data
-clear image data and upload your dataset
-update the channels in metadata to match your dataset
-run through test mode and play with filter settings until satisfied with identify primary/secondary objects
-change directory for saving data
-upload all images and run code
Note: this script has no intensity filters, just a simple filter by size and then a filter to remove cells that 
have multiple nuclei<br>
RESULT: The Cell profiler script, "Colocalization_addNucOverlapfilter" exports mutiple files
(see example in folder Example data> subfolder, "Exported_CellProfiler")<br>
In our example we only need: 
1. "20191010Image"
this contains the filename (RowColumnFeild of view) and lists corresponding Image number/object number.
2. "20191010Mask_Size_OneNuclei"
Contains ROI colocalization data for BR,BG,GR channels, size of ROI, median and mean Venus, Cyan and Red channel intensity. 
However, the exported data does not have my column/row information.  This is our second step in the analysis. 

#STEP 2: Get Row/Column identity for full dataset
To prepare data to run through open Both 1) "20191010Image" and 2) "20191010Mask_Size_OneNuclei" and duplicate the first
row * to add a second title row in the data.  Then save these files as, "filename.csv" and "Colocalization.csv", respectively. 
ie. See duplicate title:<br>

![plot](./screenshots/Picture1.png)
