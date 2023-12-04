# Consolidation of metadata into a master file encompassing all three involved
# projects. Euler diagram of curated strain metadata for the marine library
# 2023/11/30 - Konrad Herbst, herbstk@bu.edu

library(tidyverse)
library(readxl)
library(eulerr)

physical_marine_library <- read_tsv("20221101-strain_lib.tsv") %>%
  mutate(project = 'physical_library') %>%
  mutate(tmp_id = str_to_lower(Strain_nickname))

curated_metadata <- read_xlsx('20231026-master_metadata_file-curated.xlsx')

clean_project_column <- function(x){
  x <- str_split(x, '/')
  x <- map(x, ~.x[.x != ''])
  ret <- map_chr(x, ~str_c(.x, collapse = '&'))
  return(ret)
}

master_metadata <- curated_metadata %>%
  full_join(., physical_marine_library, by = c('ds_strain_id' = 'tmp_id')) %>%
  mutate(project.x = str_replace_na(project.x, ''), project.y = str_replace_na(project.y, ''),
         project = str_c(project.x, project.y, sep = '/')) %>%
  select(-project.x, -project.y) %>% mutate(project = clean_project_column(project))%>%
  select(ds_strain_id, starts_with("project"), everything()) %>%
  arrange(project) %>%
  mutate(Source.x = str_replace_na(Source.x, replacement = ''), Source.y = str_replace_na(Source.y, replacement = ''),
    Source = if_else(Source.x==Source.y,Source.x,str_c(Source.x, Source.y, sep = '&'))) %>%
  write_tsv('all_metadata_file.tsv')

project_sets <- master_metadata %>% count(project)
project_sets <- structure(project_sets$n, names = project_sets$project)
set.seed(42)
strain_euler <- euler(project_sets, input = 'disjoint', shape = 'ellipse')
png('20231027-all_sets-euler.png', width = 6, height = 5, res = 300, units = 'in')
plot(strain_euler, quantities = TRUE, legend = TRUE)
dev.off()

zoccarato22 <- read_xlsx('../Zoccarato2022/zoccarato2022-a_comparative_whole-genome_approach_identfies_bacterial_traits_for_marine_microbial_interactions.xlsx', sheet = 'Supp_Data_3', skip = 3)

left_join(curated_metadata, zoccarato22 %>% select(Species, `NCBI taxonID`, `Accession number`, Filename, Repository), by = c('species_name' = 'Species')) %>% View
