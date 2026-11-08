# Copy outside both the workload repository and wrapper directory; chmod 600.
# This is trusted executable shell configuration. Fill every placeholder.
PROJECT='/CHOOSE/shared/workload repository'
SOURCE_ROOT='/CHOOSE/shared/staged source'
OUTPUT_ROOT='/CHOOSE/shared/output root'
RECEIPT_ROOT='/CHOOSE/private/shared/receipts'
ENV_SETUP='/CHOOSE/private/shared/environment.sh'
PYTHON='/CHOOSE/python executable'
# Explicitly choose after consulting site policy: ALL, NONE, or a variable list.
EXPORT_POLICY='CHOOSE'
# Set account, partition, QoS (or deliberately use site defaults), and resources.
# Each array can contain quoted options such as '--mem=8G' or '--time=01:00:00'.
COMMON_OPTIONS=()
PREP_OPTIONS=()
TRAIN_OPTIONS=()
EVAL_OPTIONS=()
# Required acknowledgement after filling resource arrays or choosing site defaults.
SITE_CONFIGURED=no
