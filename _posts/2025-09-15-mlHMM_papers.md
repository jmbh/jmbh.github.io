---
layout: post
title: "Two New Preprints on Multilevel Hidden Markov Models"
date: 2025-09-15 09:00:00 +0100
categories: 
comments: true
---

Hidden Markov models (HMMs) are powerful models to capture the complex behaviours of psychological processes that switch between different latent states. Examples include manic and depressive states in bipolar disorder, recovery and relapse states as seen in addiction, and "normal" and "depressive" mood states in major depressive disorder. In addition to detecting latent mood/behavior states empirically, each of which is associated with different subjective experiences, HMMs model the tendency to switch between different latent states over time. For instance, inferring the probability of remaining in a depressive state or switching to a manic state from one moment to the next. This is something that typically used models (e.g., autoregressive models) cannot do. Emmeke Aarts and myself have two new preprints on multilevel HMMs: In the first (https://osf.io/preprints/psyarxiv/prm3t_v1), we provide gentle introduction to multilevel HMMs and a fully reproducible tutorial on model specification, estimation, selection, and interpretation on EMA emotion time series dataset. In the second  (https://osf.io/preprints/psyarxiv/b5mxk_v2) we conduct an extensive simulation study to evaluate whether existing software works as intended and how well multilevel HMMs can be estimated in typical time series designs in psychology.