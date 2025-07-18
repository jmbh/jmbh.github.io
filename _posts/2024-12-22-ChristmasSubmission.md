---
layout: post
title: "Should you Submit Papers before Christmas? Submission Distribution Across the Year"
date: 2024-12-22 09:00:00 +0100
categories: r
comments: true
---

The argument sounds reasonable enough: Everyone is trying to wrap up projects before the end of the year, so the number of submissions in December is significantly higher than in earlier months. Assuming that the number of papers sent out for review remains constant across months (which seems reasonable, since resources such as editors and reviewers do not increase in December---indeed, the opposite), this would imply that the desk rejection rate increases in December. And consequently, all else being equal, one should avoid submitting a paper in December. To my surprise, a simple web search was not sufficient to check the premise that more papers are submitted in December. Helpfully, [arxiv.org](http://arxiv.org), a preprint server popular in physics, mathematics, computer science, and quantitative biology, provides [monthly submission statistics](https://arxiv.org/stats/get_monthly_submissions) since 1993. 

We can download a CSV with the monthly submission statistics from their website:


{% highlight r %}
# Load Data
data <- read.table("https://arxiv.org/stats/get_monthly_submissions", sep=",", header=TRUE)
head(data)
{% endhighlight %}



{% highlight text %}
##     month submissions historical_delta
## 1 1991-07           2               -2
## 2 1991-08          28               -1
## 3 1991-09          58                0
## 4 1991-10          76                0
## 5 1991-11          64                0
## 6 1991-12          78                0
{% endhighlight %}



{% highlight r %}
# Get Numeric Month/Year variables
data$month_n <- as.numeric(substr(data$month, 6, 8))
data$year_n <- as.numeric(substr(data$month, 1, 4))
{% endhighlight %}

The plot on the arxiv.org [monthly submissions website](https://arxiv.org/stats/get_monthly_submissions) clearly shows that submissions grow exponentially. Therefore, the distributions of submissions within months across years will show huge variance across years, which would mask systematic differences across months. For example, the number of submissions in January 1994 and 2024 are very different:


{% highlight r %}
data$submissions[data$month_n==1 & data$year_n %in% c(1992, 2024)]
{% endhighlight %}



{% highlight text %}
## [1]   193 18085
{% endhighlight %}

Therefore, we instead compute the proportions of submissions for each month within each year, and then show the distribution of proportions across years for each month:


{% highlight r %}
# Exclude years 1991 (only data from July) and 2024 (no complete data for December yet)
data_sub <- data[(data$year_n != 2024) & (data$year_n >= 1992), ]

# Compute proportions within each year
library(plyr)
props <- ddply(data_sub, .(year_n), function(x) x$submissions / sum( x$submissions ))
{% endhighlight %}

We can visualize the proportions for each month across years with a boxplot:


{% highlight r %}
par(mar=c(4.3,5,3,2))
boxplot(props[,-1], axes=FALSE, ylim=c(0.06, 0.11))
axis(1, month.abb, at=1:12)
axis(2, las=2, at=seq(0.06, 0.11, length=6), labels=paste0(seq(0.06, 0.11, length=6)*100, "%"))
abline(h=1/12, lty=1, col="lightgrey")
axis(2, at=1/12, label="8.3%", las=2, col.axis="grey")
boxplot(props[,-1], axes=FALSE, ylim=c(0.06, 0.11), add=TRUE)
title(main = "Percentage of aXiv.org Submissions in each Month 1992-2023", font.main=1)
title(ylab="Percentage Submissions", line=3.5)
{% endhighlight %}

<div class="figure" style="text-align: center">
<img src="/assets/img/2024-12-22-ChristmasSubmission.Rmd/unnamed-chunk-4-1.png" alt="plot of chunk unnamed-chunk-4"  />
</div>

We see that submissions are lowest in January (median 7.4%) and February (7.3%), compared to the 8.3% representing equal distribution across 12 months. We see an increase in March (8.2%), but submissions drop again in April (7.7%). Submissions stabilize at higher levels before the summer in May (8.3%), June (8.5%), and July (8.5%), and drop significantly during the summer break in August (7.5%). With the start of the new academic year, we see an increase in September (8.8%), and submissions reach their maximum in October (9.5%). Submissions then decline in November (9.1%) and December (8.7%). These results show that there are strong monthly patterns in the number of submissions. However, to return to our question about the Christmas break, the data do not show a marked increase in submissions specifically before the Christmas break.

If we take the arxiv.org data as the population of interest, then of course no inference is needed, and we can simply look at the observed proportions. However, if we consider the arxiv.org submissions as a (random) sample from a larger population, we obviously want to perform inference. This would imply that the estimates from earlier years with fewer submissions are less reliable estimates of the proportions. Here, I only looked at how the pattern would change if only recent years were included. All cutoffs lead to roughly the same results, but including only more recent years leads to lower variance across years because we have many more submissions to estimate the proportions; but perhaps also because the data generating process (i.e., how scientists work) may be more homogeneous closer in time. The only systematic difference in the results when considering only later years is a higher percentage of submissions in May.

What explains these patterns is anyone's guess. It would have been intuitive to me that, for psychological reasons, scientists try to finish papers before major vacation breaks. However, this is not supported by the data. A drop in submissions during perhaps the longest holiday break in August makes sense. The higher percentage of submissions in May in later years is probably explained by the fact that the overall percentage of computer science / machine learning papers on arxiv.org increased over the years, which often have conference paper deadlines in May (e.g. [NeurIPS](https://nips.cc/Conferences/2024/Dates) on May 15). However, I have no good explanation for why so many papers are submitted in October and November, and so few in January and February. I did not expect such large differences between months, and I find them quite interesting because they suggest that scientists work in relatively homogeneous cycles throughout the year.

All I could find in a quick online search was [this Cell blog post](https://crosstalk.cell.com/blog/when-are-the-best-and-worst-times-to-submit-your-paper), which says that most papers are submitted in June/July/August and October/November, which is only partially consistent with the arxiv.org data. [A Nature blog post](https://www.nature.com/nature-index/news/best-day-submitting-academic-scholar-research-science-article-publication) discusses a study by [Boja et al. (2018)](https://link.springer.com/article/10.1007/s11192-018-2911-7) that analyzed papers submitted to Physica A, PLOS ONE, Nature, and Cell and found that more papers were submitted during the Christmas period, defined as December 20 - January 10, compared to the rest of the year. These results are not consistent with the arxiv.org results. In [another Nature blog](https://www.nature.com/nature-index/news/april-publishing-lull-follows-end-of-year-academic-flurry) they show data on publications of Nature journals throughout the year. However, since they add the probably quite variable reviewing and production process on top of the submission date, these data probably contain little information about when papers are submitted.

