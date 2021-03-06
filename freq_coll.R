# This program reads in data generated by "keywd_extract.py".
# Mainly focus on finding the exact UNC collaborator from multiple abstracts
# Output top 10 UNC collaborator and their emphases field

# 0. Preparation for processing ----------------------------------------------


# 0.1 Read in required packages
library(readr)
library(tidyverse)
library(ggplot2)


# 0.2 Read in data files
data_list <- read_delim("fina_2.csv", delim = '\t', col_names = FALSE)
data_list <- data_list %>% select(-X1)
colnames(data_list) <- c("institution", "keyword", "id")

# 0.3. Get keywords
key_word <- data_list[[2]] %>% str_split("\\|", simplify = TRUE) %>% as.tibble()
key_word[key_word == ""] <- NA

# 0.4 Reorganize dataset for processing
origin <-  bind_cols(data_list[c(3, 1)], key_word) %>% mutate(institution = str_to_lower(institution))


# 1. Get hierarchy in author information ----------------------------------


# 1.1 Remove redundant information
institution_1 <-  origin['institution']
institution <-  institution_1[[1]] %>% str_replace("^\\d+\\s*", "") %>% str_replace("(^a)|(^the)\\s*", "")
institution <- institution %>% str_replace("electronic address.*$", "")
  
# 1.2 split each hierarchy
hierarchy = institution %>% str_split(., ",")

# 1.3 Match institution level

# 1.3.1 University

# Extract matches
match_ins <- hierarchy %>% 
  map(~str_subset(., "university")) %>%
  map(~.[length(.)])

# Find non-matches
index.1 <- match_ins %>% map(~ifelse(length(.) == 0, TRUE, FALSE)) %>% unlist()

# 1.3.2 Low rank institutions

# Extract matches
match_ins_1 <- hierarchy[index.1] %>% 
  map(~str_subset(., "administration|(key\\slab)|agency|system|organisation|clinic|program|hospital|institution|institute|centre|school|college|unc|network|ministry")) %>% 
  map(~.[length(.)])
match_ins[index.1] <- match_ins_1

# Find non-matches
index.1 <- match_ins %>% map(~ifelse(length(.) == 0, TRUE, FALSE)) %>% unlist()

# 1.3.3 Least low rank "center"

# Extract matches
match_ins_1 <- hierarchy[index.1] %>% 
  map(~str_subset(., "center")) %>% 
  map(~.[length(.)])

# Find non-matches
match_ins[index.1] <- match_ins_1

index.1 <- match_ins %>% map(~ifelse(length(.) == 0, TRUE, FALSE)) %>% unlist()

# 1.3.4 Set non-matches to original address strings
match_ins[index.1] <- institution[index.1]
collaborator = match_ins %>% unlist() 



# 2. Special case processing ----------------------------------------------

# 2. For those with school name going after University name. Extract university name only.
# Such as "duke university school of medicine"

# 2.1 Extract qualified observations
index.2 <- collaborator %>% str_detect("(?<=university).*(?=\\sschool)")
rm_school <- collaborator[index.2]

# 2.2 Locate correct university name
rm_school <- rm_school %>% 
  str_replace("(?<=university)\\s[^(of)(in)].*(\\sschool).*$", "") %>% 
  str_replace("(?<=university)\\s\\w+\\sschool.*$", "") %>% 
  str_replace("\\sschool\\sof\\s[(medicine)(nursing)(public)].*$", "") %>%
  str_replace("(?<=michigan|massachusetts|pittsburgh|miami|angeles|pennsylvania).*$", "")

# 2.3 Replace original list
collaborator[index.2] <- rm_school



# 3. Set standardized name for main institutions --------------------------

# 3.0 Remove tailing dot
collaborator <- collaborator %>% str_replace("\\.$", "")

# 3.1 Yale
collaborator <- collaborator %>% str_replace("^.*yale.*", "yale university")

# 3.2 U-Washington 
collaborator <- collaborator %>% str_trim() %>%
  str_replace("^washington university( medical center)?$", "university of washington") %>%
  str_replace("^.*university of washington.*", "university of washington")
  
# 3.3 U-Chicago
collaborator <- collaborator %>% str_trim() %>%
  str_replace("^.*university of chicago.*$", "university of chicago")

# 3.4 Cambridge
collaborator <- collaborator %>% str_trim() %>%
  str_replace("^.*cambridge university.*$", "university of cambridge")

# 3.5 Stanford
collaborator <- collaborator %>% str_trim() %>%
  str_replace("^.*stanford.*$", "stanford university")

