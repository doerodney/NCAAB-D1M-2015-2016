setwd("c:/github/doerodney/NCAAB-D1M-2015-2016")

df = read.csv("dataframe.csv", header=TRUE)

summary(df)

# margin of victory
# df$mov = df$win_points_scored - df$loss_points_scored

model = lm(win_points_scored ~
	win_conference + 
	win_possessions + 
	win_offensive_rating + 
	win_defensive_rating + 
	win_personal_fouls + 
	loss_conference + 
	loss_possessions + 
	loss_offensive_rating + 
	loss_defensive_rating + 
	loss_defensive_rebounds + 
	loss_steals + 
	loss_blocked_shots + 
	loss_personal_fouls,
	data=df)

# remove low contributors
plotFit <- function(yObserved, yFitted, intercept=0) {
  plot(yObserved, yFitted, xlab="Actual", ylab="Predicted")
  abline(intercept, 1, lty=2, col=rgb(1,0,0))
}

plotFit(df$win_points_scored, fitted(model))


getGamePossessionRange <- function(df, teamName, opponentName) {
    teamPossessions <- getPossessions(df, teamName)
    opponentPossessions <- getPossessions(df, opponentName)
    
    possessions <- sort(c(teamPossessions, opponentPossessions))
    
    possessionRange <- seq(min(possessions), max(possessions))
    
    return(possessionRange)
}  


getPossessions <- function(df, teamName) {
    df <- as.data.frame(df)
    Possessions <- c(df$win_possessions[which(df$win_team == teamName)],
                     df$loss_possessions[which(df$loss_team == teamName)])
    return(Possessions)
}


getOffensiveRatings <- function(df, teamName) {
    df <- as.data.frame(df)
    OffensiveRatings <- c(df$win_offensive_rating[which(df$win_team == teamName)],
                          df$loss_offensive_rating[which(df$loss_team == teamName)])
    return(OffensiveRatings)
}


getDefensiveRatings <- function(df, teamName) {
    df <- as.data.frame(df)
    DefensiveRatings <- c(df$win_defensive_rating[which(df$win_team == teamName)],
                          df$loss_defensive_rating[which(df$loss_team == teamName)])
    return(DefensiveRatings)
}


getDefensiveRebounds <- function(df, teamName) {
    df <- as.data.frame(df)
    DefensiveRebounds <- c(df$win_defensive_rebounds[which(df$win_team == teamName)],
                              df$loss_defensive_rebounds[which(df$loss_team == teamName)])
    return(DefensiveRebounds)
}


getPersonalFouls <- function(df, teamName) {
    df <- as.data.frame(df)
    PersonalFouls <- c(df$win_personal_fouls[which(df$win_team == teamName)],
                       df$loss_personal_fouls[which(df$loss_team == teamName)])
    return(PersonalFouls)
}


getSteals <- function(df, teamName) {
    df <- as.data.frame(df)
    Steals <- c(df$win_steals[which(df$win_team == teamName)],
                df$loss_steals[which(df$loss_team == teamName)])
    return(Steals)
}


getBlockedShots <- function(df, teamName) {
    df <- as.data.frame(df)
    BlockedShots <- c(df$win_blocked_shots[which(df$win_team == teamName)],
                      df$loss_blocked_shots[which(df$loss_team == teamName)])
    return(BlockedShots)
}


getTeamConference <- function(df, teamName) {
    df <- as.data.frame(df)
  
    TeamConferences = df$win_conference[which(df$win_team == teamName)]
    if (length(TeamConferences) == 0) {
        TeamConferences = df$loss_conference[which(df$loss_team == teamName)]
    }
    return(as.character(TeamConferences[1]))
}


