import pandas as pd
import numpy as np
import heapq
import matplotlib.pyplot as plt
from sklearn.cluster import KMeans
from sklearn.datasets import make_blobs
from sklearn.cluster import DBSCAN
from sklearn.preprocessing import StandardScaler
from sklearn.preprocessing import normalize
from sklearn.decomposition import PCA
import tkinter as tk
from tkinter import ttk
from collections import defaultdict
import hdbscan
from sklearn.datasets import make_blobs


def csv_files_import(csv_path='batting-stance.csv'):
    batting_stance_df = pd.read_csv(csv_path)
    batting_stances = batting_stance_df.to_dict(orient='records')

    # list of dicts
    return batting_stances


def find_kmeans_clusters(feature1, feature2, feature_name1, feature_name2, player_names, n_clusters=3):

    def find_unscaled_axes(ax, scaler):
        # Get current axis limits (in scaled space)
        x_min, x_max = ax.get_xlim()
        y_min, y_max = ax.get_ylim()

        # Map scaled axis limits back to original values
        scaled_x_range = np.array([[x_min], [x_max]])
        scaled_y_range = np.array([[y_min], [y_max]])

        original_x_range = scaler.inverse_transform(np.column_stack([scaled_x_range, np.zeros(2)]))[:, 0]
        original_y_range = scaler.inverse_transform(np.column_stack([np.zeros(2), scaled_y_range]))[:, 1]

        # Set new tick labels with original values
        x_ticks = ax.get_xticks()
        y_ticks = ax.get_yticks()

        x_tick_labels = [f"{original_x_range[0] + (original_x_range[1] - original_x_range[0]) * (t - x_min) / (x_max - x_min):.2f}" for t in x_ticks]
        y_tick_labels = [f"{original_y_range[0] + (original_y_range[1] - original_y_range[0]) * (t - y_min) / (y_max - y_min):.2f}" for t in y_ticks]

        return x_tick_labels, y_tick_labels



    # Would love to figure out how the axis/values are being scaled/what being scaled does to the plot
    # Values on plot, as well as axes values, are most likely plotted correctly.


    # Extract features for clustering
    X = np.array(list(zip(feature1, feature2)))

    # STANDARDIZE THE FEATURES
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X)

    # Apply KMeans clustering
    kmeans = KMeans(n_clusters=n_clusters, random_state=0)
    kmeans.fit(X_scaled)

    y_kmeans = kmeans.predict(X_scaled)

    labels = kmeans.labels_
    # centroids = kmeans.cluster_centers_
    centroids_scaled = kmeans.cluster_centers_
    centroids = scaler.inverse_transform(centroids_scaled)
    # print(f"labels: {labels}")
    # print(f"Centroids: {centroids}")

    # Plot the clusters
    fig, ax = plt.subplots(figsize=(8, 6))
    scatter = ax.scatter(X_scaled[:, 0], X_scaled[:, 1], c=y_kmeans, cmap='viridis', marker='o', edgecolor='k', s=100)
    ax.scatter(centroids_scaled[:, 0], centroids_scaled[:, 1], c='red', marker='X', s=200, label='Centroids')
    ax.set_title('KMeans Clustering of Batting Stances')
    ax.set_xlabel(f"{feature_name1}")
    ax.set_ylabel(f"{feature_name2}")

    x_tick_labels, y_tick_labels = find_unscaled_axes(ax, scaler)
    ax.set_xticklabels(x_tick_labels)
    ax.set_yticklabels(y_tick_labels)

    ax.legend()

    # Create hover functionality
    annot = ax.annotate('', xy=(0,0), xytext=(20,20), textcoords="offset points",
                        bbox=dict(boxstyle="round", fc="lightblue", alpha=1.0),
                        arrowprops=dict(arrowstyle="->"))
    annot.set_visible(False)

    def update_annot(ind):
        pos = scatter.get_offsets()[ind["ind"][0]]
        annot.xy = pos
        text = f"{player_names[ind['ind'][0]]}"
        annot.set_text(text)
        annot.get_bbox_patch().set_facecolor('lightblue')
        annot.get_bbox_patch().set_alpha(1.0)  # Solid background (no transparency)

    def hover(event):
        vis = annot.get_visible()
        if event.inaxes == ax:
            cont, ind = scatter.contains(event)
            if cont:
                update_annot(ind)
                annot.set_visible(True)
                fig.canvas.draw()
            else:
                if vis:
                    annot.set_visible(False)
                    fig.canvas.draw()

    fig.canvas.mpl_connect("motion_notify_event", hover)
    
    plt.show()

    return labels




