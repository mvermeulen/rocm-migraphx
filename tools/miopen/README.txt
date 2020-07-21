Several different scripts in this directory:

- build_miopen.sh - will build MIOpen from source (likely needs to be updated
  after ROCm 3.5)
- miopen_tune.c - is a program to see if a particular configuration is in the
  miopen database
- check_tuning.sh - is a program that uses miopen_tune to review a logfile.
