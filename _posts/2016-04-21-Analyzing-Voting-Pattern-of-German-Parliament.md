---
layout: post
title: Analyzing voting pattern of German parliament
category: r
---

Inspired by a [paper by Mladen Kolar](http://arxiv.org/abs/0812.5087), in this post I visualize the votting pattern amongst members of the current German parliament from 26.11.2014 - 14.04.2016, during which it passed 136 recorded bills. I downloaded the data [here](https://www.bundestag.de/abstimmung) and the aggregated data and the code used to produce the figures below are available at [Github](http://arxiv.org/abs/1510.05677).

Missing values, invalid votes, abstention from voting and not showing up vor the vote was coded as a separate category (-1), such that all other responses are a yes (1) or no (2) vote. 36 of the 659 members of parliaments were removed from the data because more than 50% of the votes were coded as -1. The reason was that they either joined or left the parliament during the analyzed period of time.

As we look at the full population of interest, I simply calculate the sample (population) correlation matrix between members of parliament. In order to get an idea of how the voting pattern changes across time, I estimate the graph at 10 equally spaced time steps. At each of the time steps t, we assign a weighting to all cases which is defined by a Gaussian kernel with mean t and standard deviation .15.

Here are the networks for the time points .25 and .75 in the normalized [0,1] time interval: green edges (positive correlation) indicate that two politicians tend to vote for/against the same bills. If the correlation is 1, they vote identically. The reverse is true for red edges (negative correlations).

![center](http://jmbh.github.io//figs/2016-04-24-Analyzing-Voting-Pattern-of-German-Parliament/bundestag18_cor_t25.jpg) 

![center](http://jmbh.github.io//figs/2016-04-24-Analyzing-Voting-Pattern-of-German-Parliament/legend.jpg) 

One can...
 