---
layout: post
title: Predictability in Network Models
category: r
---

[[Click here for the original post with larger figures]](http://)

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

We treat all variables as continous and hence set the type of all variables to `type = 'g'` and the number of categories for each variable to 1, which is the default for continuous variables `lev = 1`:

{% highlight r %}
{% endhighlight %}

The remaining arguments are tuning parameters, a detailed description of these can be found in the [mgm paper](https://arxiv.org/pdf/1510.06871v2.pdf).



Compute Predictability of Nodes
------

- explain what we do, what the function returns
- mention that we could have mixed variables
- refer to paper for detail

{% highlight r %}
{% endhighlight %}

- shortly discuss predictability measures, reiterate intepretation

Visualize Network & Predictability
------

- explain qgraph arguments, explain edge.color

{% highlight r %}
{% endhighlight %}

- intepreat graph
  - green edges: only positive
  - blue pie chart indicates the predictability returned above
  - not that easy to infer predictability (variance explained) by network structure (e.g. amnesia)
  - some interpretation of clusters
  - some conclusions about possible interventions, drawn from the graph


![center](http://jmbh.github.io/figs/2017-11-30-Closer-Look/Autism_VarTypes.jpg) 



Compare within vs. out of sample Predictability
------


{% highlight r %}
{% endhighlight %}










