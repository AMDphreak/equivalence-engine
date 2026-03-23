#!/bin/bash
# Build engine if needed
if [ ! -f "../bin/evolution-engine" ]; then
    echo "Rebuilding engine..."
    cd .. && dub build -b release && cd tests
fi

# Run test
echo "Running evolution-engine test..."
../bin/evolution-engine --path . --rules-dir ../rules/qt --from 5.15 --to 6.0
