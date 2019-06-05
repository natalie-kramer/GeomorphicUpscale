
---
title: Selecting
---

# Select
We sample the [existing database]({{ site.baseurl }}/1.Familiarizing) based on geomorphic incicators to predict geomorphic assemblages for reach types defined on the  network of interest. In the example data, the network is mapped by River Styles (RS) and Geomorphic Condition varience as in Brierly and Fryirs (2005).  

## Step 1. Define your Reach Types on your Network
Categorize your network into similar reach types or process domains and characterize bounds of indicator variables for each reach type. The geoindicators that are available to use are summarized below. The categorical variables describe the predominant character of the reach for each of the variables. The continuous variables were chosen for their ease of acquisition as well as for their general geomorphic importance. The file [*Database_reachcharacteristics.csv*](https://github.com/natalie-kramer/GeomorphicUpscale/blob/master/Database/Database_reachcharacteristics.csv) housed in the [Database](https://github.com/natalie-kramer/GeomorphicUpscale/tree/master/Database) folder contains these data for each stream in the database. 

### <u>Continuous Variables </u>
- **Gradient** ratio elevation drop over distance 
- **LWfreq** frequency of large wood in #/100m stream length
- **Braid** Braiding Index as total channel length over just the main channel length
- **Sinuousity** Curviness of reach, length of stream divided by straight line distance between start and end of reach.
- **D50**  median grains size in mm
- **Bldr** percentage of stream bed substrate made up of boulders
- **Cbl** percentage of stream bed substrate made up of cobbles
- **Gvl** percentage of stream bed substrate made up of gravel
- **Sndf** percentage of stream bed substrate made up of sand
- **bfw** bankful width in m
- **bfd** bankful depth in m

### <u>Categorical Variables</u>
- **Planform** Sinuous; Straight; Meandering; Wandering; Anabranching
- **Bedform**Plane Bed; Pool-Riffle; Step-Pool; Rapid; Cascade
- **Threads** Single; Transitional; Multi
- **Substrate** boulder-cobble-gravel-sand (Different combinations  of all four variables are possible)
- **Confinement** CV;PC; UCV (confined valley, partly confined valley, uconfined valley) 

You use these indicators to help you select a subset of the rivers in the database that are similar in character to each of your defined reach types.  You do not need to utilize all of the geo-indicator variables, just the ones that you think are most important for your reaches. We highly recommend that at the minimum you include gradient, the Bedform categorical variable and either the Braid continuous variable or the Threads categorical variable. 

For the Asotin example, we used the criterion in this table [](https://github.com/natalie-kramer/GeomorphicUpscale/tree/master/docs/assets/.PNG)

Although we used the same set of geoindicators for each river style and condition in the Asotin basin, you don't have to.  For example you could choose to use a D50 geoindicator for only one type of river style. It is important to recognize that you could have a River Style that is wandering, but the actual reach planform is something else, like straight.  This is because River Style usually takes a slightly broader view of the landscape around the reach, characterizing what the character of the planform should be if it was in good condition.  A disconnect between the River Style name and the geo-indicator planforms (or other characteristic) most often occur in reaches that are in poor or moderate condition. The main thing is to pick geoindicators that differentiate river styles and conditions.

## Step 2. Select Analogue Reaches from the Database
Once you have your indicators defined for your reach types and conditions, you are ready to use the indicator variables to help select empirical subsets.  You do this with using a series of logical statements that will subselect reaches from the database that meet your criteria.  The trick is not to be too restrictive - so that you end up with a large enough pool of sites to acquire a good empirical estimate; but restrictive enough - so that you don't end up with sites that are not good analogues.  We provide [*RSelection.R*](https://github.com/natalie-kramer/GeomorphicUpscale/blob/master/scripts/RSselection.R) as a starting point template script to help with the selections. To run these scripts you need R ([*download R Studio*](https://www.rstudio.com/products/rstudio/download/).  This script will authomatically save a *selections.csv* file to the Inputs folder within your project directory for use in the upscale.

An alternate way to select reaches is to simply hand select reaches from the database after reviewing their characteristics  [*(Database_reachcharacteristics.csv)*](https://github.com/natalie-kramer/GeomorphicUpscale/blob/master/Database/Database_reachcharacteristics.csv) and/or their GUT maps.  All Tier2 and Tier3 GUT maps of the reaches in the databse can be accessed by downloading and unpackaging [*Maps.zip*](https://github.com/natalie-kramer/GeomorphicUpscale/tree/master/Database/Maps.zip)  housed in the [Database](https://github.com/natalie-kramer/GeomorphicUpscale/tree/master/Database) folder.  If you choose to do hand selection you will want to make sure that your final selection table is a *.csv* file that relates visits in the database to each reach type and condition that you have mapped for your network.  At the minimum you need three columns:'visit', 'RS', and 'Condition. *visit* specifies the visit of the analogue reach in the empirical subset, *RS* specifies River Style category in a shorthand code, and *Condition* specifies the condition varient of the River Style. If you aren't differentiating condition, set this to 'NA'.  You can use the  example data [*selections.csv*](https://github.com/natalie-kramer/GeomorphicUpscale/blob/master/Exampledata/selections.csv), as a template.  In this example table, we carry over many database metrics other than 'visit', 'RS', and 'Condition', but these extra variables are not necessary for moving forward. You should save your manually created *selections.csv* file in an Inputs folder within your project directory.

## Step 3. Review and Refine your Selections
Once you have your lists of selections for each of reach types and conditions, it is useful to view the GUT output maps of to make sure that the reaches chosen are similar in character to your reaches.  To ease the review process, the script    [*MapsbyRSselection.R*](https://github.com/natalie-kramer/GeomorphicUpscale/blob/master/scripts/MapsbyRSselection.R) will copy maps from database folders to separate folders in your local directory that correspond to the reach typing categories in your *.csv* file from Step 2.  The [*RSelection.R*](https://github.com/natalie-kramer/GeomorphicUpscale/blob/master/scripts/RSselection.R) will do this for you.

You will want to throw out any sites within each grouping that don't fit before moving on to estimating geomorphic assemblages. If the selections just seem off as a whole or you would like greater numbers, you will want to go back and revise your initial selection. If the streams from the database just don't seem like good analogues, then be aware that the geomorphic assemblage estimates may not reflect reality for your situation. You may consider just upscaling the reaches where the selections decently the mimic geomorphic character of your reaches. When you are happy with your *selection.csv* file you are ready to move on!

## What's next?
Once you are happy with your selections and they are saved in your local project directory within an Inputs folder (see example data [*selections.csv*](https://github.com/natalie-kramer/GeomorphicUpscale/blob/master/AsotinUpscaleExample/Inputs/selections.csv)) You are now ready to [Estimate]({{ site.baseurl }}/4.Estimating) the assemblages and your fish response by geomorphic unit using your selections output.

## References

Brierley, G.J. and Fryirs, K.A. 2005. Geomorphology and River Management: Applications of the River Styles Framework. Blackwell Publications, Oxford, UK.