def find_hdbscan(list_of_stats, name_list, list_of_stat_names, MIN_CLUSTER_SIZE=5):
    # Idk if I will need min_samples for hdbscan, but I am including it for now
    # Update: It seems to work fine without it, so I am leaving it out for now.

    # print(f"list_of_stats[0] = {list_of_stats[0]}")

    # IF WE HAVE TIME, LOOK AT FINDING OUT WHY NAMES ARE NOT POPPING UP WHEN THE MOUSE HOVERS OVER DOTS

    # Standardize the features
    N_COMPONENTS = len(list_of_stats)
    # print(f"N_COMPONENTS: {N_COMPONENTS}")
    original_X = np.array(list_of_stats).T
    X = StandardScaler().fit_transform(np.array(list_of_stats).T)

    # Apply PCA for dimensionality reduction
    # PCA = Principle Component Analysis
    pca = PCA(n_components=N_COMPONENTS)
    X_pca = pca.fit_transform(X)

    X_pca = X

    # Apply HDBSCAN ################################################################################
    clusterer = hdbscan.HDBSCAN(min_cluster_size=MIN_CLUSTER_SIZE)
    cluster_labels = clusterer.fit_predict(X_pca)
    # print(f"Cluster labels: {cluster_labels}")

    # Group player names by their cluster labels
    cluster_groups_names = defaultdict(list)
    # Holds all stats for players in ALL clusters
    all_cluster_stats = defaultdict(list)
    average_cluster_stats = defaultdict(list)

    # print(f"original_X shape: {original_X.shape}, type: {type(original_X)}")
    # print(f"original_X = {original_X}")
    # return

    for idx, label in enumerate(cluster_labels):

        player_name = name_list[idx]
        player_stat_list = original_X[idx]
        cluster_groups_names[label].append(player_name)
        all_cluster_stats[label].append(player_stat_list)
        # Find the average stats for each cluster

        '''for idx, item in enumerate(player_stat_list):
            stat_name = list_of_stat_names[idx]
            all_cluster_stats[stat_name].append(item)'''

        # all_cluster_stats[label].append(player_stat_list)
    # Loops through each cluster label
    for cluster_label, cluster_stat_list in all_cluster_stats.items():
        # Holds all stats for players in a SINGLE cluster, labels are stat names
        accumulated_single_cluster_stats = defaultdict(list)
        
        # Loops through each player's stats in that cluster
        for player_idx, player_stat_list in enumerate(cluster_stat_list):

            # Loops through each stat of that player
            for stat_idx, stat in enumerate(player_stat_list):
                stat_name = list_of_stat_names[stat_idx]
                accumulated_single_cluster_stats[stat_name].append(stat)
                # print(f"Cluster {label}, Player {cluster_groups_names[label][idx]}, Stats: {stat}, type of {type(stat)}, type(stat[0]): {type(stat[0])}, stat_name: {stat_name}")


        # Now find the average of each stat for that cluster
        average_cluster_stats[cluster_label] = []
        for stat_name, stats in accumulated_single_cluster_stats.items():
            average_stat = np.mean(stats)
            average_cluster_stats[cluster_label].append(average_stat)

            # print(f"Cluster {label}, Player {cluster_groups_names[label][idx]}, Stats: {stat}, type of {type(stat)}, type(stat[0]): {type(stat[0])}, stat_name: {stat_name}")

    '''print(f"Cluster Groups and their Players:\n")
    for label, players in cluster_groups_names.items():
        print(f"  Cluster {label}: {players}\n")
    print(f"Average Stats per Cluster:\n\n")
    temp_idx = 0
    for label, avg_stats in average_cluster_stats.items():
        print(f"  Cluster {label}:")
        print(f"    Number of Players: {len(cluster_groups_names[label])}")
        for stat_name, avg_stat in zip(list_of_stat_names, avg_stats):
            print(f"    {stat_name}: {avg_stat:.2f}")
        print(f"        Sum of all stats: {sum(avg_stats):.2f}")
        print()
        temp_idx += 1'''
    '''if temp_idx >= 5:
        break'''


    # Plot the results
    fig, ax = plt.subplots(figsize=(10, 6))
    scatter = ax.scatter(original_X[:, 0], original_X[:, 1], c=cluster_labels, s=30, cmap='jet')
    ax.set_title("HDBSCAN Clustering")
    ax.set_xlabel(f'{list_of_stat_names[0]}')
    ax.set_ylabel(f'{list_of_stat_names[1]}')

    # Create hover functionality
    annot = ax.annotate('', xy=(0,0), xytext=(20,20), textcoords="offset points",
                        bbox=dict(boxstyle="round", fc="lightblue", alpha=1.0),
                        arrowprops=dict(arrowstyle="->"))
    annot.set_visible(False)


    def update_annot(ind):
        pos = scatter.get_offsets()[ind["ind"][0]]
        annot.xy = pos
        text = f"{name_list[ind['ind'][0]]}"
        annot.set_text(text)
        annot.get_bbox_patch().set_facecolor('lightblue')
        annot.get_bbox_patch().set_alpha(1.0)  # Solid background (no transparency)

    def hover(event):
        vis = annot.get_visible()
        if event.inaxes == ax:
            cont, ind = scatter.contains(event)
            if cont:
                update_annot(ind)
                annot.set_visible(True)
                fig.canvas.draw()
            else:
                if vis:
                    annot.set_visible(False)
                    fig.canvas.draw()

    fig.canvas.mpl_connect("motion_notify_event", hover)
    plt.show()

    return cluster_labels



