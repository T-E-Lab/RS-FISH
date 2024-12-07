# batch_mask_filtering.py
# ImageJ macro written in Jython (python 2.7 with access to FIJI library)
# This script walks through directory of RSFish results and neuron masks
# It then filters the results through the neuron masks
# Creating:
# results filtered on only the cell bodies 
# and results filtered on the whole neuron
#
# Pseudocode / outline:
# Walk through results directory
# for each result csv file
#   Get both masks of neuron
#   filter results csv on each mask
#   store filtered results in subfolders

import os
from ij import IJ, ImagePlus


def get_masks(brain_dir):
    # Given the brain directory find the vvd masks
    # Return a list of mask paths
    
    # Get vvd masks directory
    vvd_dir = None
    for item in os.listdir(brain_dir):
        item_path = brain_dir + "/" + item
        if os.path.isdir(item_path) and item_path.endswith(".vrp_files"):
            vvd_dir = item_path
            
    if vvd_dir is None:
        print("No masks found in " + brain_dir)
        return None
    
    # Get mask paths in vvd_dir
    mask_list = []
    for item in os.listdir(vvd_dir):
        item_path = vvd_dir + "/" + item
        if os.path.isfile(item_path) and item_path.endswith(".msk"):
            mask_list.append(item_path)
            print("mask path: " + item_path)
    
    return mask_list
 
 
def process_brain(brain_dir):
    # Find masks
	# for each mask filter the results files
    # and store it in a subfolder named after the mask
    
    # Find masks
    mask_list = get_masks(brain_dir)
    if mask_list is None:
        return
    
    # Get result files
    brain_name = brain_dir.split("/")[-1].split(".")[0]

    # Filter on each mask
    exclude_size = 0 # Minimum results file size to filter (in kilobytes)
    for mask_path in mask_list:
        # Create folder to store filtered results
        mask_name = mask_path.split("/")[-1]
        if "cell_body" in mask_name:
            output_name = "cell_body_filtered"
        elif "full_neuron" in mask_name:
            output_name = "full_neuron_filtered"
        else:
            output_name = mask_name.split(".czi_")[-1].split(".")[0] + "_filtered"
        print("output_name: " + output_name)
        output_path = brain_dir + "/" + output_name
        if not os.path.exists(output_path):
            os.mkdir(output_path)

        for channel in ['2', '4']:
            inputs = brain_dir + "/" + "results_C"+channel+"-" + brain_name + ".csv"
            # Filter results
            mask_filtering_args = (" inputs=" + inputs
                + " mask=" + mask_path
                + " output=" + output_path
                + " exclude=" + str(exclude_size) )
            IJ.run("Mask Filtering", mask_filtering_args)
            print(mask_filtering_args)

def walk_files(src_dir):
    for root, directories, filenames in os.walk(src_dir):
        print(directories)
        for dirname in directories:
            print("checking if brain folder: " + dirname)
            if dirname.endswith(".czi"):
                print("processing " + dirname)
                process_brain(root + "/" + dirname)
                # directories.remove(dirname)
                print("processed " + dirname)


def main():
    parent_src_dir = "C:\Users\remoteuser\Desktop\temp_easifish_folder"
    walk_files(parent_src_dir)


if __name__ == "__main__":
    main()