#MARKET VALUE BY POSITION (ANOVA)

source("R/00_setup.R")

# Groups: market value split by playing position
positions = c("GK", "DEF", "MID", "FWD")
MV = list()
for(j in 1:length(positions)){
  MV[[j]] = players$market_value_eur[players$position == positions[j]]
}

# Box plots of market value by position
boxplot(MV, names = positions, ylab = "Market value (EUR)",
        xlab = "Position", border = "blue")

# Overall mean, group means, sizes
n   = sapply(MV, length)
N   = sum(n)
k   = length(MV)
Yi. = sapply(MV, mean)
Y.. = mean(unlist(MV))

# Observed SSE, SST and F-ratio
SSE = SST = 0
for(j in 1:k){
  SSE = SSE + sum((MV[[j]] - Yi.[j])^2)
  SST = SST + n[j]*(Yi.[j] - Y..)^2
}
Fr_obs = (SST/(k - 1)) / (SSE/(N - k))

# Bootstrapping under H0: pool everything, re-split into same group sizes
B = 5000
bstr_ratios = numeric(B)
all_values  = unlist(MV)
set.seed(2026)
for(b in 1:B){
  draw  = sample(all_values, N, replace = TRUE)
  boots = list()
  idx   = 0
  for(j in 1:k){
    boots[[j]] = draw[(idx + 1):(idx + n[j])]
    idx        = idx + n[j]
  }
  Y.. = mean(unlist(boots))
  Yi. = sapply(boots, mean)
  SSE = SST = 0
  for(j in 1:k){
    SSE = SSE + sum((boots[[j]] - Yi.[j])^2)
    SST = SST + n[j]*(Yi.[j] - Y..)^2
  }
  bstr_ratios[b] = (SST/(k - 1)) / (SSE/(N - k))
}

# Distribution of the bootstrapped F-ratios
hist(bstr_ratios, col = "blue", breaks = 30,
     main = "Bootstrapped F-ratios", xlab = "F ratios")
abline(v = Fr_obs, col = "red", lwd = 2)

# HYPOTHESIS TESTING