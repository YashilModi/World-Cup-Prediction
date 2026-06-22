source("R/00_setup.R")

## The data: home goal margin in each completed match
completed = matches[matches$status == "Completed", ]
margin    = completed$home_score - completed$away_score
obs_mean  = mean(margin)

## Bootstrapping
# number of bootstrap samples
B = 5000
# matrix to store the bootstrap samples
bstr <- matrix(0, ncol = length(margin), nrow = B)
set.seed(2026)
for(i in 1:B){
  samp     = sample(margin, size = length(margin), replace = TRUE)
  bstr[i,] = samp
}
# Bootstrapped means
bstrm = apply(bstr, 1, mean)

## Distribution of the bootstrapped means
hist(bstrm, breaks = 30, col = "wheat",
     main = "Bootstrapped mean home margin",
     xlab = expression(bar(X)[b]))
abline(v = obs_mean, col = "red", lwd = 2)

# CONFIDENCE INTERVALS
sortedmeans = sort(bstrm)
alpha = 0.05
# positions of the quantiles
pos1 = (alpha/2)*B       ; pos2 = (1 - (alpha/2))*B
q1   = sortedmeans[pos1] ; q2   = sortedmeans[pos2]
cat("95% percentile CI for mean home margin: (", q1, " , ", q2, ")", sep = "")