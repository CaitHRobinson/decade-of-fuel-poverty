# A decade of fuel poverty indicators in England: Spatio-temporal analysis
We use sequence and cluster analysis to identify key spatial trajectories in fuel poverty based on definitions and indicators used in national policy in England. 

### Datasets
Datasets: We analyse sub-regional fuel poverty indicators from 2010 - 2020. In order to analyse sequences within fuel poverty data over time, it was necessary to transform the data into a categorical, rather than continuous dataset. This allowed for analysis of how Local Authorities move through different states over time. Relative deciles were selected as an appropriate categorical classification for the dataset, classifying Local Authorities into deciles (i.e. the top 10%, top 10% etc.) for each year between 2010-2019. 

### Methods
*Sequence analysis:* We use the [TraMineR](http://traminer.unige.ch/) package in R, a useful package for mining and visualising sequences of states. We compute optimal matching (OM) distances. Optimal matching generates distances based on the minimal cost (in terms of insertions, deletions, and substitutions) of transforming one sequence into another. We use an insertion and deletion cost of one, the default value in TraMineR.

![10years](https://user-images.githubusercontent.com/57355504/130454920-5925f9e2-5958-401c-bc13-c679678e1831.png)

*Cluster analysis:* Once the temporal sequences are derived, clustering is applied to aggregate the sequences into a reduced number of groups. Using the [cluster](https://cran.r-project.org/web/packages/cluster/cluster.pdf) package, we build a Ward hierarchical clustering of the sequences from the optimal matching distances, retrieving a cluster member for every individual sequence according to a three, four, five, six, seven, eight and nine class solution. We settle on a five cluster solution.

![Clusters_5_300dpi_Vidris](https://user-images.githubusercontent.com/57355504/130453702-79f473af-68b1-42ba-a6a2-916b5816c226.jpg)

