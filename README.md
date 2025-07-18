 # Approximate Bayesian Computation

Approximate Bayesian Computation (ABC) is a class of likelihood-free inference methods used when the likelihood function is either unavailable or computationally expensive to evaluate. Instead of computing likelihoods explicitly, ABC infers posterior distributions by simulating data from the model and comparing it to observed data using distance metrics or summary statistics.

Originally developed in population genetics, ABC has evolved to support complex, high-dimensional, and noisy models through algorithmic extensions such as:
- ABC with regression adjustment
- ABC-MCMC (Markov Chain Monte Carlo)
- ABC-SMC (Sequential Monte Carlo)
- Machine learning-based ABC (e.g., random forests, deep learning)

ABC is particularly useful in:
- Dynamical systems
- Stochastic biological networks
- Ecological and epidemiological models
- Engineering and technological diffusion models

Its flexibility and model-agnostic structure make it a powerful tool when traditional likelihood-based Bayesian inference is infeasible.

---

## Overview of Simulation Studies

Two simulation studies are implemented to demonstrate ABC rejection in action:

- **Study I: Normal Distribution**  
  Parameters (mean and standard deviation) of a normal distribution are estimated via ABC rejection. Summary statistics based on empirical quantiles are used for comparing simulated and observed datasets.

- **Study II: Logistic Growth Curve Model**  
  A logistic population growth model is used to estimate growth rate and carrying capacity. Noisy observed data are matched with simulated curves using Euclidean distance. ABC accurately recovers the underlying parameters of the dynamical system.

These examples show how ABC can recover posterior distributions even when likelihoods are unknown or intractable.

---

## Overview of Case Studies

Two real-world datasets are analyzed using ABC rejection sampling:

- **Case Study I: LCD-TV Adoption Data**  
  The Gompertz model is fitted to cumulative LCD-TV sales data from Taiwan (2003–2007)[Trappey & Wu, 2008]. ABC is used to estimate growth and saturation rates, demonstrating excellent agreement between model and data.

- **Case Study II: Horse and Mule Populations in the U.S.**  
  A time-varying logistic model is applied to historical population data of horses and mules on U.S. farms (1865–1960)[Banks, 1994]. ABC estimates parameters of a dynamic carrying capacity model, showing how ABC adapts to nonstationary real-world data.

---

## Significance of the Work

This work demonstrates the implementation of ABC rejection algorithms for both synthetic and empirical datasets using the Julia programming language. All case studies are executed using the `GpABC.jl`[Tankhilevich et al., 2020] package and structured to support reproducibility.

By combining theoretical foundations with practical applications, this repository provides a computational toolkit for researchers dealing with models where likelihood-based inference is not feasible. It also serves as a learning resource for statisticians, computational biologists, and engineers working with complex simulation-based models.

---

## References

1. Rubin, D. B. (1984). Bayesianly Justifiable and Relevant Frequency Calculations for the Applied Statistician. *The Annals of Statistics*, 12(4). https://doi.org/10.1214/aos/1176346785  
2. Pritchard, J. K., Seielstad, M. T., Perez-Lezaun, A., & Feldman, M. W. (1999). Population growth of human Y chromosomes: A study of Y chromosome microsatellites. *Molecular Biology and Evolution*, 16(12), 1791–1798. https://doi.org/10.1093/oxfordjournals.molbev.a026091  
3. Trappey, C. V., & Wu, H.-Y. (2008). An evaluation of the time-varying extended logistic, simple logistic, and Gompertz models for forecasting short product lifecycles. *Advanced Engineering Informatics*, 22(4), 421–430. https://doi.org/10.1016/j.aei.2008.05.007  
4. Banks, R. B. (1994). *Growth and Diffusion Phenomena: Mathematical Frameworks and Applications*. Springer.  
5. Toni, T., Welch, D., Strelkowa, N., Ipsen, A., & Stumpf, M. P. H. (2009). Approximate Bayesian computation scheme for parameter inference and model selection in dynamical systems. *Journal of The Royal Society Interface*, 6(31), 187–202. https://doi.org/10.1098/rsif.2008.0172
6. Tankhilevich, E., Ish-Horowicz, J., Hameed, T., Roesch, E., Kleijn, I., Stumpf, M. P. H., & He, F. (2020). GpABC: A Julia package for approximate Bayesian computation with Gaussian process emulation. Bioinformatics, 36(10), 3286–3287. https://doi.org/10.1093/bioinformatics/btaa078
