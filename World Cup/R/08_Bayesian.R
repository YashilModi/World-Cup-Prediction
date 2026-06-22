#BAYESIAN SPONSOR DECISION (EVPI)

# A sponsor backs ONE of three contenders to win the tournament.
# States  (columns) = which team actually wins
# Actions (rows)    = which team the sponsor backs

# PAYOFF MATRIX (profit, EUR millions)
# Underdogs pay more if they come through (cheaper to back).
profit.mat <- matrix(c( 8, -2, -2,      # Back Argentina
                        -2, 12, -2,      # Back Spain
                        -2, -2, 18),     # Back France
                     nrow = 3, byrow = TRUE)
colnames(profit.mat) <- c("Arg wins", "Spa wins", "Fra wins")
rownames(profit.mat) <- c("Back Arg", "Back Spa", "Back Fra")
profit.mat

# PRIOR PROBABILITIES
# Win chance among the three (could be read off your Monte Carlo prob_table)
prior.probs <- c(0.45, 0.30, 0.25)

# EXPECTED PROFIT PER ACTION
exp.profit <- profit.mat %*% prior.probs
exp.profit
rownames(profit.mat)[which.max(exp.profit)]   # the best action

# EVPI: value of a perfect forecast of the winner
profit.PI <- apply(profit.mat, 2, max) %*% prior.probs
EVPI      <- profit.PI - max(exp.profit)
EVPI

# Full treatment
# A scouting/betting-market signal (illustrative): rows = report, cols = states
cond.probs <- matrix(c(0.7, 0.4, 0.2,     # "short odds on favourite"
                       0.3, 0.6, 0.8),    # "market wide open"
                     nrow = 2, byrow = TRUE)
colnames(cond.probs) <- c("Arg wins", "Spa wins", "Fra wins")
rownames(cond.probs) <- c("Short odds", "Wide open")

bayes.decision <- function(payoff.mat, priors, cond.probs, max = FALSE){
  exp.loss <- payoff.mat %*% priors
  joint.probs <- t(apply(cond.probs, 1, function(x) x*priors))
  pred.probs  <- rowSums(joint.probs)
  posterior   <- joint.probs / pred.probs
  
  posterior.exp.losses <- payoff.mat %*% posterior[1,]
  if (dim(posterior)[1] > 1){
    for (i in 2:dim(posterior)[1]){
      ptemp <- payoff.mat %*% posterior[i,]
      posterior.exp.losses <- cbind(posterior.exp.losses, ptemp)
    }
  }
  
  if (max == FALSE){
    loss.PI <- apply(payoff.mat, 2, min) %*% priors
    EVPI <- min(exp.loss) - loss.PI
    predictive.exp.loss <- apply(posterior.exp.losses, 2, min) %*% pred.probs
    EVSI <- min(exp.loss) - predictive.exp.loss
  } else {
    profit.PI <- apply(payoff.mat, 2, max) %*% priors
    EVPI <- profit.PI - max(exp.loss)
    predictive.exp.loss <- apply(posterior.exp.losses, 2, max) %*% pred.probs
    EVSI <- predictive.exp.loss - max(exp.loss)
  }
  return(list("EVPI" = EVPI, "Posterior probs" = posterior,
              "Posterior exp." = posterior.exp.losses,
              "Predictive exp." = predictive.exp.loss, "EVSI" = EVSI))
}

sponsor <- bayes.decision(profit.mat, prior.probs, cond.probs, max = TRUE)
sponsor