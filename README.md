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

Enough of the personal talking, let’s start. To reproduce the entire
analysis in this hands-on, I would advise two main procedures:

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
pkgs <- c("here", "simplerspec", "tidyverse", "data.table",
  "future", "doFuture")
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

1.  Soil sampling and sample preparation

2.  Spectral measurements

3.  Selection of calibration samples

4.  Soil analytical reference analyses

5.  1.  Calibration or Recalibration
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
plan(multisession)
registerDoFuture()
availableCores()
```

    ## system 
    ##      8

``` r
# files to read
files_spc <- list.files(
  here("data", "spectra", "example-yamsys"), full.names = TRUE)
# one example file
files_spc[[1]]
```

    ## [1] "/media/ssd/nas-ethz/doktorat/projects/04_communication/simplerspec-pedometron-article/data/spectra/example-yamsys/BF_lo_01_soil_cal.0"

``` r
# read the files
suppressMessages(
  spc_list <- read_opus_univ(fnames = files_spc, extract = c("spc"), 
    parallel = TRUE)
)
length(spc_list)
```

    ## [1] 284

``` r
names(spc_list[[1]])
```

    ##  [1] "metadata"          "spc"               "spc_nocomp"       
    ##  [4] "sc_sm"             "sc_rf"             "ig_sm"            
    ##  [7] "ig_rf"             "wavenumbers"       "wavenumbers_sc_sm"
    ## [10] "wavenumbers_sc_rf"

Typically, list information is nicely ordered, however printing is
really verbose. Therefore, we can gather the list into a so-called
spectral tibble (`spc_tbl`).

``` r
# Gather from list into tibble data.frame
(spc_tbl <- 
  spc_list %>%
  gather_spc())
```

    ## # A tibble: 284 x 6
    ##    unique_id        file_id    sample_id   metadata   spc       wavenumbers
    ##    <chr>            <chr>      <chr>       <named li> <named l> <named lis>
    ##  1 BF_lo_01_soil_c… BF_lo_01_… BF_lo_01_s… <tibble [… <df[,171… <dbl [1,71…
    ##  2 BF_lo_01_soil_c… BF_lo_01_… BF_lo_01_s… <tibble [… <df[,171… <dbl [1,71…
    ##  3 BF_lo_01_soil_c… BF_lo_01_… BF_lo_01_s… <tibble [… <df[,171… <dbl [1,71…
    ##  4 BF_lo_02_soil_c… BF_lo_02_… BF_lo_02_s… <tibble [… <df[,171… <dbl [1,71…
    ##  5 BF_lo_02_soil_c… BF_lo_02_… BF_lo_02_s… <tibble [… <df[,171… <dbl [1,71…
    ##  6 BF_lo_02_soil_c… BF_lo_02_… BF_lo_02_s… <tibble [… <df[,171… <dbl [1,71…
    ##  7 BF_lo_03_soil_c… BF_lo_03_… BF_lo_03_s… <tibble [… <df[,171… <dbl [1,71…
    ##  8 BF_lo_03_soil_c… BF_lo_03_… BF_lo_03_s… <tibble [… <df[,171… <dbl [1,71…
    ##  9 BF_lo_03_soil_c… BF_lo_03_… BF_lo_03_s… <tibble [… <df[,171… <dbl [1,71…
    ## 10 BF_lo_04_soil_c… BF_lo_04_… BF_lo_04_s… <tibble [… <df[,171… <dbl [1,71…
    ## # … with 274 more rows

Instead of appending a matrix of spectra as a single column in a
data.frame, spectra in a spectral tibble form a list-column. A
list-column is basically a column ist a list instead of an atomic
vector. With this we can extract this list column of spectra.

``` r
spc_dt <- data.table::rbindlist(spc_tbl$spc)
dim(spc_dt)
```

    ## [1]  284 1716

``` r
class(spc_dt)
```

    ## [1] "data.table" "data.frame"

The spectral pre-processing pipeline is what is abstracted in these
basic steps that are commonly done. Simplerspec uses prospectr for key
steps and data.table for simple operations. The following graph
summarizes the steps.

Resampling refers to create a new a axis interval in spectra.

# Outro

Simplerspec are some first baby steps in spectral adventures. It would
be great to further develop streamlining packages which are good at
doing single things. It would also be fantastic to co-develop a new set
of programs that automatically tune spectral machine learning pipelines.
If you have ideas, just send me an email or interact via github.