def find_outliers(all_stats, name_list, stat_names, num_outliers=10):
    # Find the top x outliers for each stat/sum of stats, using the IQR method or summing all the stats together
    sums_of_player_stats = []
    for i in range(len(name_list)):
        all_player_stats = [all_stats[j][i] for j in range(len(all_stats))]
        sums_of_player_stats.append(sum(all_player_stats))

    largest_outliers = heapq.nlargest(num_outliers, sums_of_player_stats)

    # If player is an outlier, mark them
    in_outliers = [0 for _ in range(len(name_list))]

    # print(f"\nAll stats: {stat_names}")
    # print(f"\nLargest outliers based on sum of all stats:\n")
    for i in range(len(largest_outliers)):
        outlier_index = sums_of_player_stats.index(largest_outliers[i])
        outlier_name = name_list[outlier_index]
        # print(f"{i+1}: {outlier_name} with a sum of {largest_outliers[i]}\n")
        in_outliers[outlier_index] = 1
    return largest_outliers, in_outliers
    





def main():

    print(f"in main")
    

    # Clean up code
    
    batting_stances = csv_files_import()

    # return

    # Separate names from numerical features
    player_names = np.array([stance['name'] for stance in batting_stances])

    # Only include numerical features for clustering
    features = np.array([[stance['avg_batter_y_position'], stance['avg_batter_x_position'], stance['avg_foot_sep'], stance['avg_stance_angle'], stance['avg_intercept_y_vs_batter'], stance['avg_intercept_y_vs_plate']] for stance in batting_stances])
    feature_names = ['avg_batter_y_position', 'avg_batter_x_position', 'avg_foot_sep', 'avg_stance_angle', 'avg_intercept_y_vs_batter', 'avg_intercept_y_vs_plate']
    print(f"batting_stances[0]: {batting_stances[0]}")
    
    num_of_players = -1
    features = features[:num_of_players]
    transposed_features = features.T
    batting_stances = batting_stances[:num_of_players]
    player_names = player_names[:num_of_players]

    # PARAMETERS ##########################################################
    stat1_index = 5
    stat2_index = 4
    min_cluster_size = 5 # for HDBSCAN
    min_samples = 5
    num_of_players_ranked = 25 # Number of top players to show per stat
    #######################################################################

    # Stats to include in HDBSCAN
    included_stat_indexes = [0, 1, 2]
    transposed_features = transposed_features[included_stat_indexes]
    feature_names = [feature_names[i] for i in included_stat_indexes]

    # kmeans_labels = list(find_kmeans_clusters(features[:,stat1_index], features[:,stat2_index], feature_names[stat1_index], feature_names[stat2_index], player_names, n_clusters=3))
    outliers = find_outliers(transposed_features, player_names, feature_names, num_of_players_ranked)
    cluster_labels = find_hdbscan(transposed_features, player_names, feature_names, min_cluster_size)
    return
    print(f"len of kmeans_labels: {len(kmeans_labels)}")
    print(f"len of features[:20, 3]: {len(features[:num_of_players,3])}")
    print(f"kmeans_labels: {kmeans_labels}")

    # print(f"labels shape: {labels.shape}")
    # add the kmeans cluster labels to the original data
    for i, stance in enumerate(batting_stances):
        stance['kmeans_label'] = kmeans_labels[i]
    
    # print out the batting stances with their cluster labels
    for stance in batting_stances:
        print(f"Batter: {stance['name']}, KMeans Cluster: {stance['kmeans_label']}")




#if __name__ == "__main__":
#    main()



