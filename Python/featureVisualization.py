import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import math

from DataCleaning import CleanDataFrame

class FeatureVisualization(object):
    def __init__(self, df):
        self.df = df

    def court_visualization(self):
        # Plotting the shot locations on a basketball court
        fig, ax = plt.subplots(figsize=(15, 7))

        # Drawing the basketball court
        # Main court lines
        plt.plot([-250, 250], [-47.5, -47.5], color='black')
        plt.plot([-250, 250], [422.5, 422.5], color='black')
        plt.plot([-250, -250], [-47.5, 422.5], color='black')
        plt.plot([250, 250], [-47.5, 422.5], color='black')

        # Hoops
        hoop = plt.Circle((0, 0), 7.5, linewidth=1.5, color='black', fill=False)
        ax.add_patch(hoop)

        # Backboard
        plt.plot([-30, 30], [-7.5, -7.5], color='black', linewidth=1.5)

        # Paint area
        plt.plot([-80, -80], [-47.5, 143.5], color='black')
        plt.plot([80, 80], [-47.5, 143.5], color='black')
        plt.plot([-80, 80], [143.5, 143.5], color='black')

        # Free throw circle
        free_throw_circle = plt.Circle((0, 143.5), 60, linewidth=1.5, color='black', fill=False)
        ax.add_patch(free_throw_circle)

        # Restricted area
        restricted_area = plt.Circle((0, 0), 40, linewidth=1.5, color='black', fill=False)
        ax.add_patch(restricted_area)

        # Three point line
        three_point_circle = plt.Circle((0, 0), 237.5, linewidth=1.5, color='black', fill=False)
        ax.add_patch(three_point_circle)

        # Three point line arcs
        plt.plot([-237.5, -237.5], [-47.5, 89.477], color='black')
        plt.plot([237.5, 237.5], [-47.5, 89.477], color='black')

        # Drawing the shots
        shot_made_in = self.df[self.df['shot_made_flag'] == 1]
        shot_made_out = self.df[self.df['shot_made_flag'] == 0]

        plt.scatter(shot_made_in['loc_x'], shot_made_in['loc_y'], color='red', s=1, zorder=10, label='Made')
        plt.scatter(shot_made_out['loc_x'], shot_made_out['loc_y'], color='blue', s=1, zorder=10, label='Missed')

        plt.legend()
        # Setting axis limits and removing ticks
        plt.xlim(-250, 250)
        plt.ylim(-50, 450)
        plt.xticks([])
        plt.yticks([])
        plt.gca().set_aspect('equal', adjustable='box')

        plt.title('Shot Locations on a Basketball Court')
        plt.show()

    
    def count_target_feature(self):
        # Set the aesthetic style of the plots
        sns.set(style="whitegrid")

        # Create the histogram with customized colors using manual plotting to ensure specific color assignment
        plt.figure(figsize=(10, 6))

        # Plotting each category separately to assign specific colors
        shot_made_counts = self.df['shot_made_flag'].value_counts().sort_index()
        plt.bar(shot_made_counts.index, shot_made_counts.values, color=['purple', 'yellow'])

        # Adding titles and labels
        plt.title('Distribution of Shot Made Flag', fontsize=16)
        plt.xlabel('Shot Made Flag', fontsize=14)
        plt.ylabel('Frequency', fontsize=14)

        # Customizing the x-ticks
        plt.xticks(ticks=[0, 1], labels=['Missed (0)', 'Made (1)'])

        # Display the plot
        plt.show()

    def num_plotter(self, target = "shot_made_flag"):
    # Select numeric columns
        numerical_columns = self.df.select_dtypes(['int','float']).columns

        # Number of plots
        n_plots = len(numerical_columns)

        # Calculate number of rows needed
        n_cols = 3
        n_rows = math.ceil(n_plots / n_cols)

        # Create subplots
        fig, axes = plt.subplots(n_rows, n_cols, figsize=(5 * n_cols, 5 * n_rows))

        # Flatten axes array for easy iteration
        axes = axes.flatten()

        # Plot each numeric column
        for ax, col in zip(axes, numerical_columns):
            sns.boxplot(data=self.df, x=target, y=col, ax=ax,palette=['purple', 'yellow'])

        # Remove empty subplots
        for ax in axes[n_plots:]:
            ax.remove()

        # Display the plots
        plt.tight_layout()
        plt.show()

    def distribution_visualizer(self):
        numerical_columns = self.df.select_dtypes(['int','float']).columns

        columns_per_figure = 4
        num_numerical_columns = len(numerical_columns)


        # Loop through numerical columns and plot distributions
        for i in range(0, len(numerical_columns), columns_per_figure):
            columns_subset = numerical_columns[i:i+columns_per_figure]
            
            # Create a new figure
            plt.figure(figsize=(14, 4))
            
            for j, column in enumerate(columns_subset, start=1):
                plt.subplot((num_numerical_columns - i - 1) // columns_per_figure + 1, columns_per_figure, j)
                
                # Check the distribution of each numerical column
                sns.histplot(data=self.df, x=column, bins=20, color='purple', edgecolor='black', kde=True)
                
                # Calculate mean and median
                mean_value = self.df[column].mean()
                median_value = self.df[column].median()
                
                # Add mean and median lines
                plt.axvline(mean_value, color='red', linestyle='dashed', linewidth=2, label=f'Mean: {mean_value:.2f}')
                plt.axvline(median_value, color='yellow', linestyle='dashed', linewidth=2, label=f'Median: {median_value:.2f}')
                
                # Set title and labels
                plt.title(f"Distribution of {column}")
                plt.xlabel(column)
                plt.ylabel("Count")
                plt.legend()
            
            # Adjust layout
            plt.tight_layout()
        
            # Show the figure
            plt.show()

       
    def cat_plotter(self, target = 'shot_made_flag'):
        cat_columns = self.df.select_dtypes(['object']).columns

        num_plots = len(cat_columns)
        rows = (num_plots // 3) + (num_plots % 3 > 0)
        
        fig, axes = plt.subplots(nrows=rows, ncols=3, figsize=(20, 5 * rows))
        axes = axes.flatten()

        for i, col in enumerate(cat_columns):
            aggregated_data = (
                self.df
                .groupby(col, as_index=False)
                .agg({target: 'count'})
                .sort_values(by=target, ascending=False)
            )
            sns.barplot(
                data=aggregated_data,
                x=col,
                y=target,
                ax=axes[i]
            )
            axes[i].set_xticklabels(axes[i].get_xticklabels(), rotation=45)
            axes[i].set_title(col)
        
        # Remove any unused subplots
        for j in range(i + 1, len(axes)):
            fig.delaxes(axes[j])

        plt.tight_layout()
        plt.show()

    def shot_percentage(self,):
        # Identify categorical features
        categorical_features = self.df.select_dtypes(include=['object', 'category']).columns

        # Calculate number of rows and columns for subplots
        num_features = len(categorical_features)
        num_cols = 3  # Number of columns of subplots
        num_rows = (num_features + 1) // num_cols  # Number of rows of subplots, rounded up

        # Create subplots
        fig, axes = plt.subplots(num_rows, num_cols, figsize=(15, 5 * num_rows))
        fig.suptitle('Proportion of Each Target Class within Each Category', fontsize=16)

        # Plot for each categorical feature
        for i, feature in enumerate(categorical_features):
            row = i // num_cols
            col = i % num_cols

            # Create a pivot table to get counts of target variable within each category of categorical feature
            pivot_table = pd.crosstab(self.df[feature], self.df['shot_made_flag'])

            # Normalize the counts to get proportions
            pivot_table_proportions = pivot_table.div(pivot_table.sum(axis=1), axis=0)

            # Plot the stacked bar plot
            ax = pivot_table_proportions.plot(kind='bar', stacked=True, colormap='coolwarm', ax=axes[row, col])

            # Add labels and title
            ax.set_xlabel(feature)
            ax.set_ylabel('Proportion')
            ax.set_title(f'{feature}')
            # Rotate x labels
            ax.set_xticklabels(ax.get_xticklabels(), rotation=45)
            # Add annotations
            for p in ax.patches:
                width, height = p.get_width(), p.get_height()
                x, y = p.get_xy()
                ax.text(x + width / 2, y + height / 2, f'{height:.2f}', ha='center', va='center', color='white')

        # Adjust layout
        plt.tight_layout()
        plt.subplots_adjust(top=0.95)  # Add space for the title
        plt.show()
    #cat_columns = train_df.drop('shot_made_flag',axis =1 ).select_dtypes(['object']).columns.to_list()

# Call the function with your DataFrame and target column
#cat_plotter(train_df, "shot_made_flag",cat_columns)  
#num_plotter(train_df, "shot_made_flag")



if __name__ == "__main__":
    df_cleaner = CleanDataFrame()
    train_df, test_df = df_cleaner.clean_data()
    viz = FeatureVisualization(train_df)

    viz.count_target_feature()