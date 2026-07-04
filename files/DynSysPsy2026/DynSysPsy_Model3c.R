# jonashaslbeck@protonmail.com; July 3rd, 2026

# --------------------------------------------
# -------- What is happening here? -----------
# --------------------------------------------

# This is the version of the substance abuse model after Exercise 1, and after solving
# the divergence issue.

# The question here is: How can we change the model such that sustainable/healthy 
# substance abuse is possible?


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
# -------- Model 3b: Avoided Divergence ------
# --------------------------------------------

# ----- Model Setup -----
Nt <- 300
x <- numeric(Nt)
u <- integer(Nt)
x_base <- rep(5, Nt)
min_base <- 0
x[1] <- 5
u[1] <- 0
K <- 0

set.seed(1)
for(t in 2:Nt) {
  # Probability substance use
  p_u <- 1/(1+ exp(-1*(5-x[t-1]) + 2))
  # Substance abuse
  u[t] <- sample(0:1, size= 1, prob = c(1-p_u, p_u))
  # pleasure
  x[t] <- x[t-1] + 0.8*(x_base[t-1]-x[t-1]) + 3*u[t-1]
  # Resource
  x_base[t] <- x_base[t-1] - 0.2*u[t-1] * (x_base[t-1] - K)
}


# ----- Plotting -----
df <- data.frame(
  time = 1:Nt,
  y = x, 
  x_base = x_base)

plotModel(df = df, 
          title = "Model 3c", 
          pdf = FALSE)



