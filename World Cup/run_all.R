#RUN ALL
#Reproduce the whole project from start to finish
#(open World Cup.Rproj first, then Source this)

# --- Prediction pipeline ---------------------------------------------------
# Sourcing 05 chains back through 04 -> 03 -> 02 -> 00, so this single line
# loads the data, fits the Poisson model, runs the 10,000 simulations, and
# saves the championship chart to figures/.  (Takes a minute or two.)
source("R/05_Monte_Carlo.R")

# --- Supporting analyses ---------------------------------------------------
source("R/01_Bootstrap.R")      # Module 1.1 - home advantage CI
source("R/06_ANOVA.R")          # Module 1.3 - market value by position
source("R/07_Logistic_GLM.R")   # Module 2.3 - did a player score?
source("R/08_Bayesian.R")       # Module 3.1 - sponsor decision (EVPI)

# --- Final report ----------------------------------------------------------
# Knits report.Rmd to HTML.  Needs the rmarkdown package installed.
rmarkdown::render("report.Rmd")

cat("\nDone. See figures/championship_probabilities.png and report.html\n")