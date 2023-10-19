# Merge and unify strain metadata for the marine library
# 2022/11/01 - Konrad Herbst, herbstk@bu.edu

library(tidyverse)
library(readxl)

old <- read_xlsx("20221024-strain_lib.xlsx")
forchielli22a <- read_xlsx("Forchielli2022/forchielli2022-metabolic_phenotyping_of_marine_heterotrophs_on_refactored_media_reveals_diverse_metabolic_adaptations_and_lifestyle_strategies-ST1.xlsx")
# some strains are for some reason missing from the above supplementary table
forchielli22 <- read_xlsx("Forchielli2022/marine_heterotrophs/data/strain_tax copy.xlsx") %>%
  select(name, phylum, class, order, family, genus, species, `strain designation` = strain_desig,
         Source = strain.Source, `catalog number` = strain.Cat_No, strain_nickname = strain) %>%
  filter(strain_nickname %in% c("Parctic", "PR1red", "PR1white", "plank"))

new <- bind_rows(forchielli22a, forchielli22) %>%
left_join(old, ., by = c("strain_nickname" = "strain_nickname")) %>%
  # unify sources
  mutate(Source = recode(Source.y,
                         "J Christie-Oleza" = "Joseph Christie-Oleza",
                         "MA Moran" = "Mary Ann Moran",
                         "D Sher" = "Daniel Sher",
                         "D. Sher" = "Daniel Sher",
                         "HP Grossart" = "Hans-Peter Grossart")) %>%
  # reorder columns removing redundant ones
  select(Location_Column, Location_Box, Location_BoxNo, BoxRow = Row, TubeLabel,
         Strain_nickname = strain_nickname, Name = name, Phylum = phylum,
         Class = class, Order = order, Family = family, Genus = genus,
         Species = species, Strain = `strain designation`, 
         Other_Names = `Other Names`, Source,
         Source_catalog_number = `catalog number`, Note = note) %>%
  # manual curations
  mutate(Note = if_else(Strain == "HP15", "DSM 23420 from DSMZ", Note)) %>%
  mutate(Note = if_else(Strain == "T2", "DSM 15272 from DSMZ", Note)) %>%
  mutate(Note = if_else(Strain == "BS11", "DSM 26494 from DSMZ", Note)) %>%
  mutate(Note = if_else(Species == "citrea", "DSM 8771 from DSMZ", Note)) %>%
  mutate(Note = if_else(Strain == "DSS-3", "DSM 15171 from DSMZ", Note)) %>%
  mutate(Note = if_else(Strain == "KT0803", "DSM 17595 from DSMZ", Note)) %>%
  mutate(Note = if_else(Strain == "PR1", "DSM 23439 from DSMZ", Note)) %>%
  mutate(Note = if_else(Strain == "CNB440", "DSM 44818 from DSMZ", Note)) %>%
  write_tsv("20221101-strain_lib.tsv")
