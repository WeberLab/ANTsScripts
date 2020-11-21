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

This script is for creating an unbiased template that best represents a group of images.
By default it will use intensity bias field correction (recommended) and will create an 
unbiased starting point by averaging all inputs (definitely recommended).

Example:
    ants_create_template.sh templateInput.csv

*WHERE ALL IMAGES MUST BE LOCATED IN THE SAME DIRECTORY*

For an example of how to format the input file, see:
    /data/ubcitm10/Adam/ANTs/Example_Data/templateInput.csv

To disconnect, call as:
nohup ants_create_template.sh -k templateInput.csv &


Compulsory arguments:

     -k  List of images in the current directory, eg *_t1.nii.gz. Should be at the end
          of the command.  Optionally, one can specify a .csv or .txt file where each
          line is the location of the input image.


NB: All images to be added to the template should be in the same directory, and this
    script should be invoked from that directory.



Optional arguments:

     -d:  ImageDimension: 2 or 3 (for 2 or 3 dimensional registration of single volume)
   ImageDimension: 4 (for template generation of time-series data)

     -o:  OutputPrefix; Folder and for output with prefix that is prepended to all output files.
          Default: ./ANTs_Template/T_

     -g:  Gradient step size: smaller in magnitude results in more
          cautious steps.
          Default: 0.15

     -i:  Iteration limit: iterations of the template construction
          (Iteration limit)*NumImages registrations.
          Default: 4

     -j:  Number of cpu cores to use locally for pexec option
          Default: 4

     -q:  Max iterations for each pairwise registration:
          specified in the form ...xJxKxL where
            J = max iterations at coarsest resolution (here, reduced by power of 2^2)
            K = middle resolution iterations (here, reduced by power of 2)
            L = fine resolution iteratioxns (here, full resolution).
          Finer resolutions take much more time per iteration than coarser resolutions.
          Default: 100x100x80x40

     -f:  Shrink factors:  Also in the same form as -q max iterations.  
          Needs to have the same number of components.
          Default: 6x4x2x1

     -s:  Smoothing factors:  Also in the same form as -q max
          iterations.  Needs to have the same number of components.
          Default: 3x2x1x0

     -n:  N4BiasFieldCorrection of moving image: 0 == off, 1 == on 
          Default: 1

     -l:  Use linear image registration stages during the pairwise (template/subject)
          deformable registration.  Otherwise, registration is limited to SyN or
          B-spline SyN (see '-t' option).  
          Default: 1

     -m:  Type of similarity metric used for registration:  Options are
            CC = cross-correlation
            MI = mutual information
            MSQ = mean square difference
            DEMONS = demon's metric
          If the CC metric is chosen, one can also specify the radius e.g. '-m CC[4]'.
          Default: CC

     -t:  Type of transformation model used for registration:  Options are
            SyN = Greedy SyN
            BSplineSyN = Greedy B-spline SyN
            TimeVaryingVelocityField = Time-varying velocity field
            TimeVaryingBSplineVelocityField = Time-varying B-spline velocity field
          Default = SyN

     -y:  Update the template with the full affine transform. If 0, the rigid
          component of the affine transform will not be used to update the template. 
          If your template drifts in translation or orientation try -y 0.
          Default: 1

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
Please reference http://www.ncbi.nlm.nih.gov/pubmed/20851191 when employing this script
in your studies. A reproducible evaluation of ANTs similarity metric performance in
brain image registration:

* Avants BB, Tustison NJ, Song G, Cook PA, Klein A, Gee JC. Neuroimage, 2011.

Also see http://www.ncbi.nlm.nih.gov/pubmed/19818860 for more details.

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
dimension=3
outpre="./ANTs_Template/T_"
grad=0.15
iter=4
cores=4
piter=100x100x80x40
shrink=6x4x2x1
smooth=3x2x1x0
N4bias=1
linear=1
similarity=CC
tranfo=SyN
fullaffine=1

########################## Parsing command line arguments

while getopts "k:d:o:g:i:j:q:f:s:n:l:m:t:y:h:" OPT
  do
  case $OPT in
      h) #help
   Help
   exit 0
   ;;
      k)
   input=$OPTARG
   ;;
      d)
   dimension=$OPTARG
   ;;
      o)
   outpre=$OPTARG
   ;;
      g)
   grad=$OPTARG
   ;;
      i)
   iter=$OPTARG
   ;;
      j)
   cores=$OPTARG
   ;;
      q)
   piter=$OPTARG
   ;;
      f)
   shrink=$OPTARG
   ;;
      s)
   smooth=$OPTARG
   ;;
      n)
   N4bias=$OPTARG
   ;;
      l)
   linear=$OPTARG
   ;;
      m)
   similarity=$OPTARG
   ;;
      t)
   tranfo=$OPTARG
   ;;
      y)
   fullaffine=$OPTARG
   ;;
     \?) # getopts issues an error message
   Help >&2
   exit
   ;;
  esac
done


########################## Check for required

if [[ ${input} == ? ]];then
  echo " Error:  Must provide all required inputs"
  exit 1
fi

#####################################################################################
# Run commands

###############  TEMPLATE CREATION

# Print date and time begins
printf " \n BEGINNING TEMPLATE CREATION \n "
date +"Date : %d/%m/%Y Time : %H.%M.%S"
printf "  \n "


antsMultivariateTemplateConstruction2.sh \
  -d ${dimension} \
  -o ${outpre} \
  -i ${iter} \
  -g ${grad} \
  -e 1 \
  -c 2 \
  -j ${cores} \
  -k 1 \
  -w 1 \
  -f ${shrink} \
  -s ${smooth} \
  -q ${piter} \
  -n ${N4bias} \
  -a 1 \
  -y ${fullaffine} \
  -r 1 \
  -m ${similarity} \
  -l ${linear} \
  -t ${tranfo} \
  ${input}
###############

# previously 
# -g 0.2
# -q 100x70x50x10
# -y 1

# Print date and time finishes
printf " \n COMPLETED TEMPLATE CREATION \n "
date +"Date : %d/%m/%Y Time : %H.%M.%S"
printf "  \n "










