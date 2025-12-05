---
layout: post
title: "New Preprint: Model Checking for Vector Autoregressive Models"
date: 2025-12-04 09:00:00 +0100
categories: r
comments: true
---

Time series have become pervasive in psychological research and Vector Autoregressive (VAR) models have become one of the most popular classes of models to study within-person dynamics in such data. However, systematic checking of how well a VAR model fits the data is hardly ever performed. This is a problem, because model misfit can lead both to incorrect interpretations of model parameters and to missing effects in the data that would be theoretically interesting. We provide a tutorial that explains the theory behind model checking, introduces the most common types of VAR model misspecification in the context of psychological time series, and introduces diagnostics for them, using plots and simulations. We then apply these tools to assess model fit for a multilevel VAR model estimated on a typical empirical dataset of emotion measurements over three weeks of 179 persons. We conclude by discussing three complementary areas of research that could improve the modeling of psychological time series in the future. The preprint is available [here](https://osf.io/preprints/psyarxiv/k6uz4_v2) and [here](https://github.com/jmbh/ModelCheckingForVAR) is a Github repository with the R-code to reproduce all analyses shown in the paper.