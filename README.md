---
html:
  embed_local_images: true

print_background: false
---

# README for measureFrontiers


# Introduction

We run the Dean et al. algorithm on data from Norway and Sweden. The algorithm detects step changes in the proportion of residents belonging to a minority group between zones. Here the minority group refers to foreign-born residents in a zone but can be extended to other groups.

The setup for the algorithm is as follows: suppose there are $n$ aerial units. $k$ is an index number. For aerial unit $k$, we know the number of residents who belong to a minority group denoted by $Y_k$. The total resident population of an aerial unit is $N_k$. The proportion of minority group residents is $p_k$ ($Y_k/N_k$). See the example data structure below:


*Example data*
| Aerial unit $k$ | Minority count $Y_k$     | Total residents $N_k$ | $p_k$|
| :------------- | :------------- | :----| :----|
| 1       | 100       | 200 | 0.5 |
| 2   | 50   | 200| 0.25 |
|....   |   |   |   |
|n   | $Y_n$   | $N_n$  | $p_n$  |

The spatial relationship between aerial units $A_k$ and its neighbours is captured by the spatial weights matrix $W_0$ where 1 indicates contiguous zones (else 0).

The first step of the algorithm is to model the data using a Bayesian spatial conditional autoregressive model (Lee and Mitchell 2013). The distribution of $Y_k$ is given by:

$$Y_k \sim Binomial(N_k, p_k); k = 1...n$$

$p_k$ is modelled as:

$$ln(p_k/[1 - p_k]) = \beta_0 + u_k$$

$$u_k|u_{-k}, W, \lambda, \tau^2 \sim N(\frac{\lambda \Sigma_{k\sim l}  u_l}{1 - \lambda + \lambda_{wk+}}. \frac{1}{\tau^2(1-\lambda + \lambda_{wk+})})$$

$$\beta_0 \sim N(0, b)$$

$$\tau^2 \sim gamma(e',f')$$

$$logit(\lambda) \sim N(0, 100) $$

In this model, the parameters of interest are $u_k$ and $W$. Unlike other spatial models, the spatial relations between contiguous zones is not assumed. In short, we do not assume that neighbouring aerial units necessarily have any spatial autocorrelation. Instead, the algorithm starts with a model with $W_0$ for estimation and iterates until $W$ is found.

For a border adjoining aerial units $A_1$ and $A_2$, we can work out:
- a measure of sharpness $\phi$ where $\phi = |u_1 - u_2|$
- whether there is spatial autocorrelation as given by $W$

In the Dean et al. paper, a statistically significant frontier is a border with no spatial autocorrelation (as determined by $W$) and where the 95% credible interval for.$\phi$ does not overlap with zero. However, not all significant frontiers are substantial.


## Sweden

