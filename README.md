
# README


This repository accompanies the manuscript *Pavlovian Bias is Associated with Symptom Severity but Not Diagnostic Status in Individuals with both Anxious and Non-Anxious Depression* (Goldman et al., 2025). It provides the full set of scripts, data, and outputs used to model, fit, and analyze behavioral data from a Go/No-Go task using Reinforcement Learning Drift Diffusion Models (RLDDMs). The repository integrates MATLAB and Python code for computational modeling, along with R scripts and datasets for statistical analysis and visualization.

## Data Analysis Files
The `data_and_analysis_scripts/` folder contains the following:

- `GNG_analyses_5-13-25.Rmd`: R Markdown notebook for conducting the main behavioral and statistical analyses reported in the paper. 
- `corrplotplus.R`: Custom R function for generating enhanced correlation matrices with annotated Bayes Factors or p-values, significance stars, and optional clustering.
- `GNG_experiment_data_5-6-25.csv`: Dataset including computational and descriptive indices of task performance as well as psychological measures.
- `GNG_experiment_data_5-6-25_dictionary.xlsx`: Data dictionary accompanying the CSV file, detailing column definitions, coding schemes, and variable descriptions.
- `param_recov_full_param_distributions.csv`: Parameter recovery results using the full reasonable distributions of computational parameter values.
- `param_recov_full_param_distributions_dictionary.xlsx`: Dictionary file providing explanations of each column in the parameter recovery CSV.


---

## Repository Files

### MATLAB Scripts

1. **`GNG_main_hierarchichal_RLDDM.m`**  
   - Main wrapper script for fitting and simulating RLDDMs.  
   - Supports hierarchical and non-hierarchical parameter fitting using parametric empirical Bayes.  
   - Configurable parameters include learning rates, decision thresholds, drift rates, and biases.  
   - Outputs fit results and optionally simulates and re-fits on simulated data.

2. **`fit_gonogo_laplace.m`**  
   - Function for fitting RLDDMs to Go/No-Go task data.  
   - Uses variational Bayesian methods to estimate posterior distributions of model parameters.  
   - Handles parameter transformations and hierarchical modeling.

3. **`GNG_dcm_peb_fit.m`**  
   - Performs group-level hierarchical model fitting using parametric empirical Bayes.  
   - Incorporates second-level constraints to refine parameter estimates across subjects.

4. **`GNG_spm_dcm_fit.m`**  
   - Wrapper for Bayesian inversion of subject-specific DCMs.  
   - Supports parallel computation and includes diagnostic output for model performance.

5. **`GNG_spm_dcm_peb.m`**  
   - Core function for hierarchical inversion of DCMs with second-level design matrices.  
   - Implements Bayesian model reduction and variational Laplace for parameter estimation.

6. **`wfpt.m`**  
   - Computes the probability density function of first-passage times for a Wiener diffusion process.  
   - Used for calculating response probabilities in DDMs.

---

### Python Scripts

1. **`run_RL_DDM_test_multiple_models.py`**  
   - Automates testing of multiple RLDDM configurations.  
   - Submits Slurm jobs for parallelized fitting across subjects and models.  
   - Supports dynamic creation of result directories and custom parameter mappings.

---

### Slurm Batch Script

1. **`run_RL_DDM_test_multiple_models.ssub`**  
   - Template for Slurm job submission.  
   - Executes RLDDM fitting for a given subject and model configuration.

---

## Usage

1. **MATLAB Workflow:**
   - Edit `GNG_main_hierarchichal_RLDDM.m` to configure paths, subjects, and model parameters.  
   - Run the script for fitting and simulation.

2. **Python Workflow:**
   - Edit `run_RL_DDM_test_multiple_models.py` to specify subjects, models, and result directories.  
   - Submit Slurm jobs using `run_RL_DDM_test_multiple_models.ssub`.

---


## Dependencies

- **MATLAB:** Requires the [SPM12](https://www.fil.ion.ucl.ac.uk/spm/software/spm12/) toolbox, including the `DEM` submodule.  
- **Python 3.x:** Requires standard libraries such as `os` and `subprocess`.  
- **Slurm:** Needed for batch processing on high-performance computing clusters.  
- **R (version ≥ 4.0):** Required packages include `tidyverse`, `Hmisc`, `corrplot`, `BayesFactor`, and `glue`.  
- **RStudio (optional):** Recommended for running and knitting `.Rmd` files.  
- **Microsoft Excel or compatible software:** Required to view `.xlsx` data dictionary and parameter recovery documentation files.

---
