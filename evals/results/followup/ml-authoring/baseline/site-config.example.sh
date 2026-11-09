# Copy outside your repository (e.g. ~/.config/ml-slurm/site.sh), chmod 600,
# then replace every CHANGE_ME value. This is trusted Bash, sourced by submit.sh.
PROJECT_DIR='/absolute/path with spaces/to/existing ML programs'
SOURCE_ROOT='/absolute/path with spaces/to/staged source'
RUN_ROOT='/absolute/shared/path with spaces/to/runs'
# Shared, readable Bash setup file: activate your preinstalled environment here.
# It must work noninteractively without internet. Use ':' for no-op contents.
ENV_SETUP='/absolute/private/shared/path/environment.sh'
PARTITION='CHANGE_ME'
ACCOUNT='CHANGE_ME'
PREP_TIME='CHANGE_ME' # e.g. 00:30:00
TRAIN_TIME='CHANGE_ME' # e.g. 04:00:00
EVAL_TIME='CHANGE_ME' # e.g. 00:30:00
PREP_CPUS='CHANGE_ME'
TRAIN_CPUS='CHANGE_ME'
EVAL_CPUS='CHANGE_ME'
PREP_MEMORY='CHANGE_ME' # Slurm memory syntax, e.g. 8G
TRAIN_MEMORY='CHANGE_ME'
EVAL_MEMORY='CHANGE_ME'
# Optional site arguments; array elements preserve spaces. Configure GPUs here.
PREP_EXTRA=()
TRAIN_EXTRA=() # e.g. (--gres=gpu:1)
EVAL_EXTRA=()
