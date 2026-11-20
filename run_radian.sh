#!/bin/bash
# MEMO: Adjust according to your R version
export DYLD_INSERT_LIBRARIES=/Library/Frameworks/R.framework/Versions/4.4-arm64/Resources/lib/libR.dylib 

# Start radian in the virtual environment (adjust the path to match your environment)
# For a .venv directory at the project root:
exec ./.venv/bin/radian "$@"