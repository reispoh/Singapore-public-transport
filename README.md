## Project overview 
This project analyses bus stop connectivity across Singapore using interactive data visualisation. It explores how bus services are distributed across different roads and neighbourhoods, highlighting issues of accessibility and equity in public transport.  

This project uses publicly available data from the Singapore Land Transport Authority (LTA) DataMall API. To reproduce the analysis, users should request an LTA DataMall API key and run the data collection / processing script in RStudio.

The dataset provides information on bus stops, bus routes, and service counts.  
The project aims to:

1. Map bus stop locations and connectivity levels  
2. Compare service counts across roads using bar charts  
3. Explore distributional differences with ridgeline plots  
4. Allow users to filter and select specific roads for comparison  

By combining technical analysis with interactive design, the dashboard uncovers patterns of inequality and accessibility in Singapore’s transport system.

## Workflow

Load the dataset in RStudio as follows:
```r
routes_with_locations <- readRDS("data/routes_with_locations.rds")

Please ensure that the latest version of R studio is being used.

These can be installed using pacman::p_load() in R studio. 
You will require the following libraries to be loaded: 
  httr
  jsonlite
  dplyr
  ggplot2
  purrr
  tidyverse)

## Help
If you have questions regarding this project, you can contact the host at reis.poh.24@ucl.ac.uk
