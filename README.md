
# README

## Description

This repository contains MATLAB and Python scripts for modeling, simulating, and fitting **Reinforcement Learning Drift Diffusion Models (RLDDMs)** to behavioral data. The scripts support hierarchical model fitting, parameter optimization, and batch processing.

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

- **MATLAB:** Required toolboxes include `spm12` and its `DEM` submodule.  
- **Python 3.x:** Requires `os` and `subprocess` libraries.  
- **Slurm:** Needed for batch processing.

---