predictWinner <- function(teamName, opponentName, df, model, nScenarios=10000)
{
  gamePossessionRange = getGamePossessionRange(df, teamName, opponentName)    
    
  teamConference = getTeamConference(df, teamName)
  teamOffensiveRatings = getOffensiveRatings(df, teamName)
  teamDefensiveRatings = getDefensiveRatings(df, teamName)
  teamDefensiveRebounds  = getDefensiveRebounds(df, teamName)
  teamSteals = getSteals(df, teamName)
  teamPersonalFouls = getPersonalFouls(df, teamName)
  teamBlockedShots = getBlockedShots(df, teamName)
  
  opponentConference = getTeamConference(df, opponentName)
  opponentOffensiveRatings = getOffensiveRatings(df, opponentName)
  opponentDefensiveRatings = getDefensiveRatings(df, opponentName)
  opponentDefensiveRebounds  = getDefensiveRebounds(df, opponentName)
  opponentSteals = getSteals(df, opponentName)
  opponentPersonalFouls = getPersonalFouls(df, opponentName)
  opponentBlockedShots = getBlockedShots(df, opponentName)
  
  game_possessions = sample(gamePossessionRange, nScenarios, replace=TRUE)
  
  # Simulate data between the 10th and 90th quantile.
  minQuantile = 0.1
  maxQuantile = 0.9
  
  win_conference = rep(teamConference, nScenarios)
  win_possessions = game_possessions
  
  filtered = quantile(teamOffensiveRatings, c(minQuantile, maxQuantile))
  win_offensive_rating = runif(nScenarios, filtered[[1]], filtered[[2]])
  
  filtered = quantile(teamDefensiveRatings, c(minQuantile, maxQuantile))
  win_defensive_rating = runif(nScenarios, filtered[[1]], filtered[[2]])
  
  win_personal_fouls = sample(min(teamPersonalFouls):max(teamPersonalFouls), nScenarios, replace=TRUE)
  loss_conference = rep(opponentConference, nScenarios)
  loss_possessions = game_possessions
  
  filtered = quantile(opponentOffensiveRatings, c(minQuantile, maxQuantile))
  loss_offensive_rating = runif(nScenarios, filtered[[1]], filtered[[2]])
  
  filtered = quantile(opponentDefensiveRatings, c(minQuantile, maxQuantile))
  loss_defensive_rating = runif(nScenarios, filtered[[1]], filtered[[2]])
  loss_defensive_rebounds = runif(nScenarios, min(opponentDefensiveRebounds), max(opponentDefensiveRebounds))
  loss_steals = sample(min(opponentSteals):max(opponentSteals), nScenarios, replace=TRUE)
  loss_blocked_shots = sample(min(opponentBlockedShots):max(opponentBlockedShots), nScenarios, replace=TRUE)
  
  loss_personal_fouls = sample(min(opponentPersonalFouls):max(opponentPersonalFouls), nScenarios, replace=TRUE)
  
  # Create data frame for team score prediction.
  dfpt = cbind.data.frame(
    win_conference,
    win_possessions,
    win_offensive_rating,
    win_defensive_rating,
    win_personal_fouls,
    loss_conference,
    loss_possessions,
    loss_offensive_rating,
    loss_defensive_rating,
    loss_defensive_rebounds,
    loss_steals,
    loss_blocked_shots,
    loss_personal_fouls
  )
  
  teamPointsScored = round(predict(model, dfpt))
  
  # Create data frame for opponent score prediction.
  # Switch conferences
  x = loss_conference
  loss_conference = win_conference
  win_conference = x
  
  # Switch possessions
  x = loss_possessions
  loss_possessions = win_possessions
  win_possessions = x
  
  # Switch offensive ratings
  x = loss_offensive_rating
  loss_offensive_rating = win_offensive_rating
  win_offensive_rating = x
  
  # Switch defensive ratings
  x = loss_defensive_rating
  loss_defensive_rating = win_defensive_rating
  win_defensive_rating= x
  
  win_personal_fouls = sample(min(opponentPersonalFouls):max(opponentPersonalFouls), nScenarios, replace=TRUE)
  
  loss_defensive_rebounds = runif(nScenarios, min(teamDefensiveRebounds), max(teamDefensiveRebounds))
  loss_steals = sample(min(teamSteals):max(teamSteals), nScenarios, replace=TRUE)
  loss_blocked_shots = sample(min(teamBlockedShots):max(teamBlockedShots), nScenarios, replace=TRUE)
  loss_personal_fouls = sample(min(teamPersonalFouls):max(teamPersonalFouls), nScenarios, replace=TRUE)
  
  dfpo = cbind.data.frame(
    win_conference,
    win_possessions,
    win_offensive_rating,
    win_defensive_rating,
    win_personal_fouls,
    loss_conference,
    loss_possessions,
    loss_offensive_rating,
    loss_defensive_rating,
    loss_defensive_rebounds,
    loss_steals,
    loss_blocked_shots,
    loss_personal_fouls
  )
  
  # Predict opponent points scored.
  opponentPointsScored = round(predict(model, dfpo))
  
  # Make a dataframe of points scored.  Not sure why...
  pointsScored = cbind.data.frame(teamPointsScored, opponentPointsScored)
  
  # Produce/report a result message.
  teamWins = pointsScored$teamPointsScored > pointsScored$opponentPointsScored
  msg = sprintf("%d scenarios of %s versus %s:\n", nScenarios, teamName, opponentName)
  cat(msg)
  nTeamWins = length(which(teamWins == TRUE))
  nOpponentWins = nScenarios - nTeamWins
  margin = numeric(nScenarios)
  xlabel = ''
  ylabel = ''
  x = seq(1:nScenarios)
  win_team_name = ''
  scenarios_won = 0
  if (nTeamWins > nOpponentWins) {
    margin = sort(pointsScored$teamPointsScored - pointsScored$opponentPointsScored)
    
    win_team_name = teamName
    scenarios_won = nTeamWins
  } else {
    margin = sort(pointsScored$opponentPointsScored - pointsScored$teamPointsScored)
    win_team_name = opponentName
    scenarios_won = nOpponentWins
  }
  
  margin.min = min(margin)
  margin.max = max(margin)
  margin.mean = mean(margin)
  margin.sd = sd(margin)
  xlabel = sprintf("%s wins %d scenarios with a mean margin of %4.1f, sd = %5.2f.\n", win_team_name, scenarios_won, margin.mean, margin.sd)
  
  x = seq(margin.min, margin.max, length=1000)
  y = dnorm(x, mean=margin.mean, sd=margin.sd)
  plot(x, y, main=msg, xlab=xlabel, ylab=ylabel, type="l")
  
  abline(v=(mean(margin)))

  cat(xlabel)
  cat("\n")
  
  return(win_team_name)
}
# Run to here...

