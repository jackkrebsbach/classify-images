# Uses the meanshift segmentaton algorithm to segment an image. Returns File name as the output
import pymeanshift as pms
from os import path
import cv2
import sys

def segment(image_path, spatial_radius = 6 , range_radius = 4.5, min_density =  50, doComp = True):
    #Check to make sure the file exists
    if not path.isfile(image_path) or not isinstance(image_path, str):
        doComp = False
    
    out_path = ("/".join(image_path.split("/")[:-1]) + "/" + 
                image_path.split("/")[-1].split(".")[0] +"_seg_" + 
                str(int(spatial_radius)) + "_" + str(float(range_radius)) + "_" + 
                str(int(min_density)) + ".tif")
    
    if(len(image_path.split("/")) == 1):
        out_path = out_path.split("/")[1]
        
    if doComp:
        #Original image to be segmented
        original_image =  cv2.imread(image_path)
        #Segment the image
        (segmented_image, labels_image, number_regions) = pms.segment(original_image,
                                                                    spatial_radius = int(spatial_radius),
                                                                    range_radius = float(range_radius),
                                                                    min_density = int(min_density))
        #Using CV2 to write the image
        cv2.imwrite(out_path, segmented_image)
        #The path to write the segmented image.
        
    return out_path


#if __name__ == "__main__":
#    out_path = segment(image_path = sys.argv[1],
#                                   spatial_radius = sys.argv[2],
#                                   range_radius=sys.argv[3],
#                                   min_density=sys.argv[4])
#    print(out_path)
