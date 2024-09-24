# A decade of fuel poverty indicators in England: Spatio-temporal analysis

💬 **Language:** R

📌 **Section summary:** Sequence and cluster analysis used to identify key spatial trajectories in fuel poverty based on definitions and indicators used in national policy in England. The full code to replicate the analysis and outputs in R is available [here](https://github.com/CaitHRobinson/decade-of-fuel-poverty/blob/main/TenYears.Rmd).

*Fuel poverty indicators:* We analyse [sub-regional fuel poverty indicators from 2010 - 2019](https://www.gov.uk/government/collections/fuel-poverty-sub-regional-statistics). 

*Transforming data:* In order to analyse sequences within fuel poverty data over time, it is necessary to transform the data into a categorical, rather than continuous dataset. This allows for analysis of how Local Authorities move through different states over time. Relative deciles are selected as an appropriate categorical classification for the dataset, classifying Local Authorities into deciles (i.e. the top 10%, top 10% etc.) for each year between 2010-2019. [Data_deciles.csv](https://github.com/CaitHRobinson/decade-of-fuel-poverty/blob/main/data_deciles.csv) includes the raw fuel poverty data (as a percentage) followed by a decile classification for each year.

*Other contextual data:* [LA_variables.csv](https://github.com/CaitHRobinson/decade-of-fuel-poverty/blob/main/LA_variables.csv) includes the LA scale contextual variables (e.g. unpaid care, deprivation etc.).

📊 **Dataset download:** The final classification of Local Authorities and the clusters assigned is available [here](https://github.com/CaitHRobinson/decade-of-fuel-poverty/blob/main/LA_finaldataset.csv).

![Figure4](https://user-images.githubusercontent.com/57355504/236172237-bcea9eff-b136-480f-849a-d7c588e77029.png)
