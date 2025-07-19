# load the required packages
using Statistics
using Random
using Distributions
using StatsBase
using Plots

Random.seed!(123)

# True parameter values
r_true = 0.6
K_true = 100.0
sigma_true = 3.0

# Time and data generation
dt = 0.1
t = collect(dt:dt:10.0)
N0 = 20.0
N = zeros(length(t))

for i in eachindex(t)
    N[i] = K_true / (((K_true - N0)/N0) * exp(-r_true * t[i]) + 1) + rand(Normal(0, sigma_true))
end

# Observed data
N_obs = copy(N)

# Distance function (Euclidean)
function dist(x, y)
    return sqrt(sum((x .- y).^2))
end

# ABC-Rejection parameters
iter = 200_000
eps = 50.0
post_r = Float64[]
post_K = Float64[]
dist_arr = zeros(Float64, iter)

# ABC Rejection loop
for j in 1:iter
    r = rand(Uniform(0.001, 2.0))
    K = rand(Uniform(50.0, 200.0))
    N_sim = zeros(length(t))
    for i in eachindex(t)
        N_sim[i] = K / (((K - N0)/N0) * exp(-r * t[i]) + 1) + rand(Normal(0, sigma_true))
    end
    d = dist(N_obs, N_sim)
    dist_arr[j] = d
    if d < eps
        push!(post_r, r)
        push!(post_K, K)
    end
end

# Plot histogram of distances
plt = histogram(dist_arr, normalize = true,
    xlabel = L"d(N_{sim}, N_{obs})", title = L"\epsilon = 50",ylabel = "density", 
    label = "", color = "lightblue")

# Plot posterior distributions
plt = plot(layout = (1, 2), size = (700, 400))

p1 = histogram!(post_r, normalize = true, xlabel = L"r", ylabel = "density",
    label = "", color = "lightgrey", title = "Posterior Distribution of r",subplot = 1)
scatter!([r_true], [0.0], color = "red", label = L"r_{true}", 
    subplot = 1)
scatter!([mean(post_r)], [0.0], color = "blue", label = L"r_{posterior}", 
    subplot= 1)

p2 = histogram!(post_K, normalize = true, xlabel = L"K", ylabel = "density", 
    label = "", color = "lightgrey", title = "Posterior Distribution of K" ,subplot= 2)
scatter!([K_true], [0.0], color = "red", label = L"K_{true}", 
 subplot= 2)
scatter!([mean(post_K)], [0.0], color = "blue" , label = L"K_{posterior}", 
 subplot= 2)

# fitted curve vs data
fitted_vals = zeros(length(N_obs))
for i in eachindex(t)
    fitted_vals[i] = mean(post_K) / (((mean(post_K) - N0)/N0) * exp(-mean(post_r) * t[i]) + 1)
end

plt = plot(t, N_obs, seriestype = :scatter, label = "Simulated data", color = "red",
    xlabel = "Time", ylabel = "Population size")
plot!(t, fitted_vals, label = "Fitted curve", lw = 3, color = "blue")

# Acceptance rate
acceptance_rate = length(post_r) / iter
println("Acceptance rate: ", acceptance_rate)
println("Number of accepted samples: ", length(post_r))
