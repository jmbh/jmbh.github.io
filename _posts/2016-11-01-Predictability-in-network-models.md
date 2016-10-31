---
layout: post
title: Predictability in Network Models
category: 
---

Network models are [everywhere](http://www.sachaepskamp.com/files/NA/NetworkTakeover.pdf).

....

Network models (or Graphical models) have become a popular way to abstract complex systems and gain insights into relational patterns among observed variables. Applications are found in basically any field field of of science, running the gammut from statistical mechanics, biology, neuroscience and XX to XX and XX. Many software packages are available to estimate network models (e.g. [huge](https://cran.r-project.org/web/packages/huge/index.html), [glasso](https://cran.r-project.org/web/packages/glasso/index.html), [mgm](https://cran.r-project.org/web/packages/mgm/index.html)) and to visualize them (e.g. [igraph](https://cran.r-project.org/web/packages/igraph/index.html), [qgraph](https://cran.r-project.org/web/packages/qgraph/index.html), [ggnet2](https://briatte.github.io/ggnet/), [ggraph](https://github.com/thomasp85/ggraph)). This allows the analysis of the network structure both visually and using network analysis tools.

If the network is not directly observed (Alice and Bob are friends) but *estimated* from data (there is a relation between smoking and cancer), we can analyze - in addition to the network structure - the predictability of the nodes in the network. That is, we would like to know: 'how well can an arbitrarily picked node in the network predicted by all remaining nodes in the network?'

This is often interesting information because it gives us an indication of how practically relevant edges are: for example if node A is connected to many other nodes but these only explain, let's say, 1% of its variance, how much do I care about these edges? The question of predictability is especially interesting in settings where the goal is to design effective interventions on a network, like in medicine: if a symptom S (e.g. insomnia) of a syndrome is poorly predicted by other nodes in the network, there is little chance that we can intervene efficiently on S via the network. In such a situation we would need to find additional variables or try to intervene on S directly (e.g. by administering sleeping pills).

In this blogpost we show how to estimate a network, compute predictability of its nodes and visualize both together using the R-packages [mgm](https://cran.r-project.org/web/packages/mgm/index.html) and [qgraph](https://cran.r-project.org/web/packages/qgraph/index.html). As an example data set we use a publicly available dataset on [Post Traumatic Stress Disorder (PTSD) symptoms reported by survivors](http://cpx.sagepub.com/content/3/6/836.short) of the [Wenchuan earthquake in China 2008](https://en.wikipedia.org/wiki/2008_Sichuan_earthquake).



Load Data
------

We load the data which the authors made freely available:

{% highlight r %}
data <- read.csv('http://psychosystems.org/wp-content/uploads/2014/10/Wenchuan.csv')
dim(data)
{% endhighlight %}

The datasets contains complete responses to 17 PTSD symptoms of 344 individuals. The answer categories for the intensity of symptoms ranges from 1 'not at all' to 5 'extremely'.


Estimate Network Model
------

We treat all variables as continuous and hence set the type of all variables to `type = 'g'` and the number of categories for each variable to 1, which is the default for continuous variables `lev = 1`:

{% highlight r %}
library(mgm)
fit_obj <- mgmfit(data = data, 
                  type = rep('g', p),
                  lev = rep(1, p),
                  rule.reg = 'OR')
{% endhighlight %}

We combine estimates from the neighborhood regression procedure using the OR-rule. For details and info about this and other tuning parameters check the [mgm paper](https://arxiv.org/pdf/1510.06871v2.pdf). [In a previous post I](http://jmbh.github.io/Estimation-of-mixed-graphical-models/) showed in more detail how to use the `mgmfit()` function to fit Mixed Graphical Models. [This paper](http://www.jstor.org/stable/25463463) by Meinshausen and Buehlmann shows that we use the neighborhood regression approach to estimate the whole graph.


Compute Predictability of Nodes
------

Now that we obtained the network model we compute the predictability of each node, that is, how well we can predict any given node by all other nodes in the network. The predictability (or error) measure can be easily computed next to estimation, because we estimate the graph by taking each node and regressing all other nodes on it. We have to choose a specific measure and pick the proportion of explained variance, as it is straight forward to interpret: 0 means the node at hand is not explained at all by other nodes in the nentwork, 1 means perfect prediction. We centered all variables before estimation in order to remove any influence of the intercepts. For a detailed description of how to compute predictions and to choose predictability measures, [check out this paper](https://arxiv.org/abs/1610.09108). In case we are additional variable types (e.g. categorical) in the network, we can choose an apropriate measure for these variables (e.g. %correct classification).

{% highlight r %}
pred_obj <- predict(fit_obj, data, 
                    error.continuous = 'VarExpl')

> pred_obj$error
    Variable Error ErrorType
1  intrusion 0.583   VarExpl
2     dreams 0.590   VarExpl
3      flash 0.513   VarExpl
4      upset 0.615   VarExpl
5    physior 0.601   VarExpl
6    avoidth 0.648   VarExpl
7   avoidact 0.626   VarExpl
8    amnesia 0.327   VarExpl
9    lossint 0.419   VarExpl
10   distant 0.450   VarExpl
11      numb 0.333   VarExpl
12    future 0.450   VarExpl
13     sleep 0.531   VarExpl
14     anger 0.483   VarExpl
15    concen 0.604   VarExpl
16     hyper 0.602   VarExpl
17   startle 0.605   VarExpl

{% endhighlight %}

We calculated the percentage of variance explained in each of the nodes in the network. Next, we visualize the estimated network and discuss its structure in relation to explained variance.


Visualize Network & Predictability
------

We provide the estimated weighted adjacency matrix and the node wise predictability measures as arguments to `qgraph()` ...

{% highlight r %}
library(qgraph)
jpeg(paste0(figDir, 'McNellyNetwork.jpg'), width = 1500, height = 1500)
qgraph(fit_obj$wadj, # weighted adjacency matrix as input
       layout = 'spring', 
       pie = pred_obj$error$Error, # provide errors as input
       pieColor = rep('#377EB8',p),
       node.color = fit_obj$edgecolor,
       labels = colnames(data))
dev.off()
{% endhighlight %}

... and get the following network visualization:

![center](http://jmbh.github.io/figs/2016-11-01-Predictability-in-network-models/McNellyNetwork.jpg) 

[[Click here for the original post with larger figures]](http://)

Each variable is represented by a node and the edges correspond to partial correlations, because in this dataset the MGM consists only of conditional Gaussian variables. The green color of the edges indicates that all partial correlations in this graph are positive, and the edge-width is proportional to the absolute value of the partial correlation. The blue pie chart behind the node indicates the predictability measure for each node.

We can make many observations about the interactions between symptoms: for example, we see that intrusive memories, traumatic dreams and flashbacks cluster together. We see that avoidance of thoughts (avoidth) about trauma interacts with avoidance of acitivies reminiscent of the trauma (avoidact) and that hypervigilant (hyper) behavior is related to feeling easily startled (startle). But there are also less obvious interactions, for instance between anger and concentration problems.

Now, if we are interested in designing interventions, we can use the network model to judge their efficiency: if we would like to work on sleep problems, the network model suggests to intervene on the variables anger and startle. But what the network structure does not tell us is *how much* we could possibly change sleep through the variables anger and startle. The predictability measure gives us an answer to this question: 53.1%. If the goal was to intervene on Amnesia, we see that all adjacent nodes in the network explain only 32.7% of its variance. In addition, we see that there are many small edge weights, suggesting that it is hard to intervene on amnesia via other nodes in the symptom network. Thus, one could try to find additional variables that are not included in the network that interact with amnesia or try to intervene on amnesia directly. 

Of course there are limitions to interpreting explained variance as predicted treatment outcome. First, we cannot know the causal direction of the edges, so any edge could point in one or both directions. However, if there is no edge, there is also no causal effect in any direction. Also, it is often reasonable to combine the network model with general knoweldge: for instance, it seems more likely that amnesia causes being upset than the other way around. Second, we estimated the model on cross-sectional data and hence assume that all people are the same, which is an assumption that likely to be violated. To solve this problems one would need (many) repeated measurements of a single person, in order to estimate a model specific to that person. This also solves the first problem to some extent as we can use the direction of time to decide on causality.


Compare: Within vs. Out of Sample Predictability
------

So far we looked into how well we can predict nodes by all other nodes within our sample. But in most situations we are interested in the predictability of nodes in new, unseen data. In what follows, we compare the within sample predictability with the out of sample predictability.

We first split the data in two parts: a training part (60% of the data), which we use to estimate the network model and a test part, which we will use to compute predictability measures on:

{% highlight r %}

set.seed(1)
ind <- sample(c(TRUE,FALSE), prob=c(.6, .4), size=nrow(data), replace=T) # divide data in 2 parts (60% training set, 40% test set)
{% endhighlight %}

Next, we estimate the network only on the training data and compute the predictability measure both on the training data and the test data:

{% highlight r %}
fit_obj_cv <- mgmfit(data = data[ind,], 
                    type = rep('g', p),
                    lev = rep(1, p),
                    rule.reg = 'OR')

pred_obj_train <- predict(fit_obj_cv, data[ind,], error.continuous = 'VarExpl') # Compute Preditions on training data 60%
pred_obj_test <- predict(fit_obj_cv, data[!ind,], error.continuous = 'VarExpl')# Compute Predictions on test data 40%

{% endhighlight %}

We now look at the mean predictability over nodes for the training- and test dataset:

{% highlight r %}
mean(pred_obj_train$error$Error) # mean explained variance training data
[1] 0.5384118

mean(pred_obj_test$error$Error) # mean explained variance test data
[1] 0.4494118
{% endhighlight %}

As to be expected, the explained variance is higher in the training dataset. This is because we fit the model to structure that is specific to the training data and is not present in the population (noise!). Note that both means are lower than the mean we would get by taking the mean of the explained variances above, because we used less observation to estimate the model and hence have less power to detect edges.

While the explained variance values are lower in the test set, there is a strong correlation between the explained variance of a node in the training- and the test set:

{% highlight r %}
cor(pred_obj_train$error$Error, pred_obj_test$error$Error)
[1] 0.8018155
{% endhighlight %}

This means that if a node has high explained variance in the training set, it tends to also have a high explained variance in the test set.




