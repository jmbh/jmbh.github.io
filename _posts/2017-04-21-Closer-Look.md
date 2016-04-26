---
layout: post
title: A closer look at interactions between categorical variables in mixed graphical models
category: 
---

In a [previous post](http://jmbh.github.io/_posts/2015-11-30-Estimation-of-mixed-graphical-models.md) we recovered the conditional independence structure in a [dataset](https://github.com/jmbh/AutismData) of *mixed variables* describing different aspects of the life of individuals diagnosed with Autism Spectrum Disorder using the [mgm package](https://cran.r-project.org/web/packages/mgm/index.html). While depicting the independence structure in multivariate data set gives a first overview of the relations between variables, in most applications we interested in the exact parameter estimates. For instance, for interactions between continuous variables, we would like to know the sign and the size of parameters. In the case of interactions between categorical variables, we are interested in the signs and sizes of the set of parameters that describes the (possibly) non-linear relationship between variables.

In this post, we take the analysis a step further and show how to use the output of the [mgm package](https://cran.r-project.org/web/packages/mgm/index.html) to take a closer look at the recovered dependencies. Specificly, we will recover the sign and weight of interaction parameter between continuous variables and zoom into interactions between categorical and continuous variables and between two categorical variables. The dataset and code used are available on [Github](https://github.com/jmbh/AutismData).

We start out with the conditional dependence graph estimated in the previous post, however, now with variables grouped by their type:

![center](http://jmbh.github.io/figs/2017-11-30-Closer-Look/Autism_VarTypes.jpg) 

We obtained this graph by fitting a mixed graphical model using the mgmfit() function:


{% highlight r %}
datalist <- readRDS('autism_datalist.RDS') # available on Github
data <- datalist$data
type <- type
lev <- datalist$lev

library(mgm)
fit <- mgmfit(data, type, lev, lamda.sel="EBIC", d=2)

{% endhighlight %}

We now also display the weights of the dependencies. For interactions between continuous (Gaussian, Poisson) variables, we can additionally determine the sign of the dependency, as it only depends on one parameter. We first take the sub matrix of continuous - continuous interactions:

{% highlight r %}

# get signs out of model parameter matrix
ind <- which(fit$par.labels %in%  which(type!='c'))
signs <- sign(fit$mpar.matrix[ind, ind])
diag(signs) <- 0

{% endhighlight %}

fit$par.labels indicates which column/row in the parameter matrix coresponds to which variables. For categorical variables, there is more than one column/row in the parameter matrix. For a detailed explanation of the parameters in fit$mpar.matrix, see [this paper](http://arxiv.org/abs/1510.06871).

We now construct a matrix that gives colors to edges, depending on whether the corresponding edge weight is positive/negative (for interactions between continuous variables) or undefined (for interactions involving categorical variables):


{% highlight r %}

# add signs to weighted adjacency matrix
wgraph <- fit$wadj
wgraph[which(lev==1), which(lev==1)] <- wgraph[which(lev==1), which(lev==1)]*signs

# define colors of edges: sign obtainable (green/red) or not (grey)
edgeColor <- wgraph
edgeColor[edgeColor!=0] <- 999
edgeColor[which(lev==1), which(lev==1)] <- signs
edgeColor[edgeColor==-1] <- 'firebrick2'
edgeColor[edgeColor==1] <- 'chartreuse4'
edgeColor[edgeColor==999] <- 'grey'
edgeColor[edgeColor==0] <- 'orange' #just to fill

colnames(graph) <- datalist$colnames

# define variable types
groups_typeV <- list("Gaussian"=which(datalist$type=='g'), 
                     "Poisson"=which(datalist$type=='p'),
                     "Categorical"=which(datalist$type=='c'))

# pick some nice colors
group_col <- c("#72CF53", "#53B0CF", "#ED3939")

{% endhighlight %}

Finally, we plot the graphical model with edge weights and signs (where defined) using qgraph:

{% highlight r %}

library(qgraph)

qgraph(wgraph, 
       vsize=3.5, 
       esize=5, 
       layout=Q0$layout, # this gives us the same layout as in the graph above
       edge.color = edgeColor, 
       color=group_col,
       border.width=1.5,
       border.color="black",
       groups=groups_typeV,
       nodeNames=datalist$colnames,
       legend=TRUE, 
       legend.mode="style2",
       legend.cex=1.5)


{% endhighlight %}


![center](http://jmbh.github.io/figs/2017-11-30-Closer-Look/Autism_VarTypes_sign.jpg) 

Red edges correspond to negative edge weights and green edge weights correspond to positive edge weights. The width of the edges are proportional to the absolut value of the parameter weight. Grey edges connect categorical variables to continuous variables or other categorical variables and are computed from more than one parameter and thus we cannot assign a sign to these edges.

Let's now have a closer look at an interaction between the Gaussian variable 'Working hours' and the categorical variable 'Type of Work'.

{% highlight r %}

library(mgm)
fit <- mgmfit(data, type, cat, lamda.sel="EBIC", d=2)

{% endhighlight %}










