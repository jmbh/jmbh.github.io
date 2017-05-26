---
layout: post
title: Interactions between Categorical Variables in Mixed Graphical Models
category: r
---

{:center: style="text-align: center"}
In a [previous post](http://jmbh.github.io/Estimation-of-mixed-graphical-models/) we estimated a Mixed Graphical Model (MGM) on a dataset of *mixed variables* describing different aspects of the life of individuals diagnosed with Autism Spectrum Disorder, using the [mgm package](https://cran.r-project.org/web/packages/mgm/index.html). For interactions between continuous variables, the weighted adjacency matrix fully describes the underlying interaction parameter. Correspondinly, the parameters are represented in the graph visualization: the width of the edges is proportional to the absolute value of the parameter, and the edge color indicates the sign of the parameter. This means that we can clearly interpret an edge between two continuous variables as a positive or negative linear relationship of some strength.

Interactions between categorical variables, however, can involve several parameter that can describe non-linear relationships. A present edge between two categorical variables, or between a categorical and a continuous variable only tells us that there is *some* interaction. In order to find out the exact nature of the interaction, we have to look at all estimated parameters. This is what this blog post is about.

We first re-estimate the MGM on the Autism Spectrum Disorder (ADS) dataset from this [previous post](http://jmbh.github.io/Estimation-of-mixed-graphical-models/):


{% highlight r %}

set.seed(1)
fit_ADS <- mgm(data = autism_data_large$data, 
               type = autism_data_large$type,
               level = autism_data_large$level,
               k = 2, 
               lambdaSel = 'EBIC', 
               lambdaGam = 0.25)

{% endhighlight %}

We then plot the weighted adjacency matrix as in the previous blog post, however, we now group the variables by their type:

{% highlight r %}

groups_typeV <- list("Gaussian"=which(autism_data_large$type=='g'), 
                     "Poisson"=which(autism_data_large$type=='p'),
                     "Categorical"=which(autism_data_large$type=='c'))
                     
qgraph(fit_ADS$pairwise$wadj, 
       layout = 'spring', repulsion = 1.3,
       edge.color = fit_ADS$pairwise$edgecolor, 
       nodeNames = autism_data_large$colnames,
       color = autism_data_large$groups_color, 
       groups = groups_typeV,
       legend.mode="style2", legend.cex=.8, 
       vsize = 3.5, esize = 15)
       
dev.off()


{% endhighlight %}

The above code produces the following figure:

![center](http://jmbh.github.io/figs/2017-11-30-Closer-Look/Fig_mgm_application_Autism_byTypes.png) 

Red edges correspond to negative edge weights and green edge weights correspond to positive edge weights. The width of the edges is proportional to the absolut value of the parameter weight. Grey edges connect categorical variables to continuous variables or to other categorical variables and are computed from more than one parameter and thus we cannot assign a sign to these edges.

While the interaction between continuous variables can be interpreted as a conditional covariance similar to the well-known multivariate Gaussian case, the interpretation of edge-weights involving categorical variables is more intricate as they are comprised of several parameters. In the following two sections we show how to retrieve necessary parameters from the `fit_ADS` object in order to interpret interactions between continuous and categorical, and betwen categorical and categorical variables.

Interpretation of Interaction: Continuous - Categorical
------

We first consider the edge weight between the continuous Gaussian variable 'Working hours' and the categorical variable 'Type of Work', which has the categories (1) No work, (2) Supervised work, (3) Unpaid work and (4) Paid work. 

In order to get the necessary parameter, we look up in which row this pairwise interaction is listed in `fit_ADS$rawfactor$indicator[[1]]`. We look at the first list entry here, because we are looking for a pairwise interaction. If we estimated an MGM involving 3-way interactions, the 3-way interactions would be listed in the second list entry, etc. Here, however, we look for the pairwise interaction between 'Type of Work' (16) and 'Working hours' (17), and find it in row 86:

{% highlight r %}

> fit_ADS$rawfactor$indicator[[1]][86, ]
[1] 16 17

{% endhighlight %}

Using the row number, we can now look up all estimated parameters in `fit_ADS$rawfactor$weights`:

{% highlight r %}
> fit_ADS$rawfactor$weights[[1]][[86]]

[[1]]
[1] -14.6460488  -0.7576681   0.7576681   1.4885513

[[2]]
           [,1]
V16.2 0.5150313
V16.3 1.3871043
V16.4 1.7926628

{% endhighlight %}

The first entry corresponds to the regression on 'Type of Work' (16). Since we model the probability of every level of a categorical variable (see the [glmnet paper](http://www.ncbi.nlm.nih.gov/pmc/articles/PMC2929880/pdf/nihms201118.pdf) for a detailed explanation), we get for each of the four levels of 'Type of Work' a parameter for 'Working hours'. We see that there is a huge negative parameter for the first category of 'Type of Work', which is 'No work'. This makes sense, since in the data all individuals with no work logically also work 0 hours. The differences between the remaining categories are less strong. However, we see that the more hours one works, the more one is likely to be in category (4) 'Paid work'.

The second entry corresponds to the regression on 'Working hours' (17). Now the categorical variable is a predictor variable, which means that the first category is coded as a dummy category which is absorbed in the intercept. Note that we could also model all categories explicitly by using the overparameterized parameterization by setting `overparameterize = TRUE` in `mgm()`. Here we see that being in category (3) 'Unpaid work' predicts a larger amount of working hours than being in category (2) 'Supervised work', and that being in category (4) 'Paid work' predicts a larger amount of working hours than being in category (3) 'Unpaid work', which makes sense.

In order to interpret the interaction between 'Type of Work' (16) and 'Working hours' (17) one can choose either of the two regressions. One or the other regression may be more appropriate, depending on which interpretation is easier to understand, or depending on which regression reflects the more plausible causal direction.


Interpretation of Interaction: Categorical - Categorical
------

Next we consider the edge weight between the categorical variables (14) 'Type of Housing' and the variable (16) 'Type of Work' from above. 'Type of Housing' has two categories, (a) 'Not independent' and (b) 'Independent'. As in the previous example, we look up the row of the pairwise interaction in `fit_ADS$rawfactor$indicator[[1]]`:

{% highlight r %}
> fit_ADS$rawfactor$indicator[[1]][81, ]
[1] 14 16
{% endhighlight %}


{% highlight r %}

> fit_ADS$rawfactor$weights[[1]][[81]]
[[1]]
[[1]][[1]]
             [,1]
V16.2  0.00000000
V16.3 -0.08987943
V16.4 -0.62798733

[[1]][[2]]
            [,1]
V16.2 0.00000000
V16.3 0.08987943
V16.4 0.62798733


[[2]]
[1] -0.5882431 -0.1582227  0.1582227  1.7812274

{% endhighlight %}

The first entry of `fit_ADS$rawfactor$weights[[1]][[81]]` shows the interaction between (14) 'Type of Housing' and (16) 'Type of Work' from the regression on 'Type of Housing'. We predict the probability of both (a) 'Not independent' and (b) 'Independent'. 'Type of Work' is a predictor variable, hence the first category is a dummy category that gets absorbed in the intercept. We see that 'Unpaid Job' and 'Paid Job' increase the probability of living independently, whereas the latter does increase this probability more.

The second entry shows the same interaction from the regression on 'Type of Work'. We now have 4 parameters, corresponding to the 4 categories of 'Type of Work'. Since 'Type of Housing' has only two categories, and the first one (a) is a dummy category that gets absorbed in the intercept and only the indicator function for (b) is left as a predictor. We see that the better the works situation is, the higher the probability that the individual is living independently, which makes sense.

As above, in order to choose one of the two regressions in order to interpret the interaction, one might want to take the regression that is easier to interpret or/and the regression that reflects the more plausible causal direction.
