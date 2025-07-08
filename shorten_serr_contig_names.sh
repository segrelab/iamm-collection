#!/bin/bash

# --- Configuration ---
# The original file you want to read from
INPUT_FILE="/projectnb/hfsp/IAMM_reference_files/fasta/2526164535.fna"

# The new file where the modified content will be saved
OUTPUT_FILE="/projectnb/hfsp/IAMM_reference_files/fasta/2526164535-custom-contig-name.fna"

# --- Script ---
echo "Processing ${INPUT_FILE}..."

# Run sed on the input file and redirect the standard output to the new file
sed 's/_draft_12-05-13.1$//' "$INPUT_FILE" > "$OUTPUT_FILE"

echo "Done. Modified FASTA saved to ${OUTPUT_FILE}"