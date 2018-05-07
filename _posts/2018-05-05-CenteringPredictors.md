---
layout: post
title: Regression with Interactions Terms - how Centering Predictors influences Main Effects
category: random
---

<script type="text/javascript" async
  src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-MML-AM_CHTML">
</script>

Centering predictors in a regression model with only main effects has no influence on the main effects. In contrast, in a regression model including interaction terms centering predictors *does* have an influence on the main effects. After getting confused by this, I read [this](https://amstat.tandfonline.com/doi/pdf/10.1080/10691898.2011.11889620) nice paper on the topic and played around with the examples in R. I summarized the resulting notes and code snippets in this blogpost.

We give an explanation on two levels:

1. By illustrating the issue with the simplest possible example
2. By showing in general how main effects are a function of the constants (e.g. means) that are substracted from predictor variables


Explanation 1: Simplest example
-----


The simplest possible example to illustrate the issue is a regression model in which variable $Y$ is a linear function of variables $X_1$, $X_2$ and their product $X_1X_2$

$$
Y = \beta_0 + \beta_1 X_1 + \beta_2 X_2 + \beta_3 X_1X_2 + \epsilon,
$$

where we set $\beta_0 = 1, \beta_1 = 0.3, \beta_2 = 0.2, \beta_3 = 0.2$, and $\epsilon \sim N(0, \sigma^2)$ is a draw from a Gaussian distribution with mean zero and variance $\sigma^2$. We define the predictors $X_1, X_2$ as Gaussians with means $\mu_{X_1} = \mu_{X_2} = 1$ and $\sigma_{X_1}^{2}=\sigma_{X_2}^{2}=1$. This code samples $n = 10000$ observations from this model:

{% highlight r %}

n <- 10000
b0 <- 1; b1 <- .3; b2 <- .2; b3 <- .2
set.seed(1)
x1 <- rnorm(n, mean = 1, sd = 1)
x2 <- rnorm(n, mean = 1, sd = 1)
y <- b0 + b1 * x1 + b2 * x2 + b3 * x1 * x2 + rnorm(n)

{% endhighlight %}


**Regression models with main effects**
  
  We first verify that centering variables indeed does not affect the main effects. To do so, we first fit the linear regression with only main effects with uncenetered predictors

{% highlight r %}
lm(y ~ x1 + x2)

Call:
  lm(formula = y ~ x1 + x2)

Coefficients:
  (Intercept)           x1           x2  
0.8088       0.4983       0.4015  
{% endhighlight %}

and then with centered predictors

{% highlight r %}
x1_c <- x1 - mean(x1) # center predictors
x2_c <- x2 - mean(x2)
lm(y ~ x1_c + x2_c)

Call:
  lm(formula = y ~ x1_c + x2_c)

Coefficients:
  (Intercept)         x1_c         x2_c  
1.7036       0.4983       0.4015  
{% endhighlight %}


The parameter estimates of the regression with uncentered predictors are $\hat\beta_1 \approx 0.50$ and $\hat\beta_2 \approx 0.40$. The estimates of the regression with *centered* predictors are $\hat\beta_1^* \approx 0.50$ and $\hat\beta_2^* \approx 0.40$ (we denote estimates from regressions with centered predictors with an asterisk). And indeed, $\hat\beta_1 = \hat\beta_1^*$ and $\hat\beta_2 = \hat\beta_2^*$.


**Regression models with main effects + interaction**
  
  We include the interaction term and show that centering the predictors now does *does* affect the main effects. We first fit the regression model without centering

{% highlight r %}
lm(y ~ x1 * x2)

Call:
  lm(formula = y ~ x1 * x2)

Coefficients:
  (Intercept)           x1           x2        x1:x2  
1.0183       0.2883       0.1898       0.2111  
{% endhighlight %}

and then with centering

{% highlight r %}
lm(y ~ x1_c * x2_c)

Call:
  lm(formula = y ~ x1_c * x2_c)

Coefficients:
  (Intercept)         x1_c         x2_c    x1_c:x2_c  
1.7026       0.4984       0.3995       0.2111  
{% endhighlight %}

We see that $\hat\beta_1 \approx 0.29$ and $\hat\beta_2 \approx 0.19$ and $\hat\beta_1^* \approx 0.50$ and $\hat\beta_2^* \approx 0.40$. While the two models have different parameters, they are statistically equivalent. Here this means that expected values of both models are the same. In empirical terms this means that their coefficient of determination $R^2$ is the same. The reader will be able to verify this in Explanation 2 below.

We make two observations: 
  
  1. In the model with interaction terms, the main effects differ between the regressions with/without centering of predictors
2. When centering predictors, the main effects are the same in the model with/without the interaction term (up to some numerical inaccuracy)

**Why does centering influence main effects in the presence of an interaction term?**
  
  The reason is that in the model with the interaction term, the parameter $\beta_1$ (uncentered predictors) is the main effect of $X_1$ on $Y$ if $X_2 = 0$, and the parameter $\beta_1^*$ (centered predictors) is the main effect of $X_1$ on $Y$ if $X_2 = \mu_{X_2}$. This means that $\beta_1$ and $\beta_1^*$ are modeling different effects in the data. Here is a more detailed explanation:
  
  Rewriting the model equation in the following way

$$
  \begin{aligned}
\mathbb{E}[Y] &= \beta_0 + \beta_1 X_1 + \beta_2 X_2 + \beta_3 X_1X_2 \\
&= \beta_0 + (\beta_1 + \beta_3 X_2) X_1 + \beta_2 X_2
\end{aligned}
$$
  
  shows that in the model with interaction term, the main effect of $X_1$ on $Y$ is equal to $(\beta_1 + \beta_3 X_2)$ and therefore a funtion of $X_2$. What the parameter $\beta_1$ model here? It models the effect of $X_1$ on $Y$ when $X_2 = 0$. Similarly we could rewrite the effect of $X_1$ on $Y$ as a function of $X_2$.

Now let $X_1^c = X_1 - \mu_{X_1}$ and $X_2^c = X_2 - \mu_{X_2}$ be the centered predictors. We get the same model equations, now with the parameters estimated using the centered predictors $X_1^c, X_2^c$:
  
  
  $$
  \begin{aligned}
\mathbb{E}[Y] &= \beta_0^* + \beta_1^* X_1^c + \beta_2^* X_2^c + \beta_3^* X_1^c X_2^c \\
&= \beta_0^* + (\beta_1^* + \beta_3^*  X_2^c) X_1^c + \beta_2^*  X_2^c \\
\end{aligned}
$$
  
  Again we focus on the main effect $(\beta_1^* + \beta_3^*  X_2^c)$ of $X_1^c$ on $Y$. What does the the parameter $\beta_1^*$ model here? It models the main effect of $X_1^c$ on $Y$ when $X_2^c = \mu_{X_2^c} = 0$. What remained the same is that $\beta_1^*$ is the main effect of $X_1^c$ on $Y$ when $X_2^c = 0$. But what is new is that $\mu_{X_2^c} = 0$.

Therefore, in the uncentered case $\beta_i$ is the main effect when the predictor variable $X_i$ is equal to zero. In the centered case, $\beta_i^*$ is the main effect when the predictor variable $X_i$ is equal to its mean. Clearly, $\beta_i$ and $\beta_i^*$ model different effects in the data and it is therefore not surprising that the two regressions give us very different estimates.


**Centering $\rightarrow$ interpretation of $\beta$ remains the same when adding interaction**
  
  Our second observation above was that the estimates of main effects are the same with/without interaction term when centering the predictor variables. This is because in the models *without* interaction term (centered or uncentered predictors) the interpretation of $\beta_1$ is the same as in the model *with* interaction term and centered predictors.

More precisely, in the regression model with only main effects, $\beta_1$ is the main effect of $X_1$ on $Y$ averaged over all values of $X_2$, which is the same as the main effect of $X_1$ on $Y$ for $X_2 = \mu_{X_2}$. This means that if we center predictors, $\beta_1$ models the same effect in the data in a model with/without interaction term. This is an attractive property to have when one is interested in comparing models with/without interaction term. It is therefore the main reason to center predictors in regressions with interaction terms, next to reducing the correlations between single predictors and product interaction terms.


