#!/bin/bash

# --- Configuration ---
# Path to the CSV file containing the master list of genomes.
CSV_FILE="/projectnb/hfsp/iamm-collection/iamm_references.csv"
# Base path for the directories you want to check.
BASE_DIR="/projectnb/hfsp/IAMM_reference_files"

# --- Script ---

# Check if a subdirectory name was provided as an argument.
if [ -z "$1" ]; then
    echo "Error: No subdirectory name provided."
    echo "Usage: $0 <subdirectory_name>"
    echo "Example: $0 fasta"
    exit 1
fi

# Construct the full path to the genomes directory based on user input.
SUBDIR_NAME=$1
GENOMES_DIR="${BASE_DIR}/${SUBDIR_NAME}"

# Check if the specified directory exists.
if [ ! -d "$GENOMES_DIR" ]; then
    echo "Error: Directory not found at '${GENOMES_DIR}'"
    exit 1
fi

echo "Checking directory: ${GENOMES_DIR}"
echo ""

# Create a sorted list of expected filenames from the CSV (column 2, skipping header).
# The `tr -d '\r'` handles potential Windows-style line endings in the CSV.
expected_files=$(tail -n +2 "$CSV_FILE" | cut -d, -f2 | tr -d '\r' | sort)

# Create a sorted list of actual filenames in the directory, with extensions removed.
actual_files=$(ls "$GENOMES_DIR" | sed 's/\.[^.]*$//' | sort)

# --- Comparison ---

echo "--- Missing Files (in CSV but not in directory) ---"
# comm -23 shows only lines unique to the first list (the expected files).
comm -23 <(echo "$expected_files") <(echo "$actual_files")

echo "" # Add a blank line for readability

echo "--- Files to Delete (in directory but not in CSV) ---"
# comm -13 shows only lines unique to the second list (the actual files).
comm -13 <(echo "$expected_files") <(echo "$actual_files") | while read -r basename; do
    # Find the original full filename in the directory to show the exact file to delete.
    find "$GENOMES_DIR" -maxdepth 1 -name "${basename}.*" -print
done