# RPI = (WP * 0.25) + (OWP * 0.50) + (OOWP * 0.25)

predictBracketWinner<-function(team_list, df, model, nScenarios=10000)
{
  winner = ''
  
  # Preallocate vectors for subsequent rounds.
  quarter_finalist = character(8)
  semi_finalist = character(4)
  finalist = character(2)
  
  if (length(team_list == 16)) {
    cat("\n")
    cat("Round of 16:\n")
    quarter_finalist[1] = predictWinner(team_list[1], team_list[16], df, model, nScenarios) 
    quarter_finalist[2] = predictWinner(team_list[8], team_list[9], df, model, nScenarios)
    quarter_finalist[3] = predictWinner(team_list[5], team_list[12], df, model, nScenarios)
    quarter_finalist[4] = predictWinner(team_list[4], team_list[13], df, model, nScenarios)
    quarter_finalist[5] = predictWinner(team_list[6], team_list[11], df, model, nScenarios)
    quarter_finalist[6] = predictWinner(team_list[3], team_list[14], df, model, nScenarios)
    quarter_finalist[7] = predictWinner(team_list[7], team_list[10], df, model, nScenarios)
    quarter_finalist[8] = predictWinner(team_list[2], team_list[15], df, model, nScenarios)
    
    cat("\n")
    cat("Quarter-finals:\n")
    semi_finalist[1] = predictWinner(quarter_finalist[1], quarter_finalist[2], df, model, nScenarios)
    semi_finalist[2] = predictWinner(quarter_finalist[3], quarter_finalist[4], df, model, nScenarios)
    semi_finalist[3] = predictWinner(quarter_finalist[5], quarter_finalist[6], df, model, nScenarios)
    semi_finalist[4] = predictWinner(quarter_finalist[7], quarter_finalist[8], df, model, nScenarios)
    
    cat("\n")
    cat("Semi-finals:\n")
    finalist[1] = predictWinner(semi_finalist[1], semi_finalist[2], df, model, nScenarios)
    finalist[2] = predictWinner(semi_finalist[3], semi_finalist[4], df, model, nScenarios)
    
    cat("\n")
    cat("Final:\n")
    winner = predictWinner(finalist[1], finalist[2], df, model, nScenarios)
  }
  else {
    winner = sprintf("The team list needs 16 teams.  The supplied list has %d.", length(team_list))
  }
  
  return(winner)
}  


