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

# for reproducibility
Random.seed!(123)

# Observed LCD-TV adoption data
x = [26.900, 63.100, 164.100, 407.500, 787.500,
     1194.500, 1603.900, 2178.600, 2993.600, 4059.600,
     5432.200, 7101.652, 8883.652, 10896.652,
     13379.652, 16097.652, 18563.652, 21794.652]

t = 0:(length(x)-1)

x0 = x[1]  # Known initial value

# first plot the reference data
plt = Plots.scatter(t, x,xlabel = "t", ylabel = "Cummulatve Sales of LCD-TV ( in thousands)" ,
    title = "", color = "red", label = "")  


#  We simulate only based on r and α, with known X0 # define the Gompertz Model
gompertz(t, x0, r, alpha) = x0 * exp.(r * (1 .- exp.(-alpha .* t)) ./ alpha)


# simulate the data 
function simulator(var_params)
    r, alpha = var_params
    sim = gompertz(t, x0, r, alpha)
    return reshape(sim, :, 1)  # ensure it's a matrix
end


# set the prior parameter
priors = [Uniform(0.1, 2.0), Uniform(0.1, 3.0)]

reference_data = reshape(x, :, 1)  # convert vector to column matrix


n_particles = 1001
threshold = 10000.0  
max_iter = 1_000_000  # maximum iterations
sim_result = SimulatedABCRejection(
    reference_data,
    simulator,
    priors,
    threshold,
    n_particles;
    max_iter=max_iter,
    write_progress=true
)
Plots.plot(sim_result)

r_posterior_mean = mean(sim_result.population[:,1])
r_posterior_mode = mode(sim_result.population[:,1])
r_posterior_median = median(sim_result.population[:,1])
println("r_posterior_mean: $r_posterior_mean")
println("r_posterior_mode : $r_posterior_mode")
println("r_posterior_median : $r_posterior_median")

alpha_posterior_mean = mean(sim_result.population[:,2])
alpha_posterior_mode = mode(sim_result.population[:,2])
alpha_posterior_median = median(sim_result.population[:,2])

println("alpha_posterior_mean: $alpha_posterior_mean")
println("alpha_posterior_mode : $alpha_posterior_mode")
println("alpha_posterior_median : $alpha_posterior_median")

# Generate fitted curve using the posterior mean estimates
fitted_curve_mean = gompertz(t, x0, r_posterior_mean, alpha_posterior_mean)
fitted_curve_median = gompertz(t, x0, r_posterior_median, alpha_posterior_median)
fitted_curve_mode = gompertz(t, x0, r_posterior_mode, alpha_posterior_mode)
# Plot original data and fitted curve
plt = Plots.scatter(t, x, xlabel = "t", ylabel = "x",
        title = "", 
        color = :red, label = "Observed Data")
Plots.plot!(t, fitted_curve_mean, lw = 2, label = "Posterior Mean", color = :blue)
Plots.plot!(t, fitted_curve_median, lw = 2, label = "Posterior Median", color = :orange)
Plots.plot!(t, fitted_curve_mode, lw = 2, label = "Posterior Mode", color = :magenta)

# 95% credible interval for parameter r from the posterior samples
quantile(sim_result.population[:,1], [2.5 , 97.5] ./100) 

# 95% credible interval for parameter alpha from the posterior samples
quantile(sim_result.population[:,2], [2.5 , 97.5] ./100) 

# Extract the posterior samples (assuming `sim_result` is your ABC output)
posterior_samples = sim_result.population  # This is likely a matrix

# DataFrame with named columns
df = DataFrame(r = posterior_samples[:, 1], alpha = posterior_samples[:, 2])

vars = [:r, :α]
labels = [L"r", L"\alpha"]
n = length(vars)

fig = Figure(size = (600, 600))
grid = fig[1, 1] = GridLayout(n, n)

for i in 1:n, j in 1:n
    ax = Axis(grid[i, j])
    x = df[!, vars[j]]
    y = df[!, vars[i]]

    if i == j
        CairoMakie.hist!(ax, x; bins=30, color=:gray)
    else
        CairoMakie.scatter!(ax, x, y; markersize=3, color=:blue)
    end

    # Label only outer axes
    if i == n
        ax.xlabel = labels[j]
    end
    if j == 1
        ax.ylabel = labels[i]
    end
end

fig   # pairplot
