Article
================
Philipp Baumann
2019-12-01

# Intro

Albert Einstein would probably not have felt the necessity for
simplerspec, as he would have followed his quote *“Everything should be
made as simple as possible, but not simpler”*. In line with this
recommendation, I was told that spectral analysis in R is standard
practice and straight forward using the famous partial least squares
(PLS) regression when I started my MSc back in July 2015. I was given
the honour of the exiting task to sample and model both soils and yam
plants from 20 fields at 4 landscapes across the West African yam belt
(see [here](www.yamsys.org) for details). Since I was both fascinated by
R, statistics, soils, and their interplay with plants, I started my
first scientific journey with the premise that I just had to deepen a
bit my R knowledge. I thought that the tools out there are simple enough
for achieving my neat MSc task.

Being a big fan of R and other open source tools, I was happy to find
quite a bit of chemometrics and other modeling toolsets, many of them
for example available via [CRAN](https://cran.r-project.org/) and listed
in the CRAN Task View [Chemometrics and Computational
Physics](https://cran.r-project.org/web/views/ChemPhys.html) or [Machine
Learning & Statistical
Learning](https://cran.r-project.org/web/views/MachineLearning.html). I
would opinionately consider most of them good at solving single tasks,
but I somehow missed a clean common interface that interlinked the key
steps required for spectral processing and modeling. While doing first
analysis steps, my intuition told me that streamlining all analysis
steps would be aiding in more efficiently estimating the composition and
properties of natural materials. And more importantly, I would allow a
sustainable basis for model development and sharing with collaborators.

However, I was far from being there (now still). Soon I realized that
while extending explorations of various options along modeling steps,
such as pre-processing to achieve robust and accurate models, I ended up
writing more and more verbose code for repetitive or only slighly
different tasks. I felt I could do better at some point and get rid of
the verbose boilerplate coding I was doing. To solve this more
elegantly, I started continously building the simplerspec package with
the goal of delivering beginner-friendly and standardized functions. In
short, to provide a rapid prototyping pipeline for various spectroscopy
applications that share common tasks.

# Prepare the R environment for spectral analysis

Enough of the personal talking. To reproduce the entire analysis in this
hands-on, I would advise two main procedures:

1.  Installing exact package versions and sources using the renv package
    and the snapshot file `renv.lock`
2.  Manual installation of R packages with specific version tags

To restore and reproduce this entire analysis and document, first clone
this repository to your local computer. Then install renv and restore R
packages based on the `renv.lock` file in an isolated project library in
two lines of code.

``` r
## Option 1 for installation
install.packages("renv")
renv::restore("renv.lock")
```

Option 1 is probably the easiest as it makes automatically sure that all
dependencies are met and the computational environment is the same.

To install and attach all required R packages used in this article with
more manual care and less guarantees, you can run the following lines:

``` r
## Option 2 for installation
pkgs <- c("here", "simplerspec", "tidyverse", "data.table")
new_pkgs <- pkgs[!(pkgs %in% installed.packages()[, "Package"])]
# Install only new packages
if (length(new_pkgs)) {
  if ("remotes" %in% new_pkgs) install.packages("remotes")
  if ("simplerspec" %in% new_pkgs) {
    remotes::install_github("philipp-baumann/simplerspec")}
  install.packages(new_pkgs)
}
```

# Hands-on

Now we are ready to proceed to the fundamentals of the package. First,
let’s load required packages. The tidyverse is optional, so if you feel
it is not required you won’t need to load it.

``` r
# Load required packages
# `walk()` is like `lapply()`, but returns invisibly
suppressPackageStartupMessages(
  purrr::walk(pkgs, library, character.only = TRUE, quietly = TRUE)
)
```

A typical simple spectroscopy modeling project has the following
components:

1.  Soil sampling

2.  Sample preparation

3.  Spectral measurements

4.  Selection of calibration samples

5.  Soil analytical reference analyses

6.  1.  Calibration or Recalibration
    2.  Estimation of properties of new soils based on new spectra and
        established models.

Simplerspec focuses on the key tasks and provides user-friendly modules
in the form of a standardized function pipeline. This pipeline builds
upon common design principles of spectral R objects which are shared
between function inputs and outputs.

First, you may want to read files from spectra that you measured on your
spectrometer. Spectral inputting is the first step done when doing
spectral analysis prior the standard chemical analysis. This is useful
when you have a lot of samples and you want to save some time and money
to to do reference analysis, and then predict the remaining samples only
with infrared spectroscopy.

Here we read from a Bruker Alpha mid-Infrared spectrometer:

``` r
# Files to read
files_spc <- list.files("data/spectra/example-yamsys", full.names = TRUE)
files_spc[[1]]
```

    ## [1] "data/spectra/example-yamsys/BF_lo_01_soil_cal.0"

``` r
# Read the files
spc_list <- read_opus_univ(fnames = files_spc, extract = c("spc"))
```

    ## Extracted spectra data from file: <BF_lo_01_soil_cal.0>

    ## Extracted spectra data from file: <BF_lo_01_soil_cal.1>

    ## Extracted spectra data from file: <BF_lo_01_soil_cal.2>

    ## Extracted spectra data from file: <BF_lo_02_soil_cal.0>

    ## Extracted spectra data from file: <BF_lo_02_soil_cal.1>

    ## Extracted spectra data from file: <BF_lo_02_soil_cal.2>

    ## Extracted spectra data from file: <BF_lo_03_soil_cal.0>

    ## Extracted spectra data from file: <BF_lo_03_soil_cal.1>

    ## Extracted spectra data from file: <BF_lo_03_soil_cal.2>

    ## Extracted spectra data from file: <BF_lo_04_soil_cal.0>

    ## Extracted spectra data from file: <BF_lo_04_soil_cal.1>

    ## Extracted spectra data from file: <BF_lo_04_soil_cal.2>

    ## Extracted spectra data from file: <BF_lo_05_soil_cal.0>

    ## Extracted spectra data from file: <BF_lo_05_soil_cal.1>

    ## Extracted spectra data from file: <BF_lo_05_soil_cal.2>

    ## Extracted spectra data from file: <BF_lo_06_soil_cal.0>

    ## Extracted spectra data from file: <BF_lo_06_soil_cal.1>

    ## Extracted spectra data from file: <BF_lo_06_soil_cal.2>

    ## Extracted spectra data from file: <BF_lo_07_soil_cal.0>

    ## Extracted spectra data from file: <BF_lo_07_soil_cal.1>

    ## Extracted spectra data from file: <BF_lo_07_soil_cal.2>

    ## Extracted spectra data from file: <BF_lo_08_soil_cal.0>

    ## Extracted spectra data from file: <BF_lo_08_soil_cal.1>

    ## Extracted spectra data from file: <BF_lo_08_soil_cal.2>

    ## Extracted spectra data from file: <BF_lo_09_soil_cal.0>

    ## Extracted spectra data from file: <BF_lo_09_soil_cal.1>

    ## Extracted spectra data from file: <BF_lo_09_soil_cal.2>

    ## Extracted spectra data from file: <BF_lo_10_soil_cal.0>

    ## Extracted spectra data from file: <BF_lo_10_soil_cal.1>

    ## Extracted spectra data from file: <BF_lo_10_soil_cal.2>

    ## Extracted spectra data from file: <BF_lo_11_soil_cal.0>

    ## Extracted spectra data from file: <BF_lo_11_soil_cal.1>

    ## Extracted spectra data from file: <BF_lo_11_soil_cal.2>

    ## Extracted spectra data from file: <BF_lo_12_soil_cal.0>

    ## Extracted spectra data from file: <BF_lo_12_soil_cal.1>

    ## Extracted spectra data from file: <BF_lo_12_soil_cal.2>

    ## Extracted spectra data from file: <BF_lo_13_soil_cal.3>

    ## Extracted spectra data from file: <BF_lo_13_soil_cal.4>

    ## Extracted spectra data from file: <BF_lo_13_soil_cal.5>

    ## Extracted spectra data from file: <BF_lo_14_soil_cal.0>

    ## Extracted spectra data from file: <BF_lo_14_soil_cal.1>

    ## Extracted spectra data from file: <BF_lo_14_soil_cal.2>

    ## Extracted spectra data from file: <BF_lo_15_soil_cal.0>

    ## Extracted spectra data from file: <BF_lo_15_soil_cal.1>

    ## Extracted spectra data from file: <BF_lo_15_soil_cal.2>

    ## Extracted spectra data from file: <BF_lo_16_soil_cal.0>

    ## Extracted spectra data from file: <BF_lo_16_soil_cal.1>

    ## Extracted spectra data from file: <BF_lo_16_soil_cal.2>

    ## Extracted spectra data from file: <BF_lo_17_soil_cal.0>

    ## Extracted spectra data from file: <BF_lo_17_soil_cal.1>

    ## Extracted spectra data from file: <BF_lo_17_soil_cal.2>

    ## Extracted spectra data from file: <BF_lo_18_soil_cal.0>

    ## Extracted spectra data from file: <BF_lo_18_soil_cal.1>

    ## Extracted spectra data from file: <BF_lo_18_soil_cal.2>

    ## Extracted spectra data from file: <BF_lo_19_soil_cal.0>

    ## Extracted spectra data from file: <BF_lo_19_soil_cal.1>

    ## Extracted spectra data from file: <BF_lo_19_soil_cal.2>

    ## Extracted spectra data from file: <BF_lo_20_soil_cal.0>

    ## Extracted spectra data from file: <BF_lo_20_soil_cal.1>

    ## Extracted spectra data from file: <BF_lo_20_soil_cal.2>

    ## Extracted spectra data from file: <BF_mo_01_soil_cal.0>

    ## Extracted spectra data from file: <BF_mo_01_soil_cal.1>

    ## Extracted spectra data from file: <BF_mo_01_soil_cal.2>

    ## Extracted spectra data from file: <BF_mo_02_soil_cal.0>

    ## Extracted spectra data from file: <BF_mo_02_soil_cal.1>

    ## Extracted spectra data from file: <BF_mo_02_soil_cal.2>

    ## Extracted spectra data from file: <BF_mo_03_soil_cal.0>

    ## Extracted spectra data from file: <BF_mo_03_soil_cal.1>

    ## Extracted spectra data from file: <BF_mo_03_soil_cal.2>

    ## Extracted spectra data from file: <BF_mo_04_soil_cal.0>

    ## Extracted spectra data from file: <BF_mo_04_soil_cal.1>

    ## Extracted spectra data from file: <BF_mo_04_soil_cal.2>

    ## Extracted spectra data from file: <BF_mo_05_soil_cal.0>

    ## Extracted spectra data from file: <BF_mo_05_soil_cal.1>

    ## Extracted spectra data from file: <BF_mo_05_soil_cal.2>

    ## Extracted spectra data from file: <BF_mo_06_soil_cal.0>

    ## Extracted spectra data from file: <BF_mo_06_soil_cal.1>

    ## Extracted spectra data from file: <BF_mo_06_soil_cal.2>

    ## Extracted spectra data from file: <BF_mo_07_soil_cal.0>

    ## Extracted spectra data from file: <BF_mo_07_soil_cal.1>

    ## Extracted spectra data from file: <BF_mo_07_soil_cal.2>

    ## Extracted spectra data from file: <BF_mo_08_soil_cal.0>

    ## Extracted spectra data from file: <BF_mo_08_soil_cal.1>

    ## Extracted spectra data from file: <BF_mo_09_soil_cal.0>

    ## Extracted spectra data from file: <BF_mo_09_soil_cal.1>

    ## Extracted spectra data from file: <BF_mo_09_soil_cal.2>

    ## Extracted spectra data from file: <BF_mo_10_soil_cal.0>

    ## Extracted spectra data from file: <BF_mo_10_soil_cal.1>

    ## Extracted spectra data from file: <BF_mo_10_soil_cal.2>

    ## Extracted spectra data from file: <BF_mo_11_soil_cal.0>

    ## Extracted spectra data from file: <BF_mo_11_soil_cal.1>

    ## Extracted spectra data from file: <BF_mo_11_soil_cal.2>

    ## Extracted spectra data from file: <BF_mo_12_soil_cal.0>

    ## Extracted spectra data from file: <BF_mo_12_soil_cal.1>

    ## Extracted spectra data from file: <BF_mo_12_soil_cal.2>

    ## Extracted spectra data from file: <BF_mo_13_soil_cal.0>

    ## Extracted spectra data from file: <BF_mo_13_soil_cal.1>

    ## Extracted spectra data from file: <BF_mo_13_soil_cal.2>

    ## Extracted spectra data from file: <BF_mo_14_soil_cal.0>

    ## Extracted spectra data from file: <BF_mo_14_soil_cal.1>

    ## Extracted spectra data from file: <BF_mo_14_soil_cal.2>

    ## Extracted spectra data from file: <BF_mo_15_soil_cal.0>

    ## Extracted spectra data from file: <BF_mo_15_soil_cal.1>

    ## Extracted spectra data from file: <BF_mo_15_soil_cal.2>

    ## Extracted spectra data from file: <BF_mo_16_soil_cal.0>

    ## Extracted spectra data from file: <BF_mo_16_soil_cal.1>

    ## Extracted spectra data from file: <BF_mo_16_soil_cal.2>

    ## Extracted spectra data from file: <BF_mo_17_soil_cal.0>

    ## Extracted spectra data from file: <BF_mo_17_soil_cal.1>

    ## Extracted spectra data from file: <BF_mo_17_soil_cal.2>

    ## Extracted spectra data from file: <BF_mo_18_soil_cal.0>

    ## Extracted spectra data from file: <BF_mo_18_soil_cal.1>

    ## Extracted spectra data from file: <BF_mo_18_soil_cal.2>

    ## Extracted spectra data from file: <BF_mo_19_soil_cal.0>

    ## Extracted spectra data from file: <BF_mo_19_soil_cal.1>

    ## Extracted spectra data from file: <BF_mo_19_soil_cal.2>

    ## Extracted spectra data from file: <BF_mo_20_soil_cal.0>

    ## Extracted spectra data from file: <BF_mo_20_soil_cal.1>

    ## Extracted spectra data from file: <BF_mo_20_soil_cal.2>

    ## Extracted spectra data from file: <CI_sb_01_soil_cal.0>

    ## Extracted spectra data from file: <CI_sb_01_soil_cal.1>

    ## Extracted spectra data from file: <CI_sb_01_soil_cal.2>

    ## Extracted spectra data from file: <CI_sb_02_soil_cal.0>

    ## Extracted spectra data from file: <CI_sb_02_soil_cal.1>

    ## Extracted spectra data from file: <CI_sb_02_soil_cal.2>

    ## Extracted spectra data from file: <CI_sb_03_soil_cal.0>

    ## Extracted spectra data from file: <CI_sb_03_soil_cal.1>

    ## Extracted spectra data from file: <CI_sb_03_soil_cal.2>

    ## Extracted spectra data from file: <CI_sb_04_soil_cal.0>

    ## Extracted spectra data from file: <CI_sb_04_soil_cal.1>

    ## Extracted spectra data from file: <CI_sb_04_soil_cal.2>

    ## Extracted spectra data from file: <CI_sb_05_soil_cal.0>

    ## Extracted spectra data from file: <CI_sb_05_soil_cal.1>

    ## Extracted spectra data from file: <CI_sb_05_soil_cal.2>

    ## Extracted spectra data from file: <CI_sb_06_soil_cal.0>

    ## Extracted spectra data from file: <CI_sb_06_soil_cal.1>

    ## Extracted spectra data from file: <CI_sb_06_soil_cal.2>

    ## Extracted spectra data from file: <CI_sb_07_soil_cal.0>

    ## Extracted spectra data from file: <CI_sb_07_soil_cal.1>

    ## Extracted spectra data from file: <CI_sb_07_soil_cal.2>

    ## Extracted spectra data from file: <CI_sb_08_soil_cal.0>

    ## Extracted spectra data from file: <CI_sb_08_soil_cal.1>

    ## Extracted spectra data from file: <CI_sb_08_soil_cal.2>

    ## Extracted spectra data from file: <CI_sb_09_soil_cal.0>

    ## Extracted spectra data from file: <CI_sb_09_soil_cal.1>

    ## Extracted spectra data from file: <CI_sb_09_soil_cal.2>

    ## Extracted spectra data from file: <CI_sb_10_soil_cal.0>

    ## Extracted spectra data from file: <CI_sb_10_soil_cal.1>

    ## Extracted spectra data from file: <CI_sb_10_soil_cal.2>

    ## Extracted spectra data from file: <CI_sb_11_soil_cal.0>

    ## Extracted spectra data from file: <CI_sb_11_soil_cal.1>

    ## Extracted spectra data from file: <CI_sb_11_soil_cal.2>

    ## Extracted spectra data from file: <CI_sb_12_soil_cal.0>

    ## Extracted spectra data from file: <CI_sb_12_soil_cal.1>

    ## Extracted spectra data from file: <CI_sb_12_soil_cal.2>

    ## Extracted spectra data from file: <CI_sb_13_soil_cal.0>

    ## Extracted spectra data from file: <CI_sb_13_soil_cal.1>

    ## Extracted spectra data from file: <CI_sb_13_soil_cal.2>

    ## Extracted spectra data from file: <CI_sb_14_soil_cal.0>

    ## Extracted spectra data from file: <CI_sb_14_soil_cal.1>

    ## Extracted spectra data from file: <CI_sb_14_soil_cal.2>

    ## Extracted spectra data from file: <CI_sb_15_soil_cal.0>

    ## Extracted spectra data from file: <CI_sb_15_soil_cal.1>

    ## Extracted spectra data from file: <CI_sb_15_soil_cal.2>

    ## Extracted spectra data from file: <CI_sb_16_soil_cal.1>

    ## Extracted spectra data from file: <CI_sb_16_soil_cal.2>

    ## Extracted spectra data from file: <CI_sb_16_soil_cal.3>

    ## Extracted spectra data from file: <CI_sb_17_soil_cal.0>

    ## Extracted spectra data from file: <CI_sb_17_soil_cal.1>

    ## Extracted spectra data from file: <CI_sb_17_soil_cal.2>

    ## Extracted spectra data from file: <CI_sb_18_soil_cal.0>

    ## Extracted spectra data from file: <CI_sb_18_soil_cal.1>

    ## Extracted spectra data from file: <CI_sb_18_soil_cal.2>

    ## Extracted spectra data from file: <CI_sb_19_soil_cal.0>

    ## Extracted spectra data from file: <CI_sb_19_soil_cal.1>

    ## Extracted spectra data from file: <CI_sb_19_soil_cal.2>

    ## Extracted spectra data from file: <CI_sb_20_soil_cal.0>

    ## Extracted spectra data from file: <CI_sb_20_soil_cal.1>

    ## Extracted spectra data from file: <CI_sb_20_soil_cal.2>

    ## Extracted spectra data from file: <CI_sb_YAMS_0001.0>

    ## Extracted spectra data from file: <CI_sb_YAMS_0001.1>

    ## Extracted spectra data from file: <CI_sb_YAMS_0001.2>

    ## Extracted spectra data from file: <CI_sb_YAMS_0002.0>

    ## Extracted spectra data from file: <CI_sb_YAMS_0002.1>

    ## Extracted spectra data from file: <CI_sb_YAMS_0002.2>

    ## Extracted spectra data from file: <CI_sb_YAMS_0003.0>

    ## Extracted spectra data from file: <CI_sb_YAMS_0003.1>

    ## Extracted spectra data from file: <CI_sb_YAMS_0003.2>

    ## Extracted spectra data from file: <CI_sb_YAMS_0004.0>

    ## Extracted spectra data from file: <CI_sb_YAMS_0004.1>

    ## Extracted spectra data from file: <CI_sb_YAMS_0004.2>

    ## Extracted spectra data from file: <CI_sb_YAMS_0005.0>

    ## Extracted spectra data from file: <CI_sb_YAMS_0005.1>

    ## Extracted spectra data from file: <CI_sb_YAMS_0005.2>

    ## Extracted spectra data from file: <CI_sb_YAMS_0006.0>

    ## Extracted spectra data from file: <CI_sb_YAMS_0006.1>

    ## Extracted spectra data from file: <CI_sb_YAMS_0006.2>

    ## Extracted spectra data from file: <CI_sb_YAMS_0007.0>

    ## Extracted spectra data from file: <CI_sb_YAMS_0007.1>

    ## Extracted spectra data from file: <CI_sb_YAMS_0007.2>

    ## Extracted spectra data from file: <CI_sb_YAMS_0008.0>

    ## Extracted spectra data from file: <CI_sb_YAMS_0008.1>

    ## Extracted spectra data from file: <CI_sb_YAMS_0008.2>

    ## Extracted spectra data from file: <CI_sb_YAMS_0009.0>

    ## Extracted spectra data from file: <CI_sb_YAMS_0009.1>

    ## Extracted spectra data from file: <CI_sb_YAMS_0009.2>

    ## Extracted spectra data from file: <CI_sb_YAMS_0010.0>

    ## Extracted spectra data from file: <CI_sb_YAMS_0010.1>

    ## Extracted spectra data from file: <CI_sb_YAMS_0010.2>

    ## Extracted spectra data from file: <CI_sb_YAMS_0011.0>

    ## Extracted spectra data from file: <CI_sb_YAMS_0011.1>

    ## Extracted spectra data from file: <CI_sb_YAMS_0011.2>

    ## Extracted spectra data from file: <CI_sb_YAMS_0012.0>

    ## Extracted spectra data from file: <CI_sb_YAMS_0012.1>

    ## Extracted spectra data from file: <CI_sb_YAMS_0012.2>

    ## Extracted spectra data from file: <CI_sb_YAMS_0013.0>

    ## Extracted spectra data from file: <CI_sb_YAMS_0013.1>

    ## Extracted spectra data from file: <CI_sb_YAMS_0013.2>

    ## Extracted spectra data from file: <CI_sb_YAMS_0014.0>

    ## Extracted spectra data from file: <CI_sb_YAMS_0014.1>

    ## Extracted spectra data from file: <CI_sb_YAMS_0014.2>

    ## Extracted spectra data from file: <CI_tb_01_soil_cal.0>

    ## Extracted spectra data from file: <CI_tb_01_soil_cal.1>

    ## Extracted spectra data from file: <CI_tb_01_soil_cal.2>

    ## Extracted spectra data from file: <CI_tb_02_soil_cal.0>

    ## Extracted spectra data from file: <CI_tb_02_soil_cal.1>

    ## Extracted spectra data from file: <CI_tb_02_soil_cal.2>

    ## Extracted spectra data from file: <CI_tb_02_soil_cal.3>

    ## Extracted spectra data from file: <CI_tb_02_soil_cal.4>

    ## Extracted spectra data from file: <CI_tb_02_soil_cal.5>

    ## Extracted spectra data from file: <CI_tb_03_soil_cal.0>

    ## Extracted spectra data from file: <CI_tb_03_soil_cal.1>

    ## Extracted spectra data from file: <CI_tb_03_soil_cal.2>

    ## Extracted spectra data from file: <CI_tb_04_soil_cal.0>

    ## Extracted spectra data from file: <CI_tb_04_soil_cal.1>

    ## Extracted spectra data from file: <CI_tb_04_soil_cal.2>

    ## Extracted spectra data from file: <CI_tb_05_soil_cal.0>

    ## Extracted spectra data from file: <CI_tb_05_soil_cal.1>

    ## Extracted spectra data from file: <CI_tb_05_soil_cal.2>

    ## Extracted spectra data from file: <CI_tb_06_soil_cal.0>

    ## Extracted spectra data from file: <CI_tb_06_soil_cal.1>

    ## Extracted spectra data from file: <CI_tb_06_soil_cal.2>

    ## Extracted spectra data from file: <CI_tb_07_soil_cal.0>

    ## Extracted spectra data from file: <CI_tb_07_soil_cal.1>

    ## Extracted spectra data from file: <CI_tb_07_soil_cal.2>

    ## Extracted spectra data from file: <CI_tb_08_soil_cal.0>

    ## Extracted spectra data from file: <CI_tb_08_soil_cal.1>

    ## Extracted spectra data from file: <CI_tb_08_soil_cal.2>

    ## Extracted spectra data from file: <CI_tb_09_soil_cal.0>

    ## Extracted spectra data from file: <CI_tb_09_soil_cal.1>

    ## Extracted spectra data from file: <CI_tb_09_soil_cal.2>

    ## Extracted spectra data from file: <CI_tb_10_soil_cal.0>

    ## Extracted spectra data from file: <CI_tb_10_soil_cal.1>

    ## Extracted spectra data from file: <CI_tb_10_soil_cal.2>

    ## Extracted spectra data from file: <CI_tb_11_soil_cal.0>

    ## Extracted spectra data from file: <CI_tb_11_soil_cal.1>

    ## Extracted spectra data from file: <CI_tb_11_soil_cal.2>

    ## Extracted spectra data from file: <CI_tb_12_soil_cal.0>

    ## Extracted spectra data from file: <CI_tb_12_soil_cal.1>

    ## Extracted spectra data from file: <CI_tb_12_soil_cal.2>

    ## Extracted spectra data from file: <CI_tb_13_soil_cal.0>

    ## Extracted spectra data from file: <CI_tb_13_soil_cal.1>

    ## Extracted spectra data from file: <CI_tb_13_soil_cal.2>

    ## Extracted spectra data from file: <CI_tb_14_soil_cal.0>

    ## Extracted spectra data from file: <CI_tb_14_soil_cal.1>

    ## Extracted spectra data from file: <CI_tb_14_soil_cal.2>

    ## Extracted spectra data from file: <CI_tb_15_soil_cal.0>

    ## Extracted spectra data from file: <CI_tb_15_soil_cal.1>

    ## Extracted spectra data from file: <CI_tb_15_soil_cal.2>

    ## Extracted spectra data from file: <CI_tb_16_soil_cal.0>

    ## Extracted spectra data from file: <CI_tb_16_soil_cal.1>

    ## Extracted spectra data from file: <CI_tb_16_soil_cal.2>

    ## Extracted spectra data from file: <CI_tb_17_soil_cal.0>

    ## Extracted spectra data from file: <CI_tb_17_soil_cal.1>

    ## Extracted spectra data from file: <CI_tb_17_soil_cal.2>

    ## Extracted spectra data from file: <CI_tb_18_soil_cal.0>

    ## Extracted spectra data from file: <CI_tb_18_soil_cal.1>

    ## Extracted spectra data from file: <CI_tb_18_soil_cal.2>

    ## Extracted spectra data from file: <CI_tb_19_soil_cal.0>

    ## Extracted spectra data from file: <CI_tb_19_soil_cal.1>

    ## Extracted spectra data from file: <CI_tb_19_soil_cal.2>

    ## Extracted spectra data from file: <CI_tb_20_soil_cal.0>

    ## Extracted spectra data from file: <CI_tb_20_soil_cal.1>

    ## Extracted spectra data from file: <CI_tb_20_soil_cal.2>

``` r
length(spc_list)
```

    ## [1] 284

``` r
names(spc_list)
```

    ##   [1] "BF_lo_01_soil_cal.0" "BF_lo_01_soil_cal.1" "BF_lo_01_soil_cal.2"
    ##   [4] "BF_lo_02_soil_cal.0" "BF_lo_02_soil_cal.1" "BF_lo_02_soil_cal.2"
    ##   [7] "BF_lo_03_soil_cal.0" "BF_lo_03_soil_cal.1" "BF_lo_03_soil_cal.2"
    ##  [10] "BF_lo_04_soil_cal.0" "BF_lo_04_soil_cal.1" "BF_lo_04_soil_cal.2"
    ##  [13] "BF_lo_05_soil_cal.0" "BF_lo_05_soil_cal.1" "BF_lo_05_soil_cal.2"
    ##  [16] "BF_lo_06_soil_cal.0" "BF_lo_06_soil_cal.1" "BF_lo_06_soil_cal.2"
    ##  [19] "BF_lo_07_soil_cal.0" "BF_lo_07_soil_cal.1" "BF_lo_07_soil_cal.2"
    ##  [22] "BF_lo_08_soil_cal.0" "BF_lo_08_soil_cal.1" "BF_lo_08_soil_cal.2"
    ##  [25] "BF_lo_09_soil_cal.0" "BF_lo_09_soil_cal.1" "BF_lo_09_soil_cal.2"
    ##  [28] "BF_lo_10_soil_cal.0" "BF_lo_10_soil_cal.1" "BF_lo_10_soil_cal.2"
    ##  [31] "BF_lo_11_soil_cal.0" "BF_lo_11_soil_cal.1" "BF_lo_11_soil_cal.2"
    ##  [34] "BF_lo_12_soil_cal.0" "BF_lo_12_soil_cal.1" "BF_lo_12_soil_cal.2"
    ##  [37] "BF_lo_13_soil_cal.3" "BF_lo_13_soil_cal.4" "BF_lo_13_soil_cal.5"
    ##  [40] "BF_lo_14_soil_cal.0" "BF_lo_14_soil_cal.1" "BF_lo_14_soil_cal.2"
    ##  [43] "BF_lo_15_soil_cal.0" "BF_lo_15_soil_cal.1" "BF_lo_15_soil_cal.2"
    ##  [46] "BF_lo_16_soil_cal.0" "BF_lo_16_soil_cal.1" "BF_lo_16_soil_cal.2"
    ##  [49] "BF_lo_17_soil_cal.0" "BF_lo_17_soil_cal.1" "BF_lo_17_soil_cal.2"
    ##  [52] "BF_lo_18_soil_cal.0" "BF_lo_18_soil_cal.1" "BF_lo_18_soil_cal.2"
    ##  [55] "BF_lo_19_soil_cal.0" "BF_lo_19_soil_cal.1" "BF_lo_19_soil_cal.2"
    ##  [58] "BF_lo_20_soil_cal.0" "BF_lo_20_soil_cal.1" "BF_lo_20_soil_cal.2"
    ##  [61] "BF_mo_01_soil_cal.0" "BF_mo_01_soil_cal.1" "BF_mo_01_soil_cal.2"
    ##  [64] "BF_mo_02_soil_cal.0" "BF_mo_02_soil_cal.1" "BF_mo_02_soil_cal.2"
    ##  [67] "BF_mo_03_soil_cal.0" "BF_mo_03_soil_cal.1" "BF_mo_03_soil_cal.2"
    ##  [70] "BF_mo_04_soil_cal.0" "BF_mo_04_soil_cal.1" "BF_mo_04_soil_cal.2"
    ##  [73] "BF_mo_05_soil_cal.0" "BF_mo_05_soil_cal.1" "BF_mo_05_soil_cal.2"
    ##  [76] "BF_mo_06_soil_cal.0" "BF_mo_06_soil_cal.1" "BF_mo_06_soil_cal.2"
    ##  [79] "BF_mo_07_soil_cal.0" "BF_mo_07_soil_cal.1" "BF_mo_07_soil_cal.2"
    ##  [82] "BF_mo_08_soil_cal.0" "BF_mo_08_soil_cal.1" "BF_mo_09_soil_cal.0"
    ##  [85] "BF_mo_09_soil_cal.1" "BF_mo_09_soil_cal.2" "BF_mo_10_soil_cal.0"
    ##  [88] "BF_mo_10_soil_cal.1" "BF_mo_10_soil_cal.2" "BF_mo_11_soil_cal.0"
    ##  [91] "BF_mo_11_soil_cal.1" "BF_mo_11_soil_cal.2" "BF_mo_12_soil_cal.0"
    ##  [94] "BF_mo_12_soil_cal.1" "BF_mo_12_soil_cal.2" "BF_mo_13_soil_cal.0"
    ##  [97] "BF_mo_13_soil_cal.1" "BF_mo_13_soil_cal.2" "BF_mo_14_soil_cal.0"
    ## [100] "BF_mo_14_soil_cal.1" "BF_mo_14_soil_cal.2" "BF_mo_15_soil_cal.0"
    ## [103] "BF_mo_15_soil_cal.1" "BF_mo_15_soil_cal.2" "BF_mo_16_soil_cal.0"
    ## [106] "BF_mo_16_soil_cal.1" "BF_mo_16_soil_cal.2" "BF_mo_17_soil_cal.0"
    ## [109] "BF_mo_17_soil_cal.1" "BF_mo_17_soil_cal.2" "BF_mo_18_soil_cal.0"
    ## [112] "BF_mo_18_soil_cal.1" "BF_mo_18_soil_cal.2" "BF_mo_19_soil_cal.0"
    ## [115] "BF_mo_19_soil_cal.1" "BF_mo_19_soil_cal.2" "BF_mo_20_soil_cal.0"
    ## [118] "BF_mo_20_soil_cal.1" "BF_mo_20_soil_cal.2" "CI_sb_01_soil_cal.0"
    ## [121] "CI_sb_01_soil_cal.1" "CI_sb_01_soil_cal.2" "CI_sb_02_soil_cal.0"
    ## [124] "CI_sb_02_soil_cal.1" "CI_sb_02_soil_cal.2" "CI_sb_03_soil_cal.0"
    ## [127] "CI_sb_03_soil_cal.1" "CI_sb_03_soil_cal.2" "CI_sb_04_soil_cal.0"
    ## [130] "CI_sb_04_soil_cal.1" "CI_sb_04_soil_cal.2" "CI_sb_05_soil_cal.0"
    ## [133] "CI_sb_05_soil_cal.1" "CI_sb_05_soil_cal.2" "CI_sb_06_soil_cal.0"
    ## [136] "CI_sb_06_soil_cal.1" "CI_sb_06_soil_cal.2" "CI_sb_07_soil_cal.0"
    ## [139] "CI_sb_07_soil_cal.1" "CI_sb_07_soil_cal.2" "CI_sb_08_soil_cal.0"
    ## [142] "CI_sb_08_soil_cal.1" "CI_sb_08_soil_cal.2" "CI_sb_09_soil_cal.0"
    ## [145] "CI_sb_09_soil_cal.1" "CI_sb_09_soil_cal.2" "CI_sb_10_soil_cal.0"
    ## [148] "CI_sb_10_soil_cal.1" "CI_sb_10_soil_cal.2" "CI_sb_11_soil_cal.0"
    ## [151] "CI_sb_11_soil_cal.1" "CI_sb_11_soil_cal.2" "CI_sb_12_soil_cal.0"
    ## [154] "CI_sb_12_soil_cal.1" "CI_sb_12_soil_cal.2" "CI_sb_13_soil_cal.0"
    ## [157] "CI_sb_13_soil_cal.1" "CI_sb_13_soil_cal.2" "CI_sb_14_soil_cal.0"
    ## [160] "CI_sb_14_soil_cal.1" "CI_sb_14_soil_cal.2" "CI_sb_15_soil_cal.0"
    ## [163] "CI_sb_15_soil_cal.1" "CI_sb_15_soil_cal.2" "CI_sb_16_soil_cal.1"
    ## [166] "CI_sb_16_soil_cal.2" "CI_sb_16_soil_cal.3" "CI_sb_17_soil_cal.0"
    ## [169] "CI_sb_17_soil_cal.1" "CI_sb_17_soil_cal.2" "CI_sb_18_soil_cal.0"
    ## [172] "CI_sb_18_soil_cal.1" "CI_sb_18_soil_cal.2" "CI_sb_19_soil_cal.0"
    ## [175] "CI_sb_19_soil_cal.1" "CI_sb_19_soil_cal.2" "CI_sb_20_soil_cal.0"
    ## [178] "CI_sb_20_soil_cal.1" "CI_sb_20_soil_cal.2" "CI_sb_YAMS_0001.0"  
    ## [181] "CI_sb_YAMS_0001.1"   "CI_sb_YAMS_0001.2"   "CI_sb_YAMS_0002.0"  
    ## [184] "CI_sb_YAMS_0002.1"   "CI_sb_YAMS_0002.2"   "CI_sb_YAMS_0003.0"  
    ## [187] "CI_sb_YAMS_0003.1"   "CI_sb_YAMS_0003.2"   "CI_sb_YAMS_0004.0"  
    ## [190] "CI_sb_YAMS_0004.1"   "CI_sb_YAMS_0004.2"   "CI_sb_YAMS_0005.0"  
    ## [193] "CI_sb_YAMS_0005.1"   "CI_sb_YAMS_0005.2"   "CI_sb_YAMS_0006.0"  
    ## [196] "CI_sb_YAMS_0006.1"   "CI_sb_YAMS_0006.2"   "CI_sb_YAMS_0007.0"  
    ## [199] "CI_sb_YAMS_0007.1"   "CI_sb_YAMS_0007.2"   "CI_sb_YAMS_0008.0"  
    ## [202] "CI_sb_YAMS_0008.1"   "CI_sb_YAMS_0008.2"   "CI_sb_YAMS_0009.0"  
    ## [205] "CI_sb_YAMS_0009.1"   "CI_sb_YAMS_0009.2"   "CI_sb_YAMS_0010.0"  
    ## [208] "CI_sb_YAMS_0010.1"   "CI_sb_YAMS_0010.2"   "CI_sb_YAMS_0011.0"  
    ## [211] "CI_sb_YAMS_0011.1"   "CI_sb_YAMS_0011.2"   "CI_sb_YAMS_0012.0"  
    ## [214] "CI_sb_YAMS_0012.1"   "CI_sb_YAMS_0012.2"   "CI_sb_YAMS_0013.0"  
    ## [217] "CI_sb_YAMS_0013.1"   "CI_sb_YAMS_0013.2"   "CI_sb_YAMS_0014.0"  
    ## [220] "CI_sb_YAMS_0014.1"   "CI_sb_YAMS_0014.2"   "CI_tb_01_soil_cal.0"
    ## [223] "CI_tb_01_soil_cal.1" "CI_tb_01_soil_cal.2" "CI_tb_02_soil_cal.0"
    ## [226] "CI_tb_02_soil_cal.1" "CI_tb_02_soil_cal.2" "CI_tb_02_soil_cal.3"
    ## [229] "CI_tb_02_soil_cal.4" "CI_tb_02_soil_cal.5" "CI_tb_03_soil_cal.0"
    ## [232] "CI_tb_03_soil_cal.1" "CI_tb_03_soil_cal.2" "CI_tb_04_soil_cal.0"
    ## [235] "CI_tb_04_soil_cal.1" "CI_tb_04_soil_cal.2" "CI_tb_05_soil_cal.0"
    ## [238] "CI_tb_05_soil_cal.1" "CI_tb_05_soil_cal.2" "CI_tb_06_soil_cal.0"
    ## [241] "CI_tb_06_soil_cal.1" "CI_tb_06_soil_cal.2" "CI_tb_07_soil_cal.0"
    ## [244] "CI_tb_07_soil_cal.1" "CI_tb_07_soil_cal.2" "CI_tb_08_soil_cal.0"
    ## [247] "CI_tb_08_soil_cal.1" "CI_tb_08_soil_cal.2" "CI_tb_09_soil_cal.0"
    ## [250] "CI_tb_09_soil_cal.1" "CI_tb_09_soil_cal.2" "CI_tb_10_soil_cal.0"
    ## [253] "CI_tb_10_soil_cal.1" "CI_tb_10_soil_cal.2" "CI_tb_11_soil_cal.0"
    ## [256] "CI_tb_11_soil_cal.1" "CI_tb_11_soil_cal.2" "CI_tb_12_soil_cal.0"
    ## [259] "CI_tb_12_soil_cal.1" "CI_tb_12_soil_cal.2" "CI_tb_13_soil_cal.0"
    ## [262] "CI_tb_13_soil_cal.1" "CI_tb_13_soil_cal.2" "CI_tb_14_soil_cal.0"
    ## [265] "CI_tb_14_soil_cal.1" "CI_tb_14_soil_cal.2" "CI_tb_15_soil_cal.0"
    ## [268] "CI_tb_15_soil_cal.1" "CI_tb_15_soil_cal.2" "CI_tb_16_soil_cal.0"
    ## [271] "CI_tb_16_soil_cal.1" "CI_tb_16_soil_cal.2" "CI_tb_17_soil_cal.0"
    ## [274] "CI_tb_17_soil_cal.1" "CI_tb_17_soil_cal.2" "CI_tb_18_soil_cal.0"
    ## [277] "CI_tb_18_soil_cal.1" "CI_tb_18_soil_cal.2" "CI_tb_19_soil_cal.0"
    ## [280] "CI_tb_19_soil_cal.1" "CI_tb_19_soil_cal.2" "CI_tb_20_soil_cal.0"
    ## [283] "CI_tb_20_soil_cal.1" "CI_tb_20_soil_cal.2"

Typically, list information is nicely ordered, however printing is
really verbose.ß Therefore, we can gather the list into a so-called
spectral tibble (`spc_tbl`).

The spectral pre-processing pipeline is what is abstracted in these
basic steps that are commonly done.

# Outro

Simplerspec are some first baby steps in spectral adventures. It would
be great to further develop streamlining packages which are good at
doing single things. It would be great to co-develop a new set of
programs that automatically tune spectral machine learning pipelines. If
you have ideas, just send an email to me or interact via
    github.

``` r
devtools::session_info()
```

    ## ─ Session info ──────────────────────────────────────────────────────────
    ##  setting  value                       
    ##  version  R version 3.6.1 (2019-07-05)
    ##  os       Ubuntu 18.04.2 LTS          
    ##  system   x86_64, linux-gnu           
    ##  ui       X11                         
    ##  language (EN)                        
    ##  collate  en_US.UTF-8                 
    ##  ctype    en_US.UTF-8                 
    ##  tz       Europe/Zurich               
    ##  date     2019-12-12                  
    ## 
    ## ─ Packages ──────────────────────────────────────────────────────────────
    ##  ! package     * version   date       lib
    ##  P assertthat    0.2.1     2019-03-21 [?]
    ##    backports     1.1.5     2019-10-02 [1]
    ##  P broom         0.5.2     2019-04-07 [?]
    ##  P callr         3.3.2     2019-09-22 [?]
    ##  P cellranger    1.1.0     2016-07-27 [?]
    ##  P class         7.3-15    2019-01-01 [?]
    ##  P cli           1.1.0     2019-03-19 [?]
    ##  P codetools     0.2-16    2018-12-24 [?]
    ##  P colorspace    1.4-1     2019-03-18 [?]
    ##  P crayon        1.3.4     2017-09-16 [?]
    ##  P data.table  * 1.12.6    2019-10-18 [?]
    ##  P DBI           1.0.0     2018-05-02 [?]
    ##  P dbplyr        1.4.2     2019-06-17 [?]
    ##  P desc          1.2.0     2018-05-01 [?]
    ##  P devtools      2.2.1     2019-09-24 [?]
    ##  P digest        0.6.21    2019-09-20 [?]
    ##  P dplyr       * 0.8.3     2019-07-04 [?]
    ##  P e1071         1.7-3     2019-11-26 [?]
    ##  P ellipsis      0.3.0     2019-09-20 [?]
    ##  P evaluate      0.14      2019-05-28 [?]
    ##  P forcats     * 0.4.0     2019-02-17 [?]
    ##  P foreach     * 1.4.7     2019-07-27 [?]
    ##  P fs            1.3.1     2019-05-06 [?]
    ##  P generics      0.0.2     2018-11-29 [?]
    ##  P ggplot2     * 3.2.1     2019-08-10 [?]
    ##  P glue          1.3.1     2019-03-12 [?]
    ##  P gtable        0.3.0     2019-03-25 [?]
    ##  P haven         2.2.0     2019-11-08 [?]
    ##  P here        * 0.1       2017-05-28 [?]
    ##  P hexView       0.3-4     2019-03-13 [?]
    ##  P hms           0.5.2     2019-10-30 [?]
    ##  P htmltools     0.4.0     2019-10-04 [?]
    ##  P httr          1.4.1     2019-08-05 [?]
    ##  P iterators     1.0.12    2019-07-26 [?]
    ##  P jsonlite      1.6       2018-12-07 [?]
    ##  P knitr         1.23      2019-05-18 [?]
    ##  P lattice       0.20-38   2018-11-04 [?]
    ##  P lazyeval      0.2.2     2019-03-15 [?]
    ##  P lifecycle     0.1.0     2019-08-01 [?]
    ##  P lubridate     1.7.4     2018-04-11 [?]
    ##  P magrittr      1.5       2014-11-22 [?]
    ##  P memoise       1.1.0     2017-04-21 [?]
    ##  P modelr        0.1.5     2019-08-08 [?]
    ##  P munsell       0.5.0     2018-06-12 [?]
    ##  P nlme          3.1-140   2019-05-12 [?]
    ##  P pillar        1.4.2     2019-06-29 [?]
    ##  P pkgbuild      1.0.6     2019-10-09 [?]
    ##  P pkgconfig     2.0.3     2019-09-22 [?]
    ##  P pkgload       1.0.2     2018-10-29 [?]
    ##  P prettyunits   1.0.2     2015-07-13 [?]
    ##  P processx      3.4.1     2019-07-18 [?]
    ##  P ps            1.3.0     2018-12-21 [?]
    ##  P purrr       * 0.3.3     2019-10-18 [?]
    ##  P R6            2.4.1     2019-11-12 [?]
    ##  P Rcpp          1.0.2     2019-07-25 [?]
    ##  P readr       * 1.3.1     2018-12-21 [?]
    ##  P readxl        1.3.1     2019-03-13 [?]
    ##  P remotes       2.1.0     2019-06-24 [?]
    ##    renv          0.7.0-111 2019-10-06 [1]
    ##  P reprex        0.3.0     2019-05-16 [?]
    ##  P rlang         0.4.2     2019-11-23 [?]
    ##  P rmarkdown     1.13      2019-05-22 [?]
    ##    rprojroot     1.3-2     2018-01-03 [1]
    ##  P rstudioapi    0.10      2019-03-19 [?]
    ##  P rvest         0.3.5     2019-11-08 [?]
    ##  P scales        1.1.0     2019-11-18 [?]
    ##  P sessioninfo   1.1.1     2018-11-05 [?]
    ##  P simplerspec * 0.1.0     2019-11-22 [?]
    ##  P stringi       1.4.3     2019-03-12 [?]
    ##  P stringr     * 1.4.0     2019-02-10 [?]
    ##  P testthat      2.3.1     2019-12-01 [?]
    ##  P tibble      * 2.1.3     2019-06-06 [?]
    ##  P tidyr       * 1.0.0     2019-09-11 [?]
    ##  P tidyselect    0.2.5     2018-10-11 [?]
    ##  P tidyverse   * 1.3.0     2019-11-21 [?]
    ##  P usethis       1.5.1     2019-07-04 [?]
    ##  P vctrs         0.2.0     2019-07-05 [?]
    ##  P withr         2.1.2     2018-03-15 [?]
    ##  P xfun          0.8       2019-06-25 [?]
    ##  P xml2          1.2.2     2019-08-09 [?]
    ##  P yaml          2.2.0     2018-07-25 [?]
    ##  P zeallot       0.1.0     2018-01-28 [?]
    ##  source                                      
    ##  CRAN (R 3.6.0)                              
    ##  CRAN (R 3.6.1)                              
    ##  CRAN (R 3.6.0)                              
    ##  CRAN (R 3.6.1)                              
    ##  CRAN (R 3.6.0)                              
    ##  CRAN (R 3.5.2)                              
    ##  CRAN (R 3.6.0)                              
    ##  CRAN (R 3.5.2)                              
    ##  CRAN (R 3.6.0)                              
    ##  CRAN (R 3.6.0)                              
    ##  CRAN (R 3.6.1)                              
    ##  CRAN (R 3.6.0)                              
    ##  CRAN (R 3.6.0)                              
    ##  standard (@1.2.0)                           
    ##  CRAN (R 3.6.1)                              
    ##  CRAN (R 3.6.1)                              
    ##  CRAN (R 3.6.0)                              
    ##  CRAN (R 3.6.1)                              
    ##  CRAN (R 3.6.1)                              
    ##  CRAN (R 3.6.0)                              
    ##  CRAN (R 3.6.0)                              
    ##  CRAN (R 3.6.0)                              
    ##  CRAN (R 3.6.0)                              
    ##  CRAN (R 3.6.0)                              
    ##  CRAN (R 3.6.1)                              
    ##  CRAN (R 3.6.0)                              
    ##  CRAN (R 3.6.0)                              
    ##  CRAN (R 3.6.1)                              
    ##  CRAN (R 3.6.0)                              
    ##  CRAN (R 3.6.0)                              
    ##  CRAN (R 3.6.1)                              
    ##  CRAN (R 3.6.1)                              
    ##  CRAN (R 3.6.1)                              
    ##  CRAN (R 3.6.0)                              
    ##  CRAN (R 3.6.0)                              
    ##  CRAN (R 3.6.0)                              
    ##  CRAN (R 3.5.1)                              
    ##  CRAN (R 3.6.0)                              
    ##  standard (@0.1.0)                           
    ##  CRAN (R 3.6.0)                              
    ##  CRAN (R 3.6.0)                              
    ##  standard (@1.1.0)                           
    ##  CRAN (R 3.6.1)                              
    ##  CRAN (R 3.6.0)                              
    ##  CRAN (R 3.6.0)                              
    ##  CRAN (R 3.6.0)                              
    ##  CRAN (R 3.6.1)                              
    ##  CRAN (R 3.6.1)                              
    ##  standard (@1.0.2)                           
    ##  CRAN (R 3.6.0)                              
    ##  CRAN (R 3.6.0)                              
    ##  CRAN (R 3.6.0)                              
    ##  CRAN (R 3.6.1)                              
    ##  CRAN (R 3.6.1)                              
    ##  CRAN (R 3.6.0)                              
    ##  CRAN (R 3.6.0)                              
    ##  CRAN (R 3.6.0)                              
    ##  standard (@2.1.0)                           
    ##  Github (rstudio/renv@1e4ed65)               
    ##  CRAN (R 3.6.0)                              
    ##  CRAN (R 3.6.1)                              
    ##  CRAN (R 3.6.0)                              
    ##  CRAN (R 3.6.1)                              
    ##  CRAN (R 3.6.0)                              
    ##  CRAN (R 3.6.1)                              
    ##  CRAN (R 3.6.1)                              
    ##  standard (@1.1.1)                           
    ##  github (philipp-baumann/simplerspec@fd909c5)
    ##  CRAN (R 3.6.0)                              
    ##  CRAN (R 3.6.0)                              
    ##  CRAN (R 3.6.1)                              
    ##  CRAN (R 3.6.0)                              
    ##  CRAN (R 3.6.1)                              
    ##  CRAN (R 3.6.0)                              
    ##  CRAN (R 3.6.1)                              
    ##  standard (@1.5.1)                           
    ##  CRAN (R 3.6.0)                              
    ##  CRAN (R 3.6.0)                              
    ##  CRAN (R 3.6.0)                              
    ##  CRAN (R 3.6.1)                              
    ##  CRAN (R 3.6.0)                              
    ##  CRAN (R 3.6.0)                              
    ## 
    ## [1] /media/ssd/nas-ethz/doktorat/projects/04_communication/simplerspec-pedometron-article/renv/library/R-3.6/x86_64-pc-linux-gnu
    ## [2] /tmp/RtmpNokjnQ/renv-system-library
    ## 
    ##  P ── Loaded and on-disk path mismatch.
