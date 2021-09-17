# A decade of fuel poverty indicators in England: Spatio-temporal analysis
Sequence and cluster analysis used to identify key spatial trajectories in fuel poverty based on definitions and indicators used in national policy in England. The full code to replicate the analysis and outputs in R is available [here](https://github.com/CaitHRobinson/decade-of-fuel-poverty/blob/main/TenYears.Rmd).

### Datasets
Analyse [sub-regional fuel poverty indicators from 2010 - 2019](https://www.gov.uk/government/collections/fuel-poverty-sub-regional-statistics). In order to analyse sequences within fuel poverty data over time, it was necessary to transform the data into a categorical, rather than continuous dataset. This allowed for analysis of how Local Authorities move through different states over time. Relative deciles were selected as an appropriate categorical classification for the dataset, classifying Local Authorities into deciles (i.e. the top 10%, top 10% etc.) for each year between 2010-2019. 

LA_variables.csv includes the LA scale contextual variables (e.g. unpaid care, deprivation etc.)
data_decales.csv includes the raw fuel poverty data (as a percentage) followed by a decile classification for each year.

![10years](https://user-images.githubusercontent.com/57355504/130454920-5925f9e2-5958-401c-bc13-c679678e1831.png)

