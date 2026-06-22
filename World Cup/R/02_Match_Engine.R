#02: MATCH ENGINE
#Poisson GLM for goals + simulate_match() function

source("R/00_setup.R")   # loads teams, matches, etc.

# THE IDEA
# A team's goals depend on its own strength (Elo) and the
# opponent's strength. We fit a Poisson model of goals on
# Elo, then draw random scorelines from it.

# DATA PREP
# Keep only matches that have actually been played
completed <- matches[matches$status == "Completed", ]
nrow(completed)                       # check: should be 28

# Attach each side's Elo rating
completed$home_elo <- teams$elo_rating[match(completed$home_team_id, teams$team_id)]
completed$away_elo <- teams$elo_rating[match(completed$away_team_id, teams$team_id)]

# Reshape to one row per team per match (home view stacked on away view)
home_view <- data.frame(goals   = completed$home_score,
                        own_elo = completed$home_elo,
                        opp_elo = completed$away_elo,
                        home    = 1)

away_view <- data.frame(goals   = completed$away_score,
                        own_elo = completed$away_elo,
                        opp_elo = completed$home_elo,
                        home    = 0)

long_table <- rbind(home_view, away_view)
nrow(long_table)                      # check: should be 56

# FIT THE MODEL
rate <- glm(goals ~ own_elo + opp_elo + home, family = poisson(), data = long_table)
summary(rate)

# QUICK TEST OF THE METHOD
# Strong side (eloA) should have a higher expected count than the weak side (eloB)
eloA <- 2120
eloB <- 1640
lambda_A <- predict(rate, newdata = data.frame(own_elo = eloA, opp_elo = eloB, home = 1), type = "response")
lambda_B <- predict(rate, newdata = data.frame(own_elo = eloB, opp_elo = eloA, home = 0), type = "response")
cat(rpois(1, lambda_A), "-", rpois(1, lambda_B), "\n")

# THE MATCH ENGINE
# Input: two team ids.  Output: a simulated scoreline.
simulate_match <- function(home_id, away_id){

  # Look up each team's Elo
  elo_home <- teams$elo_rating[match(home_id, teams$team_id)]
  elo_away <- teams$elo_rating[match(away_id, teams$team_id)]

  # Expected goals for each side
  lambda_home <- predict(rate, newdata = data.frame(own_elo = elo_home, opp_elo = elo_away, home = 1), type = "response")
  lambda_away <- predict(rate, newdata = data.frame(own_elo = elo_away, opp_elo = elo_home, home = 0), type = "response")

  # Draw an actual scoreline
  goals_home <- rpois(1, lambda_home)
  goals_away <- rpois(1, lambda_away)

  return(c(home = goals_home, away = goals_away))
}
