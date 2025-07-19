# load the required packages
using Random, Distributions, Statistics, StatsBase
using Plots, LaTeXStrings

Random.seed!(123)  # for reproducibility

# true prameters
mu_true = 0
sigma_true = 1
length_data = 100
Y_E = rand(Normal(mu_true,sigma_true), length_data)
first(Y_E, 6)  # first 6 values

# prior distributions for mu and sigma
prior_mu() = rand(Uniform(-4,4))
prior_sigma() = rand(Uniform(0.0001,3))

# functions for simulating the data
simulate_data(length_data, mu, sigma) = rand(Normal(mu, sigma),length_data)
compute_quantiles(data) = quantile(data, [0.1,0.5, 0.9])

# Distance Function
function D(true_data, simulated_data)
    sqrt(sum((true_data .- simulated_data).^2))
end

epsilon = 0.5
iterations = 20000

post_mu = Float64[]
post_sigma = Float64[]

for i in 1:iterations
    mu = prior_mu()
    sigma = prior_sigma()
    Y_S = simulate_data(length_data, mu, sigma)
    rho = D(compute_quantiles(Y_E), compute_quantiles(Y_S))
    if rho <= epsilon
        push!(post_mu, mu)
        push!(post_sigma, sigma)
    end
end

mean(post_mu)  # mean of posterior mean

mean(post_sigma) # mean of posterior sigma

length(post_mu)  # number of accepted values
length(post_sigma) # number of accepted values

p1 = histogram(post_mu, normalize = true, ylims = (0, 3.5), xlabel = L"\mu",
ylabel = "density", label = "")
scatter!([mu_true],[0], color = "blue", markersize = 10, 
    label = L"\mu_{true}")
scatter!([mean(post_mu)],[0], color = "red", markersize = 10, 
    label = L"\mu_{posterior}" )

p2 = histogram(post_sigma, normalize = true, ylims = (0, 3.5), xlabel = L"\sigma", 
ylabel = "density", label = "")
scatter!([sigma_true],[0], color = "blue", markersize = 10, 
    label = L"\sigma_{ture}")
scatter!([mean(post_sigma)],[0], color = "red", markersize = 10, 
    label = L"\sigma_{posterior}" )
plt = plot(p1, p2, layout = (1,2), size = (700, 400))
