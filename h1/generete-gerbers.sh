#!/usr/bin/env bash

set -euo pipefail

PROJECTS=("pcb-spacer" "pcb-stator")

for proj in "${PROJECTS[@]}"; do
    echo "=== Processing $proj ==="

    if [ ! -d "$proj" ]; then
        echo "Directory $proj not found, skipping."
        continue
    fi

    pushd "$proj" > /dev/null

    PCB_FILE=$(ls *.kicad_pcb 2>/dev/null | head -n 1)

    if [ -z "$PCB_FILE" ]; then
        echo "No .kicad_pcb file found in $proj"
        popd > /dev/null
        continue
    fi

    BOARD_NAME="${PCB_FILE%.kicad_pcb}"
    OUTDIR="fabrication"

    rm -rf "$OUTDIR"
    mkdir -p "$OUTDIR"

    if [ "$proj" = "pcb-spacer" ]; then
        echo "Generating Gerbers (NO TOP SOLDERMASK)..."

        kicad-cli pcb export gerbers "$PCB_FILE" \
            --layers "F.Cu,B.Cu,B.Mask,F.SilkS,B.SilkS,Edge.Cuts" \
            --output "$OUTDIR"

    else
        echo "Generating standard Gerbers..."

        kicad-cli pcb export gerbers "$PCB_FILE" \
            --output "$OUTDIR"
    fi

    echo "Generating drill files..."
    kicad-cli pcb export drill "$PCB_FILE" --output "$OUTDIR"

    ZIP_NAME="${BOARD_NAME}-gerbers.zip"

    echo "Creating zip archive $ZIP_NAME..."
    (
        cd "$OUTDIR"
        zip -r "../h1-$ZIP_NAME" .
    )

    echo "Archive created: $proj/$ZIP_NAME"

    popd > /dev/null
done

echo "=== All projects processed ==="
