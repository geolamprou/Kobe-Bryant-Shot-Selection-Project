# Kobe Bryant Shot Selecection Project

## Introduction

Without any doubt, Kobe Bryant was one of the greatest basketball players of all time! In his twenty-year professional career with the Los Angeles Lakers, Kobe Bryant took a total of **35,697 shots** and scored **33,643 points.**. The purpose of this analysis is to analyze Kobe's shots and find which parameters are significant about whether a shot is successful or unsuccessful.

The data came from a dataset on Kaggle named: "Kobe Bryant Shot Selection - Which shots did Kobe sink?". You can find the dataset be clicking [here](https://www.kaggle.com/competitions/kobe-bryant-shot-selection).

This work is dedicated to the memorial of Kobe Bryant, the player and mostly the personality that make us to love basketball with a more romantic way!

For the data management, data visualization, statistical data analysis, models' construction and predictions, the programming languages **R** and **Python** were used. Also we provide a report, in a presentation format, which can be seen [here](https://github.com/geolamprou/Kobe-Bryant-Shot-Selection-Project/blob/main/Presentation/kobe_project_presentation.pdf).

## R Language
R Programming Language is one of the most famous programming languages specially for statisticians and data scientist. The purpose of using R in the current project mostly is to manage the main the dataset and to create some beautiful data visualizations using the ggplot package. Furthermore, we apply a few statistical tests in order to extract which basketball factor play a significant role on Kobe's shot. 
Before, the results' presentation, it is worth to mention that based the main dataset we created a new variable with the name "home_at". This variable contains 2 values: Home: when Kobe played at home & Away: when Kobe played 'on the road'. So main statistical results are presented below.
1. There is a statistical significant correlation between variables shot_made_flag and home_at (Χ^2= 10.358, df=1, p < 0.05). In other words, the shot result is related to whether Kobe Bryant was playing the match at home or away 
2. There is a statistical significant correlation between variables shot_made_flag and shot_type (Χ^2= 378.51, df=1, p < 0.05). In other words, the shot result is related to the shot type.

You can read the whole R code which includes the data management, the visualizations and the statical tests, by clicking the file [kobe_shot_selection_R_work.R](https://github.com/geolamprou/Kobe-Bryant-Shot-Selection-Project/blob/main/R/kobe_shot_selection_R_work.R).  

## Python
Python is an object-oriented language and a powerful tool for data scientists. The main purpose of using Python in this context is to predict the success of basketball shots. Additionally, we clean the data and perform Exploratory Data Analysis (EDA) techniques to understand how various parameters impact the shots made by Kobe Bryant.

During the analysis, we create many Python files. First of all, we provide two main code.

1. [kobe_bryant_shot_selection](https://github.com/geolamprou/Kobe-Bryant-Shot-Selection-Project/blob/main/Python/kobe_bryant_shot_selection.ipynb) :The raw file which we clean the data, perform EDA, Inferential statistics and Prediction.
2. [predict_shot_selection](https://github.com/geolamprou/Kobe-Bryant-Shot-Selection-Project/blob/main/Python/predict_shot_selection.ipynb) : This is a Jupyter Notebook that uses Object-Oriented techniques to make the code cleaner and more professional. 

Furthermore, in the [predict_shot_selection](https://github.com/geolamprou/Kobe-Bryant-Shot-Selection-Project/blob/main/Python/predict_shot_selection.ipynb) Jupyter notebook we use some custom methods that created based on the raw Jupyter notebook [kobe_bryant_shot_selection](https://github.com/geolamprou/Kobe-Bryant-Shot-Selection-Project/blob/main/Python/kobe_bryant_shot_selection.ipynb). So the custom methods is the following:

- [DataCleaning](https://github.com/geolamprou/Kobe-Bryant-Shot-Selection-Project/blob/main/Python/DataCleaning.py): In this file we check for null or duplicates values and split the dataset into training and tesing set. We also change the data type of some features.
- [featureVisualization](https://github.com/geolamprou/Kobe-Bryant-Shot-Selection-Project/blob/main/Python/featureVisualization.py): We perform feature visualization to undestrand the dataset furthermore and select which parameters will be better predictors.
- [inferentialStatistics](https://github.com/geolamprou/Kobe-Bryant-Shot-Selection-Project/blob/main/Python/inferentialStatistics.py): We create three methods that apply some statistical tests. Logistic Regression model to determine which continous features are good predictors. Chi-square and fisher test to determine if a binary feature is statistical significant. 
- [dataProcess](https://github.com/geolamprou/Kobe-Bryant-Shot-Selection-Project/blob/main/Python/dataProcess.py): We perform feature engineering to create or modify features that we think will be helpful inputs for improving model's performance.
- [modelEvaluation](https://github.com/geolamprou/Kobe-Bryant-Shot-Selection-Project/blob/main/Python/modelEvaluation.py): In this file we calculate some metrics and also we compute the confusion matrix.


All the above codes are used to the [predict_shot_selection](https://github.com/geolamprou/Kobe-Bryant-Shot-Selection-Project/blob/main/Python/predict_shot_selection.ipynb) to make more cleaner and professional code. In this file we use the two best model which is Regularized Logistic Regression and Artificial Neural Networks. Finally, we compare this two models to see which is better. You can check all the Python codes [here](https://github.com/geolamprou/Kobe-Bryant-Shot-Selection-Project/tree/main/Python).

## Results

As for results, our predictions is quite low. It seems that we don't have strong features to predict the success of a shot. But let's compare the models in some visualization.
Let's see the confusion matrices of the two models.

![Poll Mockup](./images/confusion_matrices2.png)


The roc curves of two models.
![Poll Mockup](./images/roc_curves_comparison.png)

Finally, we visualize a comparison of metrics.

![Poll Mockup](./images/metrics_comparison.png)
