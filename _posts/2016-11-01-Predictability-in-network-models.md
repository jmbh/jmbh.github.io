---
layout: post
title: Predictability in Network Models
category: 
---

Network models have become a popular way to abstract complex systems and gain insights into relational patterns among observed variables in [almost any area of science](http://www.sachaepskamp.com/files/NA/NetworkTakeover.pdf). The majority of these applications focuses on analyzing the structure of the network. However, if the network is not directly observed (Alice and Bob are friends) but *estimated* from data (there is a relation between smoking and cancer), we can analyze - in addition to the network structure - the predictability of the nodes in the network. That is, we would like to know: how well can an arbitrarily picked node in the network predicted by all remaining nodes in the network?

Predictability is interesting for several reasons:

1. it gives us an idea of how *practically relevant* edges are: if node A is connected to many other nodes but these only explain, let's say, 1% of its variance, how interesting are these edges connecting A to other nodes?
2. we get an indication of how to design an *intervention* in order to achieve a change in a certain set of nodes and we can estimate how efficient the intervention will be
3. it tells us to which extent different parts of the network are *self-determined* or determined by other factors that are not included in the network

In this blogpost, we use the R-package [mgm](https://cran.r-project.org/web/packages/mgm/index.html) to estimate a network model and compute node wise predictability measures for a [dataset](http://cpx.sagepub.com/content/3/6/836.short) on [Post Traumatic Stress Disorder (PTSD)](https://en.wikipedia.org/wiki/Posttraumatic_stress_disorder) symptoms of [Chinese earthquake victims](https://en.wikipedia.org/wiki/2008_Sichuan_earthquake). We visualize the network model and predictability using [the qgraph package](https://cran.r-project.org/web/packages/qgraph/index.html) and discuss how the combination of network model and node wise predictability can be used to design effective interventions on the symptom network.


Load Data
------

We load the data which the authors made freely available:

{% highlight r %}
data <- read.csv('http://psychosystems.org/wp-content/uploads/2014/10/Wenchuan.csv')
data <- na.omit(data)
p <- ncol(data)
dim(data)
[1] 344  17
{% endhighlight %}

The datasets contains complete responses to 17 PTSD symptoms of 344 individuals. The answer categories for the intensity of symptoms ranges from 1 'not at all' to 5 'extremely'. The exact wording of all symptoms is in the [paper of McNally and colleagues](http://cpx.sagepub.com/content/3/6/836.short).


Estimate Network Model
------

We estimate a [Mixed Graphical Model (MGM)](http://www.jmlr.org/proceedings/papers/v33/yang14a.pdf), where we treat all variables as continuous-Gaussian variables. Hence we set the type of all variables to `type = 'g'` and the number of categories for each variable to 1, which is the default for continuous variables `lev = 1`:

{% highlight r %}
library(mgm)
fit_obj <- mgmfit(data = data, 
                  type = rep('g', p),
                  lev = rep(1, p),
                  rule.reg = 'OR')
{% endhighlight %}

For more info on how to estimate Mixed Graphical Models using the mgm package see [this previous post](http://jmbh.github.io/Estimation-of-mixed-graphical-models/) or the [mgm paper](https://arxiv.org/pdf/1510.06871v2.pdf).


Compute Predictability of Nodes
------

After estimating the network model we are ready to compute the predictability for each node. Node wise predictability (or error) can be easily computed, because the graph is estimated by taking each node in turn and regressing all other nodes on it. As a measure for predictability we pick the propotion of explained variance, as it is straight forward to interpret:  0 means the node at hand is not explained at all by other nodes in the nentwork, 1 means perfect prediction. We centered all variables before estimation in order to remove any influence of the intercepts. For a detailed description of how to compute predictions and to choose predictability measures, [check out this preprint](https://arxiv.org/abs/1610.09108). In case there are additional variable types (e.g. categorical) in the network, we can choose an apropriate measure for these variables (e.g. % correct classification, see `?predict.mgm`).

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
jpeg(paste0(figDir, 'McNallyNetwork.jpg'), width = 1500, height = 1500)
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

We see that intrusive memories, traumatic dreams and flashbacks cluster together. Also, we observe that avoidance of thoughts (avoidth) about trauma interacts with avoidance of acitivies reminiscent of the trauma (avoidact) and that hypervigilant (hyper) behavior is related to feeling easily startled (startle). But there are also less obvious interactions, for instance between anger and concentration problems.

Now, if we would like to reduce sleep problems, the network model suggests to intervene on the variables anger and startle. But what the network structure does not tell us is *how much* we could possibly change sleep through the variables anger and startle. The predictability measure gives us an answer to this question: 53.1%. If the goal was to intervene on amnesia, we see that all adjacent nodes in the network explain only 32.7% of its variance. In addition, we see that there are many small edges connected to amnesia, suggesting that it is hard to intervene on amnesia via other nodes in the symptom network. Thus, one would possibly try to find additional variables that are not included in the network that interact with amnesia or try to intervene on amnesia directly. 

Of course, there are limitions to interpreting explained variance as predicted treatment outcome: first, we cannot know the causal direction of the edges, so any edge could point in one or both directions. However, if there is no edge, there is also no causal effect in any direction. Also, it is often reasonable to combine the network model with general knoweldge: for instance, it seems more likely that amnesia causes being upset than the other way around. Second, we estimated the model on cross-sectional data (each row is one person) and hence assume that all people are the same, which is an assumption that is always violated to some extent. To solve this problems one would need (many) repeated measurements of a single person, in order to estimate a model specific to that person. This also solves the first problem to some degree as we can use the direction of time to decide on causality.


Compare Within vs. Out of Sample Predictability
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

As to be expected, the explained variance is higher in the training dataset. This is because we fit the model to structure that is specific to the training data and is not present in the population (noise). Note that both means are lower than the mean we would get by taking the mean of the explained variances above, because we used less observation to estimate the model and hence have less power to detect edges.

While the explained variance values are lower in the test set, there is a strong correlation between the explained variance of a node in the training- and the test set

{% highlight r %}
cor(pred_obj_train$error$Error, pred_obj_test$error$Error)
[1] 0.8018155
{% endhighlight %}

which means that if a node has high explained variance in the training set, it tends to also have a high explained variance in the test set.









