options(stringsAsFactors = FALSE)

requires <- c("magrittr",
              "crayon",
              "scales",
              "here",
              "httr",
              "jsonlite",
              "tm",
              "tidytext",
              "topicmodels",
              "textfeatures",
              "cleanNLP",
              "kableExtra",
              "tidyverse")
to_install <- c(requires %in% rownames(installed.packages()) == FALSE)
install.packages(c(requires[to_install], "NA"), repos = "https://cloud.r-project.org/" )
rm(requires, to_install)

knitr::opts_chunk$set(echo = TRUE,
                      cache = FALSE,
                      fig.width=8.5,
                      split = T,
                      fig.align = 'center',
                      fig.path='figs/',
                      warning=FALSE,
                      message=FALSE)


library(tidyverse)
library(here)
library(rvest)
library(readr)
library(magrittr)
library(tidytext)
library(knitr)
library(kableExtra)
library(here)
library(crayon)
library(scales)

# devtools::install_github("judgelord/legislators")
library(legislators)

library(ggplot2); theme_set(theme_minimal())
options(
  ggplot2.continuous.color = "viridis",
  ggplot2.continuous.fill = "viridis"
)
scale_color_discrete <- function(...)
  scale_color_viridis_d(...)
scale_fill_discrete <- function(...)
  scale_fill_viridis_d(...)

kablebox <- . %>%
  head(100) %>%
  knitr::kable() %>%
  kable_styling() %>%
  scroll_box(height = "400px")

congress_years<- function(congress){
  years<- c(congress*2 + 1787, congress*2 + 1788 )
  return(years)
}

year_congress<- function(year){
  return(floor((year - 1787)/2))
}
