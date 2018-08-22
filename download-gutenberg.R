library(gutenbergr)
library(dplyr)
library(tidyr)
library(stringr)
library(purrr)

FOLDER = "text"

dir.create(FOLDER)

works <- gutenberg_works()

works[1:5,] %>%
  select(id = gutenberg_id) %>%
  pwalk(function(id) {
  cat(sprintf("%d / %d\n", id, nrow(works)))
    
    path = file.path(FOLDER, sprintf("%d.txt", id))
    
    if (!file.exists(path)) {
      gutenberg_download(id) %>%
        pull(text) %>%
        writeLines(path)
    }
  })

# Generate list of the works that we collected.
#
collected_works <- list.files(FOLDER, full.names = TRUE) %>%
  file.info() %>%
  mutate(
    gutenberg_id = rownames(.) %>% str_replace_all("[^0-9]", "") %>% as.integer()
  ) %>%
  select(gutenberg_id, size) %>%
  # Exclude empty files (some downloads seem to fail systematically).
  filter(size != 0)

works <- works %>% inner_join(collected_works)

works %>%
  select(id = gutenberg_id, author, title, size) %>%
  write.csv2("gutenberg-catalog.csv", quote = FALSE, row.names = FALSE)
