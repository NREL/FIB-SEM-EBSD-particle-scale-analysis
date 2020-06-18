# FIB-SEM-EBSD-particle-scale-analysis
Collection of MATLAB files used to analyse FIB-SEM-EBSD data.
Currently, only the 3D histogram and the SI PDE model are uploaded. 

We will upload the remaining scripts, data, and functions after granted permission from NREL. Please contact us for more information or clarification.

The Lead Contact for the corresponding manuscript is Donal Finegan (Donal.Finegan@nrel.gov).
Questions regarding the code can be directly addressed to the code author at alex_quinn2@yahoo.com. Please include Donal Finegan in correspondance.

Below we describe the scripts provided.

## EBSD1_image_quality.m
Generation of the TIFF image quality map used in segmentations.

## EBSD2_segmentation.m
Walk-through style script for cleaning the segmentation produced in another software (e.g. Weka Trainable Segmentation) using the TIFF image shown above. Output values can be used as inputs into EBSD3_analysis.

## EBSD3_analysis.m
Collection of calculations and processing that creates and saves a struct named "grain_props". This struct contains morphology and orientation information for the particle analyzed. An option exists for saving data in excel format, although not all data is included.

## EBSD4_morphology.m
Visualization of morphology parameters. Creates items shown in Figure 5.

## EBSD5_3DHistograms.m
Visualization of c-axis orientations to global direction for Figures 3 and 6.

## EBSD6_rorientation.m
Calculation and visualization of the r-orientation, describing grain orientations relative to particle radial direction. For Figure 7.

## EBSD7_gmisorientation.m
Calculation and visualization of the g-misorientation (angle between c-axes of neighboring grains). For Figure 8.

## EBSD8_SI.m
Produces some of the SI Figures.

## EBSD9_other.m
Used to demonstrate other methods to visualize the data. May be updated later.

## pde_model_single_particle.m
Simple single-particle model with only cathode activation overpotential and diffusion in solid-state spherical particle.
