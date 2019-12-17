pkgs <- c("simplerspec", "here", "tidyverse", "data.table",
  "future", "doFuture", "remotes")

suppressPackageStartupMessages(
  purrr::walk(pkgs, library, character.only = TRUE, quietly = TRUE)
)

# multicore futures are not supported when using RStudio (stability reasons)
plan(multisession)
registerDoFuture()
# availableCores()

# files to read
files_spc <- list.files(
  here("data", "spectra", "example-yamsys"), full.names = TRUE)
# read the files
suppressMessages(
  spc_list <- read_opus_univ(fnames = files_spc, extract = c("spc"),
    parallel = TRUE)
)

spc_tbl <- gather_spc(data = spc_list)

spc_dt <- data.table::rbindlist(spc_tbl$spc)
dim(spc_dt); class(spc_dt)

# spectral processing pipeline
spc_proc <- 
  spc_tbl %>%
  resample_spc(wn_lower = 500, wn_upper = 3996, wn_interval = 2) %>%
  average_spc(by = "sample_id") %>%
  preprocess_spc(select = "sg_1_w21") %>%
  group_by(sample_id) %>%
  slice(1L) # remove replicate spectra (averaged)

# see data/reference-data/metadata_soilchem_yamsys.txt for further details
reference_data <- fread(
  file = here("data", "reference-data", "soilchem_yamsys.csv")) %>%
  as_tibble()
# number of rows and columns
dim(reference_data)

# fuse spectra and reference data by `sample_id`
spc_refdata <- 
  inner_join(
    x = spc_proc,
    y = reference_data %>% rename(sample_id = sample_ID),
    by = "sample_id"
  )

# explore final processed spectra
p_spc_refdata <- 
  spc_refdata %>%
  filter(site %in% c("lo", "mo")) %>% 
  plot_spc_ext(
    spc_tbl = .,
    lcols_spc = c("spc", "spc_pre"),
    lcol_measure = "C",
    group_id = "site")

ggsave(filename = "spc-refdata-plot.pdf", plot = p_spc_refdata,
  path = here("img"), width = 7, height = 4)
ggsave(filename = "spc-refdata-plot.png", plot = p_spc_refdata,
  path = here("img"), width = 7, height = 4)

# selecting reference analytical samples based on Kennard-Stone
spc_tbl_selection <- select_ref_spc(spc_tbl = spc_proc, ratio_ref = 0.5)
# PCA biplot
p_pca_selection <- spc_tbl_selection$p_pca

ggsave(filename = "pca-selection.pdf", plot = p_pca_selection, 
  path = here("img"), width = 5.5, height = 4)
ggsave(filename = "pca-selection.png", plot = p_pca_selection, 
  path = here("img"), width = 5.5, height = 4)

# develop a partial least squares (PLS) calibration model
pls_carbon <- fit_pls(spec_chem = spc_refdata, response = C,
  evaluation_method = "resampling", print = FALSE)

p_pls_carbon <- 
  pls_carbon$p_model +
  xlab(expression(paste("Measured C [g", ~kg^-1))) +
  ylab(expression(paste("Predicted C [g", ~kg^-1)))

ggsave(filename = "pls-C-eval.pdf", plot = p_pls_carbon,
  path = here("img"), width = 4, height = 4)
ggsave(filename = "pls-C-eval.png", plot = p_pls_carbon,
  path = here("img"), width = 4, height = 4)