get_east_teams<-function()
{  
  teams = c('villanova-wildcats', 'virginia-cavaliers', 
  'oklahoma-sooners', 'louisville-cardinals',
  'uni-panthers', 'providence-friars',
  'michigan-state-spartans', 'north-carolina-state-wolfpack',
  'lsu-tigers', 'georgia-bulldogs', 
  'dayton-flyers', 'wyoming-cowboys', 
  'uc-irvine-anteaters', 'albany-great-danes', 
  'belmont-bruins', 'lafayette-leopards') 
  
  return(teams)
}  
 
 
get_midwest_teams<-function()
{
  teams = c('kentucky-wildcats', 'kansas-jayhawks', 
  'notre-dame-fighting-irish', 'maryland-terrapins', 
  'west-virginia-mountaineers','butler-bulldogs',  
  'wichita-state-shockers',  'cincinnati-bearcats', 
  'purdue-boilermakers', 'indiana-hoosiers', 
  'texas-longhorns', 'buffalo-bulls', 
  'valparaiso-crusaders', 'northeastern-huskies',
  'new-mexico-state-aggies', 'hampton-pirates')
  
  return(teams)
}


get_south_teams<-function()
{
  teams = c('duke-blue-devils','gonzaga-bulldogs',
  'iowa-state-cyclones', 'georgetown-hoyas',
  'utah-runnin-utes', 'smu-mustangs',
  'iowa-hawkeyes', 'san-diego-state-aztecs',
  'st-johns-red-storm', 'davidson-wildcats',
  'ucla-bruins', 'stephen-f-austin-lumberjacks',
  'eastern-washington-eagles', 'uab-blazers',
  'north-dakota-state-bison', 'robert-morris-colonials')
  
   return(teams)
}


get_west_teams<-function()
{
  teams = c('wisconsin-badgers', 'arizona-wildcats', 
  'baylor-bears', 'north-carolina-tar-heels', 
  'arkansas-razorbacks', 'xavier-musketeers',
  'vcu-rams', 'oregon-ducks',
  'oklahoma-state-cowboys', 'ohio-state-buckeyes',
  'ole-miss-rebels', 'wofford-terriers',
  'harvard-crimson', 'georgia-state-panthers',
  'texas-southern-tigers', 'coastal-carolina-chanticleers')
  
  return(teams)
}


predictTournamentWinner<-function(df, model)
{
	semifinalists = character(4)
	# East
	cat("\n")
    cat("East Bracket Championship:\n")
	teams = get_east_teams()
	semifinalists[1] = predictBracketWinner(teams, df, model)
	
	# Midwest
	cat("\n")
    cat("Midwest Bracket Championship:\n")
	teams = get_midwest_teams()
	semifinalists[2] = predictBracketWinner(teams, df, model)
	
	# West
	cat("\n")
    cat("West Bracket Championship:\n")
	teams = get_west_teams()
	semifinalists[3] = predictBracketWinner(teams, df, model)
	
	# South
	cat("\n")
    cat("South Bracket Championship:\n")
	teams = get_south_teams()
	semifinalists[4] = predictBracketWinner(teams, df, model)
	
	cat("\n")
    cat("Final Four:\n")
	finalists = character(2)
	finalists[1] = predictWinner(semifinalists[1], semifinalists[4], df, model)
	finalists[2] = predictWinner(semifinalists[2], semifinalists[3], df, model)
	cat("\n")
  
  cat("Final Two:\n")
  champion = predictWinner( finalists[1], finalists[2], df, model)
    
}

#---Run from top down to here.--------------------------------




getHomeAwayMarginOfVictory<- function( team_name, df) {
    # Determine indexes that involve team.
	win_index = which(df$win_team == team_name)
	loss_index = which(df$loss_team == team_name)
	
	# What were the win and loss margins?
	win_margin = df$win_points_scored[win_index] - df$loss_points[win_index]
	loss_margin = df$loss_points[loss_index] - df$win_points_scored[loss_index]
	
	# What courts were used?
	win_loss = c('home', 'away')
	win_court = ifelse(df$win_court[win_index] == win_loss[1], win_loss[1], win_loss[2])
	loss_court = ifelse(df$win_court[loss_index] == 'home', win_loss[2], win_loss[1])

	margin = c(win_margin, loss_margin)
	court = c(win_court, loss_court)
	court = as.factor(court)
	df_team = data.frame(margin, court)
	
	return(df_team)
}

