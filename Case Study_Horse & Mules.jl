using Random
Random.seed!(123)  # for reproducibility

using GpABC, Distributions, OrdinaryDiffEq, Plots  # load the required package

# Observed data and time points
x_obs = [7, 8.270, 10.881, 12.170, 14.802, 17.518, 20.557, 20.004,
         22.077, 24.211, 26.490, 25.742, 22.569, 19.124, 16.683,
         14.478, 11.950, 7.781, 4.309, 3.089]
t_obs = 0:5:95
reference_data = reshape(x_obs, :, 1)

plt = Plots.scatter(t_obs, x_obs, color = "red", xlabel = "Time", 
    ylabel = "Population Size" ,label = "")

# Define the logistic model with time-dependent carrying capacity
function logistic_carrying!(du, u, p, t)
    a0, Nstar0, c = p
    du[1] = a0 * u[1] * (1 - u[1] / (Nstar0 * (1 + c * t)))
end

# Simulator function with initial condition as a parameter
function simulator(var_params)
    a0, Nstar0, c, u0_val = var_params
    u0 = [u0_val]
    prob = ODEProblem(logistic_carrying!, u0, (0.0, 95.0), [a0, Nstar0, c])
    sol = solve(prob, Tsit5(), saveat=t_obs)
    return reshape(sol[1, :], :, 1)
end

# Define priors: a0, N_star0, c, and u0
priors = [
    Uniform(0.01, 0.1),     # a0
    Uniform(20.0, 80.0),    # N_star0
    Uniform(-0.05, 0.01),   # c
    Uniform(5.0, 9.0)       # u0 
]

# ABC configuration
n_particles = 1000
threshold = 20.0
max_iter = 1_000_000

# Run ABC Rejection
sim_result = SimulatedABCRejection(
    reference_data,
    simulator,
    priors,
    threshold,
    n_particles;
    max_iter=max_iter,
    write_progress=true
)

# Plot posterior distributions
plot(sim_result, legend=false)

a0_posterior_mean = mean(sim_result.population[:,1])

# 95% credible interval for parameter a0 from the posterior samples
quantile(sim_result.population[:,1], [2.5 , 97.5] ./100) 

NStar_0_posterior_mean = mean(sim_result.population[:,2])

# 95% credible interval for parameter Nstar0 from the posterior samples
quantile(sim_result.population[:,2], [2.5 , 97.5] ./100) 

N0_posterior_mean = mean(sim_result.population[:,4])

# 95% credible interval for parameter U0 from the posterior samples
quantile(sim_result.population[:,4], [2.5 , 97.5] ./100) 

using DataFrames, CairoMakie, LaTeXStrings

posterior_samples = sim_result.population

# Create DataFrame with nice parameter names (as best possible in code)
df = DataFrame(
    a₀ = posterior_samples[:, 1],
    Nstar₀ = posterior_samples[:, 2],
    c = posterior_samples[:, 3],
    N₀ = posterior_samples[:, 4]  # initial value
)

# Posterior samples are already in df
vars = names(df)  # [:a₀, :Nstar₀, :c, :N₀]
labels = [L"a_0", L"N_{*0}", L"c", L"N_0"]  

n = length(vars)

fig = Figure(size = (800, 800))
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

    if i == n
        ax.xlabel = labels[j]
    end
    if j == 1
        ax.ylabel = labels[i]
    end
end

fig  # pairplot

function logistic_carrying!(du, u, p, t)
    a0, Nstar0, c = p
    du[1] = a0 * u[1] * (1 - u[1] / (Nstar0 * (1 + c * t)))
end


function traj_mean_fit(a0, Nstar0, c, u0_val)
    u0 = [u0_val]
    prob = ODEProblem(logistic_carrying!, u0, (0.0, 95.0), [a0, Nstar0, c])
    sol = solve(prob, Tsit5(), saveat=t_obs)
    return sol[1, :]
end


traj = traj_mean_fit(a0_posterior_mean, NStar_0_posterior_mean, 
C_posterior_mean, N0_posterior_mean)


Plots.scatter(t_obs, x_obs, color = "red", xlabel = "TIme", ylabel = "Population Size",
    label = "Observed data")
Plots.plot!(t_obs, traj, label = "Posterior Mean",color = "blue",lw=2)


# Generating prediction band 
#  Sample posterior draws
n_draws = 500
posterior_indices = rand(1:size(df, 1), n_draws)
valid_trajectories = []

#  Generate trajectories from posterior
for idx in posterior_indices
    a₀ = df.a₀[idx]
    Nstar₀ = df.Nstar₀[idx]
    c = df.c[idx]
    U0 = df. N₀[idx]   

    try
        traj = traj_mean_fit(a₀, Nstar₀, c, U0)   
        if length(traj) == length(t_obs)
            push!(valid_trajectories, traj)
        end
    catch e
        @warn "Simulation failed for index $idx: $e"
    end
end

# Compute prediction bands and mean trajectory
trajectory_matrix = reduce(vcat, [permutedims(traj) for traj in valid_trajectories])
lower = mapslices(x -> quantile(x, 0.025), trajectory_matrix; dims=1)[:]
upper = mapslices(x -> quantile(x, 0.975), trajectory_matrix; dims=1)[:]
mean_traj = mapslices(mean, trajectory_matrix; dims=1)[:]

 

# Plot mean trajectory
Plots.plot(t_obs, mean_traj, label="", lw=2, color=:blue)

# Plot 95% prediction band WITHOUT plotting lower line
plt = Plots.plot!(t_obs, mean_traj, ribbon=(mean_traj .- lower, upper .- mean_traj),
      fillalpha=0.3, label="", color=:gray, linealpha=0)

# Overlay observed data
Plots.scatter!(t_obs, x_obs, label="", color=:red, marker=:circle)

