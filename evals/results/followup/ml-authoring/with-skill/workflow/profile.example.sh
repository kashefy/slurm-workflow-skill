# COPY outside both project and skill repositories; chmod 600 before editing.
PROJECT='/ABSOLUTE/shared/project with spaces'
SOURCE_ROOT='/ABSOLUTE/shared/staged data'
RUN_PARENT='/ABSOLUTE/shared/fresh runs'
RECEIPT_PARENT='/ABSOLUTE/private/shared/receipts'
ENV_SETUP='/ABSOLUTE/private/shared/environment.sh'
# Fill site account/partition/QoS, CPUs, memory, time and GPU needs locally.
# Empty arrays mean site defaults, and must be deliberately reviewed.
PREP_OPTIONS=()
TRAIN_OPTIONS=()
EVAL_OPTIONS=()
# Decide --export policy for each stage explicitly with your site.
# Do not add array, dependency, parsable, or cluster-routing options.