# 3.6 Ohio state
collaborator <- collaborator %>% str_trim() %>%
  str_replace("^.*ohio state.*$", "ohio state university")

# 3.7 NYU
collaborator <- collaborator %>% str_trim() %>%
  str_replace("^.*new york university.*$", "new york university")

# 3.8 Memorial Sloan Kettering Cancer Center
collaborator <- collaborator %>% str_trim() %>%
  str_replace("ladanyim@mskcc.org.", "")

# 3.9 Mayo Clinic
collaborator <- collaborator %>% str_trim() %>%
  str_replace("^.*mayo clinic.*$", "mayo clinic")

# 3.10 UNC
collaborator <- collaborator %>% str_trim() %>%
  str_replace("^.*lineberger.*$", "unc") %>%
  str_replace("^.*gillings*$", "unc")

# 3.11 Johns Hopkins
collaborator <- collaborator %>% str_trim() %>%
  str_replace("^.*johns hopkins.*$", "johns hopkins university")

# 3.12 Imperial College
collaborator <- collaborator %>% str_trim() %>%
  str_replace("^.*imperial college.*$", "imperial college london")

# 3.13 Huntsman
collaborator <- collaborator %>% str_trim() %>%
  str_replace("^.*huntsman.*$", "huntsman cancer institute")

# 3.14 Harvard
collaborator <- collaborator %>% str_trim() %>%
  str_replace("^.*harvard.*$", "harvard university")

# 3.15 german cancer research center
collaborator <- collaborator %>% str_trim() %>%
  str_replace("^.*german cancer research center.*$", "german cancer research center")

# 3.16 Dartmouth
collaborator <- collaborator %>% str_trim() %>%
  str_replace("^.*geisel.*$", "dartmouth college")

# 3.17 Emory
collaborator <- collaborator %>% str_trim() %>%
  str_replace("^.*emory.*$", "emory university")

# 3.18 Duke
collaborator <- collaborator %>% str_trim() %>%
  str_replace("^.*duke.*$", "duke university")
  
# 3.19 Baylor college of medicine
collaborator <- collaborator %>% str_trim() %>%
  str_replace("^.*duncan.*$", "baylor college of medicine") %>%
  str_replace("^.*baylor college of medicine.*$", "baylor college of medicine")
  
# 3.20 Cornell
collaborator <- collaborator %>% str_trim() %>%
  str_replace("^.*weill cornell medicine.*$", "weill cornell medicine") %>%
  str_replace("^.*weill medical.*$", "weill cornell medical college") %>%
  str_replace("^.*weill cornell medical college.*$", "cornell university")
  
# 3.21 Cleveland Clinic
collaborator <- collaborator %>% str_trim() %>%
  str_replace("^.*cleveland clinic.*$", "cleveland clinic")

# 3.22 Brigham
collaborator <- collaborator %>% str_trim() %>%
  str_replace("^.*brigham.*$", "brigham and women's hospital")



# 4. add collaborator column to original dataset --------------------------

process_1 <- origin %>% add_column(collaborator = str_trim(collaborator))



# 5. Top 10 collaborators -------------------------------------------------

# 5.1 select unique collaborator in each thesis
process_2 <- process_1 %>% select(-institution) %>% unique()

# 5.2 exclude unc itself
process_3 <- process_2 %>% 
  mutate(unc = str_detect(collaborator, "unc|university of north carolina")) %>% 
  group_by(id) %>% 
  filter(sum(unc) > 0) %>% ungroup() %>%
  filter(!unc)

# 5.3 Get collaboration strength
clbrtn_strength <- process_3 %>% 
  select(id, collaborator) %>% 
  count(collaborator) %>% 
  arrange(desc(n))

# 5.4 Keep top 10 on list
top_10 <- clbrtn_strength %>% 
  filter(min_rank(desc(n))<=10) %>% 
  mutate(coll = str_c('#', min_rank(desc(n)), ' ', collaborator))


# 5.5 Keywords in top 10 collaborators
keyword_rank <- process_3 %>% gather(level, keyword, -id, -collaborator, -unc) %>% 
  filter(!is.na(keyword)) %>% 
  select(collaborator, keyword) %>% 
  count(collaborator, keyword) %>% arrange(desc(n)) %>% right_join(top_10, by = "collaborator") %>%
  rename(keyword_freq = n.x, coll_strenth = n.y) %>% mutate(collaborator = str_to_title(collaborator),
                                                            coll = str_to_title(coll)) 



# 6. Output ---------------------------------------------------------------

write_csv(keyword_rank, "keyword_rank.csv")





