---
layout: post
title: Regression with Interactions Terms - how Centering Predictors influences Main Effects
category: random
---

Centering predictors in a regression model with only main effects has no influence on the main effects. In contrast, in a regression model including interaction terms centering predictors *does* have an influence on the main effects. After getting confused by this, I read [this](https://amstat.tandfonline.com/doi/pdf/10.1080/10691898.2011.11889620) nice paper on the topic and played around with the examples in R. I summarized the resulting notes and code snippets in this blogpost.

We give an explanation on two levels:

1. By illustrating the issue with the simplest possible example
2. By showing in general how main effects are a function of the constants (e.g. means) that are substracted from predictor variables


Explanation 1: Simplest example
-----


The simplest possible example to illustrate the issue is a regression model in which variable $$Y$$ is a linear function of variables $$X_1$$, $$X_2$$ and their product $$X_1X_2$$

$$
Y = \beta_0 + \beta_1 X_1 + \beta_2 X_2 + \beta_3 X_1X_2 + \epsilon,
$$

where we set $$\beta_0 = 1, \beta_1 = 0.3, \beta_2 = 0.2, \beta_3 = 0.2$$, and $$\epsilon \sim N(0, \sigma^2)$$ is a draw from a Gaussian distribution with mean zero and variance $$\sigma^2$$. We define the predictors $$X_1, X_2$$ as Gaussians with means $$\mu_{X_1} = \mu_{X_2} = 1$$ and $$\sigma_{X_1}^{2}=\sigma_{X_2}^{2}=1$$. This code samples $$n = 10000$$ observations from this model:

