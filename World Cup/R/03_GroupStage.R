########################################################
#                  03: GROUP STAGE                     #
#       simulate_group() -> one ranked group table     #
########################################################

source("R/02_Match_Engine.R")   # gives simulate_match(), rate, teams, etc.

simulate_group <- function(group_letter){

  # THIS GROUP'S TEAMS AND FIXTURES ######################
  group_ids     <- teams$team_id[teams$group_letter == group_letter]
  group_matches <- matches[matches$home_team_id %in% group_ids &
                           matches$away_team_id %in% group_ids, ]

  # A FINAL SCORE FOR EVERY MATCH ########################
  group_matches$home_goals <- NA
  group_matches$away_goals <- NA
  for(i in 1:nrow(group_matches)){
    if(group_matches$status[i] == "Completed"){
      group_matches$home_goals[i] <- group_matches$home_score[i]
      group_matches$away_goals[i] <- group_matches$away_score[i]
    } else {
      result <- simulate_match(group_matches$home_team_id[i], group_matches$away_team_id[i])
      group_matches$home_goals[i] <- result["home"]
      group_matches$away_goals[i] <- result["away"]
    }
  }

  # BUILD THE STANDINGS TABLE ############################
  standings <- data.frame(team_id = group_ids, points = 0, gf = 0, ga = 0)
  for(i in 1:nrow(group_matches)){
    h  <- group_matches$home_team_id[i]
    a  <- group_matches$away_team_id[i]
    hg <- group_matches$home_goals[i]
    ag <- group_matches$away_goals[i]

    hrow <- which(standings$team_id == h)
    arow <- which(standings$team_id == a)

    standings$gf[hrow] <- standings$gf[hrow] + hg
    standings$ga[hrow] <- standings$ga[hrow] + ag
    standings$gf[arow] <- standings$gf[arow] + ag
    standings$ga[arow] <- standings$ga[arow] + hg

    if(hg > ag){
      standings$points[hrow] <- standings$points[hrow] + 3
    } else if(ag > hg){
      standings$points[arow] <- standings$points[arow] + 3
    } else {
      standings$points[hrow] <- standings$points[hrow] + 1
      standings$points[arow] <- standings$points[arow] + 1
    }
  }
  standings$gd <- standings$gf - standings$ga

  # SORT: points -> goal difference -> goals scored ######
  standings <- standings[order(-standings$points, -standings$gd, -standings$gf), ]

  return(standings)
}
