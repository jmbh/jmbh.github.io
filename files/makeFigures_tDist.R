# jonashaslbeck@protonmail.com; May 18th, 2024

# ----------------------------------------------------
# ---------- What is happening here? -----------------
# ----------------------------------------------------

# Make figures for t-distribution mini lecture


# ----------------------------------------------------
# ---------- Load Packages ---------------------------
# ----------------------------------------------------

library(RColorBrewer)


# ----------------------------------------------------
# ---------- Get Colors for coloring Z-equation ------
# ----------------------------------------------------

cols <- brewer.pal(4, "Set1")
cols


# ----------------------------------------------------
# ---------- Scenario A: Known Variance --------------
# ----------------------------------------------------

# ------ Plot A.1 Recap Z-test ------

x <- seq(-4, 4, length=1000)
y <- dnorm(x, 0, 1)
alpha <- 0.05
crit <- qnorm(c(alpha/2, 1-alpha/2), 0, 1)

pdf("Figures/Zdist.pdf", width=6, height=5)
Baseplot_ZScore <- function(crit, showCrit=TRUE, colcrit="darkgrey", type="Z") {
  par(mar=c(4.2,4,2,1))
  plot.new()
  plot.window(xlim=c(-4,4), ylim=c(0,.53))
  axis(1)
  axis(2, las=2)
  title(xlab="Z score")
  title(ylab="Density")

  if(showCrit) {

    segments(crit[1], 0, crit[1], 0.5, lwd=2, lty=2, col=colcrit)
    segments(crit[2], 0, crit[2], 0.5, lwd=2, lty=2, col=colcrit)

    arrows(x0 = crit[1], 0.45, -4, 0.45, length = 0.15, code=3, col="tomato", lwd=2)
    arrows(x0 = crit[2], 0.45, 4, 0.45, length = 0.15, code=3, col="tomato", lwd=2)
    arrows(x0 = crit[1], 0.45, crit[2], 0.45, length = 0.15, code=3, col="lightblue", lwd=2)
    text(0, 0.48, "H0 not rejected", col="lightblue")
    text((-4 + crit[1])/2, 0.48, "H0 rejected", col="tomato")
    text((4 + crit[2])/2, 0.48, "H0 rejected", col="tomato")
    if(type=="Z") {
    text(crit[1], 0.52, expression(Z[0.025]), col=colcrit)
    text(crit[2], 0.52, expression(Z[0.975]), col=colcrit)
    } else {
      text(crit[1], 0.52, expression(t[0.025]), col=colcrit)
      text(crit[2], 0.52, expression(t[0.975]), col=colcrit)
    }
  }
}
Baseplot_ZScore(crit=crit)
lines(x, y, lwd=2)
dev.off()

# ------ Plot A.2 Verify CLT ------

# Simulate
nIter <- 1000000
N <- 15
v_Z <- rep(NA, nIter)
set.seed(1)
for(i in 1:nIter) v_Z[i] <- (mean(rnorm(N, 0, 1))-0) / (1 / sqrt(N))
# Compute coverage
ind_cov <- v_Z > crit[1] & v_Z < crit[2]

# Plot
pdf("Figures/Zdist_Verify_CLT.pdf", width=6, height=5)
Baseplot_ZScore(crit=crit)
hist(v_Z, breaks=seq(-11, 11, length=200), add=TRUE, freq = FALSE)
lines(x, y, lwd=2)
rect(0-1.4, 0.1-0.02, 0+1.4, 0.1+0.02, col="white")
text(0, 0.1, paste0("Coverage = ", round(mean(ind_cov), 4)*100, "%"), col="lightblue")
dev.off()


# ----------------------------------------------------
# ---------- Scenario B: Estimated Variance ----------
# ----------------------------------------------------

# Simulate
nIter <- 100000
N <- 15
v_Z <- rep(NA, nIter)
set.seed(1)
for(i in 1:nIter) {
  data <- rnorm(N, 0, 1)
  v_Z[i] <- (mean(data)-0) / (sd(data) / sqrt(N))
}
# Compute Coverage
ind_cov <- v_Z > crit[1] & v_Z < crit[2]

# ------- Plot B.1 Z crit vals with samp dist estimated SDs -------

# Plot
pdf("Figures/Zdist_SampDist_estSD.pdf", width=6, height=5)
Baseplot_ZScore(crit=crit)
hist(v_Z, breaks=seq(-11, 11, length=200), add=TRUE, freq = FALSE)
lines(x, y, lwd=2)
rect(0-1.3, 0.1-0.02, 0+1.3, 0.1+0.02, col="white")
text(0, 0.1, paste0("Coverage = ", round(mean(ind_cov), 4)*100, "%"), col="lightblue")
dev.off()


# ------- Plot B.2 Show t-density estimated SDs -------

# Compute density of t-distribution
y_t <- dt(x, df=N-1)

# Plot
pdf("Figures/Zdist_SampDist_estSD_with_tDist.pdf", width=6, height=5)
Baseplot_ZScore(crit=crit, showCrit = FALSE)
hist(v_Z, breaks=seq(-11, 11, length=200), add=TRUE, freq = FALSE)
lines(x, y, lwd=2)
lines(x, y_t, col="orange", lwd=2)
text(0, 0.45, "t-distribution (df=9)", col="orange")
dev.off()


# ------- Plot B.3 Show t-density + t-crit values estimated SDs -------

# Compute critical values
crit_t <- qt(c(alpha/2, 1-alpha/2), df=N-1)
# Compute Coverage using t-distributiom
ind_cov_t <- v_Z > crit_t[1] & v_Z < crit_t[2]

# Plot
pdf("Figures/Zdist_SampDist_estSD_with_tDist_plusCrit.pdf", width=6, height=5)
Baseplot_ZScore(crit=crit_t, showCrit = TRUE, colcrit = "orange", type="t")
hist(v_Z, breaks=seq(-11, 11, length=200), add=TRUE, freq = FALSE)
lines(x, y_t, col="orange", lwd=2)
rect(0-1.3, 0.1-0.02, 0+1.3, 0.1+0.02, col="white")
text(0, 0.1, paste0("Coverage = ", round(mean(ind_cov_t), 4)*100, "%"), col="lightblue")
dev.off()


# ----------------------------------------------------
# ---------- Show Convergence of t to Z --------------
# ----------------------------------------------------

# Compute densities
x <- seq(-4, 4, length=1000)
y <- dnorm(x, 0, 1)
lines(x, y, col="black", lwd=2)
l_t <- list()
v_dfs <- c(1,2,3,5,10)
for(i in 1:5) l_t[[i]] <- dt(x, df=v_dfs[i])
cols <- brewer.pal(6, "Blues")[-1]

# Plot
pdf("Figures/ZvsT.pdf", width=6, height=5)

par(mar=c(4.2,4,1.5,1))
plot.new()
plot.window(xlim=c(-4,4), ylim=c(0,.45))
axis(1)
axis(2, las=2)
title(xlab="Z score")
title(ylab="Density")
lines(x, y, lwd=2)
for(i in 1:5) lines(x, l_t[[i]], col=cols[i], lwd=2)
legend("right", legend=c("Standard normal", paste0("t(df=", v_dfs, ")")),
       bty="n", text.col=c("black", cols))

dev.off()





