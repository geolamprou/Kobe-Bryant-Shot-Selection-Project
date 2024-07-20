import pandas as pd
import numpy as np
import warnings

warnings.filterwarnings('ignore')

class CleanDataFrame(object):
    datafile = 'data.csv'

    def __init__(self, datadir = r'C:\Users\dimit\OneDrive\Desktop\my_work_git\kobe_bryant_shot_selection'):
        self.datadir = datadir
    
    # Create a module that reads the dataframe.
    def read_dataframe(self):
        # Read the dataframe
        self.df = pd.read_csv(f'{self.datadir}/{self.datafile}',  index_col='shot_id')

        # Columns to drop 
        drop_columns = ['game_event_id','team_id', 'team_name','game_id', 'action_type']
        # Drop some unnecessary columns
        self.df.drop(drop_columns, axis=1, inplace=True)

    # Create a function that changes the data type of some columns
    def data_type_change(self, df):
        
        #Change the game_date to datetime format
        df['game_date'] = pd.to_datetime(df['game_date'])

        # Chagne the period to categorical variable.
        df['period'] = df['period'].astype('object')

        # Change the playoff to categorical
        df['playoffs'] = df['playoffs'].astype('object')

        # Shot made flag to categorical
        df['shot_made_flag'] = df['shot_made_flag'].astype('object')        

        return df
        
    
    # Create a module that cleans the dataframe.
    def clean_data(self):
        self.read_dataframe()

        # Check for duplicates and missing values.
        duplicates = self.df.duplicated()

        if duplicates.any():
            print("We have duplicate values.\n")
        else:
            print("We don't have duplicate values.\n")

        # Check for missing values
        if self.df.isna().any().any():
            print("We have missing values.\nWe need to handle this")
        else:
            print("We don't have missing values.")
        
        # We have missing values. This missing values is in the target variable.
        # So now we will create the final test set, that our algorithm will be applied to.
        test_df = self.df[self.df['shot_made_flag'].isnull()]

        # By dropping the null values we will create the training test.
        train_df = self.df.dropna()

        # Change data types
        train_df = self.data_type_change(train_df)
        test_df = self.data_type_change(test_df)
    
        return train_df, test_df
    


if __name__ == "__main__":
    df_cleaner = CleanDataFrame()
    train_df, test_df = df_cleaner.clean_data()
    print(train_df.info())
    print(test_df.info())
