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
Physics](https://cran.r-project.org/web/views/ChemPhys.html). I would
opinionately consider most of them good at solving single tasks, but I
somehow missed a clean common interface that interlinked the key steps
required for spectral processing and modeling. While doing first
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

To reproduce the entire analysis in this hands-on, I would advise two
main procedures:

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

Now we are ready to proceed to the fundamentals of the package.

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

Simplerspec focuses on the key tasks and provides user-friendly modules
in the form of a standardized function pipeline. This pipeline builds
upon common design principles of spectral R objects which are shared
between function inputs and outputs.

First, you may want to read files from spectra that you measured on your
spectrometer. Spectral inputting is the first step done when doing
spectral analysis prior the standard chemical analysis. This is useful
when

The spectral pre-processing pipeline is what is abstracted in these
basic steps that are commonly
    done.

# Outro

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
    ##  date     2019-12-11                  
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
    ## [2] /tmp/RtmpXUllGa/renv-system-library
    ## 
    ##  P ── Loaded and on-disk path mismatch.
