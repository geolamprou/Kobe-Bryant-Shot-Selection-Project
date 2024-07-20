import pandas as pd
import numpy as np
import seaborn as sns 
import matplotlib.pyplot as plt

import statsmodels.api as sm 
from scipy.stats import chi2_contingency
from scipy.stats import fisher_exact

import dataProcess
import featureVisualization
import DataCleaning

class InferStats(object):
    def __init__(self,df):
        self.df = df


    """Statistical test to determine if some columns is usefull for predictions."""
    def chi_square(self,feature):

        contingency_table = pd.crosstab(self.df[feature], self.df['shot_made_flag'])

        chi2, p, dof, expected = chi2_contingency(contingency_table)


        print(f"Chi-Square Statistic: {chi2}")
        print(f"P-Value: {p}")
        print(f"Degrees of Freedom: {dof}")

    """Fisher Test to detrmine the usefull categorical features."""
    def fisher_test(self, feature):
        # Statistical test to determine if some columns is usefull for predictions.
        # Apply fisher test.
        contingency_table = pd.crosstab(self.df['playoffs'], self.df['shot_made_flag'])
        # Perform Fisher's Exact Test
        oddsratio, p_value = fisher_exact(contingency_table)

        print(f"Odds Ratio: {oddsratio}")
        print(f"P-Value: {p_value}")
    
    """ Logistic Regessiong Test to determine which featurs are usefull predictors"""
    def logistic_regression(self, features):
        self.df['shot_made_flag'] = self.df['shot_made_flag'].astype(float)
        for feature in features:
            self.df[feature] = self.df[feature].astype(float)

        X = self.df[features]

        y = self.df['shot_made_flag']

        # Adding a constant (intercept) to the predictor variables
        X = sm.add_constant(X)

        # Fitting a logistic regression model
        log_reg = sm.Logit(y, X).fit()  

        # Printing the summary of the logistic regression model
        print(log_reg.summary())          
        print(log_reg.aic)