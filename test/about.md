---
title: 'Diabetes predictor using Decision Tree algorithm'
subtitle: ""

author: ""
date: ''
output:
  html_document:
    df_print: paged
    toc: no
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







### Summary of data used to build Decision Tree model 
<table class="table" style="width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> pregnant </th>
   <th style="text-align:right;"> glucose </th>
   <th style="text-align:right;"> pressure </th>
   <th style="text-align:right;"> triceps </th>
   <th style="text-align:right;"> insulin </th>
   <th style="text-align:right;"> mass </th>
   <th style="text-align:right;"> pedigree </th>
   <th style="text-align:right;"> age </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Min. </td>
   <td style="text-align:right;"> 0.00000 </td>
   <td style="text-align:right;"> 56.0000 </td>
   <td style="text-align:right;"> 24.00000 </td>
   <td style="text-align:right;"> 7.00000 </td>
   <td style="text-align:right;"> 14.0000 </td>
   <td style="text-align:right;"> 18.20000 </td>
   <td style="text-align:right;"> 0.0850000 </td>
   <td style="text-align:right;"> 21.0000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1st Qu. </td>
   <td style="text-align:right;"> 1.00000 </td>
   <td style="text-align:right;"> 99.0000 </td>
   <td style="text-align:right;"> 62.00000 </td>
   <td style="text-align:right;"> 21.00000 </td>
   <td style="text-align:right;"> 76.7500 </td>
   <td style="text-align:right;"> 28.40000 </td>
   <td style="text-align:right;"> 0.2697500 </td>
   <td style="text-align:right;"> 23.0000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Median </td>
   <td style="text-align:right;"> 2.00000 </td>
   <td style="text-align:right;"> 119.0000 </td>
   <td style="text-align:right;"> 70.00000 </td>
   <td style="text-align:right;"> 29.00000 </td>
   <td style="text-align:right;"> 125.5000 </td>
   <td style="text-align:right;"> 33.20000 </td>
   <td style="text-align:right;"> 0.4495000 </td>
   <td style="text-align:right;"> 27.0000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Mean </td>
   <td style="text-align:right;"> 3.30102 </td>
   <td style="text-align:right;"> 122.6276 </td>
   <td style="text-align:right;"> 70.66327 </td>
   <td style="text-align:right;"> 29.14541 </td>
   <td style="text-align:right;"> 156.0561 </td>
   <td style="text-align:right;"> 33.08622 </td>
   <td style="text-align:right;"> 0.5230459 </td>
   <td style="text-align:right;"> 30.8648 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 3rd Qu. </td>
   <td style="text-align:right;"> 5.00000 </td>
   <td style="text-align:right;"> 143.0000 </td>
   <td style="text-align:right;"> 78.00000 </td>
   <td style="text-align:right;"> 37.00000 </td>
   <td style="text-align:right;"> 190.0000 </td>
   <td style="text-align:right;"> 37.10000 </td>
   <td style="text-align:right;"> 0.6870000 </td>
   <td style="text-align:right;"> 36.0000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Max. </td>
   <td style="text-align:right;"> 17.00000 </td>
   <td style="text-align:right;"> 198.0000 </td>
   <td style="text-align:right;"> 110.00000 </td>
   <td style="text-align:right;"> 63.00000 </td>
   <td style="text-align:right;"> 846.0000 </td>
   <td style="text-align:right;"> 67.10000 </td>
   <td style="text-align:right;"> 2.4200000 </td>
   <td style="text-align:right;"> 81.0000 </td>
  </tr>
</tbody>
</table>



```
Error in eval(predvars, data, env): object 'ID' not found
```

### Algorithm performance

```
Error: `data` and `reference` should be factors with the same levels.
```



### References


