---
layout: post
title: "Should you Submit Papers before Christmas? Submission Percentages across Months of the Year"
date: 2024-02-14 10:00:00 +0100
categories: r
comments: true
---

The last weeks I came across the argument that one should not submit papers just before the holiday break. The argument sounds sensible enough: Everyone is trying to finish projects before the end of the year and therefore submissions are considerably higher in December than in earlier months. Assuming that the number of papers sent out for review remains constant across months (which seems reasonable since resources such as editors and reviewers do not grow in December --- rather the opposite), this would imply that the desk-rejection rate goes up in December. And consequently, everything else equal, one should avoid submitting a paper in December.

To my surprise, a simple web search did not allow me to check the premise that more papers are submitted in December. Helpfully, [arxiv.org](http://arxiv.org), a preprint server popular in physics, mathematics, computer science, and quantitative biology provides [monthly submission statistics](https://arxiv.org/stats/get_monthly_submissions) since 1993. 

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

The plot on the arxiv.org [monthly submission website](https://arxiv.org/stats/get_monthly_submissions) clearly shows that submissions are growing exponentially. Therefore, the distributions of submissions within month across years will show huge variance across years, which would mask systematic differences across months. For example, the number of submissions in January 1994 and 2024 are widely different:


{% highlight r %}
data$submissions[data$month_n==1 & data$year_n %in% c(1992, 2024)]
{% endhighlight %}



{% highlight text %}
## [1]   193 18085
{% endhighlight %}

We therefore compute the proportions of submission of each month within each year and then show the distribution of proportions across years for each month:


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
<img src="/assets/img/2024-12-22-ChristmasSubmission.Rmd/unnamed-chunk-33-1.png" alt="plot of chunk unnamed-chunk-33"  />
<p class="caption">plot of chunk unnamed-chunk-33</p>
</div>
We see that submissions are lowest in January (Median 7.4%) and February (7.3%) compared to the 8.3% representing equal distribution across 12 months. We see an uptick in March (8.2%), but submissions drop again in April (7.7%). Submissions stabilize at a higher level before the summer in May (8.3%), June (8.5%), and July (8.5%) and clearly drop during the summer break in August (7.5%). With the beginning of the new academic year, we see an increase in September (8.8%) and the submissions reach their maximum in October (9.5%). After that, submissions decrease again in November (9.1%) and December (8.7%). These results show that there are strong monthly patterns in the amount of papers submitted. However, coming back to our question about the Christmas break, the data does not show a marked increase in submission specifically before the Christmas holiday.

If we take the arxiv.org data as the population of interest, obviously no inference is needed and we can simply look at the observed proportions. However, if we consider the arxiv.org submissions as (random) samples from a larger population, we of course want to perform inference. This would imply that the estimates from earlier years with fewer submissions are less reliable estimates for the proportions. Here, I only looked at how the pattern would change when including only more recent years. All cutoffs lead to roughly the same results, but including only more recent years led to lower variance across years, because we have many more submissions to estimate the proportions; but perhaps also because the data generating process (i.e., how scientists work) may be more homogeneous closer in time. The only systematic difference in results when only considering only later years is a higher percentage of submissions in May.

What explains these patterns is anyone's guess. It would have been intuitive to me that scientists try to get papers finished before larger holiday breaks for psychological reasons. However, this is not supported by the data. A drop in submission during the perhaps longest holiday break during August makes sense. The higher submission percentage in May is probably explained by the fact that the overall percentage of computer science / machine learning papers grew on arxiv.org, which commonly have deadlines for conference papers in May (for example [NeurIPS](https://nips.cc/Conferences/2024/Dates) on May 15th). However, I have no good explanation for why so many papers are submitted in October and November, and so few in January and Feburary. I did not expect such large differences between months and find them quite interesting, because they suggest that scientists work in relatively homogeneous cycles throughout the year.

All I could find in a quick online search was [this blog post by Cell](https://crosstalk.cell.com/blog/when-are-the-best-and-worst-times-to-submit-your-paper) saying that most papers are submitted in June/July/August and October/November, which is only partially aligning with the present arxiv.org data. [This Nature blog post](https://www.nature.com/nature-index/news/best-day-submitting-academic-scholar-research-science-article-publication) discusses a study by [Boja et al. (2018)](https://link.springer.com/article/10.1007/s11192-018-2911-7) who analyzed papers submitted to Physica A, PLOS ONE, Nature and Cell and found that more papers were submitted during the Christmas period defined as December 20th - January 10th, compared to the rest of the year. These results are not consistent with the present arxiv.org results. In [another Nature blog](https://www.nature.com/nature-index/news/april-publishing-lull-follows-end-of-year-academic-flurry) they show data about publications of Nature journals across the year. However, since this adds the probably quite variable reviewing and production process on top of the submission date, these data are likely containing little information about when papers are submitted.

