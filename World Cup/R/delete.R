source("R/00_setup.R")

## The data: home goal margin in each completed match
completed = matches[matches$status == "Completed", ]
margin    = completed$home_score - completed$away_score
obs_mean  = mean(margin)

## Bootstrapping
B=5000
bstr=matrix(0,ncol=length(margin),nrow=B)
set.seed(2026)
for(i in 1:B)
{
  sampp=samp
}