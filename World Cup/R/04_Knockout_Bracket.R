########################################################
#               04: KNOCKOUT BRACKET                   #
#    Qualifiers -> single elimination -> champion      #
########################################################

source("R/03_GroupStage.R")

# PLAY ALL 12 GROUPS #####################################
group_letters <- LETTERS[1:12]
winners    <- c()
runners_up <- c()
thirds     <- data.frame()
for(g in group_letters){
  tbl <- simulate_group(g)
  winners    <- c(winners,    tbl$team_id[1])
  runners_up <- c(runners_up, tbl$team_id[2])
  thirds     <- rbind(thirds, tbl[3, ])
}

# 8 BEST THIRD-PLACED TEAMS ##############################
thirds      <- thirds[order(-thirds$points, -thirds$gd, -thirds$gf), ]
best_thirds <- thirds$team_id[1:8]

# ASSEMBLE THE 32-TEAM BRACKET ###########################
qualifiers <- c(winners, runners_up, best_thirds)   # 32 teams
bracket    <- sample(qualifiers)                     # draw into bracket order

# ONE KNOCKOUT MATCH -> A WINNER #########################
knockout_match <- function(home_id, away_id){
  score <- simulate_match(home_id, away_id)
  if(score["home"] > score["away"]){
    return(home_id)
  } else if(score["away"] > score["home"]){
    return(away_id)
  } else {
    return(sample(c(home_id, away_id), 1))   # draw -> shootout (coin flip)
  }
}

# PLAY THE ROUNDS DOWN TO ONE TEAM #######################
remaining <- bracket
while(length(remaining) > 1){
  next_round <- c()
  for(j in seq(1, length(remaining), by = 2)){
    next_round <- c(next_round, knockout_match(remaining[j], remaining[j + 1]))
  }
  remaining <- next_round
}
champion <- remaining[1]
champion
