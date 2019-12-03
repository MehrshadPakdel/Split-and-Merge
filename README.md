# Split-and-Merge
A FIJI / ImageJ macro to facilitate generation of figures-ready microscopy images from raw multi-channel microscopic files

# Goal
Simple macro to speeds up the processing of microscopic multi-channel raw files into colored, merged images with scale bars and a new figure montage.  

# Installation
Simply copy the macro file to your macro folder in your [Fiji](https://imagej.net/Fiji) directory and restart Fiji. You can access the macro from the Plugin section in Fiji.    

# Usage
Acquire 2 or 3 channel images by widefield or confocal microscopy. Run the macro and assign desired colors (green, red, blue, cyan, magenta) to channels. User dialog defines image processing settings such as background subtraction for individual or all channels, cropping image selection, scale bar insertion to individual or all channels and if figure montage is desired. The macro will process the images accordingly to the settings and save RGB images and figure montage in desired order as .tif files in a new "Results_ImageName" folder in the image directory. 

# Citation
If you used the Split_and_Merge_V3.2 macro or modified it, please cite our work. 

Deng, Y., Pakdel, M., Blank, B., Sundberg, E.L., Burd, C.G., von Blume, J., 2018. Activity of the SPCA1 Calcium Pump Couples Sphingomyelin Synthesis to Sorting of Secretory Proteins in the Trans-Golgi Network. Dev. Cell 47, 464-478.e8.
https://doi.org/10.1016/j.devcel.2018.10.012
