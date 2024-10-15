vignettes <- c("IBMPopSim",
  "IBMPopSim_cpp",
  "IBMPopSim_human_pop",
  "IBMPopSim_human_pop_IMD",
  "IBMPopSim_insurance_portfolio",
  "IBMPopSim_interaction")

for (vignette_name in vignettes){
  knitr::purl(input = paste0("vignettes/", vignette_name, ".Rmd.orig"), output = paste0("vignettes/", vignette_name, ".R"),documentation = 0)
}




