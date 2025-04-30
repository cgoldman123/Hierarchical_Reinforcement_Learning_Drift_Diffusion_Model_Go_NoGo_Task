% MAIN HIERARCHICHAL GO NO GO WRAPPER
clear all;
rng(23);
dbstop if error

plot = false; % indicate if want to plot data
FIT = true; % indicate if want to fit parameters to task data 
SIMFIT = true; % indicate if want to fit parameters to task data, simulate behavior using those parameters, then fit parameters to simulated data. If true,
% the parameters used to simulate data (i.e., the fits to behavior) will be
% in GCM_simed.mat and the fits to simulated data will be in Simfit_RL<DDM>_simmed_results.mat
SIMFIT_FULL_RANGE_OF_PARAMS = false; % bypass fitting, and simulate full range of parameters passed in. If true, the parameters used to simulate data
% will be in GCM_simmed_params.mat, and the fits will be in
% Simfit_RL<DDM>_simmed_results.mat



use_ewma_rt_filter = false; % indicate if want to use am exponentially weighted moving average to filter out fast/inaccurate RTs

% load the data in
if ispc
    root = 'L:';
    subjects = ["AB434","AB607"]; % subjects to fit (or simulate)
    fit_hierarchically = false; % indicate if you would like to fit hierarchically using parametric empirical bayes.
    results_dir = 'L:/rsmith/lab-members/cgoldman/go_no_go/DDM/RL_DDM_Millner/RL_DDM_fits/test'; % results directory
    use_ddm = true; % indicate if you would like to use a drift-diffusion model on top of a reinforcement learning model
    % RL PARAMETERS
    % alpha - learning rate
    % outcome_sensitivity - reward/loss sensitivity
    % beta - go bias
    % pi - pavlovian bias
 
    % DDM Parameters
    % T - nondecision time
    % v - drift rate
    % w - starting bias
    % a - decision threshold

    fit_field = {'alpha','outcome_sensitivity','beta','pi','w','a'}; % indicate parameters to fit
    %fit_field = {'alpha'};
    % indicate mapping of RL parameters to DDM (only needed if use_ddm is
    % true)
    fit_ddm_mapping.drift = {'qval','pav','go'}; % mapping to the drift rate e.g., fit_ddm_mapping.drift = {'qval','pav','go'}
    fit_ddm_mapping.thresh = {};  % mapping to the decision threshold
    fit_ddm_mapping.bias = {};  % mapping to the starting bias
    % Please note that if ddm_mapping.drift, ddm_mapping.thresh, or ddm_mapping.bias is set, 
    % then v,a, and w should not be fit, respectively. This is because the
    % value of the drift rate, decision threshold, and starting bias will
    % be determined by RL parameters and should not be free parameters fit
    % to task data.
    
    %simfit_field = {'alpha','outcome_sensitivity','zeta','beta','pi'};
    simfit_field = {'alpha','outcome_sensitivity','beta','pi','w','a'}; % indicate parameters to simfit
    %simfit_field = {'alpha'};
    % after having fit then simulated data.
    simfit_ddm_mapping.drift = {'qval','pav','go'};
    simfit_ddm_mapping.thresh = {};
    simfit_ddm_mapping.bias = {};
    
    use_parfor = false; % indicate if you would like to fit tasks in parallel.
    
else
    root = '/media/labs';
    subjects = strsplit(getenv('SUBJECTS'), ',');
    results_dir = getenv('RESULTS');
    fit_hierarchically = strcmp(getenv('FIT_HIERARCHICALLY'), '1');
    use_ddm = strcmp(getenv('USE_DDM'), '1');
    fit_field = strsplit(getenv('FIT_FIELD'), ',');
    simfit_field = strsplit(getenv('SIMFIT_FIELD'), ',');

    if use_ddm
        fit_ddm_mapping.thresh = cellstr(strsplit(getenv('FIT_THRESH_MAPPING'),","));
        fit_ddm_mapping.bias = cellstr(strsplit(getenv('FIT_BIAS_MAPPING'),","));
        fit_ddm_mapping.drift = cellstr(strsplit(getenv('FIT_DRIFT_MAPPING'),","));
        simfit_ddm_mapping.thresh = cellstr(strsplit(getenv('SIMFIT_THRESH_MAPPING'),","));
        simfit_ddm_mapping.bias = cellstr(strsplit(getenv('SIMFIT_BIAS_MAPPING'),","));
        simfit_ddm_mapping.drift = cellstr(strsplit(getenv('SIMFIT_DRIFT_MAPPING'),","));
        
    else
        fit_ddm_mapping.drift = {};
        fit_ddm_mapping.thresh = {};
        fit_ddm_mapping.bias = {};
        simfit_ddm_mapping.drift = {};
        simfit_ddm_mapping.thresh = {};
        simfit_ddm_mapping.bias = {};
    end
    if strcmp(fit_ddm_mapping.drift,''); fit_ddm_mapping.drift={};end
    if strcmp(fit_ddm_mapping.bias,''); fit_ddm_mapping.bias={};end
    if strcmp(fit_ddm_mapping.thresh,''); fit_ddm_mapping.thresh={};end
    if strcmp(simfit_ddm_mapping.drift,''); simfit_ddm_mapping.drift={};end
    if strcmp(simfit_ddm_mapping.bias,''); simfit_ddm_mapping.bias={};end
    if strcmp(simfit_ddm_mapping.thresh,''); simfit_ddm_mapping.thresh={};end

    use_parfor = strcmp(getenv('USE_PARFOR'), '1');
    disp(fit_ddm_mapping);
    disp(simfit_ddm_mapping);


