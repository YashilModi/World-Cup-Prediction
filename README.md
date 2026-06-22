# Predicting the 2026 FIFA World Cup Winner

A statistical simulation that forecasts the winner of the 2026 FIFA World Cup
from a partially played tournament(only 28 of the 72 group games are
complete) by modelling individual matches, simulating the games that haven't
happened yet, and playing the bracket forward to a champion thousands of times.

## Headline result

Across 10,000 simulated tournaments, Argentina emerges as the highest-rated side most likely champion.

![Championship probabilities](figures/championship_probabilities.png)

## How it works

The prediction is built up in layers:

1. Match engine: a Poisson regression (GLM) learns how team strength (Elo)
   translates into goals, fitted on the completed matches. Drawing from the
   fitted model produces a simulated scoreline for any fixture.
2. Group stage: each group is played to a ranked table, using real scores
   where available and simulated ones otherwise, with proper
   points → goal-difference → goals-scored tie-breakers.
3. Knockout bracket: the 32 qualifiers (12 winners, 12 runners-up, 8 best
   third-placed teams) are drawn into a single-elimination bracket and played
   down to one champion.
4. Monte Carlo: the whole tournament is simulated 10,000 times to estimate
   each team's championship probability.

Four shorter analyses:

- Bootstrap CI for home advantage
- Bootstrap ANOVA of player market value by position
- Logistic regression for whether a player scored
- Bayesian decision theory (EVPI/EVSI) for a sponsor's team choice

## The data

Eight linked tables describing the 48-team, 12-group tournament: team strengths,
group-stage matches (with expected goals), match events, player squads with
market values, referees, venues, and tournament stages.

## Project structure
data/                       # the 8 CSV tables
   R/
      00_setup.R              # load all data
      01_Bootstrap.R          # Module 1.1 - home advantage CI
      02_Match_Engine.R       # Poisson GLM + simulate_match()
      03_GroupStage.R         # simulate_group()
      04_Knockout_Bracket.R   # knockout_match() + bracket
      05_Monte_Carlo.R        # simulate_tournament() + 10,000 runs
      06_ANOVA.R              # Module 1.3 - market value ANOVA
      07_Logistic_GLM.R       # Module 2.3 - did a player score?
      08_Bayesian.R           # Module 3.1 - sponsor decision (EVPI)
   figures/                    # saved plots
   report.Rmd                  # full write-up
   run_all.R                   # runs the whole project end-to-end
   World Cup.Rproj
## How to run

Requirements: R (4.x) and RStudio. The project uses base R only; the
rmarkdown package is needed to knit the report.

1. Open World Cup.Rproj in RStudio
2. Run the prediction pipeline: open R/05_Monte_Carlo.R and run the file.
   It loads the data, fits the model, runs the 10,000 simulations, and saves the
   championship chart to figures/.
3. Run the supporting analyses by sourcing R/01_Bootstrap.R, R/06_ANOVA.R,
   R/07_Logistic_GLM.R, and R/08_Bayesian.R.
4. Knit report.Rmd for the full write-up.

Or simply run run_all.R to do all of the above in one go.
