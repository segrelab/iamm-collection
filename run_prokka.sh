#!/bin/bash -l
#$ -l h_rt=75:00:00                 # Specify the hard time limit for the job
#$ -j y                             # Merge the error and output streams into a single file
#$ -o run_prokka.$JOB_ID.out        # Specify the output file
#$ -P hfsp                          # Specify the SCC project name you want to use
#$ -N prokka                        # Give your job a name
#$ -pe omp 8                        # Request multiple slots for the Shared Memory application (OpenMP)

# Load the required modules
module load prokka  # To use Prokka for genome annotation
module load parallel  # To use GNU parallel for running multiple jobs in parallel

# Create a temporary file to store commands for parallel execution
commands_file=$(mktemp)

# --- Configuration ---
# Full path to your CSV file
CSV_FILE="/projectnb/hfsp/iamm-collection/Strains for phylogenomics trees single sheet.csv"

# Directory where your input .fna genome files are located
GENOMES_DIR="/projectnb/hfsp/IAMM_reference_files/fasta"

# Parent directory where all Prokka output folders will be created
PROKKA_PARENT_DIR="/projectnb/hfsp/IAMM_reference_files/prokka_results"

# --- Script ---
# Create the main output directory if it doesn't exist
mkdir -p "$PROKKA_PARENT_DIR"

# Read the CSV, skip the header line with tail
tail -n +2 "$CSV_FILE" | while IFS=, read -r strain_id _ genome_filename _; do
    # Clean up whitespace from the filename
    genome_filename=$(echo "$genome_filename" | xargs)

    # Skip if the genome filename is empty
    if [ -z "$genome_filename" ]; then
        echo "Skipping row for strain $strain_id due to empty genome filename."
        continue
    fi

    # Define the full path to the input genome
    input_fna="$GENOMES_DIR/$genome_filename"

    # Check if the input file actually exists before running
    if [ ! -f "$input_fna" ]; then
        echo "Warning: Input file not found for strain $strain_id. Expected at: $input_fna"
        continue
    fi

    # Set the prefix (filename without .fna)
    prefix=$(basename "$genome_filename" .fna)

    # Set the specific output directory for this sample
    output_dir="$PROKKA_PARENT_DIR/$prefix"

    # Run the prokka command
    echo "prokka --outdir \"$output_dir\" --prefix \"$prefix\" \"$input_fna\"" >> "$commands_file"

done

# Run all commands in parallel using 8 cores
parallel -j 8 < "$commands_file"  # Match the number of cores requested at the top of the script

# Clean up
rm "$commands_file"
