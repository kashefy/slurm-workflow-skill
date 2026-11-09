# Invented ML workload contract

Existing Python commands accept key=value arguments, including values with
spaces. Preserve them without eval. No training dependencies or datasets are
needed for authoring; do not install packages or run real ML compute.

- Preparation: `python3 prepare.py source_root=PATH output_dir=PATH` creates
  fold-00, fold-01, fold-02 each with train_ids.txt and validation_ids.txt.
- Training: `python3 train.py train_file=PATH validation_file=PATH output_dir=PATH train_seed=17`
  writes best.ckpt in that fold's output directory on success.
- Evaluation: `python3 evaluate.py run_dir=PATH checkpoint=best output_dir=PATH`
  consumes one fold's checkpoint in a fresh process.

These are interface contracts, not executable scripts. Generate wrappers, not
replacement ML implementations. Use a manifest to map task IDs 0,1,2 to the
three folds. All inputs are staged in advance; compute nodes have no internet.
Python/environment setup and all cluster settings remain user-configurable.
