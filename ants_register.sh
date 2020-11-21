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

EXAMPLE:

ants_register.sh -f C001_3DT1.nii.gz -m C002_3DT1.nii.gz -o C002_2_C001 -n 4

Compulsory arguments:

     -f:  Fixed or reference image (generally higher resolution anatomical)

     -m:  Moving image

     -o:  OutputPrefix: A prefix that is prepended to all output files.
          (Use something like GRASE_2_3DT1)

Optional arguments:

     -d:  ImageDimension: 2 or 3 (for 2 or 3 dimensional registration of single volume)
     Default: 3

     -n:  Number of threads (default = 1)

     -t:  transform type (default = 's')
        t: translation
        r: rigid
        a: rigid + affine
        s: rigid + affine + deformable syn
        sr: rigid + deformable syn
        b: rigid + affine + deformable b-spline syn
        br: rigid + deformable b-spline syn


These registrations tend to work better and faster with brain extracted images.        

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
Relevent references for this script include:
   * http://www.ncbi.nlm.nih.gov/pubmed/20851191
   * http://www.frontiersin.org/Journal/10.3389/fninf.2013.00039/abstract
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
fixed=?
moving=?
outpre=?
dimension=3
threads=2
tranfo="s"
########################## Parsing command line arguments

while getopts "f:m:o:d:n:t:h:" OPT
  do
  case $OPT in
      h) #help
   Help
   exit 0
   ;;
      f)
   fixed=$OPTARG
   ;;
      m)
   moving=$OPTARG
   ;;
      o)
   outpre=$OPTARG
   ;;
      d)
   dimension=$OPTARG
   ;;
      n)
   threads=$OPTARG
   ;;
      t)
   tranfo=$OPTARG
   ;;
     \?) # getopts issues an error message
   Help >&2
   exit
   ;;
  esac
done


########################## Check for required

if [[ ${fixed} == ? ]] || [[ ${moving} == ? ]] || [[ ${outpre} == ? ]];then
  echo " Error:  Must provide all required inputs"
  exit 1
fi

#####################################################################################
# Run commands

###############  REGISTRATION

# Print date and time begins
printf " \n BEGINNING REGISTRATION \n "
date +"Date : %d/%m/%Y Time : %H.%M.%S"
printf "  \n "

antsRegistrationSyNQuick.sh \
  -d ${dimension} \
  -f ${fixed} \
  -m ${moving} \
  -n ${threads} \
  -t ${tranfo} \
  -r 32 \
  -s 26 \
  -p d \
  -o ${outpre}

# Print date and time finishes
printf " \n COMPLETED REGISTRATION \n "
date +"Date : %d/%m/%Y Time : %H.%M.%S"
printf "  \n "


