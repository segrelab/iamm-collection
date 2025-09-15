# iamm-collection

This repository is used to consolidate various metadata related to a large portion of the Segrè lab's microbial strains. The majority of this work originated from the HFSP collaboration *Interactions Among Marine Microbes* (IAMM).

## Metadata Structure

Each metadata CSV file contains a `strain_id` column, which should be held consistent across files. Metadata files are compartmentalized for individual purposes, to enable easier, safer updating. New types of metadata should be added as new files in the same format, rather than modifying existing files. Additionally, filenames should not contain dates, as Git can be used to revisit or revert to previous versions if needed.

- [`iamm_references.csv`](iamm_references.csv) contains reference genome names, to easily access fasta files, GenBank annotations, etc.
- [`iamm_taxonomy.csv`](iamm_taxonomy.csv) contains taxonomic identity for each strain, broken down by level.

## Scripts

What to do with scripts like `shorten_serr_contig_names.sh`? Or my `taxonomy.ipynb` notebook?

## Working with metadata on the SCC

The SCC provides a [`csvtk`](https://github.com/shenwei356/csvtk) module with many convenience methods for working with CSV files, including translation to and from CSV format to other formats. The `join` command can be used to merge metadata files on the `strain_id` column, e.g. if both reference genome and taxonomic information is needed, with options for outer and inner joins to account for differences in metadata availability.

## Archive

This repository underwent a reorganization in Fall 2025. The former version of this repository can be viewed at https://github.com/segrelab/iamm-collection/tree/c4ff0893aea35950f1a9f35157504556d10b6a44.

