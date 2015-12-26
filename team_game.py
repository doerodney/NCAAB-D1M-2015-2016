class TeamGame:
    def __init__(self):
        self.__team = ''
        self.__conference = ''
        self.__game_key = ''
        self.__game_date = ''
        self.__home_court = False
        self.__neutral_court = True
        self.__minutes_played = 0
        self.__three_pointers_attempted = 0
        self.__three_pointers_made = 0
        self.__field_goals_attempted = 0
        self.__field_goals_made = 0
        self.__free_throws_attempted = 0
        self.__free_throws_made = 0
        self.__offensive_rebounds = 0
        self.__defensive_rebounds = 0
        self.__total_rebounds = 0
        self.__assists = 0
        self.__turnovers = 0
        self.__steals = 0
        self.__blocked_shots = 0
        self.__personal_fouls = 0
        self.__points_scored = 0

        # These are estimated parameters
        self.__possessions = 0
        self.__offensive_rating = 0
        self.__defensive_rating = 0
        self.__effective_field_goal_percentage = 0

        # This comes from the other team.
        self.__points_allowed = 0

    def get_common_report_string(self):
        # Prevent division by zero.
        free_throw_fraction = 0.0
        field_goal_fraction = 0.0
        three_point_fraction = 0.0

        if self.free_throws_attempted > 0:
            free_throw_fraction = float(self.free_throws_made) / float(self.free_throws_attempted)

        if self.field_goals_attempted > 0:
            field_goal_fraction = float(self.field_goals_made) / float(self.field_goals_attempted)

        if self.three_pointers_attempted > 0:
            three_point_fraction = float(self.three_pointers_made) / float(self.three_pointers_attempted)

        common_report_string = '"%s","%s",%3.0f,%s,%6.2f,%6.2f,%4.2f,%4.2f,%4.2f,%s,%s,%s,%s,%s' % \
                               (self.team, self.conference,
                                self.possessions,
                                str(self.points_scored),
                                self.__offensive_rating,
                                self.__defensive_rating,
                                field_goal_fraction,
                                three_point_fraction,
                                free_throw_fraction,
                                str(self.offensive_rebounds),
                                str(self.defensive_rebounds),
                                str(self.steals),
                                str(self.blocked_shots),
                                str(self.personal_fouls)
                               )

        return common_report_string

    @property
    def team(self):
        return self.__team

    @team.setter
    def team(self, value):
        self.__team = value

    @property
    def conference(self):
        return self.__conference

    @conference.setter
    def conference(self, value):
        self.__conference = value

    @property
    def home_court(self):
        return self.__home_court

    @home_court.setter
    def home_court(self, value):
        self.__home_court = value

    @property
    def neutral_court(self):
        return self.__neutral_court

    @neutral_court.setter
    def neutral_court(self, value):
        self.__neutral_court = value

    @property
    def game_key(self):
        return self.__game_key

    @game_key.setter
    def game_key(self, value):
        self.__game_key = value
        
    @property
    def game_date(self):
        return self.__game_date

    @game_date.setter
    def game_date(self, value):
        self.__game_date = value

    @property
    def three_pointers_attempted(self):
        return self.__three_pointers_attempted

    @three_pointers_attempted.setter
    def three_pointers_attempted(self, value):
        self.__three_pointers_attempted = value

    @property
    def three_pointers_made(self):
        return self.__three_pointers_made

    @three_pointers_made.setter
    def three_pointers_made(self, value):
        self.__three_pointers_made = value
        
    @property
    def field_goals_made(self):
        return self.__field_goals_made

    @field_goals_made.setter
    def field_goals_made(self, value):
        self.__field_goals_made = value

    @property
    def field_goals_attempted(self):
        return self.__field_goals_attempted

    @field_goals_attempted.setter
    def field_goals_attempted(self, value):
        self.__field_goals_attempted = value
        
    @property
    def free_throws_attempted(self):
        return self.__free_throws_attempted

    @free_throws_attempted.setter
    def free_throws_attempted(self, value):
        self.__free_throws_attempted = value
        
    @property
    def free_throws_made(self):
        return self.__free_throws_made

    @free_throws_made.setter
    def free_throws_made(self, value):
        self.__free_throws_made = value
        
    @property
    def offensive_rebounds(self):
        return self.__offensive_rebounds

    @offensive_rebounds.setter
    def offensive_rebounds(self, value):
        self.__offensive_rebounds = value
        
    @property
    def defensive_rebounds(self):
        return self.__defensive_rebounds

    @defensive_rebounds.setter
    def defensive_rebounds(self, value):
        self.__defensive_rebounds = value
    
    @property
    def total_rebounds(self):
        return self.__total_rebounds

    @total_rebounds.setter
    def total_rebounds(self, value):
        self.__total_rebounds = value

    @property
    def assists(self):
        return self.__assists

    @assists.setter
    def assists(self, value):
        self.__assists = value
        
    @property
    def turnovers(self):
        return self.__turnovers

    @turnovers.setter
    def turnovers(self, value):
        self.__turnovers = value 
        
    @property
    def steals(self):
        return self.__steals

    @steals.setter
    def steals(self, value):
        self.__steals = value    
        
    @property
    def blocked_shots(self):
        return self.__blocked_shots

    @blocked_shots.setter
    def blocked_shots(self, value):
        self.__blocked_shots = value  
        
    @property
    def personal_fouls(self):
        return self.__personal_fouls

    @personal_fouls.setter
    def personal_fouls(self, value):
        self.__personal_fouls = value  
        
    @property
    def points_scored(self):
        return self.__points_scored

    @points_scored.setter
    def points_scored(self, value):
        self.__points_scored = value

    @property
    def points_allowed(self):
        return self.__points_allowed

    @points_allowed.setter
    def points_allowed(self, value):
        self.__points_allowed = value

    @property
    def possessions(self):
        return self.__possessions

    def estimate_possessions(self):
        # http://en.wikipedia.org/wiki/APBRmetrics
        # Possessions = 0.96 * (FGA - OffReb + TO + (0.475 * FTA))
        field_goals_attempted = self.field_goals_attempted
        offensive_rebounds = self.offensive_rebounds
        turnovers = self.turnovers
        free_throws_attempted = self.free_throws_attempted
        self.__possessions = 0.96 * (field_goals_attempted -
                                     offensive_rebounds +
                                     turnovers +
                                     (0.475 * free_throws_attempted))

    def set_offensive_rating(self):
        # http://en.wikipedia.org/wiki/APBRmetrics
        # OffensiveRating = Pts Scored * 100 / Possessions
        self.__offensive_rating = self.points_scored * 100 / self.possessions

    def set_defensive_rating(self):
        # http://en.wikipedia.org/wiki/APBRmetrics
        # DefensiveRating = Pts Allowed * 100 / Possessions
        self.__defensive_rating = self.points_allowed * 100 / self.possessions
