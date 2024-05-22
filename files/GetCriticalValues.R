# jonashaslbeck@protonmail.com; May 21st, 2024

# -----------------------------------------------------------
# ---------- Critical Values from Standard Normal -----------
# -----------------------------------------------------------

# Define the alpha threshold
alpha <- 0.05

# Calculate the critical values for a two-tailed test
z_critical_low <- qnorm(alpha / 2)
z_critical_high <- qnorm(1 - alpha / 2)

# Print the critical values
z_critical_low
z_critical_high



# -----------------------------------------------------------
# ---------- Critical Values from t-Distribution ------------
# -----------------------------------------------------------

# Define the alpha threshold
alpha <- 0.05

# Define the degrees of freedom
df <- 19

# Calculate the critical values for a two-tailed t-test
t_critical_low <- qt(alpha / 2, df)
t_critical_high <- qt(1 - alpha / 2, df)

# Print the critical values
t_critical_low
t_critical_high
