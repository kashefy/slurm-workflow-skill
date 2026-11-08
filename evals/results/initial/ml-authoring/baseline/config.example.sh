# Copy outside project repositories (for example, ~/.config/ml-run.sh).
PROJECT_DIR='/ABSOLUTE/PATH/TO/ML PROJECT'
SOURCE_ROOT='/ABSOLUTE/PATH/TO/STAGED DATA'
RUN_ROOT='/ABSOLUTE/PATH/TO/NEW RUN'
# Required: replace with site-approved sbatch resource/account options.
# Set separately for each phase; include time, memory, CPUs, GPUs as appropriate.
PREP_OPTIONS=( '--partition=REPLACE_ME' )
TRAIN_OPTIONS=( '--partition=REPLACE_ME' )
EVAL_OPTIONS=( '--partition=REPLACE_ME' )
PYTHON=( python3 ) # e.g. ('/absolute/venv/bin/python')
# Optional absolute Bash setup script, sourced on compute nodes before Python.
ENV_SETUP=''