def run_clustering_analysis(csv_path=None, feature_indices=None, min_cluster_size=5, num_of_players_ranked=25, min_samples=5, num_of_players=-1):
    """
    Main function to run the clustering analysis.
    Can be called from R with a custom CSV path.
    """


    print(f"DEBUG: Received feature_indices: {feature_indices}")
    print(f"DEBUG: Type of feature_indices: {type(feature_indices)}")
    
    # Convert items in feature_indices to integers if they are not None
    if feature_indices is not None:
        feature_indices = [int(float(idx)) for idx in feature_indices]
        print(f"DEBUG: Converted feature_indices to integers: {feature_indices}")
    # Convert all other parameters to integers
    min_cluster_size = int(min_cluster_size)
    num_of_players_ranked = int(num_of_players_ranked)
    min_samples = int(min_samples)
    num_of_players = int(num_of_players)

    if csv_path is None:
        csv_path = 'batting-stance.csv'
    
    batting_stances = csv_files_import(csv_path)
    
    # Separate names from numerical features
    player_names = np.array([stance['name'] for stance in batting_stances])
    
    # Only include numerical features for clustering
    features = np.array([[stance['avg_batter_y_position'], 
                         stance['avg_batter_x_position'], 
                         stance['avg_foot_sep'], 
                         stance['avg_stance_angle'], 
                         stance['avg_intercept_y_vs_batter'], 
                         stance['avg_intercept_y_vs_plate']] 
                        for stance in batting_stances])
    feature_names = ['avg_batter_y_position', 'avg_batter_x_position', 
                     'avg_foot_sep', 'avg_stance_angle', 
                     'avg_intercept_y_vs_batter', 'avg_intercept_y_vs_plate']
    
    print(f"DEBUG: num_of_players type: {type(num_of_players)}, value: {num_of_players}")
    
    num_of_players = num_of_players
    features = features[:num_of_players]
    transposed_features = features.T
    batting_stances = batting_stances[:num_of_players]
    player_names = player_names[:num_of_players]

    print(f"DEBUG: transposed_features shape before indexing: {transposed_features.shape}")

    
    # PARAMETERS
    stat1_index = feature_indices[0] if feature_indices else 4 # default to avg_intercept_y_vs_plate
    stat2_index = feature_indices[1] if feature_indices else 5 # default to avg_intercept_y_vs_batter
    
    # Stats to include in HDBSCAN
    # Convert feature_indices to a list of integers if it's not None
    if feature_indices is not None:
        # Convert to list and ensure all elements are integers
        included_stat_indexes = [int(float(idx)) for idx in feature_indices]
        print(f"DEBUG: included_stat_indexes after conversion: {included_stat_indexes}")
        print(f"DEBUG: Type check: {[type(idx) for idx in included_stat_indexes]}")
    else:
        included_stat_indexes = [0, 1, 2]
        print(f"DEBUG: Using default included_stat_indexes: {included_stat_indexes}")

    # Check if indices are valid
    for idx in included_stat_indexes:
        if idx >= len(transposed_features):
            raise ValueError(f"Index {idx} is out of bounds for transposed_features with length {len(transposed_features)}")
        
    print(f"DEBUG: About to index transposed_features with {included_stat_indexes}")

    transposed_features = np.array([transposed_features[i] for i in included_stat_indexes])
    print(f"DEBUG: transposed_features shape after indexing: {transposed_features.shape}")

    feature_names = [feature_names[i] for i in included_stat_indexes]
    
    outliers, in_outliers = find_outliers(transposed_features, player_names, feature_names, num_of_players_ranked)
    cluster_labels = find_hdbscan(transposed_features, player_names, feature_names, min_cluster_size)

    # 🔥 FIX: convert (features × players) → (players × features)
    feature_matrix_for_r = transposed_features # .T

    print(f"shape of feature_matrix_for_r: {feature_matrix_for_r.shape}")
    print(f"shape of in_outliers: {len(in_outliers)}")
    print(f"shape of cluster_labels: {len(cluster_labels)}")
    print(f"\nlength of feature_matrix_for_r: {len(feature_matrix_for_r)}, length of first row: {len(feature_matrix_for_r[0])}\n")
    
    return {
        'cluster_labels': list(cluster_labels),
        'outliers': list(outliers),
        'in_outliers': list(in_outliers),
        'player_names': list(player_names),
        'features': feature_matrix_for_r.tolist(), # Replaced features with feature_matrix_for_r
        'feature_names': feature_names
    }

# Only run main() if this script is executed directly (not when imported by R)
# if __name__ == "__main__":
    # This will only run when you execute the Python script directly
    # It won't run when R sources it
    # main()
    run_clustering_analysis('batting-stance.csv')

