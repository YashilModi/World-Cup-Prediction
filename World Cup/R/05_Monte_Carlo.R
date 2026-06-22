########################################################
#                 05: MONTE CARLO                      #
#   Many simulated tournaments -> win probabilities    #
########################################################

source("R/04_Knockout_Bracket.R")

# ONE WHOLE TOURNAMENT -> A CHAMPION #####################
simulate_tournament <- function(){

  winners    <- c()
  runners_up <- c()
  thirds     <- data.frame()
  for(g in LETTERS[1:12]){
    tbl <- simulate_group(g)
    winners    <- c(winners,    tbl$team_id[1])
    runners_up <- c(runners_up, tbl$team_id[2])
    thirds     <- rbind(thirds, tbl[3, ])
  }
  thirds      <- thirds[order(-thirds$points, -thirds$gd, -thirds$gf), ]
  best_thirds <- thirds$team_id[1:8]
  bracket     <- sample(c(winners, runners_up, best_thirds))

  remaining <- bracket
  while(length(remaining) > 1){
    next_round <- c()
    for(j in seq(1, length(remaining), by = 2)){
      next_round <- c(next_round, knockout_match(remaining[j], remaining[j + 1]))
    }
    remaining <- next_round
  }
  return(remaining[1])
}

# RUN THE SIMULATION MANY TIMES ##########################
set.seed(2026)
n_sims    <- 1000
champions <- numeric(n_sims)
for(s in 1:n_sims){
  champions[s] <- simulate_tournament()
}

# COUNTS -> PROBABILITIES ################################
probs      <- sort(table(champions) / n_sims, decreasing = TRUE)
prob_table <- data.frame(team = teams$team_name[match(as.integer(names(probs)), teams$team_id)],
                         prob = round(as.numeric(probs), 3))
head(prob_table, 15)

# BAR CHART OF THE TOP 15 ################################
top15 <- head(prob_table, 15)
png("figures/championship_probabilities.png", width = 900, height = 600)
par(mar = c(5, 9, 4, 2))                   # wider left margin for team names
barplot(rev(top15$prob),                   # rev() puts the biggest bar at the top
        names.arg = rev(top15$team),
        horiz = TRUE,
        las   = 1,
        col   = "steelblue",
        xlab  = "Championship probability",
        main  = "Predicted 2026 World Cup winner")
dev.off()
