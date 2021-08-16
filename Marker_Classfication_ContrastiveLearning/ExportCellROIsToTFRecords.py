import cv2
import matplotlib.pyplot as plt
import pandas as pd
import os
import numpy as np
import tensorflow as tf


def resize_and_normalize(img):
    #resize singel cell images to 100x100 pixel using linear interpolation
    img = cv2.resize(img,(100,100),cv2.INTER_LINEAR)
    #normalize image between 0 and 255 using minmax normalization
    img = cv2.normalize(img,None,0,255,cv2.NORM_MINMAX,cv2.CV_8U)
    return img

def estimate_noise(I):
    #a simple method to estimate noise in images using a small edge detection kernel
  H, W = I.shape
  M =np.array([[1, -2, 1],
       [-2, 4, -2],
       [1, -2, 1]])
  res = cv2.filter2D(I,cv2.CV_32F,M,None)
  sigma = np.sum(np.sum(np.absolute(res)))
  sigma = sigma * np.sqrt(0.5 * np.pi) / (6 * (W-2) * (H-2))
  return sigma

def variance_of_laplacian(image):
    # compute the Laplacian of the image and then return the focus
    # measure, which is simply the variance of the Laplacian
    return cv2.Laplacian(image, cv2.CV_64F).var()







def get_transfection_label(df,row_num,column_num):
    # A simple function to extract cell line and transfection label
    # experiment dataframe given row number and column number
    mask = (df['Row']==row_num) & (df['Column']==column_num)
    if not mask.any():
        return None,None
    trans_label = df[mask]['Green'].item()
    cell_line = df[mask]['Cell_Line'].item()
    return cell_line, trans_label


