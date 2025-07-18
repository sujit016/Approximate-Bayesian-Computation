# We consider the data set of cumulative sales of LCD-TV studied by [Trappey and Wu, 2008]. 
# The data contains the cumulative quarterly sales from 2003 to 2007 (in thousands), 
# which were collected from the Market Intelligence Center Taiwan by <code>Trappey and Wu, 2008</code>. 
# The measurement schedules are rescaled as t = 0 , 1 , 2 , . . . , 17.

# load the required packages 
using GpABC, Distributions, Plots, StatsBase
using LaTeXStrings
using PairPlots
using DataFrames
using StatsPlots, CairoMakie
using Random
