# This code builds on a range of extremely useful resources for implementing sequence analysis using TraMineR.
# In particular [Gabadinho et al. (2011)](http://traminer.unige.ch/documentation.shtml) and [Nikos et al. (2019)](https://github.com/patnik/neighbourhood_change).

#### Install relevant packages and libraries

library(ggplot2)
library(tidyr)
library(RColorBrewer)
library(TraMineR)
library(cluster)
library(dplyr)
library(gridExtra)
library(WeightedCluster)
library(sf)
library(tmap)

#### Explore the data

Local Authorities were selected, as sub-regional fuel poverty estimates are understood to be reliable at this scale, allowing for comparison between particular areas (unlike estimates at LSOA scale). 

# Read data as csv
LA_data <- read.csv("fuelpoverty_data.csv", check.names=FALSE, fileEncoding = 'UTF-8-BOM')

# Convert data into long format
LA_data_long <- gather(LA_data, key="Year", value="FP_households", c(4:13))

# Make sure that R recognises the year format as a date
LA_data_long$Year<-lubridate::ymd(LA_data_long$Year, truncated = 2L)

head(LA_data_long)

Once the data is prepared, we can compute a *relative rank or decile* for each fuel poor households for each year. This allowed for analysis of how Local Authorities move through different states over time. Relative deciles were selected as an appropriate categorical classification for the dataset, classifying Local Authorities into deciles (i.e. the top 10%, top 10% etc.) for each year between 2010-2019. 

Relative ranks can then be used to create a *state sequence object*. We use the TraMineR package in R, a useful package for mining and visualising sequences of states (Gabadinho et al. 2011). 

# Find out the names of the columns in the dataset
colnames(LA_data)

# Compute relative rank for each year of data
LA_data_deciles = mutate(LA_data, x2010 = ntile(LA_data$"2010", 10), 
                                  x2011 = ntile(LA_data$"2011", 10), 
                                  x2012 = ntile(LA_data$"2012", 10), 
                                  x2013 = ntile(LA_data$"2013", 10), 
                                  x2014 = ntile(LA_data$"2014", 10),
                                  x2015 = ntile(LA_data$"2015", 10), 
                                  x2016 = ntile(LA_data$"2016", 10), 
                                  x2017 = ntile(LA_data$"2017", 10), 
                                  x2018 = ntile(LA_data$"2018", 10),
                                  x2019 = ntile(LA_data$"2019", 10))

# Create a list of states
data_alpha <- c("1", "2", "3", "4", "5", "6", "7", "8", "9", "10")

# Create a state sequence object from the fuel poverty variables 
LA_seq <- seqdef(LA_data_deciles, 14:23, ststep=NULL, alphabet=data_alpha) # Alphabet is the list of states

# Set the colour palette according to the sequence
cpal(LA_seq) <- c("#313695", "#4575b4", "#74add1", "#abd9e9", 
                  "#e0f3f8", "#fee090", "#fdae61", "#f46d43", "#d73027", "#a50026")

# The sequence data can then be plotted, both from the start and from the end.  
seqIplot(LA_seq, sortv = "from.start", with.legend = FALSE)
seqfplot(LA_seq, border = NA, with.legend = FALSE)

#### Compute distance between sequences (i.e. dissimilarities)

# We can then compute pairwise dissimilarities between sequences, or the dissimilarity from a reference sequence. 
# It is necessary to chose between several dissimilarity measures, including optimal matching (OM) and many of its variants, distance based on the count of common attributes, and distances between sequence state distributions. 
# We opt for *DHD method* (Dynamic Hamming). This approach reflects important differences, or distinct timings, within sequences. 
# In our case, the fuel poverty indicator changes across time. The DHD has a strong time sensitivity, allowing substitution costs to depend on the position **t** in the sequence. 
# See [Studer (2016)](https://rss.onlinelibrary.wiley.com/doi/pdf/10.1111/rssa.12125).

LA_DHD <- seqdist(LA_seq, method = "DHD")

#### PAM ward clustering

