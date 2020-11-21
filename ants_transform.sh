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

COMMAND: 
     antsApplyTransforms
          antsApplyTransforms, applied to an input image, transforms it according to a 
          reference image and a transform (or a set of transforms). 

Compulsory arguments:

     -i, input image

     -r, --destination image imageFileName
          For warping input images, the destination image defines the spacing, origin, size, 
          and direction of the output warped image. 

     -o, --output Filename for the warped output image

     -t, affine transformation filename (Example: C002_2_C0010GenericAffine.mat )
          Some ANTs registrations will provide two warp fields, one for the affine warp
          and one for the diffeomorphic warp.

Optional arguments:          

     -u, diffeomorphic transformation filename (Example: C002_2_C0011Warp.nii.gz )
          Some ANTs registrations will provide two warp field, one for the affine warp
          and one for the diffeomorphic warp.  These must be concatenated together ()

     -n, --interpolation Linear
                         NearestNeighbor
                         MultiLabel[<sigma=imageSpacing>,<alpha=4.0>]
                         Gaussian[<sigma=imageSpacing>,<alpha=1.0>]
                         BSpline[<order=3>]
                         CosineWindowedSinc
                         WelchWindowedSinc
                         HammingWindowedSinc
                         LanczosWindowedSinc
          Several interpolation options are available in ITK. These have all been made 
          available. 
          Default: Linear

EXAMPLE (Affine only):
ants_transform.sh -i C002_3DT1.nii.gz -r C001_3DT1.nii.gz -o Transfo_Test_Affine.nii.gz -t C002_2_C0010GenericAffine.mat 

EXAMPLE (Diffeomorphic and affine):
ants_transform.sh -i C002_3DT1.nii.gz -r C001_3DT1.nii.gz -o Transfo_Test_Diff_Affine.nii.gz -t C002_2_C0010GenericAffine.mat -u C002_2_C0011Warp.nii.gz

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
input=?
destination=?
outpre=?
interp=Linear
atranfo=?
dtranfo=?
########################## Parsing command line arguments

while getopts "i:r:o:n:t:u:h:" OPT
  do
  case $OPT in
      h) #help
   Help
   exit 0
   ;;
      i)
   input=$OPTARG
   ;;
      r)
   destination=$OPTARG
   ;;
      o)
   outpre=$OPTARG
   ;;
      n)
   interp=$OPTARG
   ;;
      t)
   atranfo=$OPTARG
   ;;
      u)
   dtranfo=$OPTARG
   ;;
     \?) # getopts issues an error message
   Help >&2
   exit
   ;;
  esac
done


########################## Check for required

if [[ ${input} == ? ]] || [[ ${destination} == ? ]] || [[ ${outpre} == ? ]] || [[ ${atranfo} == ? ]];then
  echo " Error:  Must provide all required inputs"
  exit 1
fi

#####################################################################################
# Run commands

###############  TRANSFORMATION

if [[ ${dtranfo} == "?" ]];then
  echo " Affine transformation only"
  antsApplyTransforms \
    -i ${input} \
    -r ${destination} \
    -t ${atranfo} \
    -o ${outpre} \
    -n ${interp} \
    -v 0
else
  echo " Diffeomorphic and affine transformation"
  antsApplyTransforms \
    -i ${input} \
    -r ${destination} \
    -t ${dtranfo} \
    -t ${atranfo} \
    -o ${outpre} \
    -n ${interp} \
    -v 0
fi


