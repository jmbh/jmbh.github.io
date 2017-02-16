# This code reproduces the figures in the Blogpost:
# http://jmbh.github.io/Deconstructing-ME/

# !!! DEFINE WHERE THE FIGURES SHOULD BE SAVED !!!
figDir <- '...'

# --------- 1) Simulation by the Authors ---------

set.seed(1)
nIter <- 1000
r <- .15
sims<-array(0,c(nIter,4))
xerror <- 0.5
yerror<-0.5

for (i in 1:nIter) {
  
  ## N = 50
  # No ME
  x <- rnorm(50,0,1)
  y <- r*x + rnorm(50,0,1)
  xx<-lm(y~x)
  sims[i,1]<-summary(xx)$coefficients[2,1]
  # ME
  x<-x + rnorm(50,0,xerror)
  y<-y + rnorm(50,0,yerror)
  xx<-lm(y~x)
  sims[i,2]<-summary(xx)$coefficients[2,1]
  
  ## N = 3000
  # No ME
  x <- rnorm(3000,0,1)
  y <- r*x + rnorm(3000,0,1)
  xx<-lm(y~x)
  sims[i,3]<-summary(xx)$coefficients[2,1]
  # ME
  x<-x + rnorm(3000,0,xerror)
  y<-y + rnorm(3000,0,yerror)
  xx<-lm(y~x)
  sims[i,4]<-summary(xx)$coefficients[2,1]
  
}


# --------- 2) Figure A: Densities of Sampling Distributions ---------

png(paste0(figDir, 'SamplingDistri.png'), width = 600, height = 400)

plot.new()
par(mar=c(4,2,1,1))
plot.window(xlim= c(-.3, .45), ylim=c(0,24))
box()
D_high <- density(sims[,2])
D_low <- density(sims[,4])
lines(D_high$x, D_high$y, lty = 2, lwd = 2)
lines(D_low$x, D_low$y, lty = 1, lwd = 2)
title(xlab = 'Coefficient Estimate', line = 2.5)
title(ylab = 'Density', line = 1)
axis(1, seq(-.40, .60, length = 11), cex.axis = 1)

# Mean of sampling distribution
abline(v = mean(sims[,2]), lty=2, col='red', lwd =2)
abline(v = mean(sims[,4]), lty=1, col='red', lwd = 2)
# True coefficient (without ME)
abline(v = .15, col='blue', lty=2, lwd = 2)
abline(v = mean(c(sims[,2], sims[,4])), col='green', lty=2, lwd = 2)

# Legend
legend(-.3, 22, c('Samp Dist: Low noise / high N', 'Samp Dist: High noise / small N'), lty = 1:2, lwd = c(2,2))
legend(-.3, 17, c('Mean Samp Dist: low noise', 'Mean Samp Dist: high noise'), lty = 1:2, col=c('red', 'red'), lwd=c(2,2))
legend(-.3, 12, c('True coefficient: no ME', 'True coefficient: ME'), lty = c(2,2), col=c('blue', 'green'), lwd=c(2,2))

dev.off()


# --------- 3) Figure B: Reproducing Figure in paper & rescaling ---------


png(paste0(figDir, 'ScalingIssue.png'), width = 700, height = 700)

par(mar=c(4,4,3,1), mfrow=c(2,2))

plot(sims[,4] ~ sims[,3], 
     xlab = 'No measurement error', 
     ylab = 'Measurement error', 
     main = 'Low noise / large N', 
     pch = 20, cex = .2, col = 'red',
     xlim=c(0.05, .2), 
     ylim=c(0.05, .2))
abline(0,1,col="black")
plot(sims[,2] ~ sims[,1], 
     xlab = 'No measurement error', 
     ylab = 'Measurement error', 
     main = 'High noise / small N', 
     pch = 20, cex = .2, col = 'red')
abline(0,1,col="black")

plot(sims[,4] ~ sims[,3], 
     xlab = 'No measurement error', 
     ylab = 'Measurement error', 
     main = 'Low noise / large N',
     xlim = c(-.4, .7), 
     ylim = c(-.4, .7), 
     pch = 20, cex = .2, col = 'red')
abline(0,1,col="black")
plot(sims[,2] ~ sims[,1], 
     xlab = 'No measurement error', 
     ylab = 'Measurement error', 
     main = 'High noise / small N',
     xlim = c(-.4, .7), 
     ylim = c(-.4, .7), 
     pch = 20, cex = .2, col = 'red')
abline(0,1,col="black")

dev.off()