end    
addpath([root '/rsmith/all-studies/util/spm12/']); % change to your local directory containing spm12
addpath([root '/rsmith/all-studies/util/spm12/toolbox/DEM/']); % change to your local directory containing spm12/toolbox/DEM

if FIT & ~SIMFIT_FULL_RANGE_OF_PARAMS
    if use_ddm && fit_hierarchically
        model_type = 'RLDDM fit hierarchically';
    elseif ~use_ddm && fit_hierarchically
        model_type = 'RL fit hierarchically';
    elseif use_ddm && ~fit_hierarchically
        model_type = 'RLDDM fit nonhierarchically';
    elseif ~use_ddm && ~fit_hierarchically
        model_type = 'RL fit nonhierarchically';
    end
    disp(model_type);
else
    if use_ddm 
        model_type = 'RLDDM simmed';
    else
        model_type = 'RL simmed';
    end
end
    


DCM.model_type = model_type;
estimation_prior.rs = 1;
estimation_prior.la = 1;
estimation_prior.outcome_sensitivity = 1;
estimation_prior.alpha_win = .5;
estimation_prior.alpha_loss = .5;
estimation_prior.alpha = .5;
estimation_prior.beta = 0;
estimation_prior.zeta = .2;
estimation_prior.pi_win = 0;
estimation_prior.pi_loss = 0;
estimation_prior.pi = 0;
estimation_prior.T = eps;
estimation_prior.a = 2;
estimation_prior.w = .5;
estimation_prior.v = 0;
estimation_prior.contaminant_prob = 0;

DCM.ddm_mapping.drift = fit_ddm_mapping.drift;
DCM.ddm_mapping.thresh = fit_ddm_mapping.thresh;
DCM.ddm_mapping.bias = fit_ddm_mapping.bias;
DCM.field = fit_field;


DCM.prior_variance = 1/2;
DCM.MDP = estimation_prior;
DCM.use_ddm = use_ddm;
DCM.fit_hierarchically = fit_hierarchically;
DCM.use_parfor = use_parfor;
DCM.Y = [];

% load in subjects' data
if ~ SIMFIT_FULL_RANGE_OF_PARAMS
    filePath = strcat(root,'/rsmith/lab-members/cgoldman/go_no_go/DDM/processed_behavioral_files_DDM/');
    k = 1;
    for i = 1:length(subjects)
        try
            GCM{k,1} = DCM;
            fileName = strcat(subjects(i),"_processed_behavioral_file.csv");
            fullPath = strcat(filePath,fileName);
            data = load_gonogo_data(fullPath);
            data.subject = subjects(i);
            GCM{k,1}.subject = subjects(i);
            GCM{k,1}.U = data;
            GCM{k,1}.fit_hierarchically = fit_hierarchically;
            GCM{k,1}.use_parfor = use_parfor;
            if ~use_ewma_rt_filter
               GCM{k,1}.U.keep_trial = ones(1,160);
            end
            fileName = "";
            k = k+1;
        catch e
            disp(['Could not load' fileName]);
        end
    end
    % determine which RTs to exclude
    if use_ewma_rt_filter
        GCM = analyze_RTs(GCM);
    end


    if FIT &  ~SIMFIT_FULL_RANGE_OF_PARAMS
        disp(['Parameters Fit: ' strjoin(DCM.field)]);
        if use_ddm
            disp(['Mapping to Drift: ' strjoin(DCM.ddm_mapping.drift)]);
            disp(['Mapping to Decision Threshold: ' strjoin(DCM.ddm_mapping.thresh)]);
            disp(['Mapping to Starting Bias: ' strjoin(DCM.ddm_mapping.bias)]);
        end
        fprintf('Subjects Fit: %s\n', strjoin(subjects));
        disp(['Results Directory: ',results_dir]);
        fprintf('Fitting GCM of length %d\n\n',length(GCM));
        [fit_results,fit_gcm,fit_peb,fit_m] = fit_gonogo_laplace(GCM,plot);
    
        % close the parallel pool if still running
        poolobj = gcp('nocreate');
        if ~isempty(poolobj)
            delete(poolobj);
        end
    
    
        save([results_dir '/' strrep(model_type, ' ', '_') '_results'], 'fit_results');
        save([results_dir '/' strrep(model_type, ' ', '_') '_gcm'], 'fit_gcm');
        save([results_dir '/' strrep(model_type, ' ', '_') '_m'], 'fit_m');
        if fit_hierarchically
            save([results_dir '/' strrep(model_type, ' ', '_') '_peb'], 'fit_peb');
        end
    
    end
