knitr::opts_chunk$set(
  echo = TRUE,
  fig.align = "center",
  cache = FALSE,
  collapse = TRUE,
  dev = 'png',
  fig.width = 6,
  fig.height = 4,
  dpi = 150
)

library(IBMPopSim)
library(ggfortify)
library(gridExtra)

# Generate population
N <- 900
x0 <- 1.06
agemin <- 0.
agemax <- 2.

pop_df_init <- data.frame(
  "birth" = -runif(N, agemin, agemax),
  "death" = as.double(NA),
  "birth_size" = x0
)
pop_init <- population(pop_df_init)
get_characteristics(pop_init)

# parameters for birth event
params_birth <- list(
  "p" = 0.03,
  "sigma" = sqrt(0.01),
  "alpha" = 1)

birth_event <- mk_event_individual( type = "birth",
  intensity_code = 'result = alpha * (4 - I.birth_size);',
  kernel_code = 'if (CUnif() < p)
                     newI.birth_size = min(max(0., CNorm(I.birth_size, sigma)), 4.);
                 else
                     newI.birth_size = I.birth_size;')

# parameters for death event
params_death <- list(
  "g" = 1,
  "beta" = 2./300.,
  "c" = 1.2
)

death_event <- mk_event_interaction( # Event with intensity of type interaction
  type = "death",
  interaction_code = "double x_I = I.birth_size + g * age(I,t);
                      double x_J = J.birth_size + g * age(J,t);
                      result = beta * ( 1.- 1./(1. + c * exp(-4. * (x_I-x_J))));"
)

model <- mk_model(
  characteristics = get_characteristics(pop_init),
  events = list(birth_event, death_event),
  parameters = c(params_birth, params_death)
)
summary(model)

birth_intensity_max <- 4*params_birth$alpha
interaction_fun_max <- params_death$beta

T = 500

# Multithreading is NOT possible due to interaction between individuals

sim_out <- popsim(model = model,
  initial_population = pop_init,
  events_bounds = c('birth'=birth_intensity_max, 'death'=interaction_fun_max),
  parameters = c(params_birth, params_death),
  age_max = 2,
  time = T)

sim_out$logs["duration_ns"]

str(sim_out$population)
pop_out <- sim_out$population

pop_size <- nrow(population_alive(pop_out,t = 500))
pop_size

ggplot(pop_out) + geom_segment(
                    aes(x=birth, xend=death, y=birth_size, yend=birth_size),
                    na.rm=TRUE, colour="blue", alpha=0.1) +
                xlab("Time") +
                ylab("Birth size")

params_death$g <- 0.3

sim_out <- popsim(model = model,
  initial_population = pop_init,
  events_bounds = c('birth'=birth_intensity_max, 'death'=interaction_fun_max),
  parameters = c(params_birth, params_death),
  age_max = 2,
  time = T)

pop_out <- sim_out$population

ggplot(pop_out) +
  geom_segment(aes(x=birth, xend=death, y=birth_size, yend=birth_size),
               na.rm=TRUE, colour="blue", alpha=0.1) +
  xlab("Time") + ylab("Birth size")

pyr <- age_pyramid(pop_out, ages = seq(0,2,by=0.2), time = 500)
head(pyr)

pyr$group_name <- as.character(cut(pyr$birth_size+1e-6, breaks = seq(0,4,by=0.25)))
head(pyr)

library(colorspace)
lbls <- sort(unique(pyr$group_name))
# Attribution of a color to each subgroup
colors <- c(diverging_hcl(n=length(lbls), palette = "Red-Green"))
names(colors) <- lbls

plot(pyr, group_colors = colors, group_legend = 'Birth size')

pyrs <- age_pyramids(pop_out, ages = seq(0,2,by=0.2), time = 50:500)
pyrs$group_name <- as.character(cut(pyrs$birth_size+1e-6, breaks = seq(0,4,by=0.25)))

lbls <- sort(unique(pyrs$group_name))
colors <- c(diverging_hcl(n=length(lbls), palette = "Red-Green"))
names(colors) <- lbls

# Only working for html render of the vignette
# library(gganimate)
# anim <- plot(pyrs, group_colors = colors, group_legend = 'Birth size') +
#             transition_time(time) +
#             labs(title = "Time: {frame_time}")

# animate(anim, nframes = 450, fps = 10)

N <- 2000
pop_df_init_big <- data.frame(
  "birth" = -runif(N, agemin, agemax), # Age of each individual chosen uniformly in [0,2]
  "death" = as.double(NA),
  "birth_size" = x0 # All individuals have initially the same birth size x0.
)
pop_init_big <- population(pop_df_init_big)

params_birth$alpha <- 4
params_birth$p <- 0.01 # Mutation probability
params_death$beta <- 1/100
params_death$g <- 1

birth_intensity_max <- 4*params_birth$alpha
interaction_fun_max <-  params_death$beta

sim_out <- popsim(
  model = model,
  initial_population = pop_init_big,
  events_bounds = c('birth'=birth_intensity_max, 'death'=interaction_fun_max),
  parameters = c(params_birth, params_death),
  age_max = 2,
  time = T)

pop_size <- nrow(population_alive(sim_out$population, t = 500))
pop_size

ggplot(sim_out$population) +
  geom_segment(aes(x=birth, xend=death, y=birth_size, yend=birth_size),
               na.rm=TRUE, colour="blue", alpha=0.1) +
  xlab("Time") +
  ylab("Birth size")

# Comparison full vs random
death_event_full <- mk_event_interaction(type = "death",
  interaction_type= "full",
  interaction_code = "double x_I = I.birth_size + g * age(I,t);
                      double x_J = J.birth_size + g * age(J,t);
                      result = beta * ( 1.- 1./(1. + c * exp(-4. * (x_I-x_J))));"
)
model_full <- mk_model(characteristics = get_characteristics(pop_init),
    events = list(birth_event, death_event_full),
    parameters = c(params_birth, params_death))

sim_out_full <- popsim(model = model_full,
  initial_population = pop_init_big,
  events_bounds = c('birth' = birth_intensity_max, 'death' =interaction_fun_max),
  parameters = c(params_birth, params_death),
  age_max = 2,
  time = T)

sim_out_full$logs["duration_ns"]/sim_out$logs["duration_ns"]
