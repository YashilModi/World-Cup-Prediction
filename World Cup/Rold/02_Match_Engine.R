#Step1: Write down the idea first: a team's goals depend on its own attack strength and the opponent's defence strength (plus an overall scoring level).
source("R/00_setup.R")   # loads teams, matches, etc.
completed <- matches[matches$status == "Completed",]# "matches$status == "Completed"" gives T or F
                                                    #"," shows the rest of the coloumns
nrow(completed)   # check: should print 28
completed$home_elo <- teams$elo_rating[match(completed$home_team_id, teams$team_id)]
completed$away_elo <- teams$elo_rating[match(completed$away_team_id, teams$team_id)]
home_view <- data.frame(
  goals   = completed$home_score,   # the home team's goals
  own_elo = completed$home_elo,   # the home team's own elo
  opp_elo = completed$away_elo,   # the opponent's (away) elo
  home    = 1
)

away_view <- data.frame(
  goals   = completed$away_score,  
  own_elo = completed$away_elo,
  opp_elo = completed$home_elo,
  home    = 0
)
#Step 2: From the completed matches, work out a measure of each team's attacking and defending strength. (Elo can be a starting proxy; the goals data lets you do better.)
long_table <- rbind(home_view, away_view)   # stack them
nrow(long_table)   # check: should print 56
rate<-glm(goals~own_elo + opp_elo + home,family = poisson(), data=long_table)
summary(rate)
#Step 3: Turn two teams into two expected-goal numbers — one for each side (call them the team's "rate").
#eloA<-2120
#eloB<-1640
#Check: lambda_A>lambda_B
lambda_A<-predict(rate,newdata = data.frame(own_elo = eloA, opp_elo = eloB, home = 1),
                  type = "response") #"repsonse" use to give actual expected number of goals rather than model's log scale

lambda_B<-predict(rate, newdata = data.frame(own_elo = eloB, opp_elo = eloA, home = 0),
                  type = "response")

#Step 4: Turn an expected-goal number into an actual goal count by drawing a random number from a count distribution.
random_goalA<-rpois(1, lambda_A)   # one random goal count for team A
random_goalB<-rpois(1, lambda_B)
cat(random_goalA,"-",random_goalB,"\n")

#Step 5:Wrap the two steps above into one function: input = two teams, output = a scoreline like 2–1.
simulate_match<-function(home_id,away_id){
  # 1. look up each team's Elo
  elo_home <- teams$elo_rating[match(home_id, teams$team_id)]
  elo_away <- teams$elo_rating[match(away_id, teams$team_id)]
  
  # 2. expected goals for each side  (your step 3 predict lines)
  lambda_home <- predict(rate,
                         newdata = data.frame(own_elo = elo_home, opp_elo = elo_away, home = 1),
                         type = "response")
  lambda_away <- predict(rate,
                         newdata = data.frame(own_elo = elo_away, opp_elo = elo_home, home = 0),
                         type = "response")
  
  # 3. draw an actual scoreline  (your step 4 rpois lines)
  goals_home <- rpois(1, lambda_home)
  goals_away <- rpois(1, lambda_away)
  
  # 4. hand back the result
  return(c(home = goals_home, away = goals_away))
}
