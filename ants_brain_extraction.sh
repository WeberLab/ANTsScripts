#!/bin/bash

#####################################################################################
# Script functions

# Create our "press_enter function"
function press_enter
{
    echo ""
    echo -n "Press Enter to continue"
    read
    clear
}

# Create a simple method for using comment blocks
[ -z $BASH ] || shopt -s expand_aliases
alias BCOMM="if [ ]; then"
alias ECOMM="fi"


function Help {
    cat <<HELP

Performs template-based brain extraction for a T1 weighted image or GRASE Echo 1

Example:
  ants_brain_extraction.sh -a C001_3DT1.nii.gz

Will output the following files with the specified output prefix:
  BrainExtractionBrain.nii.gz
  BrainExtractionMask.nii.gz
  BrainExtractionPrior0GenericAffine.mat (transformation from extraction process)

Required arguments:
     -a:  Anatomical image                      Structural image, typically T1.  If more than one
                                                anatomical image is specified, subsequently specified
                                                images are used during the segmentation process.  However,
                                                only the first image is used in the registration of priors.
                                                So specify the T1 as the first image.

Optional arguments:
     -d:  Image dimension                       2 or 3 (for 2- or 3-dimensional image)
                                                Default: 3
     -c:  Tissue classification                 A k-means segmentation is run to find gray or white matter around 
                                                the edge of the initial brain mask warped from the template.
                                                This produces a segmentation image with K classes, ordered by mean
                                                intensity in increasing order. With this option, you can control
                                                K and tell the script which classes represent CSF, gray and white matter. 
                                                Format (\"KxcsfLabelxgmLabelxwmLabel\")
                                                Examples:   
                                                         -c 3x1x2x3 for T1 with K=3, CSF=1, GM=2, WM=3
                                                         -c 3x3x2x1 for T2 with K=3, CSF=3, GM=2, WM=1
                                                         -c 3x1x3x2 for FLAIR with K=3, CSF=1 GM=3, WM=2
                                                         -c 4x4x2x3 uses K=4, CSF=4, GM=2, WM=3
                                                Default: -c 3x1x2x3

     -e:  Brain extraction template             Anatomical template created using e.g. LPBA40 data set with
                                                buildtemplateparallel.sh in ANTs.
                                                Default: /data/ubcitm10/Adam/ANTs/IXI/T_template2.nii.gz

     -m:  Brain extraction probability mask     Brain probability mask used for extraction. Specify 
                                                Default: /data/ubcitm10/Adam/ANTs/IXI/T_template_BrainCerebellumProbabilityMask.nii.gz

     -o:  Output prefix                         Output directory + file prefix
--------------------------------------------------------------------------------------
ANTS was created by:
--------------------------------------------------------------------------------------
Brian B. Avants, Nick Tustison and Gang Song
Penn Image Computing And Science Laboratory
University of Pennsylvania
--------------------------------------------------------------------------------------
Read the ANTS documentation at:
    http://stnava.github.io/ANTs/
--------------------------------------------------------------------------------------
Contact Adam Dvorak for help (adam.dvorak@ubc.ca)
--------------------------------------------------------------------------------------     

HELP
    exit 1
}


# Provide output for Help
if [[ "$1" == "-h" || $# -eq 0 ]];
  then
    Help >&2
  fi


#####################################################################################
# arguments default values and parsing 

########################## Default values
image=?
dimension=?
tissue="3x1x2x3"
template="/data/ubcitm10/Adam/ANTs/IXI/T_template2.nii.gz"
probmask="/data/ubcitm10/Adam/ANTs/IXI/T_template_BrainCerebellumProbabilityMask.nii.gz"
outpre="BE"


########################## Parsing command line arguments

while getopts "a:d:c:e:m:o:h:" OPT
  do
  case $OPT in
      h) #help
   Help
   exit 0
   ;;
      a)
   image=$OPTARG
   ;;
      d)
   dimension=$OPTARG
   ;;
      c)
   tissue=$OPTARG
   ;;
      e)
   template=$OPTARG
   ;;
      m)
   probmask=$OPTARG
   ;;
      o)
   outpre=$OPTARG
   ;;
     \?) # getopts issues an error message
   Help >&2
   exit
   ;;
  esac
done


########################## Check for required

if [[ ${Image} == ? ]];then
  echo " Error:  Must provide all required inputs"
  exit 1
fi

#####################################################################################
# Run commands

###############  BRAIN EXTRACTION

# Print date and time begins
printf " \n BEGINNING BRAIN EXTRACTION \n "
date +"Date : %d/%m/%Y Time : %H.%M.%S"
printf "  \n "

# # WITH TISSUE CLASSES
# bash /data/ubcitm10/Adam/ANTs/Master_Scripts/antsBrainExtraction.sh \
#   -a ${image} \
#   -d ${dimension} \
#   -c ${tissue} \
#   -e ${template} \
#   -m ${probmask} \
#   -o ${outpre}

antsBrainExtraction.sh \
  -a ${image} \
  -d ${dimension} \
  -e ${template} \
  -m ${probmask} \
  -o ${outpre}

# Print date and time finishes
printf " \n COMPLETED BRAIN EXTRACTION \n "
date +"Date : %d/%m/%Y Time : %H.%M.%S"
printf "  \n "

# Clean up
rmdir ${outpre}




