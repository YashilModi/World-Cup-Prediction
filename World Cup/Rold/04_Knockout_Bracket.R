#Goal: from all 12 groups, build the Round of 32 and play it down to one champion(knockout bracket)
source("R/03_GroupStage.R")
# Step 1: play all 12 groups, collect winners / runners-up / thirds
group_letters <- LETTERS[1:12]
winners    <- c()
runners_up <- c()
thirds     <- data.frame()
for (g in group_letters) {
  table <- simulate_group(g)
  winners    <- c(winners,    table$team_id[1])
  runners_up <- c(runners_up, table$team_id[2])
  thirds     <- rbind(thirds, table[3, ])
}

# Step 2: keep the 8 best third-placed teams
thirds <- thirds[order(-thirds$points, -thirds$gd, -thirds$gf), ]
best_thirds <- thirds$team_id[1:8]

# Step 3: assemble the 32 qualifiers into a bracket
qualifiers <- c(winners, runners_up, best_thirds)   # 32 teams
bracket <- sample(qualifiers)                        # draw into bracket order

# Step 4: play one knockout match, return the WINNER (not a scoreline)
knockout_match <- function(home_id, away_id) {
  score <- simulate_match(home_id, away_id)
  if (score["home"] > score["away"]) {
    return(home_id)
  } else if (score["away"] > score["home"]) {
    return(away_id)
  } else {
    return(sample(c(home_id, away_id), 1))   # draw → shootout (coin flip)
  }
}

# Step 5: play the rounds, halving until one team is left
remaining <- bracket
while (length(remaining) > 1) {
  next_round <- c()
  for (j in seq(1, length(remaining), by = 2)) {
    w <- knockout_match(remaining[j], remaining[j + 1])
    next_round <- c(next_round, w)
  }
  remaining <- next_round
}

# Step 6: the champion of this one simulated tournament
champion <- remaining[1]
champion