Once the temporal sequences are derived, clustering is applied to aggregate the sequences into a reduced number of groups. We opt for a PAM ward hierarchical clustering approach. This provides a more detailed cluster analysis as each cluster has the chance to be redivided (http://www.ijfcc.org/vol5/434-S059.pdf). 

# PAM ward clustering
pamwardcluster5 <- wcKMedoids(LA_DHD, k = 5)
unique(pamwardcluster5$clustering)

# Rename labels with cluster names
cl5.lab <- factor(pamwardcluster5$clustering, labels = paste(c("Sustained energy affluence", "Fluctuating energy affluence", "Changeable middle", "Fluctuating energy deprivation", "Entrenched energy deprivation")))

# Change labels in csv file
LA_data_deciles$Cluster_5 <- factor(pamwardcluster5$clustering, labels = paste(1:5))

# Write results to csv.
write.csv(LA_data_deciles, "data_deciles.csv") 
head(LA_data_deciles)

# State distribution plots
seqdplot(LA_seq, group = cl5.lab, border = NA, rows = 3, cols = 3)

# Sequence frequency plots
seqfplot(LA_seq,group = cl5.lab, border = NA, rows = 3, cols = 3)

# Transversal entropy plots
seqHtplot(LA_seq,group = cl5.lab, border = NA, rows = 3, cols = 3)

# Mean times plots
seqmtplot(LA_seq,group = cl5.lab, border = NA, rows = 3, cols = 3)

# Whole set index plots
seqIplot(LA_seq,group = cl5.lab, border = NA, rows = 3, cols = 3)

# Individual sequences
seqiplot(LA_seq,group = cl5.lab, border = NA, rows = 3, cols = 3)

# Parallel coordinate plots
seqpcplot(LA_seq,group = cl5.lab, border = NA, rows = 3, cols = 3)

# Modal state sequences
seqmsplot(LA_seq,group = cl5.lab, border = NA, rows = 3, cols = 3)

#### Working with contextual census variables

# Add additional variables
LA_additional_variables <- read.csv("LA_variables.csv", check.names=FALSE, fileEncoding = 'UTF-8-BOM')

# Merge with trajectories dataset
LA_finaldataset <- merge(LA_data_deciles, LA_additional_variables, by.x=c("LACode"), by.y=c("geography code"))

# Change cluster data to character
LA_finaldataset$Cluster_5 <- as.character(LA_finaldataset$Cluster_5)

# Unpaid Care
p1 <- ggplot(LA_finaldataset, aes(x=Cluster_5, y = UnpaidCare_person_per))+ 
  geom_violin(aes(fill=Cluster_5), color=NA)+
  labs(title="Unpaid care",y="Percentage of persons", x="", caption = "")+
  scale_fill_manual(values=c("#440154", "#3a528b", "#20908d","#5dc962", "#fde725"), 
                    name="Cluster",
                    breaks=c("1", "2", "3", "4", "5"),
                    labels=c("1", "2", "3", "4", "5"))+
  stat_summary(fun.y=median, geom="point", size=2, color="black")+ 
  theme(legend.position = "none", plot.title = element_text(size=10), axis.title.y=element_text(size=10)) 

# Private rent
h1 <- ggplot(LA_finaldataset, aes(x=Cluster_5, y = PrivateRent_hh_per))+ 
  geom_violin(aes(fill=Cluster_5), color=NA)+
  labs(title="Private renting",y="Percentage of households", x="", caption = "")+
  scale_fill_manual(values=c("#440154", "#3a528b", "#20908d","#5dc962", "#fde725"), 
                    name="Cluster",
                    breaks=c("1", "2", "3", "4", "5"),
                    labels=c("1", "2", "3", "4", "5"))+
  stat_summary(fun.y=median, geom="point", size=2, color="black")+ 
  theme(legend.position = "none", plot.title = element_text(size=10), axis.title.y=element_text(size=10))

# Social rent
h2 <- ggplot(LA_finaldataset, aes(x=Cluster_5, y = SocialRent_hh_per))+ 
  geom_violin(aes(fill=Cluster_5), color=NA)+
  labs(title="Social renting",y="", x="Clusters", caption = "")+
  scale_fill_manual(values=c("#440154", "#3a528b", "#20908d","#5dc962", "#fde725"), 
                    name="Cluster",
                    breaks=c("1", "2", "3", "4", "5"),
                    labels=c("1", "2", "3", "4", "5"))+
  stat_summary(fun.y=median, geom="point", size=2, color="black")+ 
  theme(legend.position = "none", plot.title = element_text(size=10), axis.title.x=element_text(size=10))

# Ethnicity
p2 <- ggplot(LA_finaldataset, aes(x=Cluster_5, y = Ethnicity_per))+ 
  geom_violin(aes(fill=Cluster_5), color=NA)+
  labs(title="Ethnic minority", x="", y = "", caption = "")+
  scale_fill_manual(values=c("#440154", "#3a528b", "#20908d","#5dc962", "#fde725"), 
                    name="Cluster",
                    breaks=c("1", "2", "3", "4", "5"),
                    labels=c("1", "2", "3", "4", "5"))+
  stat_summary(fun.y=median, geom="point", size=2, color="black")+ 
  theme(legend.position = "none", plot.title = element_text(size=10)) 

# Deprivaton
h3 <- ggplot(LA_finaldataset, aes(x=Cluster_5, y = Deprivation_hh_per))+ 
  geom_violin(aes(fill=Cluster_5), color=NA)+
  labs(title="Deprivation",y="", x="", caption = "")+
  scale_fill_manual(values=c("#440154", "#3a528b", "#20908d","#5dc962", "#fde725"), 
                    name="Cluster",
                    breaks=c("1", "2", "3", "4", "5"),
                    labels=c("1", "2", "3", "4", "5"))+
  stat_summary(fun.y=median, geom="point", size=2, color="black")+ 
  theme(legend.position = "none", plot.title = element_text(size=10))

# No central heating
h4 <- ggplot(LA_finaldataset, aes(x=Cluster_5, y = NoCentralHeating_per_hh))+ 
  geom_violin(aes(fill=Cluster_5), color=NA)+
  labs(title="No central heating",y="Percentage of households", x="Clusters", caption = "")+
  scale_fill_manual(values=c("#440154", "#3a528b", "#20908d","#5dc962", "#fde725"), 
                    name="Cluster",
                    breaks=c("1", "2", "3", "4", "5"),
                    labels=c("1", "2", "3", "4", "5"))+
  stat_summary(fun.y=median, geom="point", size=2, color="black")

# Disability or illness
p3 <- ggplot(LA_finaldataset, aes(x=Cluster_5, y = LimitedAlot_person_per))+ 
  geom_violin(aes(fill=Cluster_5), color=NA)+
  labs(title="Daily activities limited a lot", x = "", y="", caption = "")+
  scale_fill_manual(values=c("#440154", "#3a528b", "#20908d","#5dc962", "#fde725"), 
                    name="Cluster",
                    breaks=c("1", "2", "3", "4", "5"),
                    labels=c("1", "2", "3", "4", "5"))+
  stat_summary(fun.y=median, geom="point", size=2, color="black")+ 
  theme(legend.position = "none", plot.title = element_text(size=10))

# Final grid image
grid.arrange(p1, p2, p3, h1, h2, h3,  nrow = 2)

#### Plots of raw ful poverty data according to cluster

# Gather raw fuel poverty data
LA_data_cluster_long <- gather(LA_finaldataset, key="Year", value="FP_households", c(4:13))
head(LA_data_cluster_long)

# Use only every second label on x axis
everysecond <- function(x){
  x <- sort(unique(x))
  x[seq(2, length(x), 2)] <- ""
  x
}

# Plot fuel poverty estimates for each cluster using bins
bins <- ggplot(LA_data_cluster_long, aes(x=Year, y = FP_households))+ 
  geom_bin_2d()+
  labs(x = "", y="Fuel poor households (%)")+
  facet_wrap(~ Cluster_5)+
  scale_x_discrete(labels = everysecond(LA_data_cluster_long$Year))+
  scale_y_continuous()+
  guides(fill = guide_legend(title = "LA count"))+
  theme_minimal()

plot(bins)

#### Mapping clusters
# Import LA shapefile
LA <- st_read("EnglandandWales_LA_2019.shp")

# Merge with cluster attibutes
LA_clusters <- merge(LA, LA_data_deciles, by.x = "lad19cd", by.y = "LACode")

# Map clusters using tmap functions
Clusters_mapped <- tm_shape(LA)+
  tm_fill(col = "grey87")+ # Provide grey outline without borders of England and Wales
  tm_shape(LA_clusters)+
  tm_polygons(col = "Cluster_5", palette =c("1" ="#440154", "2" ="#3a528b", "3"= "#20908d", "4" = "#5dc962", "5" = "#fde725"), title = "Trajectory clusters")+
  tm_scale_bar(text.size = 0.6)+
  tm_layout(frame = FALSE, legend.title.fontface = "bold")
Clusters_mapped
