class PlayerGame:
    def __init__(self):
        self.__player = ''
        self.__school = ''
        self.__game_key = ''
        self.__minutes_played = 0
        self.__three_pointers_taken = 0
        self.__three_pointers_made = 0
        self.__field_goals_taken = 0
        self.__field_goals_made = 0
        self.__free_throws_taken = 0
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

    @property
    def player(self):
        return self.__player

    @player.setter
    def player(self, value):
        self.__player = value

    @property
    def school(self):
        return self.__school

    @school.setter
    def school(self, value):
        self.__school = value

    @property
    def game_key(self):
        return self.__game_key

    @game_key.setter
    def game_key(self, value):
        self.__game_key = value

    @property
    def minutes_played(self):
        return self.__minutes_played

    @minutes_played.setter
    def minutes_played(self, value):
        self.__minutes_played = value

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
    
    def __str__(self):
        pass  # TODO