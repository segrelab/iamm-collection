#!/bin/bash -l
#$ -l h_rt=0:60:00                 # Specify the hard time limit for the job
#$ -j y                             # Merge the error and output streams into a single file
#$ -o run_prokka.$JOB_ID.out        # Specify the output file
#$ -P hfsp                          # Specify the SCC project name you want to use
#$ -N prokka                        # Give your job a name
#$ -pe omp 32                       # Request multiple slots for the Shared Memory application (OpenMP)

# Load the required modules
module load perl/5.28.1  # Dependency for Prokka
module load prokka/1.14.5  # To use Prokka for genome annotation
module load parallel  # To use GNU parallel for running multiple jobs in parallel

# Set a force rerun option, to regenerate a file if it already exists
force_rerun=false

# Create a temporary file to store commands for parallel execution
commands_file=$(mktemp)

# --- Configuration ---
# Full path to your CSV file
CSV_FILE="/projectnb/hfsp/iamm-collection/iamm_references.csv"

# Directory where your input .fna genome files are located
GENOMES_DIR="/projectnb/hfsp/IAMM_reference_files/fasta"

# Parent directory where all Prokka output folders will be created
PROKKA_PARENT_DIR="/projectnb/hfsp/IAMM_reference_files/prokka_results"

# --- Script ---
# Create the main output directory if it doesn't exist
mkdir -p "$PROKKA_PARENT_DIR"

# Read the CSV, skip the header line with tail
tail -n +2 "$CSV_FILE" | while IFS=, read -r strain_id genome_filename; do
    # Clean up whitespace from the filename
    prefix=$(echo "$genome_filename" | xargs)

    # Skip if the genome filename is empty
    if [ -z "$genome_filename" ]; then
        echo "Skipping row for strain $strain_id due to empty genome filename."
        continue
    fi

    # Define the full path to the input genome
    input_fna="$GENOMES_DIR/$genome_filename.fna"

    # Check if the input file actually exists before running
    if [ ! -f "$input_fna" ]; then
        echo "Warning: Input file not found for strain $strain_id. Expected at: $input_fna"
        continue
    fi

    # Set the specific output directory for this sample
    output_dir="$PROKKA_PARENT_DIR/$prefix"

    # Check if the genbank output file already exists
    genbank_output="$output_dir/$prefix.gbk"
    if [ -f "$genbank_output" ] && [ "$force_rerun" = false ]; then
        echo "Skipping $prefix becuause $genbank_output as already exists."
        continue
    fi

    # Run the prokka command
    echo "prokka --outdir \"$output_dir\" --prefix \"$prefix\" --compliant \"$input_fna\"" >> "$commands_file"

done

# Run all commands in parallel using 32 cores
parallel -j 32 < "$commands_file"  # Match the number of cores requested at the top of the script

# Clean up
rm "$commands_file"
