# Euler diagram of curated strain metadata for the marine library
# 2023/10/27 - Konrad Herbst, herbstk@bu.edu

library(tidyverse)
library(readxl)
library(eulerr)

physical_marine_library <- read_xlsx("20221024-strain_lib.xlsx") %>%
  mutate(project = 'physical_library') %>%
  mutate(tmp_id = str_to_lower(strain_nickname))

curated_metadata <- read_xlsx('20231026-master_metadata_file-curated.xlsx')

# modified version of eulerr:::parse_list() to return set item names and not just set sizes
parse_list <- function(combinations)
{
  if (is.null(attr(combinations, "names")))
    stop("when `combinations` is a list, all vectors in that list must be named")
  
  if (any(names(combinations) == ""))
    stop("all elements of `combinations` must be named")
  
  if (!all(sapply(combinations, anyDuplicated) == 0))
    stop("vectors in `combinations` cannot contain duplicates")
  
  if (any(duplicated(names(combinations))))
    stop("names of elements in `combinations` must be unique")
  
  sets <- names(combinations)
  n <- length(sets)
  
  id <- eulerr:::bit_indexr(n)
  
  out <- integer(nrow(id))
  rownames(id) <- apply(id, 1L, function(x) paste(sets[x], collapse = "&"))
  
  intersect_sets <- as.list(rep(-1, nrow(id)))
  names(intersect_sets) <- rownames(id)
  compute_intersect <- function(bool) {
    ind <- which(bool)
    nm <- paste(sets[ind], collapse = "&")
    if (identical(intersect_sets[[nm]], -1)) { # not computed yet
      if (length(ind) == 1) {
        intersect_sets[[nm]] <<- combinations[[ind]]
      } else {
        bool[] <- FALSE
        bool[ind[1]] <- TRUE
        part1 <- compute_intersect(bool)
        bool[ind] <- TRUE
        bool[ind[1]] <- FALSE
        part2 <- compute_intersect(bool)
        intersect_sets[[nm]] <<- intersect(part1, part2)
      }
    }
    intersect_sets[[nm]]
  }
  apply(id, 1, function(x) compute_intersect(x))
}

strain_sets <- list(
  'resequencing' = curated_metadata %>% filter(str_detect(project, 'resequencing')) %>% pull(ds_strain_id) %>% unique %>% na.omit(),
  'forchielli22' = curated_metadata %>% filter(str_detect(project, 'forchielli22')) %>% pull(ds_strain_id) %>% unique,
  'physical_library' = physical_marine_library %>% pull(tmp_id)
)
strain_sets_parsed <- parse_list(strain_sets)
strain_euler <- euler(map_int(strain_sets_parsed, length), input = 'union', shape = 'ellipse')
plot(strain_euler, quantities = TRUE, legend = TRUE)

setdiff(strain_sets$physical_library, union(strain_sets$resequencing, strain_sets$forchielli22)) # TODO what about 'sflavi (smr1)'???
setdiff(strain_sets$forchielli22, union(strain_sets$resequencing, strain_sets$physical_library))
setdiff(strain_sets$resequencing, union(strain_sets$forchielli22, strain_sets$physical_library))

zoccarato22 <- read_xlsx('../Zoccarato2022/zoccarato2022-a_comparative_whole-genome_approach_identfies_bacterial_traits_for_marine_microbial_interactions.xlsx', sheet = 'Supp_Data_3', skip = 3)

left_join(curated_metadata, zoccarato22 %>% select(Species, `NCBI taxonID`, `Accession number`, Filename, Repository), by = c('species_name' = 'Species')) %>% View
