---
layout: post
title: Predictability in Network Models
category: r
---

Network models have become a popular way to abstract complex systems and gain insights into relational patterns among observed variables in [many areas of science](http://www.sachaepskamp.com/files/NA/NetworkTakeover.pdf). The majority of these applications focuses on analyzing the structure of the network. However, if the network is not directly observed (Alice and Bob are friends) but *estimated* from data (there is a relation between smoking and cancer), we can analyze - in addition to the network structure - the predictability of the nodes in the network. That is, we would like to know: how well can a given node in the network predicted by all remaining nodes in the network?

Predictability is interesting for several reasons:

1. It gives us an idea of how *practically relevant* edges are: if node A is connected to many other nodes but these only explain, let's say, only 1% of its variance, how interesting are the edges connected to A?
2. We get an indication of how to design an *intervention* in order to achieve a change in a certain set of nodes and we can estimate how efficient the intervention will be
3. It tells us to which extent different parts of the network are *self-determined or determined by other factors* that are not included in the network

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

set.seed(1)
fit_obj <- mgm(data = data, 
               type = rep('g', p),
               level = rep(1, p),
               lambdaSel = 'CV',
               ruleReg = 'OR')
{% endhighlight %}

For more info on how to estimate Mixed Graphical Models using the mgm package see [this previous post](http://jmbh.github.io/Estimation-of-mixed-graphical-models/) or the [mgm paper](https://arxiv.org/pdf/1510.06871v2.pdf).


Compute Predictability of Nodes
------

After estimating the network model we are ready to compute the predictability for each node. Node wise predictability (or error) can be easily computed, because the graph is estimated by taking each node in turn and regressing all other nodes on it. As a measure for predictability we pick the propotion of explained variance, as it is straight forward to interpret:  0 means the node at hand is not explained at all by other nodes in the nentwork, 1 means perfect prediction. We centered all variables before estimation in order to remove any influence of the intercepts. For a detailed description of how to compute predictions and to choose predictability measures, [check out this preprint](https://arxiv.org/abs/1610.09108). In case there are additional variable types (e.g. categorical) in the network, we can choose an appropriate measure for these variables (e.g. % correct classification, see `?predict.mgm`).

{% highlight r %}

pred_obj <- predict(object = fit_obj, 
                    data = data, 
                    errorCon = 'R2')

> pred_obj$error
    Variable Error.R2
1  intrusion    0.639
2     dreams    0.661
3      flash    0.601
4      upset    0.636
5    physior    0.627
6    avoidth    0.686
7   avoidact    0.681
8    amnesia     0.41
9    lossint     0.52
10   distant    0.498
11      numb    0.451
12    future     0.54
13     sleep    0.565
14     anger    0.562
15    concen    0.638
16     hyper    0.676
17   startle    0.626

{% endhighlight %}

We calculated the percentage of variance explained in each of the nodes in the network. Next, we visualize the estimated network and discuss its structure in relation to explained variance.

Visualize Network & Predictability
------

We provide the estimated weighted adjacency matrix and the node wise predictability measures as arguments to `qgraph()` ...

{% highlight r %}
library(qgraph)

qgraph(fit_obj$pairwise$wadj, # weighted adjacency matrix as input
       layout = 'spring', 
       pie = pred_obj$error[,2], # provide errors as input
       pieColor = rep('#377EB8',p),
       node.color = fit_obj$pairwise$edgecolor,
       labels = colnames(data))
       
{% endhighlight %}

... and get the following network visualization:

![center](http://jmbh.github.io/figs/2016-11-01-Predictability-in-network-models/McNellyNetwork.png) 

[[Click here for the original post with larger figures]](http://jmbh.github.io/Predictability-in-network-models/)

Each variable is represented by a node and the edges correspond to partial correlations, because in this dataset the MGM consists only of conditional Gaussian variables. The green color of the edges indicates that all partial correlations in this graph are positive, and the edge-width is proportional to the absolute value of the partial correlation. The blue pie chart behind the node indicates the predictability measure for each node (more blue = higher predictability).

We see that intrusive memories, traumatic dreams and flashbacks cluster together. Also, we observe that avoidance of thoughts (avoidth) about trauma interacts with avoidance of acitivies reminiscent of the trauma (avoidact) and that hypervigilant (hyper) behavior is related to feeling easily startled (startle). But there are also less obvious interactions, for instance between anger and concentration problems.

Now, if we would like to reduce sleep problems, the network model suggests to intervene on the variables anger and startle. But what the network structure does not tell us is *how much* we could possibly change sleep through the variables anger and startle. The predictability measure gives us an answer to this question: 53.1%. If the goal was to intervene on amnesia, we see that all adjacent nodes in the network explain only 32.7% of its variance. In addition, we see that there are many small edges connected to amnesia, suggesting that it is hard to intervene on amnesia via other nodes in the symptom network. Thus, one would possibly try to find additional variables that are not included in the network that interact with amnesia or try to intervene on amnesia directly. 


Limitations!
------

Of course, there are limitations to interpreting explained variance as predicted treatment outcome: first, we cannot know the causal direction of the edges, so any edge could point in one or both directions. However, if there is no edge, there is also no causal effect in any direction. Also, it is often reasonable to combine the network model with general knoweldge: for instance, it seems more likely that amnesia causes being upset than the other way around. Second, we estimated the model on cross-sectional data (each row is one person) and hence assume that all people are the same, which is an assumption that is always violated to some extent. To solve this problem we would need (many) repeated measurements of a single person, in order to estimate a model specific to that person. This also solves the first problem to some degree as we can use the direction of time as the direction of causality. One would then use models that predict all symptoms at time point t by all symptoms at an earlier time point, let's say t-1. An example of such a model is the [Vector Autoregressive (VAR) model](https://en.wikipedia.org/wiki/Vector_autoregression).


Compare Within vs. Out of Sample Predictability
------

So far we looked into how well we can predict nodes by all other nodes within our sample. But in most situations we are interested in the predictability of nodes in new, unseen data. In what follows, we compare the within sample predictability with the out of sample predictability.

We first split the data in two parts: a training part (60% of the data), which we use to estimate the network model and a test part, which we will use to compute predictability measures on:

{% highlight r %}
set.seed(1)
ind <- sample(c(TRUE,FALSE), prob=c(.6, .4), size=nrow(data), replace=T)
{% endhighlight %}

Next, we estimate the network only on the training data and compute the predictability measure both on the training data and the test data:

{% highlight r %}
set.seed(1)
fit_obj_ts <- mgm(data = data[ind,], 
               type = rep('g', p),
               level = rep(1, p),
               lambdaSel = 'CV',
               ruleReg = 'OR')

# Compute Preditions on training data 60%
pred_obj_train <- predict(object = fit_obj_ts, 
                          data = data[ind,], 
                          errorCon = 'R2')

# Compute Predictions on test data 40%
pred_obj_test <- predict(object = fit_obj_ts, 
                          data = data[!ind,], 
                          errorCon = 'R2')

{% endhighlight %}

We now look at the mean predictability over nodes for the training- and test dataset:

{% highlight r %}
mean(pred_obj_train$error[,2]) # mean explained variance training data
[1] 0.6258235

mean(pred_obj_test$error[,2]) # mean explained variance test data
[1] 0.4915882

{% endhighlight %}

As expected, the explained variance is higher in the training dataset. This is because we fit the model to structure that is specific to the training data and is not present in the population (noise). Note that both means are lower than the mean we would get by taking the mean of the explained variances above, because we used less observation to estimate the model and hence have less power to detect edges.

While the explained variance values are lower in the test set, there is a positive relationship between the explained variance of a node in the training- and the test set

{% highlight r %}
cor(pred_obj_train$error[,2], pred_obj_test$error[,2])
[1] 0.5539814
{% endhighlight %}

which means that if a node has high explained variance in the training set, it tends to also have a high explained variance in the test set.


Edit Nov 3rd: The AND- or OR-rule and Predictability
------

In the above example I used the OR-rule to combine estimates in the [neighborhood regression approach](http://www.jstor.org/stable/25463463), without justifying why (thanks to [Wagner de Lara Machado](https://scholar.google.com.br/citations?user=fH6qCDoAAAAJ&hl=en) for pointing this out). Here comes the explanation:

In the neighborhood regression approach to graph estimation we pick each node in the graph and regress all other nodes on this node. If we have three nodes $$x_1$$, $$x_2$$, $$x_3$$, this procedure leads to three regression models:

1. $$ x_1 = \beta_{10} + \beta_{12} x_2 + \beta_{13} x_3 $$
2. $$ x_2 = \beta_{20} + \beta_{21} x_1 + \beta_{23} x_3 $$
3. $$ x_3 = \beta_{30} + \beta_{31} x_1 + \beta_{32} x_2 $$

This procedure leads to two estimates for the edge between $$x_1$$ and $$x_2$$: $$\beta_{12}$$ from regression (1) and $$\beta_{21}$$ from regression (2). If both parameters are nonzero, we clearly set the edge between x1 and x2 to present, and if both parameters are zero, we clearly set the edge between $$x_1$$ and $$x_2$$ to not present. However, in some cases the two estimates disagree and we need a rule for this situation: The OR-rule sets an edge to be present if *at least one* of the estimates is nonzero. The AND-rule sets an edge to be present only if *both* estimates are nonzero.

Now, to compute predictions and hence a measure of predictability we use the regression models 1-3. Let's take regression model (3), where we predict $$x_3$$ by $$x_1$$ and $$x_2$$. Now, if the betas agree ($$\beta_{31}$$ and $$\beta_{13}$$ agree and $$\beta_{32}$$ and $$\beta_{23}$$ agree), everything is fine. But if there is disagreement, we have the following problem:

- When using the AND-rule: if let's say the parameter $$\beta_{32}$$ is nonzero but $$\beta_{23}$$ is zero, the AND rule sets the edge-parameter $$x_3$$-$$x_2$$ in the graph to zero; however the parameter $$\beta_{32}$$ will still be used for estimation of $$x_3$$. This leads to a predictability that is too high. Hence we could have a situation in which a node has no connection in the graph (obtained using the AND-rule) but has a nonzero predictability measure.

- When using the OR-rule: if the parameter $$\beta_{23}$$ is nonzero but $$\beta_{32}$$ is zero, the OR-rule sets the edge-parameter $$x_3$$-$$x_2$$ in the graph to be present; however we use the (zero) parameter $$\beta_{32}$$ in regression (3) for prediction. This leads to a predictability that is too small. Hence we could hae the situation that a node has a connetion in the graph but has a zero predictability measure.

Hence, when using the OR-rule, we *underestimate* the true predictability given the graph and hence get a *conservative* estimate of predictability in the graph. This is why I chose the OR-rule above.

Okay, but why don't we adjust the parameters of the regression models 1-3 by setting parameters to zero (AND-rule) or filling in parameters (OR-rule)? This is not possible, because tinkering with the parameters will destroy the prediction model in most situations.

A possible way around this would be to take the estimated graph and then re-estimate the graph (by performing p regressions) but only use those variables as predictors that were connected to the predicted node in the initial graph. However, this 2-stage procedure would lead to a (possibly) completely different scaling for the estimation of each of the neighborhoods of the different nodes. This is likely to lead to an algorithm that does not consistently recover the true graph/network.

