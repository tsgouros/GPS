## For using GPS, Dave Gow's Granger software
export FREESURFER_HOME=/Applications/freesurfer
source $FREESURFER_HOME/SetUpFreeSurfer.sh
export FSFAST_HOME=$FREESURFER_HOME/fsfast
export MNI_DIR=$FREESURFER_HOME/mni
#setenv SUBJECTS_DIR <Study processed MRI directory>
# Load the Minimum Norm Estimate software
export MNE_ROOT=/Applications/MNE-2.7.0-3106-MacOSX-i386
export MATLAB_ROOT=/Applications/MATLAB_R2018b.app
source $MNE_ROOT/bin/mne_setup_sh
## end GPS stuff
