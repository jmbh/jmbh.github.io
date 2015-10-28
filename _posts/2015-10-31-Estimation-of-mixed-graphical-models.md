---
layout: post
title: Estimating mixed graphical models
category: R
---

Determining conditional independence relationships through undirected graphical models is a key component in the statistical analysis of complex obervational data in a wide variety of disciplines. In many situations one seeks to estimate the underlying graphical model of a dataset that includes variables on different domains.

For instance is a typical dataset in the social, behavioral and medical sciences, where one is interested in interactions, for example between gender or country (categorical), frequencies of behaviors or experiences (count) and the dose of a drug (continuous). Other examples are Internet-scale marketing data or high-throughput sequencing data. 


There are already methods to estimate mixed graphical models from continuous data, however, these usually have two drawbacks: first, there is a possible information loss due to necessary transformations and second, they cannot incorporate nominal categorical variables (for an overview see [here](http://arxiv.org/abs/1510.05677).


A [new method](http://arxiv.org/abs/1510.06871) implented in the R-package [mgm](https://cran.r-project.org/web/packages/mgm/index.html) addresses these limiation. In the following, I use the mgm-package to estimate the conditional independence network of a dataset consisting




{% highlight r %}
#some code

hist(rnorm(100,1,1))
{% endhighlight %}

![center](http://jmbh.github.io/figs/2015-10-31-Estimation-of-mixed-graphical-models/unnamed-chunk-1-1.png) 




References
--------
