library(bsicons)
library(bslib)
library(dplyr)
library(DT)
library(palmerpenguins)
library(plotly)
library(shiny)

source("1_functions.R")
source("2_ui.R")
source("3_server.R")

shinyApp(ui = ui,server = server)