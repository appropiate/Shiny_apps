---
subtitle: "Decision Tree algorithm"
title: 'Diabetes predictor'
author: "Sergio Carracedo Huroz"
date: 'July 2022'
output:
  bookdown::html_document2:
    toc: no
    toc_depth: 3
    base_format: prettydoc::html_pretty
  html_document:
    toc: yes
  bookdown::pdf_document2:
    df_print: paged
    toc: yes
    toc_depth: '3'
    extra_dependencies: float
  pdf_document:
    toc: yes
    toc_depth: '2'
header-includes:
 \usepackage{float}
 \floatplacement{figure}{H}
nocite: |
  @lantz2015machine
link-citations: yes
bibliography: scholar1.bib
editor_options: 
  chunk_output_type: console
---






### Summary of data used to build Decision tree model

```
    pregnant         glucose         pressure         triceps         insulin            mass          pedigree           age        diabetes 
 Min.   : 0.000   Min.   : 56.0   Min.   : 24.00   Min.   : 7.00   Min.   : 14.00   Min.   :18.20   Min.   :0.0850   Min.   :21.00   neg:262  
 1st Qu.: 1.000   1st Qu.: 99.0   1st Qu.: 62.00   1st Qu.:21.00   1st Qu.: 76.75   1st Qu.:28.40   1st Qu.:0.2697   1st Qu.:23.00   pos:130  
 Median : 2.000   Median :119.0   Median : 70.00   Median :29.00   Median :125.50   Median :33.20   Median :0.4495   Median :27.00            
 Mean   : 3.301   Mean   :122.6   Mean   : 70.66   Mean   :29.15   Mean   :156.06   Mean   :33.09   Mean   :0.5230   Mean   :30.86            
 3rd Qu.: 5.000   3rd Qu.:143.0   3rd Qu.: 78.00   3rd Qu.:37.00   3rd Qu.:190.00   3rd Qu.:37.10   3rd Qu.:0.6870   3rd Qu.:36.00            
 Max.   :17.000   Max.   :198.0   Max.   :110.00   Max.   :63.00   Max.   :846.00   Max.   :67.10   Max.   :2.4200   Max.   :81.00            
```




### Algorithm performance

```
Confusion Matrix and Statistics

          Reference
Prediction neg pos
       neg  64   5
       pos   3  24
                                          
               Accuracy : 0.9167          
                 95% CI : (0.8424, 0.9633)
    No Information Rate : 0.6979          
    P-Value [Acc > NIR] : 2.069e-07       
                                          
                  Kappa : 0.7984          
                                          
 Mcnemar's Test P-Value : 0.7237          
                                          
            Sensitivity : 0.9552          
            Specificity : 0.8276          
         Pos Pred Value : 0.9275          
         Neg Pred Value : 0.8889          
             Prevalence : 0.6979          
         Detection Rate : 0.6667          
   Detection Prevalence : 0.7188          
      Balanced Accuracy : 0.8914          
                                          
       'Positive' Class : neg             
                                          
```

# References


