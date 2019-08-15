shape.fill = c('Concavity' = '#004DA8', 
              'Planar' = '#E6E600', 
              'Convexity' = '#A80000')

shape.levels=c("Concavity", "Planar", "Convexity")

form.fill = c('Bowl' = '#004DA8', 
              'Bowl Transition' = '#00A9E6', 
              'Trough' = '#73DFFF', 
              'Plane' = '#E6E600', 
              'Mound Transition' = '#FF7F7F', 
              'Saddle' = '#E69800', 
              'Mound' = '#A80000', 
              'Wall' = '#000000')

form.levels=c("Bowl", "Mound", "Saddle","Trough", "Plane", "Wall")
form.t.levels=c("Bowl", "Bowl Transition", "Mound", "Mound Transition", "Saddle",
           "Trough", "Plane", "Wall")


gu.fill = c('Bank' = '#000000', 
            'Barface'="red", #this needs to be changed to match GIS coloring
            'Pool' = '#004DA8', 
            'Pond' = '#0070FF', 
            'Pocket Pool' = '#73B2FF', 
            'Chute' = '#73FFDF', 
            'Rapid' = '#66CDAB', 
            'Cascade' = '#448970',
            'Glide-Run' = '#E6E600', 
            'Riffle' = '#E69800',
            'Step' = '#D7B09E', 
            'Mid Channel Bar' = '#895A44', 
            'Margin Attached Bar' = '#A80000',
            'Transition' = '#CCCCCC')

gu.levels=c("Pocket Pool","Pool", "Pond", 
         "Margin Attached Bar","Mid Channel Bar","Barface",  "Riffle",
         "Cascade", "Rapid", "Chute" ,
         "Glide-Run", "Transition", "Bank")


condition.fill = c(
            'good' = "green" ,
            'mod' = 'yellow', 
            'poor' = "red")

condition.levels=c("poor", "mod", "good")
