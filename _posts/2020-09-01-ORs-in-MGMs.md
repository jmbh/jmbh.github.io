---
layout: post
title: "Computing Odds Ratios from Mixed Graphical Models"
date: 2020-08-25 12:00:00 +0100
categories: r
comments: true
#status: development
---

Interpreting statistical network models typically involves interpreting individual edge parameters. If the network model is a Gaussian Graphical Model (GGM), the interpretation is relatively simple: the pairwise interaction parameters are partial correlations, which indicate conditional linear relationships and vary from -1 to 1. Using the standard deviations of the two involved variables, the partial correlation can also be transformed into a linear regression coefficient (see for example [here](https://arxiv.org/abs/1609.04156])). However, when studying interactions involving categorical variables, such as in an Ising model or a Mixed Graphical Model (MGM), the parameters are not limited to a certain range and their interpretation is less intuitive. In these situations it may be helpful to report the interactions between variables in terms of odds ratios.


### Odds Ratios

Odds Ratios are made up of odds, which are themselves a ratio of probabilities

$$
\text{Odds} = \frac{P(X_1=1)}{P(X_1=0)}.
$$
Since we chose to put $P(X_1=1)$ in the numerator, we interpret these odds as the "odds being in favor of $X_1=1$". For example, if $X_1$ is the symptom sleep problems which takes the values 0 (no sleep problems) with probability 0.75 and the value 1 (sleep problems) with probability 0.25, then the odds of having sleep problems are 1 to 4.

However, these odds may be different in different circumstances. Let's say these circumstances are captured by variable $X_2$ which takes values in $\{0,1\}$. In our example, those circumstances could be whether you live next to a busy street (1) or not (0). If the odds indeed depend on $X_2$ then we have

$$
\text{Odds}_{X_2=1} = \frac{P(X_1=1 \mid X_2=1)}{P(X_1=0 \mid X_2=1)} \neq
\frac{P(X_1=1 \mid X_2=0)}{P(X_1=0 \mid X_2=0)} = \text{Odds}_{X_2=0}
.
$$

A way to quantify the degree to which the odds are different depending whether we set $X_2=1$ or $X_2=0$ is to divide the odds in those two situations

$$
\text{Odds Ratio} = \frac{\text{Odds}_{X_2=1}}{\text{Odds}_{X_2=0}}
,
$$

which gives rise to an odds ratio (OR). 

How do we interpret this odds ratio? If the OR is equal to 1, then $X_2$ has no influence on the odds between $P(X_1=1)$ and $P(X_1=0)$; if OR > 1, $X_2=1$ *increases* the odds compared to $X_2=0$; and if OR < 1, $X_2=1$ *decreases* the odds compared to $X_2=0$. In our example from above, an OR = 4 would imply that the odds of sleep problems (vs. no sleep problems) are four times larger when living next to a busy street (vs. not living next to a busy street).

In the remainder of this blog post, I will illustrate how to compute such odds ratios based on MGMs estimated with the R-package [*mgm*](https://cran.r-project.org/web/packages/mgm/index.html).


### Loading Example Data

We use a data set on Autism Spectrum Disorder (ASD) which contains $n=3521$ observations of seven variables, gender (1 = male, 2 = female), IQ (continuous), Integration in Society (3 categories ordinal), Number of comorbidities (count), Type of housing (1 = supervised, 2 = unsupervised), working hours (continuous), and satisfaction with treatment (continuous).



{% highlight r %}
library(mgm) # data is loaded with mgm package (version 1.2-11)
head(autism_data$data)
{% endhighlight %}



{% highlight text %}
##   Gender   IQ Integration in Society No of Comorbidities Type of Housing Workinghours
## 1      1 6.00                      1                   1               1            0
## 2      2 6.00                      2                   1               1            0
## 3      1 5.00                      2                   0               1            0
## 4      1 6.00                      1                   0               1           10
## 5      1 5.00                      1                   1               1            0
## 6      1 4.49                      1                   1               1            0
##   Satisfaction: Treatment
## 1                    3.00
## 2                    2.00
## 3                    4.00
## 4                    3.00
## 5                    1.00
## 6                    1.75
{% endhighlight %}


For more details on this data set have a look at [this previous blog post](http://jmbh.github.io/Estimation-of-mixed-graphical-models/).


### Fitting MGM

We model gender, integration in society and type of housing as categorical variables (with 2, 3 and 2 categories), and all remaining variables as Gaussian variables


{% highlight r %}
set.seed(1)
mod <- mgm(data = autism_data$data, 
           type =  c("c", "g", "c", "g", "c", "g", "g"), 
           level = c(2, 1, 3, 1, 2, 1, 1), 
           lambdaSel = "CV", 
           ruleReg = "AND",
           pbar=FALSE)
{% endhighlight %}



{% highlight text %}
## Note that the sign of parameter estimates is stored separately; see ?mgm
{% endhighlight %}

and we visualize the dependencies of the resulting model using the [qqgraph](https://cran.r-project.org/web/packages/qgraph/index.html) package:



{% highlight r %}
library(qgraph)
qgraph(mod$pairwise$wadj, 
       nodeNames = autism_data$colnames, 
       edge.color = mod$pairwise$edgecolor,
       # edge.labels = TRUE,
       legend = TRUE, 
       layout = "spring")
{% endhighlight %}

<img src="/assets/img/2020-09-01-ORs-in-MGMs.Rmd/unnamed-chunk-3-1.png" title="plot of chunk unnamed-chunk-3" alt="plot of chunk unnamed-chunk-3" style="display: block; margin: auto;" />


### Example Calculation of Odds Ratio

We consider the simplest possible example of calculating the OR involving two binary variables. Note that we calculate the OR between two variables within a multivariate model. This means that the OR is conditional on all other variables in the model which implies that it can be different from the OR calculated based on those two variables alone (specifically, this will always happen when at least one additional variable is connected to both binary variables.)

Some of you might know that there is a simple relationship between the OR and the coefficients in logistic regression. Since multinomial regression with two outcomes is equivalent to logistic regression, we could use this simple rule in this specific example. Here, however, we start out with the definition of OR and show how to calculate it in the general case of $\geq 2$ categories. Along the way, we'll also derive the simple relationship between parameters and ORs for the binary case.

In our data set we use the two binary variables type of housing and gender for illustration. Specifically, we look at how the odds of type of housing change as a function of gender. Corresponding to the column numbers of the two variables, let $X_5$ be type of housing, and $X_1$ gender. 

The definition of ORs above shows that we need to calculate four conditional probabilities. We first calculate $P(X_5=1 \mid X_1=0)$ and $P(X_5=0 \mid X_1=0)$ in the numerator. To compute these probabilities, we need the estimated parameters of the multinomial regression on $X_5$. In the standard parameterization of multinomial regression one of the response categories serves as the reference category (see [here](https://en.wikipedia.org/wiki/Multinomial_logistic_regression)). The regularization used within the mgm package allows more direct parameterization in which the probability of each response category can be modeled directly (for details see Chapter 4 in [this paper](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2929880/) on the [glmnet](https://cran.r-project.org/web/packages/glmnet/index.html) package). We therefore get a set of parameters for *each* response category. 

We can find those parameters in `mod$nodemodels[[5]]` which contains the parameters of the multinomial regression on variable $X_5$:


{% highlight r %}
coefs <- mod$nodemodels[[5]]$model
coefs
{% endhighlight %}



{% highlight text %}
## $`1`
## 8 x 1 sparse Matrix of class "dgCMatrix"
##                       1
## (Intercept)  0.62372320
## V1.2        -0.38147442
## V2.         -0.42186120
## V3.2         0.13918915
## V3.3        -0.04001268
## V4.          0.01414994
## V6.         -0.22024227
## V7.          0.04346463
## 
## $`2`
## 8 x 1 sparse Matrix of class "dgCMatrix"
##                       1
## (Intercept) -0.62372320
## V1.2         0.38147442
## V2.          0.42186120
## V3.2        -0.13918915
## V3.3         0.04001268
## V4.         -0.01414994
## V6.          0.22024227
## V7.         -0.04346463
{% endhighlight %}

The first set of parameters in `coefs[[1]]` models $P(X_5 = 0 \mid  \dots)$ and the second set of parameters in `coefs[[2]]` models $P(X_5 = 1 \mid  \dots)$.

The data set contains seven variables, which means that we have six variables that predict variable 5. However, since variable 3 (Integration in Society) is a categorical variable with three categories, it is represented by two dummy variables that code for its 2nd and 3rd category. This is why we have a total of 5*1+2=7 predictor variables and 7 associated parameters.

Now, back to computing those probabilities in the enumerator. We would like to compute $P(X_5=1 \mid X_1=0)$ and $P(X_5=0 \mid X_1=0)$, however we see that the probability of $P(X_5)$ not only depends on $X_1$ but also on all other variables (none of the parameters are zero). We therefore need to fix all variables to some value in order to obtain a conditional probability. That is, we actually have to write the conditional probabilities as $P(X_5=1 \mid X_1, X_2, X_3, X_4, X_6, X_7)$ and $P(X_5=0 \mid X_1, X_2, X_3, X_4, X_6, X_7)$. Here we will fix all other variables to 0, but we will see later that it does not matter for our OR calculation to which value we set all these variables, as long as we choose the same values in all of the four probabilities.

The probability of $P(X_5=0 \mid \dots)$ is calculated by dividing the potential for this category by the sum of all (here two) potentials:

$$
P(X_5=0 \mid \dots) = \frac{
\text{Potential}(X_5=0 \mid \dots)
}{
\text{Potential}(X_5=0 \mid \dots) + \text{Potential}(X_5=1 \mid \dots)
}
$$
If $X_5$ would have $m$ categories, there would be $m$ terms in the denominator.

The potentials are specified by the estimated parameters

$$
\text{Potential}(X_5=1 \mid X_1=0, X_2=0, \dots, X_7=0) =
\exp \{
\beta_{0} + \beta_{0,1.2} \mathbb{I}(X_1=1)  + \dots + \beta_{0,7} X_7
\}
,
$$

where $\beta_{0}$ is the intercept and the remaining seven parameters are the ones associated with the predictor terms in the model, and $\mathbb{I}(X_1=1)$ is the indicator function (or dummy variable) for category $X_1=1$. 

Notice that we set all variables to zero, which means that the above potential simplifies to

$$
\text{Potential}(X_5=1 \mid  \dots) = 
\exp \{\beta_{0} \} \approx \exp \{ 0.624 \}
$$

where I took the intercept parameter $\beta_{0}$ from `coefs[[1]][1,1]`. Similarly, we have

$$
\text{Potential}(X_5=0 \mid  \dots) = 
\exp \{\beta_{1} \} \approx \exp \{ -0.624 \}
$$
taken from `coefs[[1]][1,1]`.

Using the two potentials, we can compute the probabilities. We now do this in R:


{% highlight r %}
Potential0 <- exp(coefs[[1]][1,1])
Potential1 <- exp(coefs[[2]][1,1])

Prob0 <- Potential0 / (Potential0 + Potential1)
Prob1 <- Potential1 / (Potential0 + Potential1)
Prob0
{% endhighlight %}



{% highlight text %}
## [1] 0.7768575
{% endhighlight %}



{% highlight r %}
Prob1
{% endhighlight %}



{% highlight text %}
## [1] 0.2231425
{% endhighlight %}

We calculated that the probability of $P(X_5=0 \mid \dots)$ (supervised housing) is $\approx 0.78$ and the probability of $P(X_5=0 \mid \dots)$ (unsupervised housing) is $\approx 0.22$.

Now we can compute the odds $\text{Odds}_{X_2=0}$:


{% highlight r %}
odds_x1_0 <- Prob1 / Prob0

odds_x1_0
{% endhighlight %}



{% highlight text %}
## [1] 0.2872373
{% endhighlight %}

The odds are smaller than one, which means that it is more likely that an individual lives in supervised housing.

Note that when computing the odds, the denominator in the calculations for the probabilities cancel out, which means we could have immediately computed the odds with the potentials:


{% highlight r %}
Potential1 / Potential0
{% endhighlight %}



{% highlight text %}
## [1] 0.2872373
{% endhighlight %}

So far, we computed the numerator of the formula of the Odds Ratio. We now compute the denominator, which includes the same conditional probabilities as above, except that we set $X_1=1$ instead of $X_1=0$. As discussed above, all other variables are kept constant at 0. To keep things short, I only show the R code for this second case:


{% highlight r %}
Potential0 <- exp(coefs[[1]][1,1] + coefs[[1]][2,1] * 1)
Potential1 <- exp(coefs[[2]][1,1] + coefs[[2]][2,1] * 1)

odds_x1_1 <- Potential1 / Potential0
{% endhighlight %}

Similar to above, `coefs[[1]][1,1]` contains the intercept and `coefs[[1]][2,1]` contains the parameter associated with predictor $X_1$ for probability $P(X_5 = 0 \mid  \dots)$. `coefs[[2]]` contains the corresponding parameters for probability $P(X_5 = 1 \mid  \dots)$.

We can now compute the OR:


{% highlight r %}
OR <- odds_x1_1 / odds_x1_0
OR
{% endhighlight %}



{% highlight text %}
## [1] 2.144591
{% endhighlight %}

We see that for females (coded 1) the odds of living in unsupervised housing (coded 1) are about twice as high as for males.

In a similar way, ORs can be calculated when the predicted variable or the predictor variable of interest has more than two categories. One can also compute ORs that combine the effect of several variables, for example by setting several variables to 1 in the numerator, and setting them all to 0 in the denominator.


### Does it matter to which value we fix the other variables?

In the above calculation we fixed all other variables to zero. Would the OR have been different if we had fixed them to a different value? We  will show with some basic calculations that the answer is no. Along the way, we will also derive a much simpler way to compute the OR from the parameter estimates for the special case in which the response variable is binary.

To keep the notation manageable, we only consider one third variable $X_3$ instead of the five in the empirical example above. However, we would reach the same conclusion with any number of additional variables that are kept constant.

We start out with the definition of the odds ratio:

$$
\text{Odds Ratio} =
\frac{\text{Odds}_{X_2=1}}{\text{Odds}_{X_2=0}}
=
\frac{
\frac{P(X_1=1 \mid X_2=1,X_3=x_3)}{P(X_1=0 \mid X_2=1,X_3=x_3)}
}{
\frac{P(X_1=1 \mid X_2=0,X_3=x_3)}{P(X_1=0 \mid X_2=0,X_3=x_3)}
}
.
$$

The question is whether it matters what we fill  in for $x_3$. We will show that the terms associated with $x_3$ cancel out and it therefore does not matter to which value we fix $x_3$.

$$
\frac{
\frac{P(X_1=1 \mid X_2=1,X_3=x_3)}{P(X_1=0 \mid X_2=1,X_3=x_3)}
}{
\frac{P(X_1=1 \mid X_2=0,X_3=x_3)}{P(X_1=0 \mid X_2=0,X_3=x_3)}
}
=
\frac{
\frac{\exp\{\beta_1 + \beta_{21}1 + \beta_{31}x_3\}
}{\exp\{\beta_0 + \beta_{20}1 + \beta_{30}x_3\}}
}{
\frac{\exp\{\beta_1 + \beta_{21}0 + \beta_{31}x_3\}
}{
\exp\{\beta_0 + \beta_{20}0 + \beta_{30}x_3\}
}
}
=
\frac{
\frac{\exp\{\beta_1 + \beta_{21} + \beta_{31}x_3\}
}{\exp\{\beta_0 + \beta_{20} + \beta_{30}x_3\}}
}{
\frac{\exp\{\beta_1 + \beta_{31}x_3\}
}{
\exp\{\beta_0 + \beta_{30}x_3\}
}
}
$$

In the first step we fixed $X_1=1$ in the numerator and $X_1=0$ in the denominator and simplified. The parameter $\beta_{21}$ refers to the coefficient associated with $X_2$ in the equation modeling $P(X_1=1 \mid \dots)$, while $\beta_{20}$ refers to the coefficient associated with $X_2$ in the equation modeling $P(X_1=0 \mid \dots)$. 

We further rearrange

$$
\frac{
\frac{\exp\{\beta_1 + \beta_{21} + \beta_{31}x_3\}
}{\exp\{\beta_0 + \beta_{20} + \beta_{30}x_3\}}
}{
\frac{\exp\{\beta_1 + \beta_{31}x_3\}
}{
\exp\{\beta_0 + \beta_{30}x_3\}
}
}
=
\frac{\exp\{\beta_1 + \beta_{21} + \beta_{31}x_3\}
}{\exp\{\beta_0 + \beta_{20} + \beta_{30}x_3\}}
\frac{\exp\{\beta_0 + \beta_{30}x_3\}
}{
\exp\{\beta_1 + \beta_{31}x_3\}
}
,
$$

which is equal to

$$
\exp\{\beta_1 + \beta_{21} + \beta_{31}x_3 + \beta_0 + \beta_{30}x_3 - (\beta_0 + \beta_{20} + \beta_{30}x_3 + \beta_1 + \beta_{31}x_3)\}
.
$$

We collect all the terms with $x_3$

$$
\exp\{
(\beta_1 + \beta_{21} + \beta_0 - \beta_0 - \beta_{20} - \beta_1)
+
(\beta_{31}x_3 + \beta_{30}x_3 - \beta_{30}x_3 - \beta_{31}x_3)
\}
$$

and we see that the terms including $x_3$ add to zero, which shows that no matter what number we fill in for $x_3$, we will always obtain the same OR.

Actually, we can further simplify and get

$$
\exp\{
(\beta_1 + \beta_{21} + \beta_0 - \beta_0 - \beta_{20} - \beta_1)
+ 0
=
\exp\{
\beta_{21} - \beta_{20}
\}
$$

which reveals a simpler way to compute the OR. We can verify this with our estimated coefficients


{% highlight r %}
exp(coefs[[2]][2,1] - coefs[[1]][2,1])
{% endhighlight %}



{% highlight text %}
## [1] 2.144591
{% endhighlight %}

and indeed we get the same OR.

If we wanted the OR with the numerator and denominator swapped, one would calculate:


{% highlight r %}
exp(coefs[[1]][2,1] - coefs[[2]][2,1])
{% endhighlight %}



{% highlight text %}
## [1] 0.4662894
{% endhighlight %}

One could verify this by repeating the derivation above with swapped numerator/denominator or by using the general approach of calculating ORs that we used above.

This reflects the well-known relation between multiple regression parameters and the OR, $\exp{\{\beta_x\}} = \text{OR}_x$ (see [here](https://en.wikipedia.org/wiki/Odds_ratio#Role_in_logistic_regression)), since the relation between logistic regression parameterization and the symmetric multinomial regression parameterization used here is $\beta_x = 2 \beta_{x1}$, where $\beta_{x1}$ is the parameter corresponding to $\beta_x$ in the equation modeling $P(X_1=1 \mid \dots)$.


### Is the OR "significant"?

The model has been estimated with $\ell_1$-regularized regression, in which the regularization parameters have been selected with 10-fold cross-validation with the goal that the parameter estimates generalize to new samples. Thus, variable selection has already been performed and it is not necessary to perform an additional hypothesis test on the OR or the underlying variables.


### An Alternative: Changes in Predicted Probabilities

An alternative to ORs is to report change in predicted probabilities of $X_5$ depending on which value we fill in for $X_1$. When considering only two variables such a change in probabilities is perhaps easier to interpret than ORs. However, we will see that changes in predicted probabilities do not have the nice property of ORs that it doesn't matter to which value we fix all other variables. This makes this alternative less attractive for models that include more than two variables.

When looking at changes in predicted probabilities we are interested in the difference

$$
P(X_5=1 \mid X_1=1, \dots) - P(X_5=0 \mid X_1=0, \dots)
.
$$

When calculating these probabilities we are again required to fix all other variables ("...") to some value, which we again choose to be 0. In the interest of brevity I only show the R-code for this calculation.

We compute the probabilities for the case $X_1=0$


{% highlight r %}
Potential0 <- exp(coefs[[1]][1,1])
Potential1 <- exp(coefs[[2]][1,1])
Prob1_x10 <- Potential1 / (Potential0 + Potential1)
{% endhighlight %}

and for the case $X_1=1$:


{% highlight r %}
Potential0 <- exp(coefs[[1]][1,1] + coefs[[1]][2,1] * 1)
Potential1 <- exp(coefs[[2]][1,1] + coefs[[2]][2,1] * 1)
Prob1_x11 <- Potential1 / (Potential0 + Potential1)
{% endhighlight %}

We see a change in probability of


{% highlight r %}
Prob1_x11 - Prob1_x10
{% endhighlight %}



{% highlight text %}
## [1] 0.1580482
{% endhighlight %}

That is, the probability of living in unsupervised housing is $\approx 0.16$ higher for females, which is consistent with the OR > 1 calculated above.

However, now let's set $X_3=1$ instead of $X_3=0$:


{% highlight r %}
Potential0 <- exp(coefs[[1]][1,1] + coefs[[1]][3,1]*1)
Potential1 <- exp(coefs[[2]][1,1] + coefs[[2]][3,1]*1)
Prob1_x10 <- Potential1 / (Potential0 + Potential1)

Potential0 <- exp(coefs[[1]][1,1] + coefs[[1]][2,1] * 1 + coefs[[1]][3,1]*1)
Potential1 <- exp(coefs[[2]][1,1] + coefs[[2]][2,1] * 1 + coefs[[2]][3,1]*1)
Prob1_x11 <- Potential1 / (Potential0 + Potential1)
{% endhighlight %}

We now get an increase of probability of


{% highlight r %}
Prob1_x11 - Prob1_x10
{% endhighlight %}



{% highlight text %}
## [1] 0.1884348
{% endhighlight %}

We see that changes in the predicted probabilities as a function of $X_5$ depend on where we fixed the other variables. So while changes in probabilities are maybe easier to interpret, they have the downside that the changes depend on which values we fix the other variables. However, this may be acceptable in situations in which we are interested in some specific state of all other variables.


### Summary

Starting out with the definition of odds ratios, I showed how to compute them in a general setting and how to compute them from the output of the [*mgm*](https://cran.r-project.org/web/packages/mgm/index.html)-package. We looked into whether the OR depends on the specific values at which we fix the other variables (it doesn't). Proving this fact revealed a simpler formula for calculating ORs for the special case of having a binary response variable. Finally, we considered predicted probabilities as an alternative for ORs.

---

I would like to thank [Oisín Ryan](https://ryanoisin.github.io/) for his feedback on this blog post.



