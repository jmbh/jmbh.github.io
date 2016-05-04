---
layout: post
title: Estimating Mixed Graphical Models
category: r
---

Determining conditional independence relationships through undirected graphical models is a key component in the statistical analysis of complex obervational data in a wide variety of disciplines. In many situations one seeks to estimate the underlying graphical model of a dataset that includes *variables of different domains*.

As an example, take a typical dataset in the social, behavioral and medical sciences, where one is interested in interactions, for example between gender or country (categorical), frequencies of behaviors or experiences (count) and the dose of a drug (continuous). Other examples are Internet-scale marketing data or high-throughput sequencing data. 

There are methods available to estimate mixed graphical models from mixed continuous data, however, these usually have two drawbacks: first, there is a possible information loss due to necessary transformations and second, they cannot incorporate (nominal) categorical variables (for an overview see [here](http://arxiv.org/abs/1510.05677)). A [new method](http://arxiv.org/abs/1510.06871) implemented in the R-package [mgm](https://cran.r-project.org/web/packages/mgm/index.html) addresses these limitations. 


In the following, we use the mgm-package to estimate the conditional independence network in a dataset of questionnaire responses of individuals diagnosed with Autism Spectrum Disorder. This dataset includes  variables of different domains, such as age (continuous), type of housing (categorical) and number of treatments (count).


The dataset consists of responses of 3521 individuals to a questionnaire including 28 variables of domains continuous, count and categorical and is available [here](https://github.com/jmbh/AutismData).


{% highlight r %}

datalist <- readRDS('autism_datalist.RDS')
data <- datalist$data
type <- datalist$type
lev <- datalist$lev

> dim(data)
 [1] 3521   28

> round(data[1:4, 1:5],2)
      sex IQ agediagnosis opennessdiagwp successself
 [1,]   1  6        -0.96              1        2.21
 [2,]   2  6        -0.52              1        6.11
 [3,]   1  5        -0.71              2        5.62
 [4,]   1  6        -0.45              1        8.00

{% endhighlight %}

We used our knowledge about the variables to specify the domain (type) of each variable and the number of categories for categorical variables (for non-categorical variables we choose 1). "c", "g", "p" stands for categorical, Gaussian and Poisson (count), respectively:

{% highlight r %}

> type
 [1] "c" "g" "g" "c" "g" "c" "c" "p" "p" "p" "p" "p" "p"
[14] "c" "p" "c" "g" "p" "p" "p" "p" "g" "g" "g" "g" "g"
[27] "c" "g"

> lev
 [1] 2 1 1 2 1 5 3 1 1 1 1 1 1 2 1 4 1 1 1 1 1 1 1 1 1 1 3
[28] 1

{% endhighlight %}

The estimation algorithm requires us to make an assumption about the highest order interaction in the true graph. Here we assume that there are at most pairwise interactions in the true graph and set d = 2. The algorithm includes an L1-penalty to obtain a sparse estimate. We can select the regularization parameter lambda using cross validation (CV) or the Extended Bayesian Information Criterion (EBIC). Here, we choose the EBIC, which is known to be a bit more conservative than CV but is computationally faster.


{% highlight r %}
library(mgm)

fit <- mgmfit(data, type, cat, lambda.sel="EBIC", d=2)

{% endhighlight %}


The fit function returns all estimated parameters and a weighted and unweighted (binarized) adjacency matrix. Here we use the [qgraph](http://www.jstatsoft.org/article/view/v048i04/v48i04.pdf) package to visualize the graph:


{% highlight r %}

# define group labels
groups_type <- list("Demographics"=c(1,14,15,28), 
                    "Psychological"=c(2,4,5,6,18,20,21),
                    "Social environment" = c(7,16,17,19,26,27),
                    "Medical"=c(3,8,9,10,11,12,13,22,23,24,25))

# pick some nice colors
group_col <- c("#72CF53", "#53B0CF", "#FFB026", "#ED3939")

# plot
library(qgraph)

qgraph(fit$adj, 
       vsize=3.5, 
       esize=4, 
       layout="spring", 
       edge.color = rgb(33,33,33,100, maxColorValue = 255), 
       color=group_col,
       border.width=1.5,
       border.color="black",
       groups=groups_type,
       nodeNames=datalist$colnames,
       legend=TRUE, 
       legend.mode="style2",
       legend.cex=.5)
             
{% endhighlight %}

![center](http://jmbh.github.io/figs/2015-10-31-Estimation-of-mixed-graphical-models/JSS_autism_figure.jpg) 


The data to reproduce this analysis can be found [here](https://github.com/jmbh/AutismData). More information about estimating mixed graphical models and the [mgm packagepackage](https://cran.r-project.org/web/packages/mgm/index.html) can be found [in this paper](http://arxiv.org/abs/1510.06871). [Here](http://arxiv.org/abs/1510.05677) is a paper explaining the theory behind the implemented algorithm.

Computationally efficient methods for Gaussian data are implemented in the [huge](https://cran.r-project.org/web/packages/huge/index.html) package and the [glasso](https://cran.r-project.org/web/packages/glasso/index.html) package. For binary data, there is the [IsingFit](https://cran.fhcrc.org/web/packages/IsingFit/index.html) package.

Great free resources about graphical models are Chapter 17 in the freely available book [The Elements of Statistical Learning](https://web.stanford.edu/~hastie/local.ftp/Springer/OLD/ESLII_print4.pdf) and the Coursera course [Probabilistic Graphical Models](https://www.coursera.org/course/pgm).