For the Swedish areal unit, data by DeSo is used. We use population data on the number of foreign-born individuals residing in a DeSo in 2020 (available [here](https://www.scb.se/vara-tjanster/oppna-data/oppna-geodata/deso--demografiska-statistikomraden/)). An urban area is defined by Tartorter (2018 boundary definition).

In total, Sweden has 15,914 borders with 9,851 statistically significant frontiers.

## Norway

Population numbers are aggregated by Basic Statistical Units (Grunkretts). Population data on native and foreign-born residents (inclusive of children of migrants) comes from 2018.

In total, Norway has 16,661 borders with 6,178 statistically significant frontiers.

## Computed variables

There are two types of outputs for the Dean et al algorithm:
1. a dataset of zones and
2. an *edge list* where each record is a border between two zones

For the former, we can derive variables indicating:
- proportion of border covered by 'frontiers'. This variable can be further split into proportions covered frontiers shared with zones with a lower or higher proportion of foreigners.
- whether the zone has a frontier and what type. For example, zone $A_i$ is classified as lower if it is always the zone with the lower value of $u$. It is classified as higher if it is always the zone with the higher $u$. Zones with a mix are classified as mixed.

For the latter edge list, we can derive these variables:
- $\phi$ between the two adjacent zones that make up the border
- indicator of whether the credible interval for $\phi$ overlaps with zero

# Code guide

[![](https://mermaid.ink/img/eyJjb2RlIjoiZ3JhcGggTFJcbiBjb21tb24tMDAgLS0-IHVrLTAxXG4gICAgY29tbW9uLTAwIC0tPiBzd2VkZS0wMVthbGxTd2VkZW5Gcm9udGllcnNOb3Rlcy5SXVxuICBjb21tb24tMDAgLS0-IG5vcndheS0wMVtub3J3YXlGcm9udGllck5vdGVzLlJdXG4gXG4gXG4gICAgc3ViZ3JhcGggVUtcbiAgdWstMDEgLS0-IHVrLTAyXG4gIHVrLTAyIC0tPiB8YmF5ZXNpYW4gZnJvbnRpZXIgbWV0aG9kfCB1ay0wM1xuICB1ay0wMiAtLT4gfGFicyBkaWZmIG1ldGhvZHwgdWstMDN4XG4gIHVrLTAzIC0tPiB8ZXh0cmFjdCBpbiBmb3JMb29wfCB1ay0wNFxuICB1ay0wNCAtLi0-IHx1c2UgZWxzZXdoZXJlfCBvdGhlci13b3JrXG4gICAgdWstMDN4IC0tPiB8ZnJvbnRpZXIgZXh0cmFjdHwgdWstMDR4XG4gIHVrLTA0eCAtLT4gc2hlZmZpZWxkX3JlcG9ydF9tZFxuICAgIGVuZFxuICAgIHN1YmdyYXBoIE5vcndheStTd2VkZW5cbiAgIHN3ZWRlLTAxW2FsbFN3ZWRlbkZyb250aWVyc05vdGVzLlJdXG4gICBub3J3YXktMDFbbm9yd2F5RnJvbnRpZXJOb3Rlcy5SXVxuICAgIGVuZCIsIm1lcm1haWQiOnsidGhlbWUiOiJkZWZhdWx0In0sInVwZGF0ZUVkaXRvciI6ZmFsc2UsImF1dG9TeW5jIjp0cnVlLCJ1cGRhdGVEaWFncmFtIjpmYWxzZX0)](https://mermaid-js.github.io/mermaid-live-editor/edit##eyJjb2RlIjoiZ3JhcGggTFJcbiBjb21tb24tMDAgLS0-IHVrLTAxXG4gICAgY29tbW9uLTAwIC0tPiBzd2VkZS0wMVthbGxTd2VkZW5Gcm9udGllcnNOb3Rlcy5SXVxuICBjb21tb24tMDAgLS0-IG5vcndheS0wMVtub3J3YXlGcm9udGllck5vdGVzLlJdXG4gXG4gXG4gICAgc3ViZ3JhcGggVUtcbiAgdWstMDEgLS0-IHVrLTAyXG4gIHVrLTAyIC0tPiB8YmF5ZXNpYW4gZnJvbnRpZXIgbWV0aG9kfCB1ay0wM1xuICB1ay0wMiAtLT4gfGFicyBkaWZmIG1ldGhvZHwgdWstMDN4XG4gIHVrLTAzIC0tPiB8ZXh0cmFjdCBpbiBmb3JMb29wfCB1ay0wNFxuICB1ay0wNCAtLi0-IHx1c2UgZWxzZXdoZXJlfCBvdGhlci13b3JrXG4gICAgdWstMDN4IC0tPiB8ZnJvbnRpZXIgZXh0cmFjdHwgdWstMDR4XG4gIHVrLTA0eCAtLT4gc2hlZmZpZWxkX3JlcG9ydF9tZFxuICAgIGVuZFxuICAgIHN1YmdyYXBoIE5vcndheStTd2VkZW5cbiAgIHN3ZWRlLTAxW2FsbFN3ZWRlbkZyb250aWVyc05vdGVzLlJdXG4gIGNvbW1vbi0wMCAtLT4gbm9yd2F5LTAxW25vcndheUZyb250aWVyTm90ZXMuUl1cbiAgICBlbmQiLCJtZXJtYWlkIjoie1xuICBcInRoZW1lXCI6IFwiZGVmYXVsdFwiXG59IiwidXBkYXRlRWRpdG9yIjpmYWxzZSwiYXV0b1N5bmMiOnRydWUsInVwZGF0ZURpYWdyYW0iOmZhbHNlfQ)


## Explanation of scripts

uk-01: Load in data from elsewhere and save it

uk-02: joins the data on ttwa, census and saves

uk-03: runs frontier analysis (filtered to top di due to size). Done in for forLoop

uk-04: extracts sf borders using forLoop

uk-03x: experimental analysis using abs diff instead

uk-04x: extract frontieirs and base layer for plots

sheffield_example: Example map for GP


# Misc

**mermaid chart code**

```
graph LR
 common-00 --> uk-01
    common-00 --> swede-01[allSwedenFrontiersNotes.R]
  common-00 --> norway-01[norwayFrontierNotes.R]


    subgraph UK
  uk-01 --> uk-02
  uk-02 --> |bayesian frontier method| uk-03
  uk-02 --> |abs diff method| uk-03x
  uk-03 --> |extract in forLoop| uk-04
  uk-04 -.-> |use elsewhere| other-work
    uk-03x --> |frontier extract| uk-04x
  uk-04x --> sheffield_report_md
    end
    subgraph Norway+Sweden
   swede-01[allSwedenFrontiersNotes.R]
   norway-01[norwayFrontierNotes.R]
    end
```
