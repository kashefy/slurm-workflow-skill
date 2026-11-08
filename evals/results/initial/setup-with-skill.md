# User-facing response: setup_skill

Start with the training task; you can keep all site-specific values local. I won’t repeat the account you provided, and no files have been created.

Please describe these first, using placeholders for private paths or arguments:

- The Python command you normally run.
- Its input files or directories and expected outputs.
- Whether you need one training job, several stages in sequence, or many independent runs.
- Any existing project launcher or environment setup convention you want preserved.

After that, we can prepare a placeholder-only configuration for you to fill locally. Choose a private directory outside your project repositories, such as `${XDG_CONFIG_HOME:-$HOME/.config}/slurm-workflows/PROFILE`. Use directory permissions `700` and configuration-file permissions `600`; keep submission receipts there too.

The later configuration will cover only applicable settings: account, partition or QoS, resources, Python environment, shared paths, and environment-export policy. We’ll leave site defaults unset where appropriate. Generated scripts will run without this skill installed.

Before submission, you’ll get a local preview and a list of unresolved settings. You will perform all cluster checks and submissions; local checks cannot establish that the scheduler will accept or run a job.
