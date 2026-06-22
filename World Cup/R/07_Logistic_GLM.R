#DID A PLAYER SCORE? (LOGISTIC REGRESSION)

source("R/00_setup.R")

# 1: Build the response and predictors
# Response: did the player score at least one goal?
players$scored <- ifelse(players$goals > 0, 1, 0)

# Age (years) at the tournament, from date of birth
players$age <- as.numeric(difftime(as.Date("2026-06-01"),
                                   as.Date(players$date_of_birth),
                                   units = "days")) / 365.25

# Position as a categorical predictor
players$position <- factor(players$position)

# 2: Fit the logistic regression
res = glm(scored ~ position + market_value_eur + caps + age,
          family = binomial(link = "logit"), data = players)
summary(res)

# 3: Odds ratios (easier to read than log-odds)
exp(coefficients(res))

# 4: Classify, then build a confusion matrix
preds <- ifelse(fitted(res) > 0.5, 1, 0)
table(preds, players$scored)