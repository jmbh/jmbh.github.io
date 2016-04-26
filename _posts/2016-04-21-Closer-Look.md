---
layout: post
title: A closer look at interactions between categorical variables in mixed graphical models
category: r
---

In a [previous post](http://jmbh.github.io/_posts/2015-11-30-Estimation-of-mixed-graphical-models.md) we recovered the conditional independence structure in a [dataset](https://github.com/jmbh/AutismData) of *mixed variables* describing different aspects of the life of individuals diagnosed with Autism Spectrum Disorder using the [mgm package](https://cran.r-project.org/web/packages/mgm/index.html). While depicting the independence structure in multivariate data set gives a first overview of the relations between variables, in most applications we interested in the exact parameter estimates. For instance, for interactions between continuous variables, we would like to know the sign and the size of parameters. In the case of interactions between categorical variables, we are interested in the signs and sizes of the set of parameters that describes the (possibly) non-linear relationship between variables.

In this post, we take the analysis a step further and show how to use the output of the [mgm package](https://cran.r-project.org/web/packages/mgm/index.html) to take a closer look at the recovered dependencies. Specificly, we will recover the sign and weight of interaction parameter between continuous variables and zoom into interactions between categorical and continuous variables and between two categorical variables. The dataset and code used are available on [Github](https://github.com/jmbh/AutismData).

We start out with the conditional dependence graph estimated in the previous post, however, now with variables grouped by their type:

![center](http://jmbh.github.io/figs/2017-11-30-Closer-Look/Autism_VarTypes.jpg) 

We obtained this graph by fitting a mixed graphical model using the mgmfit() function:


{% highlight r %}

library(mgm)
fit <- mgmfit(data, type, cat, lamda.sel="EBIC", d=2)

{% endhighlight %}

We now also display the weights of the dependencies. For interactions between continuous (Gaussian, Poisson) variables, we can also recover the sign of the dependency, as it only depends on one parameter:


![center](http://jmbh.github.io/figs/2017-11-30-Closer-Look/Autism_VarTypes_sign.jpg) 

Red edges correspond to negative edge weights and green edge weights correspond to positive edge weights. The width of the edges are proportional to the absolut value of the parameter weight. Grey edges connect categorical variables to continuous variables or other categorical variables and are computed from more than one parameter and thus we cannot assign a sign to these edges.


