---
title: Estimating
---

Go back to [home]({{ site.baseurl }})

# Overview
In order to upscale modelling responses at the reach scale that are within the database.  Click here for a [review of which data are available]({{ site.baseurl }}\5.Upscaling) within the regional database, ({{ site.baseurl }})


# Estimate

The next step is to empirically estimate geomorphic assemblages and modelling responses for each River Style and Condition variants in your network.   These scripts use as input the local directory path to summaries of GUT output.  The summary files for the reaches in the Database are located in the [*Metrics*](https://github.com/natalie-kramer/GeomorphicUpscale/tree/master/Database/Metrics)  folder housed in the [Database](https://github.com/natalie-kramer/GeomorphicUpscale/tree/master/Database) folder.  These metric summaries were generated using the [Supporting RTools associated with PyGUT](https://github.com/Riverscapes/pyGUT/tree/master/SupportingTools/RScripts/Development). 

## Step 1: Estimate Assemblages

You will estimate the geomorphic assemblage (percent of bankful reach area taken up by each geomorphic landform type) for each of your reach type and condition variants using the function *assemblage()* in the script  [*assemblage.R*](https://github.com/natalie-kramer/GeomorphicUpscale/tree/master/scripts/assemblage.R).  The script takes as input the local directory path to [*Metrics*](https://github.com/natalie-kramer/GeomorphicUpscale/tree/master/Database/GUTMetrics) as well as your selections table generated from the previous  [Select and Review](({{site.baseurl}}/2.Selecting) step.  You will also need to identify which GUT layer you want to estimate assemblages for: *Tier2_InChannel_Transitions* or *Tier3_InChannel*.  See [PyGUT webpage](https://riverscapes.github.io/pyGUT/background.html) for background documentation on these layers.

There are two functions within assemblage.R: *assemblage()* and *assemblagechart()*. 

* *assemblage()* will produce a list of  two tables *$assemblage_stat* and *$assemblage_est*. Example tables for the Asotin were exported to the [ExampleData](https://github.com/natalie-kramer/GeomorphicUpscale/tree/master/ExampleData) folder.  
  * *$assemblage_stat*  includes the summary stats for each landform for each river style and condition varient including sample size (# of reaches containing that landform type within the empirical selection for a certain RScond varient).  
  * *assemblage_est* summarizes only the estimate of the percent area for each landform for each RScond.  The values are the average percent areas, re-normalized so that the sum of all percents will equal 100.  
* *assemblagechart()* will graphically display the assemblage using values from *assemblage_est* as input.

Example assemblage outputs from the Asotin for Tier 2 Transition and Tier 3 GUT outputs are shown below.

![Tier 2data](https://github.com/natalie-kramer/GeomorphicUpscale/tree/master/docs/assets/Tier2_assemblage.PNG)

![Tier 2chart](https://github.com/natalie-kramer/GeomorphicUpscale/tree/master/docs/assets/Tier3_InChannel_Transition_assemblage.tiff)

![Tier 3data](https://github.com/natalie-kramer/GeomorphicUpscale/tree/master/docs/assets/Tier3_assemblage.PNG)

![Tier 3chart](https://github.com/natalie-kramer/GeomorphicUpscale/tree/master/docs/assets/Tier3_InChannel_assemblage.tiff)

## Step 2: Estimate the Response Variable by Unit 
Responses in the database available to upscale are fish capacity predictions as well as percent suitable habitat for NREI and HSI models of steelhead salmon.  The fish capacity predictions predict actual individual fish locations summarized as density of fish by geomorphic unit type. Percent suitable habitat is the percent of each geomorphic unit type in which the model showed fish could be present. Please refer to  the [Familiarize page]({{site.baseurl}}/1.Familiarizing) for further explanation of the response variables. These estimates can be summarized over all selected reaches or pooled by river reach type, reach type and condition. 

If you would like to upscale a different variable, you need to provide a table similar to: XXXX  in which your response is related to each geomorphic unit type.  You can have your response differ between river reach and condition variants or stay the same across variants. your choice.

The script [response.R]() provides several functions.

## What's next?
Once you have acquired your estimates and have two .csv tables that look like  [Asotin_Tier3_assemblage_est](https://github.com/natalie-kramer/GeomorphicUpscale/tree/master/ExampleData/Asotin_Tier3_assemblage_est.csv) and [](), you are now ready to [upscale]({{ site.baseurl }}\5.Upscaling) your results to the  river network. 

Go back to [home]({{ site.baseurl }})




