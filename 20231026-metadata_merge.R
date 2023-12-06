# Merge and unify strain metadata for the marine library
# 2023/10/26 - Konrad Herbst, herbstk@bu.edu

library(tidyverse)
library(readxl)

metadata_iamm <- read_csv("metafile.csv") %>%
  select(-`...10`) %>%
  mutate(strain_id = str_squish(strain_id)) %>%
  mutate(project = 'resequencing') %>%
  mutate(tmp_id = str_to_lower(strain_id))

forchielli22 <- read_xlsx("../Forchielli2022/marine_heterotrophs/data/strain_tax copy.xlsx") %>%
  select(name, phylum, class, order, family, genus, species, `strain designation` = strain_desig,
         Source = strain.Source, `catalog number` = strain.Cat_No, strain_nickname = strain) %>%
  filter(strain_nickname != 'negative') %>%
  mutate(project = 'forchielli22') %>%
  mutate(tmp_id = str_to_lower(strain_nickname))

# check consistency
# forchielli22a <- read_xlsx("../Forchielli2022/forchielli2022-metabolic_phenotyping_of_marine_heterotrophs_on_refactored_media_reveals_diverse_metabolic_adaptations_and_lifestyle_strategies-ST1.xlsx")
#   #filter(strain_nickname %in% c("Parctic", "PR1red", "PR1white", "plank"))
#forchielli22a %>% nrow()
#semi_join(forchielli22, forchielli22a, by = "strain_nickname") %>% nrow() # all strains in forchielli22a are in forchielli22

x <- metadata_iamm %>% mutate(tmp_id = str_to_lower(strain_id))
y <- forchielli22 %>% mutate(tmp_id = str_to_lower(strain_nickname))
semi_join(x, y, by = "tmp_id") # all rows in resequencing also present in forchielli22
anti_join(x, y, by = "tmp_id") # all rows in resequencing absent in forchielli22
anti_join(y, x, by = "tmp_id") # all rows in forchielli22 absent in resequencing

master_metadata <- full_join(metadata_iamm, forchielli22, by = 'tmp_id') %>%
  mutate(project.x = str_replace_na(project.x, ''), project.y = str_replace_na(project.y, ''),
    project = str_c(project.x, project.y, sep = '/')) %>%
  select(-project.x, -project.y) %>%
  select(tmp_id, starts_with("project"), everything()) %>%
  arrange(project) %>%
  write_tsv('master_metadata_file.tsv')