Legacy install-scripts
======================

The legacy `install-scripts/` directory has been removed in v2.2.0 after a full
refactor to a modular, OS-specific layout under `modules/<os>/` and shared code
in `core/`.

Highlights:
- Shared helpers live in `core/Global_functions.sh`
- Ubuntu modules in `modules/ubuntu/`
- Arch modules in `modules/arch/`

If you need any of the old scripts, check the Git history prior to v2.2.0.

