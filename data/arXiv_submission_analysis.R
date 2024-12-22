# jonashaslbeck@protonmail.com; Dec 20, 2024

# -------------------------------------------------
# ---------- What is happening here? --------------
# -------------------------------------------------

# Analyze public arxiv submissions stats to find out whether people submit more on


# -------------------------------------------------
# ---------- Load Packages ------------------------
# -------------------------------------------------

library(plyr)
library(BayesFactor)


# -------------------------------------------------
# ---------- Load Data ----------------------------
# -------------------------------------------------

data <- read.table("get_monthly_submissions.csv", sep=",", header=TRUE)


# -------------------------------------------------
# ---------- Process ------------------------------
# -------------------------------------------------

month <- as.numeric(substr(data$month, 6, 8))
year <- as.numeric(substr(data$month, 1, 4))
data$month_fixed <- month
data$year_fixed <- year


# -------------------------------------------------
# ---------- Analyze ------------------------------
# -------------------------------------------------

# Get # Submissions for each year
ddply(data, .(year_fixed), function(x) sum(x$submissions))

# Delete data from 2024
data_sub <- data[(data$year_fixed != 2024) & (data$year_fixed >= 1994), ]
data_sub$month_fixed <- as.factor(data_sub$month_fixed)

# ----- Boxplots -----
# par(mar=c(4.3,5,3,2))
# boxplot(data_sub$submissions ~ data_sub$month_fixed, xlab="Month", axes=FALSE, ylab="")
# title(main = "Monthly aXiv.org Submissions, averaged 1994-2023", font.main=1)
# title(ylab="Montly Submissions", line=3.8)
# axis(1, month.abb, at=1:12)
# axis(2, las=2)

# ----- Simple Stratification -----
# Taking mean is a bit odd, because the overall numbers are so different
# But can't come up with a better critique
# Still, I guess an easier to understand analysis would be to compute relative proportions
# across months per year; and then average the proportions; that way, we get more meaningful variation
# across year
props <- ddply(data_sub, .(year_fixed), function(x) x$submissions/sum( x$submissions))

# plot.new()
# plot.window(xlim=c(1,12), ylim=c(0.00, 0.15))
# axis(1, month.abb, at=1:12)
# axis(2, las=2)
# n_years <- nrow(props)
# for(i in 1:n_years) points(1:12, props[i,-1])

boxplot(props[,-1], axes=FALSE, ylim=c(0.06, 0.11))
axis(1, month.abb, at=1:12)
axis(2, las=2, at=seq(0.06, 0.11, length=6), labels=paste0(seq(0.06, 0.11, length=6)*100, "%"))
abline(h=1/12, lty=1, col="lightgrey")
axis(2, at=1/12, label="8.3%", las=2, col.axis="grey")
boxplot(props[,-1], axes=FALSE, ylim=c(0.06, 0.11), add=TRUE)
title(main = "Percentage of aXiv.org Submissions in each Month from 1994-2023", font.main=1)
title(ylab="Percentage Submissions", line=3.5)




# ----- Bayes Factor Test -----
# Bayesian ANOVA to test if submissions differ across months
bf <- anovaBF(submissions ~ month_fixed, data = data_sub)
# Print Bayes Factor
print(bf)

# ----- Bayes Factor Test: Only 2023 -----
data_sub2 <- data[data$year_fixed == 2023, ]
data_sub2$month_fixed <- as.factor(data_sub2$month_fixed)
bf <- anovaBF(submissions ~ month_fixed, data = data_sub2)

# ----- Regression Model -----
data_sub$month_fixed_relevel <- relevel(data_sub$month_fixed, ref = "12")
data_sub$year_fixed_exp <- exp(data_sub$year_fixed-2000)
lm_obj <- lm(data_sub$submissions_log ~ data_sub$month_fixed_relevel + data_sub$year_fixed)
summary(lm_obj)
plot(residuals(lm_obj))

plot(data_sub$submissions_log)
points(predict(lm_obj), col="red")
plot(data_sub$submissions_log, predict(lm_obj))

# ----- GAM model -----
library(mgcv)
gam_model <- gam(submissions_log ~ s(year_fixed) + month_fixed_relevel, data = data_sub)
summary(gam_model)
anova(gam_model)
plot(residuals(gam_model))

library(emmeans)
pairwise <- emmeans(gam_model, pairwise ~ month_fixed_relevel, adjust = "tukey")
# Extract only the comparisons involving December (month 12)
pairwise_sum <- summary(pairwise)
pairwise_sum$emmeans
dec_comparisons <- pairwise_sum$contrasts[grepl("12", pairwise_sum$contrast$contrast), ]

# Back-transform estimates (log differences -> ratios)
ratios_df <- data.frame(dec_comparisons)
ratios_df$Ratio <- exp(ratios_df$estimate)  # Exponentiate to get ratios
ratios_df$Percent_Change <- (ratios_df$Ratio - 1) * 100  # Convert to percentage

# Clean Table
ratios_df_cl <- ratios_df[, c("contrast", "estimate", "SE", "p.value", "Ratio")]
ratios_df_cl$contrast <- paste0(month.abb[12], " / ", month.abb[1:11])
ratios_df_cl$Ratio <- round(ratios_df_cl$Ratio, 2)
ratios_df_cl$p.value <- round(ratios_df_cl$p.value, 3)
ratios_df_cl$estimate <- round(ratios_df_cl$estimate, 3)
ratios_df_cl$SE <- round(ratios_df_cl$SE, 3)
ratios_df_cl

# # Compare with medians in data
# med_log <- ddply(data_sub, .(month_fixed_relevel), function(x) median(x$submissions_log))
# # Sanity:
# plot(med_log$V1, pairwise_sum$emmeans$emmean) # Shouldn't be exactly the same


# ----- Fir Exponential Model -----
data_sub$submissions_log <- log(data_sub$submissions)
plot(data_sub$submissions_log)
time <- 1:nrow(data_sub)
lm_obj <- lm(data_sub$submissions_log ~ time)
abline(lm_obj, col="red")





# ----- Plot Data Across months -----
plot.new()
plot.window(xlim=c(1, 12), ylim=c(0, 20000))
axis(1, month.abb, at=1:12)
axis(2, las=2)
abline(v=1:12, lty=3, col="lightgrey")
title(ylab="Montly Submissions", line=3)

u_year <- unique(data$year_fixed)
n_u_year <- length(u_year)
colors <- colorRampPalette(c("deeppink", "forestgreen"))(n_u_year-1)
for(i in 2:n_u_year) {
  data_ss <- data$submissions[data$year_fixed==u_year[i]]
  lines(1:12, data_ss, col=colors[i], lwd=2)
}




plot(data$month_fixed, data$submissions)



points(data$month_fixed, data$submissions)



# ----- Line Plot -----
nrow(data)

plot.new()
plot.window(xlim=c(1, 402), ylim=c(0,25000))
axis(1)
axis(2, las=2)
lines(data$submissions, type="l")
abline(v=which(data$month_fixed==12), col="red", lty=2)









