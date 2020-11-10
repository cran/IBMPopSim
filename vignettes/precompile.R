library(knitr)
library(xfun)
library(filesstrings)

precomp <- function(vignette_name, extension) {
  vignette_Rmd = paste0("vignettes/", vignette_name, ".Rmd")
  knitr::knit(input = paste0("vignettes/", vignette_name, ".Rmd.orig"),
              output = vignette_Rmd, envir = globalenv())
  gsub_file(vignette_Rmd,
            "<embed src=",
            "```{r, echo=FALSE, fig.align='center'}\nknitr::include_graphics(")
  gsub_file(vignette_Rmd,
            "<img src=",
            "```{r, echo=FALSE, fig.align='center'}\nknitr::include_graphics(")
  gsub_file(vignette_Rmd,
            paste0(".", extension, "[^>]*/>"),
            paste0(".", extension, "\")\n```"))
}

precomp("IBMPopSim", "pdf")
precomp("IBMPopSim_cpp", "pdf")
precomp("IBMPopSim_human_pop", "pdf")
precomp("IBMPopSim_human_pop_IMD", "pdf")
precomp("IBMPopSim_insurance_portfolio", "pdf")

# ATTENTION: pour la vignette "interaction" il faut mettre les images en .png
precomp("IBMPopSim_interaction", "png")

images <- list.files("figure/") #[grep(".pdf", list.files("figure/"))]
file.move(paste0("figure/", images),
          destinations = "./vignettes/",
          overwrite = TRUE)

#rm_path_figure <- function(vignette_name, extension) {
#  vignette_Rmd = paste0("vignettes/", vignette_name, ".Rmd")
#  gsub_file(vignette_Rmd, '"figure/', '"')
#}

#rm_path_figure("IBMPopSim")