getHomeCourtAdvantage <- function( team_name, df) {
	df_team = getHomeAwayMarginOfVictory(team_name, df)
	mdl = aov(margin ~ court, data=df_team)
	
	x = summary.lm(mdl)
	
	home_court_advantage = x$coefficients[1,1] + x$coefficients[2,1]
	probability = x$coefficients[2,4]
	
	alist = list('home_court_advantage'=home_court_advantage,
		'probability'=probability)
		
	return(alist)
}

plotHomeCourtAdvantage <- function( team_name, df) {
	df_team = getHomeAwayMarginOfVictory(team_name, df)
	alist = getHomeCourtAdvantage(team_name, df)
	home_court_advantage = alist$home_court_advantage
	probability = alist$probability
	
	significance = ifelse(probability < 0.05, 'significant', 'not significant')
	
	grand_mean = mean(df_team$margin)
	mean_margin_by_court = tapply(df_team$margin, df_team$court, mean)
	home_mean = mean_margin_by_court['home']
	away_mean = mean_margin_by_court['away']
	title = sprintf("Margin of victory against D1 opponents: %s", team_name)
	# x axis values are just an index.
	x = seq(1, length(df_team$margin))
	
	# Initially plot blanks just to initialize.
	ylabel = sprintf("Home court advantage: %2.0f (%s)", home_court_advantage, significance)
	plot(x, df_team$margin[x], main=title, xlab='game', ylab=ylabel, type='n')
	legend("topright", legend=c('home', 'away'), col=c('green', 'red'), pch=c(17,25))
	
	# Plot the mean lines.
	abline(h=0)
	abline(h=grand_mean)
	abline(h=home_mean, col='green')
	abline(h=away_mean, col='red')
	
	# Get indexes for home and away courts.
	home_index = which(df_team$court == 'home')
	away_index = which(df_team$court == 'away')
	
	# Plot points for home and away indexes.
	points(home_index, df_team$margin[home_index], col='green', pch=17)
	points(away_index, df_team$margin[away_index], col='red', pch=25)
}


plotOffensiveRating <- function( team_name, other_team_name, df) {
	# Get the offensive rating for each team in both win and loss results.
	# Get the relevant rows from the dataframe argument.
	
	# Create a subset dataframe.					  
	dfprime = subset(df, 
		select=c(win_team, win_offensive_rating, loss_team, loss_offensive_rating),
		subset=(win_team == team_name | loss_team == team_name |
		        win_team == other_team_name | loss_team == other_team_name))
	
	# Create labels for the legend.
	team_win_label = sprintf("%s win", team_name)
	team_loss_label = sprintf("%s loss", team_name)
	other_team_win_label = sprintf("%s win", other_team_name)
	other_team_loss_label = sprintf("%s loss", other_team_name)
	title_label = sprintf("Offensive ratings of %s and %s", team_name, other_team_name)
	
	# Plot points for team win and loss indexes.
	team_win_rows = which(dfprime$win_team == team_name)
	team_loss_rows = which(dfprime$loss_team == team_name)
	other_win_rows = which(dfprime$win_team == other_team_name)
	other_loss_rows = which(dfprime$loss_team == other_team_name)
	
	# Create initial plot data.
	x = c(team_win_rows, team_loss_rows, other_win_rows, other_loss_rows) 
	offensive_rating_list = c(
		dfprime$win_offensive_rating[team_win_rows],
		dfprime$loss_offensive_rating[team_loss_rows],
		dfprime$win_offensive_rating[other_win_rows],
		dfprime$loss_offensive_rating[other_loss_rows] )
	
	# Initially plot blanks just to initialize the graph.
	plot(x, offensive_rating_list, main=title_label, xlab='', ylab='offensive_rating', type='n')
	legend("topright", 
			legend=c(team_win_label, team_loss_label, 
			         other_team_win_label, other_team_loss_label), 
			col=c('green', 'red', 'blue', 'orange'), 
			pch=c(2, 6, 3, 4))
	
	points(team_win_rows, dfprime$win_offensive_rating[team_win_rows], col='green', pch=2)
	points(team_loss_rows, dfprime$loss_offensive_rating[team_loss_rows], col='red', pch=6)
	points(other_win_rows, dfprime$win_offensive_rating[other_win_rows], col='blue', pch=3)
	points(other_loss_rows, dfprime$loss_offensive_rating[other_loss_rows], col='red', pch=4)
}

