---
layout: post
title: Analyzing the voting pattern of German parliament
category: r
---

Inspired by a [paper by Mladen Kolar](http://arxiv.org/abs/0812.5087), I visualize the votting pattern amongst members of the current German parliament from 26.11.2013 - 14.04.2016, during which it passed 136 recorded bills. I downloaded the data [here](https://www.bundestag.de/abstimmung) and the both the aggregated data and the code used to produce the figures below are available at [Github](http://arxiv.org/abs/1510.05677).

Missing values, invalid votes, abstention from voting and not showing up vor the vote was coded as a separate category (-1), such that all other responses are a yes (1) or no (2) vote. 36 of the 659 members of parliaments were removed from the data because more than 50% of the votes were coded as -1. The reason was that they either joined or left the parliament during the analyzed period of time.

As we look at the pull population, I simply compute weighted sample (population) correlation matrices to illustrate the changing voting patterns over time. In order to smoothen change, I slide a Gaussian weight kernel with standard deviation .15 and mean t through the time series, where t is the time point at which we compute the correlation matrix.

Here are the networks for the time points .25 and .75 in the normalized [0,1] time interval: green edges (positive correlation) indicate that two politicians tend to vote for/against the same bills. If the correlation is 1, they vote identically. The reverse is true for red edges (negative correlations).

![center](http://jmbh.github.io//figs/2016-04-24-Analyzing-Voting-Pattern-of-German-Parliament/bundestag18_cor_t25.jpg) 

![center](http://jmbh.github.io//figs/2016-04-24-Analyzing-Voting-Pattern-of-German-Parliament/legend.jpg) 

Talk about clusters .... Introduce second plot

![center](http://jmbh.github.io//figs/2016-04-24-Analyzing-Voting-Pattern-of-German-Parliament/bundestag18_cor_t25.jpg) 

Some more blabla
 

Next, we look into how strongly politicians vote with other politicians of their own and other parties. To this end we simply take the average of the corresponding sub-matrices of the weighted correlation matrices. For instance, we take all correlations between members of "DIE LINKE" and "CDU/CSU" and take the average of those. Repeated for all time steps, this gives us the following graph:


![center](http://jmbh.github.io//figs/2016-04-24-Analyzing-Voting-Pattern-of-German-Parliament/agreement_over_time.jpg) 




Last paragraph: more to do, data available!!