end

if SIMFIT
    if SIMFIT_FULL_RANGE_OF_PARAMS
        % Simulate data based on full range of parameters
        num_to_simfit = 400;
        sim_gcm_params_full_range = cell(num_to_simfit,1);
        for k=1:num_to_simfit
            sim_gcm_params_full_range{k,1} = DCM;
            sim_gcm_params_full_range{k,1}.subject = string(num2str(k));
            % Create vector of trial conditions
            sim_gcm_params_full_range{k,1}.U.trial_type = repmat((1:4)', 40, 1);
            sim_gcm_params_full_range{k,1}.U.trial_type = sim_gcm_params_full_range{1}.U.trial_type(randperm(160));
            sim_gcm_params_full_range{k,1}.U.N = 160;
            sim_gcm_params_full_range{k,1}.U.keep_trial = ones(1,160);
            sim_gcm_params_full_range{k,1}.fitted_MDP = DCM.MDP;
            sim_gcm_params_full_range{k,1}.fitted_MDP.alpha = rand; % randomly samples between 0 and 1
            sim_gcm_params_full_range{k,1}.fitted_MDP.beta = -4 + (8 * rand); % randomly samples between 4 and -4
            sim_gcm_params_full_range{k,1}.fitted_MDP.pi = -3 + (6 * rand); % randomly samples between 3 and -3
            sim_gcm_params_full_range{k,1}.fitted_MDP.a = 1 + (4 * rand); % randomly samples  between 1 and 5
            sim_gcm_params_full_range{k,1}.fitted_MDP.w = rand; % randomly samples between 0 and 1
            sim_gcm_params_full_range{k,1}.fitted_MDP.outcome_sensitivity = 4 * rand; % randomly samples between 0 and 4
            disp(sim_gcm_params_full_range{k,1}.fitted_MDP);
        end
        save([results_dir '/sim_gcm_params_full_range'], 'sim_gcm_params_full_range');
        fprintf('\nSimming data from %d subjects\n\n',length(sim_gcm_params_full_range));
        simmed_GCM = simulate_gonogo(sim_gcm_params_full_range);
    else
        % Simulate data based on fits to actual behavior
        fprintf('\nSimming data from %d subjects\n\n',length(fit_gcm));
        simmed_GCM = simulate_gonogo(fit_gcm);
        % Save the GCM that contains behavior that was fit to get the
        % parameters used to simulate data
        save([results_dir '/GCM_simmed'], 'GCM');

    end
    
    if use_ewma_rt_filter
        simmed_GCM = analyze_RTs(simmed_GCM);
    end
    model_type = ['Simfit ' model_type];
    disp(model_type);
    disp(['Parameters simfitted: ' strjoin(simfit_field)]);
    if use_ddm
        disp(['Mapping to Drift: ' strjoin(simfit_ddm_mapping.drift)]);
        disp(['Mapping to Decision Threshold: ' strjoin(simfit_ddm_mapping.thresh)]);
        disp(['Mapping to Starting Bias: ' strjoin(simfit_ddm_mapping.bias)]);
    end
    
    for k=1:length(simmed_GCM)
        simmed_GCM{k}.field = simfit_field;
        simmed_GCM{k}.ddm_mapping.drift = simfit_ddm_mapping.drift;
        simmed_GCM{k}.ddm_mapping.thresh = simfit_ddm_mapping.thresh;
        simmed_GCM{k}.ddm_mapping.bias = simfit_ddm_mapping.bias;
    end
    
    fprintf('Simfitting GCM of length %d\n\n',length(simmed_GCM));
    [simfit_results,simfit_gcm,simfit_peb,simfit_m] = fit_gonogo_laplace(simmed_GCM,plot);

    % close the parallel pool if still running
    poolobj = gcp('nocreate');
    if ~isempty(poolobj)
        delete(poolobj);
    end
    save([results_dir '/' strrep(model_type, ' ', '_') '_results'], 'simfit_results');
    save([results_dir '/' strrep(model_type, ' ', '_') '_gcm'], 'simfit_gcm');
    save([results_dir '/' strrep(model_type, ' ', '_') '_m'], 'simfit_m');
    if fit_hierarchically
        save([results_dir '/' strrep(model_type, ' ', '_') '_peb'], 'simfit_peb');
    end

    clear all; clf;
end
    
