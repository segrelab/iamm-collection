# iamm-collection
This repo is used to consolidate various metadata related to a large portion of the Segrè lab's microbial strains. The majority of this work originated from the HFSP collaboration *Interactions Among Marine Microbes* (IAMM).

The result is a [master metadata file](all_metadata_file.tsv) which should be used as primary point of information on any of the strains covered.

## Involved projects
The following projects have in some way dealt with (some) of the strains:
 - `re-sequencing`/`RES`: Re-sequencing of bacteria retrieved from various sources to investigate genome variation.
 - `marine_library`/`LIB`: The Segrè lab library of marine microbial strains covering a wide range of (potential interaction) traits based on /in silico/ analysis by Zoccerato /et al./ (`ZOC`). This is a physical strain library which is in our -80 °C.
 - `forchielli22`/`FOR`: Phenotyping of marine bacteria on single carbon sources. DOI: <https://doi.org/10.1128/msystems.00070-22>
 - `zoccarato22`/`ZOC`: An /in silicon/ study across 473 to identify genome functional clusters (GFCs) grouping strains with similar traits (potentially involved in microbial interactions). DOI: <https://doi.org/10.1038/s42003-022-03184-4>

## Consolidation process
 - Used [20231026-metadata_merge.R](./20231026-metadata_merge.R) <./20231026-metadata_merge.R> to merge and unify strain metadata of `RES` and `FOR` projects.
   - This used the following metadata files as input:
     - [metafile.csv](./metafile.csv): initial metafile of the `RES` project
     - [strain_tax copy.xlsx](./strain_tax copy.xlsx): `FOR` metadata
   - This created `master_metadata_file.tsv`
 - The metadata from projects `FOR` and `RES` in file `master_metadata_file.tsv` where manually combined, curated and integrated resulting in [20231026-master_metadata_file-curated.xlsx](./20231026-master_metadata_file-curated.xlsx).
 - Used [20231130-consolidation_euler.R](./20231130-consolidation_euler.R) to integrate the curated metadata with `LIB` and `ZOC` project's:
   - This used the following metadata files as input:
     - [20231026-master_metadata_file-curated.xlsx](./20231026-master_metadata_file-curated.xlsx)
     - [20221101-strain_lib.tsv](./20221101-strain_lib.tsv): `LIB` metafile of the marine strain library
       - created by Konrad, 2022-11-01 using [20221101-metadata_merge.R](./20221101-metadata_merge.R)
     - [zoccarato2022-....xlsx](./zoccarato2022-a_comparative_whole-genome_approach_identfies_bacterial_traits_for_marine_microbial_interactions.xlsx): `ZOC` metadata
     - <20231205-map-metadata_zoccarrato22.tsv>: file used for manual mapping to `ZOC` metadata after using heuristics (mapping by Species, Reference-file, Source ID)
   - This creates [all_metadata_file.tsv](./all_metadata_file.tsv) and the Euler diagram below

![Euler diagram of strain overlap across projects](./20231206-all_sets-euler.png)