def main():
   
    ############################# USER DEFINED PARAMETERS #############################
    #Define experiment platemap
    #platemap 1
    plate1_df = pd.read_csv('experiment2_plate1_xl.csv')
    #platemap 2
    plate2_df = pd.read_csv('experiment2_plate2_xl.csv')
    #Measurement file generated from Cell Profile
    # which contains the image file name and the bounding box coordinates
    # for individual cells
    df = pd.read_csv(os.path.join('PATH_TO_CELLPROFILE_MEASUREMENTS','AreaMeasuresExperimentExperiment3XLFilteredCytoplasm.csv'))
    #Transfection labels
    keys = ['Venus','V-ActA','V-Cb5','V-Bik','V-Bik-L61G','V-Bik-4E','MitoGreen']
    green_channel_background = 250 # this was estimated from mean of untransfected cells
    num_of_pixels_above_bg = 4000 # this is 40% of a 100x100 pixel single cell image
    recordPath = os.path.join('PATH_TO_IMAGE_DATA','MCF7-CBclXL') #fullpath to export tfrecords

    
    ####################################################################################




    values = [i for i in list(range(len(keys)))]
    #crate a simple dictionary to convert classes into integer labesl for classification
    classes = dict(zip(keys, values))
    max_image_numbers  = np.max(df['ImageNumber'].values) #maximum number of images analyzed
    transfection_label = '' # empty string for transfection label
    cell_lin = '' #empty string for cellline 
    bestNum = 1000 #number of single cell images to be stored in each tfrecord
    num = 1 #integer to keep track of images
    recordFileNum = 1 # integer to keep track of tfrecords generated
    # name format of the tfrecord files
    recordFileName = ("Experiment2Blue.tfrecords-%.3d" % recordFileNum) #create string for tfrecord filename

    crop_count = 0 # single cell image crop count

    #create  empty tf record
    writer = tf.io.TFRecordWriter(os.path.join(recordPath ,recordFileName))

    #loop through images
    for i in range(max_image_numbers):
        print('Now Analyzing Image ', i+1, ' out of ', max_image_numbers)
        img_number = i + 1 ; 
        #create sub dataframe containing only a single image
        sub_df = df[df['ImageNumber']==img_number]
        sub_df = sub_df.reset_index()
        #if no cells were found in that image display it's number and continue
        if len(sub_df) == 0:
            print("COULD NOT FIND DATA FOR IMAGE", img_number)
            continue
        
        #get image path
        image_path = sub_df['PathName_FarRed'][0]
        #get red channel image path
        farred_filename = sub_df['FileName_FarRed'][0]
        #get green channel image path
        green_filename = sub_df['FileName_Green'][0]
        #get blue channel image path 
        blue_filename = sub_df['FileName_Blue'][0]
        #get well row number encoded in filename
        row_num = int(farred_filename[1:3])
        #get well column number encoded in filename
        col_num = int(farred_filename[4:6])

        #Measurement 1 corresponds to experiments done using platemap1
        #Measurement 2 corresponds to experiments done using platemap2

        #here the code check which platmap was used for the experiment
        # the well row_num and col_num are then used to assign experimental label to image
        
        if 'Measurement 1' in image_path:
            cell_line, transfection_label = get_transfection_label(plate1_df,row_num,col_num)
        
        elif 'Measurement 2' in image_path:
            cell_line, transfection_label = get_transfection_label(plate2_df,row_num,col_num)

        else:
            print('Transfection not found. Please check platmaps')
            break
        

        # if transfection not found break
        if transfection_label is None:
            break
        
        #create a label using the classes dictionary
        label = classes[transfection_label]
        
        #Read red, green, and blue channels for each scan
        farred_img = cv2.imread(os.path.join(image_path,farred_filename),-1)
        green_img = cv2.imread(os.path.join(image_path,green_filename),-1)
        blue_img = cv2.imread(os.path.join(image_path,blue_filename),-1)
        
        #convert to float 
        farred_img = np.float32(farred_img)
        green_img = np.float32(green_img)
        blue_img = np.float32(blue_img)

        #loop through single cell regions of interest (ROI)
        for roi_idx in range(len(sub_df)):
            # get the bounding box coordinate for the cells
            x1 = sub_df['AreaShape_BoundingBoxMaximum_X'][roi_idx]
            y1 = sub_df['AreaShape_BoundingBoxMaximum_Y'][roi_idx]
            x0 = sub_df['AreaShape_BoundingBoxMinimum_X'][roi_idx]
            y0 = sub_df['AreaShape_BoundingBoxMinimum_Y'][roi_idx]
            #crop cell far red image, resize and normalize
            farred_crop = farred_img[y0:y1,x0:x1].copy()       
            farred_crop = resize_and_normalize(farred_crop)
            # determine the variance of image Laplacian
            farred_img_focus = variance_of_laplacian(farred_crop)
            # check if cell is "in-focus", continue if cell is out of focus
            if  farred_img_focus < 30:
                continue
            
            #get cell image in green channel
            img = green_img[y0:y1,x0:x1].copy()
            img = cv2.resize(img,(100,100))        
            #create a cell mask using VENUS

            mask = np.zeros_like(img)
            mask[img > green_channel_background] = 1 
        
            #only accept image if cell intensity above background is >= 40% of image
            if np.sum(mask) < num_of_pixels_above_bg:
                continue

            #now that we have determined the cell is in focus using the draq5 channel 
            # and it is expressing enough green signal
            # we can export the blue  channel as well.
            img = blue_img[y0:y1,x0:x1].copy()
            img = cv2.resize(img,(100,100))
            img = cv2.normalize(img,None,0,255,cv2.NORM_MINMAX,cv2.CV_8U)


            # add single cell image to tfrecord files
            # if this tfrecord has over 1000 cells, create a new record
            num += 1
            if num > bestNum:
                num = 1 
                recordFileNum += 1
                recordFileName = ("Experiment2Blue.tfrecords-%.3d" % recordFileNum)
                writer = tf.io.TFRecordWriter(os.path.join(recordPath ,recordFileName))
                # print("Creating the %.3d tfrecord file" % recordFileNum)

            img_raw = img.tobytes()
            example = tf.train.Example(features=tf.train.Features(feature={
        "img_raw": tf.train.Feature(bytes_list=tf.train.BytesList(value=[img_raw])),
        "label": tf.train.Feature(int64_list=tf.train.Int64List(value=[label]))}))
            writer.write(example.SerializeToString())
            crop_count += 1

    ##### CRUICIAL close writing to tfrecord
    writer.close()

    print("ANALYSIS COMPLETE")
    print('Cells Exported to TF Record = ', crop_count)
    






if __name__ == "__main__":
    main()