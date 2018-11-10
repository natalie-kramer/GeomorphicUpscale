---
title: Selecting
---

#Selection

We sample the existing database based on geomorphic incicators to predict geomorphic assemblages for River Styles defined on the  network of interest.  

The geoindicator variables that you will be able to select in the database include 11 continuous variables and five categorical. The categorical variables describe the predominant character of the reach for each of the variables. The continuous variables were chosen for their ease of acquisition as well as for their general geomorphic importance. The file describing each of these variables for each stream in the base database is in the ExampleData folder and is called *Database_reachcharacteristics*.csv

<u>Continuous Variables</u>
**Gradient** (ratio)
**LWfreq** (frequency of large wood in #/100m stream length)
**Braid** (Braiding Index as total channel length over just the main channel length)
**Sinuousity**
**D50**
**Bldr** (percentage of stream bed substrate made up of boulders)
**Cbl** (percentage of stream bed substrate made up of cobbles)
**Gvl** (percentage of stream bed substrate made up of gravel)
**Sndf** (percentage of stream bed substrate made up of sand)
**bfw** (bankful width in m)
**bfd** (bankful depth in m)

<u>Categorical Variables</u>
**Planform**- [Sinuous, Straight, Meandering, Wandering, Anabranching]
**Bedform**-[Plane Bed, Pool-Riffle, Step-Pool, Rapid, Cascade]
**Threads**- [Single, Transitional, Multi]
**Substrate** [boulder-cobble-gravel-sand] Different combinations  of all four variables are possible
**Confinement** [CV,PC, UCV] confined valley, partly confined valley, uconfined valley, 

##Step 1.
The first step in the selection process is to define River Styles and Geomorphic Condition for your network of interest.  You will need to characterize bounds of the above indicator variables for each river style.  You do not need to utilize all of the geo-indicator variables, just the ones that you think are most important for your reaches.  We are simply using these indicators to help us select a subset of the rivers in the database that are similar in character to your defined River Style and Condition.  You will create a definition look up table for each of your river styles with geomorphic conditions. We provide an example of one such lookup table as *AsotinReachSelectionCriteria.csv* in the Example data folder.

In this table we provide as separate columns the upper and lower limits for the continuous variables and provide lists of all possible categorical descriptors separated by a semicolon.  For example, in the Asotin, Poor Condition Fan Controlled reaches are almost all characterized by Plane Bed whereas Moderate Condition Fan Controlled reaches could be Plane bed OR Pool-Riffle (Plane Bed; Pool-Riffle). A prettier, more easily readible version of this table is below  to give you the gist.  You can choose what variables to select on for each River Style and Condition, but you MUST supply a column labelled "C" which contains and estimate of the average or median braiding index for the River Style and condition. This variable is used as a scalar to to adjust channel area for multi threads.

##Step 2.
Once you have your indicators defined for your river styles and conditions you are ready to use the indicator variables to help select empirical subsets and thus estimated assemblages and fish densities for each of your River Style and Condition.  You do this with using a series of logical statements that will subselect reaches from the database that meet your criteria.  The trick is not to be too restrictive so that you end up with a large enough pool of sites to acquire a good empirical estimate, but not so restrictive that you end up with sites that don't look like your defined River Style.  We provide *RSelection.R* as a starting point script with the Asotin as an example.


##Step 3. 
View GUT output maps of  reach selections to make sure that the reaches chosen are similar in river style to your reaches.  Throw out any sites within each grouping that don't fit and re-run step 2 for that river style. Step 2 will output which visits were selected for each river style category and then you can run XXXXX to put maps corresponding to selected river styles into separate folders for ease of viewing.

##Step 4.
Once you are happy with your selections You are now ready to [Upscale]({{ site.baseurl }}/3.Upscale) using the assemblage and density estimate outputs from Step 2.


## Source Code

These scripts use R and has dyplr package dependencies




