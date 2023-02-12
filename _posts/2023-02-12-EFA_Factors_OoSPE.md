---
layout: post
title: "Selecting the Number of Factors in Exploratory Factor Analysis via out-of-sample Prediction Errors"
date: 2023-02-12 12:00:00 +0100
categories: r
comments: true
#status: development
---

[Exploratory Factor Analysis](https://en.wikipedia.org/wiki/Exploratory_factor_analysis) (EFA) identifies a number of latent factors that explain correlations between observed variables. A key issue in the application of EFA is the selection of an adequate number of factors. This is a non-trivial problem because more factors always improve the fit of the model. Most methods for selecting the number of factors fall into two categories: either they analyze the patterns of eigenvalues of the correlation matrix, such as [parallel analysis](https://en.wikipedia.org/wiki/Parallel_analysis); or they frame the selection of the number of factors as a model selection problem and use approaches such as [likelihood ratio tests](https://en.wikipedia.org/wiki/Likelihood-ratio_test) or [information criteria](https://en.wikipedia.org/wiki/Model_selection#Criteria).

[In a recent paper](https://psycnet.apa.org/fulltext/2023-13984-001.html) we proposed a new method based on model selection. We use the connection between model-implied correlation matrices and standardized regression coefficients to do model selection based on out-of-sample prediction errors, as is common in the field of machine learning. We show in a simulation study that our method slightly outperforms other standard methods on average and is relatively robust across specifications of the true model. An implementation is available in the [R-package fspe](https://cran.r-project.org/web/packages/fspe/index.html), which I present here with a short code example.

We use a dataset with 24 measurements of cognitive tasks from 301 individuals from [Holzinger and Swineford (1939)](https://psycnet.apa.org/record/1939-04445-001). [Harman (1967)](https://books.google.com/books?hl=en&lr=&id=e-vMN68C3M4C&oi=fnd&pg=PR15&dq=Harman,+H.+H.+(1967).+Modern+factor+analysis.+University+of+Chicago+Press.&ots=t6OpGtgX1C&sig=AxyxKKP9Aj7y9vhIJotRfBkQamM) presents both a four- and five-factor solution for this dataset. In the four-factor solution, the fifth factor corresponding to the variables 20–24 is eliminated. For this reason, we exclude variables 20–24, which gives us an example dataset in which we would theoretically expect four factors. This reduced dataset is is included in the fspe-package:


{% highlight r %}
library(fspe)
data(holzinger19)
dim(holzinger19)
{% endhighlight %}



{% highlight text %}
## [1] 301  19
{% endhighlight %}



{% highlight r %}
head(holzinger19)
{% endhighlight %}



{% highlight text %}
##   t01_visperc t02_cubes t03_frmbord t04_lozenges t05_geninfo t06_paracomp
## 1          20        31          12            3          40            7
## 2          32        21          12           17          34            5
## 3          27        21          12           15          20            3
## 4          32        31          16           24          42            8
## 5          29        19          12            7          37            8
## 6          32        20          11           18          31            3
##   t07_sentcomp t08_wordclas t09_wordmean t10_addition t11_code t12_countdot
## 1           23           22            9           78       74          115
## 2           12           22            9           87       84          125
## 3            7           12            3           75       49           78
## 4           18           21           17           69       65          106
## 5           16           25           18           85       63          126
## 6           12           25            6          100       92          133
##   t13_sccaps t14_wordrecg t15_numbrecg t16_figrrecg t17_objnumb t18_numbfig
## 1        229          170           86           96           6           9
## 2        285          184           85          100          12          12
## 3        159          170           85           95           1           5
## 4        175          181           80           91           5           3
## 5        213          187           99          104          15          14
## 6        270          164           84          104           6           6
##   t19_figword
## 1          16
## 2          10
## 3           6
## 4          10
## 5          14
## 6          14
{% endhighlight %}
Next to providing the data to the `fspe()` function we specify that factor models with 1, 2, ... ,10 factors should be considered (`maxK = 10`), that the cross-validation scheme should use with 10 folds (`nfold = 10)` and be repeated 10 times (`rep = 10`), and that prediction errors (`method = "PE"`) should be used. An alternative method (`method = "CovE"`) computes an out-of-sample estimation error on the covariance matrix instead of a prediction error on the raw data. This is a method that is similar to the one proposed by [Browne & Cudeck (1989)](https://www.tandfonline.com/doi/abs/10.1207/s15327906mbr2404_4). Finally, we set a seed so that the analysis demonstrated here is fully reproducible. 



{% highlight r %}
set.seed(1)
fspe_out <- fspe(holzinger19,
                 maxK = 10,
                 nfold = 10,
                 rep = 10,
                 method = "PE", 
                 pbar = FALSE)
{% endhighlight %}

We can inspect the out-of-sample prediction error averaged across variables, folds, and repetitions as a function of the number of factors:


{% highlight r %}
par(mar=c(4.5,4,0,1))
plot.new()
plot.window(xlim=c(1,10), ylim=c(0.6, 0.8))
axis(1, 1:10)
axis(2, las=2)
title(xlab="Number of Factors", ylab="Out-of-sample Prediction Error")
points(which.min(fspe_out$PEs), min(fspe_out$PEs), cex=3, col="red", lwd=2)
lines(fspe_out$PEs, lwd=2)
abline(h=min(fspe_out$PEs), col="grey", lty=2, lwd=2)
{% endhighlight %}

<img src="/assets/img/2023-02-12-EFA_Factors_OoSPE.Rmd/unnamed-chunk-3-1.png" title="plot of chunk unnamed-chunk-3" alt="plot of chunk unnamed-chunk-3" style="display: block; margin: auto;" />
We see that the out-of-sample prediction error is minimized by the factor model with four factors. The number of factors with lowest prediction error can also be directly obtained from the output object:


{% highlight r %}
fspe_out$nfactor
{% endhighlight %}



{% highlight text %}
## [1] 4
{% endhighlight %}

The un-aggregated of the 10 repetiations of the cross-validation scheme can be found in `fspe_out$PE_array`.







