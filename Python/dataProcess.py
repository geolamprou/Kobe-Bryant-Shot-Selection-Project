import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
import warnings

from sklearn.model_selection import train_test_split
#warnings.filterwarnings('ignore')
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import OneHotEncoder

from DataCleaning import CleanDataFrame

class FeatureEngineering:

    def __init__(self, df):
        self.df = df

    def calculate_time(self):
        """
        Calculate various time-related features for the game.
        """
        # Create a column that tells us how many seconds we have until the end of the period
        self.df['secondsFromPeriodEnd'] = 60 * self.df['minutes_remaining'] + self.df['seconds_remaining']

        # Create a column that returns how many seconds have passed from the start of a quarter
        self.df['secondsFromPeriodStart'] = 60 * (11 - self.df['minutes_remaining']) + (60 - self.df['seconds_remaining'])

        # Calculate the seconds until the end of the game
        self.df['secondsFromGameStart'] = ((self.df['period'] <= 4).astype(int) * (self.df['period'] - 1) * 12 * 60 + 
                                           (self.df['period'] > 4).astype(int) * ((self.df['period'] - 4) * 5 * 60 + 3 * 12 * 60) + 
                                           self.df['secondsFromPeriodStart'])

    def days_from_previous_game(self):
        """
        Calculate the number of days from the previous game.
        """
        # Remove duplicate dates to calculate the difference in days
        unique_dates = self.df['game_date'].drop_duplicates().reset_index(drop=True)
        days_passed = unique_dates.diff().dt.days.fillna(0).astype(int)

        # Create a DataFrame with the unique dates and their corresponding days_passed values
        days_passed_df = pd.DataFrame({'game_date': unique_dates, 'days_passed': days_passed})

        # Merge this DataFrame back to the original DataFrame to assign days_passed to each observation
        self.df = self.df.merge(days_passed_df, on='game_date', how='left')

    def period_matchup(self):
        """
        Modify the period column and extract home/away information from the matchup column.
        """
        # Create a new variable based on the halftime
        self.df['Half_time'] = np.where(self.df['period'] < 2, 'First_half', 
                                        np.where(self.df['period'] > 4, 'Over_Time', 'Second_half'))
        
        # Change the period 5, 6, 7 to Over-time
        self.df['period'] = np.where(self.df['period'] >= 5, 'Over-Time', self.df['period'])       

        # Extract home/away information from the matchup column
        self.df['Court_Advantage'] = np.where(self.df['matchup'].str.contains('@'), 'No', 'Yes')

        # Drop the matchup column
        self.df.drop(['matchup'], axis=1, inplace=True)

    def group_conference(self):
        """
        Group the teams based on their conference.
        """
        western_teams = ['UTA', 'VAN', 'LAC', 'SAS', 'DEN', 'GSW', 'MIN', 'SEA', 'DAL', 'POR', 'PHX', 'MEM', 'NOP', 'NOH', 'OKC']
        
        # Create a lookup dictionary for quick access
        conference_lookup = {team.strip(): 'Western_Conference' for team in western_teams}

        # Function to get conference based on the opponent
        def get_conference(opponent):
            return conference_lookup.get(opponent.strip(), 'Eastern_Conference')

        self.df['conference'] = self.df['opponent'].apply(get_conference)

    def group_division(self):
        """
        Group the teams based on their division.
        """
        divisions = {
            'Atlantic': ['BOS', 'TOR', 'PHI', 'NJN', 'NYK', 'BKN'],
            'Central': ['MIL', 'CLE', 'IND', 'CHI', 'DET'],
            'SouthEast': ['ORL', 'MIA', 'WAS', 'ATL', 'CHA'],
            'NorthWest': ['OKC', 'DEN', 'MIN', 'POR', 'UTA', 'SEA'],
            'Pacific': ['LAC', 'PHX', 'SAC', 'GSW'],
            'SouthWest': ['DAL', 'NOP', 'NOH', 'VAN', 'MEM', 'HOU', 'SAS']    
        }

        # Create a mapping from team to division
        team_to_division = {team: division for division, teams in divisions.items() for team in teams}

        # Map the 'opponent' column to the new 'division' column
        self.df['division'] = self.df['opponent'].map(team_to_division)

    def group_seasons(self):
        """
        Group the seasons into broader periods.
        """
        seasons_group = {
            '1996-00': ['1996-97', '1997-98', '1998-99', '1999-00'],
            '2000-04': ['2000-01', '2001-02', '2002-03', '2003-04'],
            '2004-08': ['2004-05', '2005-06', '2006-07', '2007-08'],
            '2008-12': ['2008-09', '2009-10', '2010-11', '2011-12'],
            '2012-16': ['2012-13', '2013-14', '2014-15', '2015-16']
        }

        # Create a mapping for the grouped seasons
        group_seasons = {season: period for period, seasons in seasons_group.items() for season in seasons}
        
        self.df['group_seasons'] = self.df['season'].map(group_seasons)

    def data_process(self):
        """
        Process the data by applying all feature engineering methods.
        """
        self.calculate_time()
        self.days_from_previous_game()
        self.period_matchup()
        self.group_conference()
        self.group_division()
        self.group_seasons()

        # Additional feature
        self.df['number'] = np.sqrt(np.abs(self.df['lat']) * np.abs(self.df['lon']))

        return self.df 



class DataPreparation(object):

    def __init__(self, df):
        self.df = df

    """ A function that split into dependent and independent variables."""
    def data_preparation(self, categories,categorical_features):
        # Independent variable
        X = self.df.drop(categories, axis=1)

        # Ensure categorical columns are treated as object type
        X[categorical_features] = X[categorical_features].astype(str)
        # Dependent variable
        y = self.df['shot_made_flag']

        X_dummies = pd.get_dummies(X, columns=categorical_features, drop_first=True)

        return X_dummies, y
    
    def split_data(self, X_dummies, y, size ):
        
        X_train, X_test, y_train, y_test = train_test_split(X_dummies, y, random_state=42, train_size=size)
        return X_train, X_test, y_train, y_test

    