plotDefensiveRating <- function( team_name, other_team_name, df) {
	# Get the defensive rating for each team in both win and loss results.
	# Get the relevant rows from the dataframe argument.
	# Create a subset dataframe.					  
	dfprime = subset(df, 
		select=c(win_team, win_defensive_rating, loss_team, loss_defensive_rating),
		subset=(win_team == team_name | loss_team == team_name |
		        win_team == other_team_name | loss_team == other_team_name))
	
	# Create labels for the legend.
	team_win_label = sprintf("%s win", team_name)
	team_loss_label = sprintf("%s loss", team_name)
	other_team_win_label = sprintf("%s win", other_team_name)
	other_team_loss_label = sprintf("%s loss", other_team_name)
	title_label = sprintf("Defensive ratings of %s and %s", team_name, other_team_name)
	
	# Plot points for team win and loss indexes.
	team_win_rows = which(dfprime$win_team == team_name)
	team_loss_rows = which(dfprime$loss_team == team_name)
	other_win_rows = which(dfprime$win_team == other_team_name)
	other_loss_rows = which(dfprime$loss_team == other_team_name)
	
	# Create initial plot data.
	x = c(team_win_rows, team_loss_rows, other_win_rows, other_loss_rows) 
	defensive_rating_list = c(
		dfprime$win_defensive_rating[team_win_rows],
		dfprime$loss_defensive_rating[team_loss_rows],
		dfprime$win_defensive_rating[other_win_rows],
		dfprime$loss_defensive_rating[other_loss_rows] )
	
	# Initially plot blanks just to initialize the graph.
	plot(x, defensive_rating_list, main=title_label, xlab='', ylab='defensive_rating', type='n')
	legend("topright", 
			legend=c(team_win_label, team_loss_label, 
			         other_team_win_label, other_team_loss_label), 
			col=c('green', 'red', 'blue', 'orange'), 
			pch=c(2, 6, 3, 4))
	
	points(team_win_rows, dfprime$win_defensive_rating[team_win_rows], col='green', pch=2)
	points(team_loss_rows, dfprime$loss_defensive_rating[team_loss_rows], col='red', pch=6)
	points(other_win_rows, dfprime$win_defensive_rating[other_win_rows], col='blue', pch=3)
	points(other_loss_rows, dfprime$loss_defensive_rating[other_loss_rows], col='red', pch=4)
}


# Bracket couples:
# 1-16
# 8-9
# 5-12
# 4-13
# 6-11
# 3-14
# 7-10
# 2-15



test_predictions<-function(game_date, data_date, df) 
{
   dfprime = df[which(df$date <= data_date), ]
   mprime = lm(win_points_scored ~
                 win_conference + 
                 win_possessions + 
                 win_offensive_rating + 
                 win_defensive_rating + 
                 win_personal_fouls + 
                 loss_conference + 
                 loss_possessions + 
                 loss_offensive_rating + 
                 loss_defensive_rating + 
                 loss_defensive_rebounds + 
                 loss_steals + 
                 loss_blocked_shots + 
                 loss_personal_fouls,
                 data=dfprime)
   win_team_list = df$win_team[which(df$date == game_date)]
   loss_team_list = df$loss_team[which(df$date == game_date)]
   
   game_count = length(win_team_list)
   
   correct_count = 0
   for (i in 1:game_count) {
     win_team = as.character(win_team_list[i])
     loss_team = as.character(loss_team_list[i])
     predicted_win_team = predictWinner(win_team, loss_team, dfprime, mprime)
     if (predicted_win_team == win_team) {
       correct_count = correct_count + 1
     }
   }
   
   sprintf("%d correct out of %d for %d using data from %d.", 
           correct_count, game_count, game_date, data_date)
}

