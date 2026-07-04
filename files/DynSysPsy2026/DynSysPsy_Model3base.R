# jonashaslbeck@protonmail.com; July 3rd, 2026

# --------------------------------------------
# -------- What is happening here? -----------
# --------------------------------------------

# This is a skeleton for the model in Exercise 1 of the dynamical systems modeling workshop at the Amsterdam theory building summer school 2026.

# --------------------------------------------
# -------- Load Packages ---------------------
# --------------------------------------------

library(ggplot2)


# --------------------------------------------
# -------- Helpers ---------------------------
# --------------------------------------------

# This is a plotting function you can use below
plotModel <- function(df, 
                      varnames = c("Pleasure", "Baseline"),
                      title, 
                      filename = NULL, 
                      print = TRUE, 
                      pdf = TRUE, 
                      ylim=c(0,10)) {
  
  p <- ggplot(df, aes(x = time)) +
    geom_line(aes(y = x, colour = varnames[1]), linewidth = 0.8)
  
  # Add baseline line only if a second variable name is provided
  if(length(varnames) >= 2) {
    p <- p +
      geom_line(aes(y = x_base, colour = varnames[2]), linewidth = 0.8)
  }
  
  # Define colours depending on number of lines
  colours <- setNames(
    c("black", "red")[seq_along(varnames)],
    varnames
  )
  
  p <- p +
    scale_colour_manual(values = colours) +
    labs(
      colour = NULL,
      x = "Time",
      y = "Value",
      title = title
    ) +
    theme_bw(base_size = 14) +
    coord_cartesian(ylim = c(ylim[1], ylim[2])) +
    theme(
      panel.border = element_blank(),
      legend.position = c(0.98, 0.98),
      legend.justification = c(1, 1),
      legend.background = element_blank()
    )
  
  # Plot
  if(is.null(filename)) filename <- title
  if(print) print(p)
  
  # Save
  if(pdf) ggsave(
    paste0("Figures/", filename, ".pdf"),
    plot = p,
    width = 7,
    height = 5,
    units = "in",
    device = cairo_pdf
  )
  
} # eoF



# --------------------------------------------
# -------- Model 0: Substance Use Skeleton ---
# --------------------------------------------

# This skeleton is just to help you get started in case you are struggling
# But the verbal description allows many implementations, so feel free to choose your own setup


# ----- Model Setup -----
Nt <- 100 # Number of time points
# Make objects
x <- numeric(Nt) # pleasure, continuous
u <- integer(Nt) # substance abuse, either 0 or 1
x_base <- rep(5, Nt) # pleasure baseline
# Initial values
x[1] <- 5
u[1] <- 0

# ----- Running the Model -----
set.seed(1) # Reproducibility

for(t in 2:Nt) {
  # Probability substance use
  # p_u <- ... function of u: lower pleasure, higher probability of substance use
  # Substance abuse
  u[t] <- sample(0:1, size= 1, prob = c(1-p_u, p_u))
  # pleasure
  # x[t] <- x[t-1] + ... # pleasure goes up when taking substance; otherwise going towards baseline
  # Resource
  # x_base[t] <- x_base[t-1] - ... # if substance abuse, resource goes down;
}

# ----- Plotting -----
df <- data.frame(
  time = 1:Nt,
  y = x, 
  x_base = x_base)

plotModel(df = df, title = "Model_XX", pdf=FALSE)
