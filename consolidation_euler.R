# Consolidation of metadata into a master file encompassing all three involved
# projects. Euler diagram of curated strain metadata for the marine library
# 2023/11/30 - Konrad Herbst, herbstk@bu.edu

library(tidyverse)
library(readxl)
library(eulerr)

# Loading different metadata tables.
curated_metadata <- read_xlsx('./20240123-master_metadata_file-curated.xlsx', na = 'NA') %>%
  rename(strain_designation = `strain designation`) %>%
  mutate(genus = if_else(is.na(genus), str_split_i(species_name, ' ', 1), genus),
         species = if_else(is.na(species), str_split_i(species_name, ' ', 2), species),
         strain_designation = if_else(is.na(strain_designation), strain_id, strain_designation)) %>%
  select(ds_strain_id,
         phylum, class, order, family, genus, species, strain_designation,
         source = Source, source_catalog_number = `catalog number`,
         id_RES = sample_name, id_FOR = strain_nickname,
         RES_sample_number = sample_number,
         RES_sample_name = sample_name, RES_in_IAMM = in_IAMM,
         RES_dna_prep = dna_prep, RES_ref_genome = ref_genome)

marine_library <- read_tsv("./20240122-strain_lib.tsv") %>%
  select(Location_Column, Location_Box, Location_BoxNo, BoxRow, TubeLabel, Other_Names,
         Source, Source_catalog_number, Note, Strain_nickname) %>%
  rename_with(~str_c('LIB_', .x)) %>%
  mutate(tmp_id = str_to_lower(LIB_Strain_nickname)) %>%
  rename(id_LIB = LIB_TubeLabel)

zoccarato22 <- read_xlsx('./zoccarato2022-a_comparative_whole-genome_approach_identfies_bacterial_traits_for_marine_microbial_interactions.xlsx',
                         sheet = 'Supp_Data_3', skip = 3) %>%
  fill(GFC) %>%
  select(ZOC_species = Species, ZOC_filename = Filename, ZOC_GFC = GFC,
         ZOC_repository = Repository, ZOC_isolation_source = `Isolation source`,
         ZOC_isolation_notes = `Isolation notes`) %>%
  mutate(id_ZOC = ZOC_species)
zoccarato22_map <- zoccarato22 %>% select(ZOC_filename, id_ZOC)

# Merging metadata.
master_metadata <- curated_metadata %>%
  full_join(., marine_library,
            by = c('ds_strain_id' = 'tmp_id')) %>%
  select(ds_strain_id, starts_with("project"), everything())

master_metadata_zoccarato22 <- zoccarato22_map %>%
  mutate(genus = str_split_i(id_ZOC, ' ', 1),
         species = str_split_i(id_ZOC, ' ', 2),
         strain_designation = str_split_i(id_ZOC, ' ', -1)) %>%
  left_join(master_metadata, ., by = c('genus', 'species', 'strain_designation')) %>% # map Zoccarato22 by Species
  mutate(genome_file = str_split_i(RES_ref_genome, '\\.', 1)) %>%
  left_join(., zoccarato22_map, by = c('genome_file' = 'ZOC_filename')) %>%  # map Zoccarato22 by Reference-file
  mutate(id_ZOC = if_else(is.na(id_ZOC.x), id_ZOC.y, id_ZOC.x), .keep = 'unused') %>%
  select(-ZOC_filename, -genome_file)

zoccarato22_manual_map <- read_tsv('20231205-map-metadata_zoccarrato22.tsv')
all_master_metadata <- zoccarato22_map %>%
  mutate(id = str_split_i(id_ZOC, ' ', -1)) %>% # map Zoccarato22 by Source ID
  left_join(master_metadata_zoccarato22, ., by = c('source_catalog_number' = 'id')) %>%
  mutate(id_ZOC = if_else(is.na(id_ZOC.x), id_ZOC.y, id_ZOC.x), .keep = 'unused') %>%
  select(-ZOC_filename) %>%
  left_join(., zoccarato22_manual_map, by = 'ds_strain_id') %>% # map Zoccarato22 by manual curation
  mutate(id_ZOC = if_else(is.na(id_ZOC.y), id_ZOC.x, id_ZOC.y), .keep = 'unused') %>%
  left_join(., zoccarato22, by = c('id_ZOC')) %>%
  select(ds_strain_id, phylum, class, order, family, genus, species,
         strain_designation, source, source_catalog_number, starts_with('id_'),
         starts_with('RES_'), starts_with('LIB_'), starts_with('FOR_'), starts_with('ZOC_'),
         everything() # there shouldn't be any more columns but just to include them.
         ) %>%
  write_tsv(str_c(format(Sys.Date(), "%Y%m%d"), '-IAMM_metadata_file.tsv'), na = '')

# Helper function.
clean_project_column <- function(x){
  x <- str_split(x, '/')
  x <- map(x, ~.x[.x != ''])
  ret <- map_chr(x, ~str_c(.x, collapse = '&'))
  return(ret)
}

# Euler diagram of Project overlaps.
project_sets <- 
  all_master_metadata %>%
  select(starts_with('id_')) %>%
  mutate(across(everything(), ~if_else(is.na(.x), '', cur_column()))) %>%
  rowwise() %>%
  mutate(x = str_c(c(id_RES, id_FOR, id_LIB, id_ZOC), collapse = '/')) %>%
  mutate(y = clean_project_column(x)) %>%
  mutate(project = str_replace_all(y, c('id_RES' = 're-sequencing',
                               'id_LIB' = 'marine_library',
                               'id_FOR' = 'forchielli2022',
                               'id_ZOC' = 'zoccarato2022'))) %>%
  count(project)
project_sets <- structure(project_sets$n, names = project_sets$project)
set.seed(42)
strain_euler <- euler(project_sets, input = 'disjoint', shape = 'ellipse')
png('20231213-all_sets-euler.png', width = 6, height = 5, res = 300, units = 'in')
plot(strain_euler, quantities = TRUE, legend = TRUE)
dev.off()
