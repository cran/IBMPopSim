# vignettes/[name].Rmd are created from vignettes/[name].Rmd.orig
# To extract R code from vignettes/[name].Rmd.orig run
# knitr::purl(input = "vignettes/[name].Rmd.orig", output = "vignettes/[name].R",documentation = 0)

library(knitr)
library(xfun)
library(filesstrings)

precomp <- function(vignette_name) {
  vignette_Rmd = paste0("vignettes/", vignette_name, ".Rmd")
  knitr::knit(input = paste0("vignettes/", vignette_name, ".Rmd.orig"),
              output = vignette_Rmd, envir = globalenv())
  gsub_file(vignette_Rmd,
            "<embed src=",
            "\n```{r, echo=FALSE, fig.align='center', out.width = '70%'}\nknitr::include_graphics(")
  gsub_file(vignette_Rmd,
            "<img src=",
            "\n```{r, echo=FALSE, fig.align='center', out.width = '70%'}\nknitr::include_graphics(")
  gsub_file(vignette_Rmd,
            paste0(".png", "[^>]*/>"),
            paste0(".png", "\")\n```"))
  gsub_file(vignette_Rmd,
            '<p class="caption">plot of chunk [a-zA-Z0-9_]+</p>',
            "")
}

precomp("IBMPopSim")
precomp("IBMPopSim_cpp")
precomp("IBMPopSim_human_pop")
precomp("IBMPopSim_human_pop_IMD")
precomp("IBMPopSim_insurance_portfolio")
precomp("IBMPopSim_interaction")

images <- list.files("figure/")

file.move(paste0("figure/", images),
          destinations = "./vignettes/",
          overwrite = TRUE)

rm_path_figure <- function(vignette_name, extension) {
  vignette_Rmd = paste0("vignettes/", vignette_name, ".Rmd")
  gsub_file(vignette_Rmd, '"figure/', '"')
}

rm_path_figure("IBMPopSim")
rm_path_figure("IBMPopSim_cpp")
rm_path_figure("IBMPopSim_human_pop")
rm_path_figure("IBMPopSim_human_pop_IMD")
rm_path_figure("IBMPopSim_insurance_portfolio")
rm_path_figure("IBMPopSim_interaction")
