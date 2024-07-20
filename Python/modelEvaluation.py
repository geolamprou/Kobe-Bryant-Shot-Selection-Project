from dataProcess import DataPreparation, FeatureEngineering
from featureVisualization import FeatureVisualization
from inferentialStatistics import InferStats

from sklearn.metrics import confusion_matrix, accuracy_score, f1_score, precision_score, recall_score, log_loss

import seaborn as sns 

class ModelEvaluation(object):
    def __init__(self,model):
        self.model = model

    """ A function that creates the confusion matrix of the model"""
    def model_confusion_matrix(self, X, y):
        # Make the predictions
        predictions = self.model.predict(X)

        # Create the confusion matrix
        model_confusion = confusion_matrix(predictions,y)

        # Visualize the results by using a heatmap
        sns.heatmap(
        model_confusion, 
        cmap="Blues",  
        annot=True, 
        fmt="g",
        square=True,
        xticklabels=["SHOT NOT MADE", "SHOT MADE"],        
        yticklabels=["SHOT NOT MADE", "SHOT MADE"]
        ).set(
            xlabel='Predicted Default',
            ylabel='Actual Default',
            title="Model's confusion matrix"
        );

    """ A function that calculates some metrics for the model."""
    def validation(self, X, y ):
        # Maked the predictions
        predictions = self.model.predict(X)

        # Make probablities predictions
        predict_proba = self.model.predict_proba(X)

        # Calculate some metrics for the Validation Set
        print("------- Calculate Metrics for  set.--------\n")
        print(f"Validation Accuracy: {self.model.score(X, y)}")
        print(f"The precision score for  set is: {precision_score(y,predictions)}")
        print(f"The recall score for  set is: {recall_score(y,predictions)}")
        print(f"The F1 score for  set is: {f1_score(y,predictions)}")

        loss_valid = log_loss(y, predict_proba)
        print(f"Log Loss : {loss_valid:.4f}\n")