% MAIN HIERARCHICHAL GO NO GO WRAPPER
clear all;
rng(23);
dbstop if error

plot = false;
use_ddm = true;
SIM = false;
FIT = true;
use_parfor = true;

% load the data in
if ispc
    root = 'L:';
    %subjects = ["BC312"];
    subjects = ["BC027","BC034"];
    fit_hierarchically = false;
    results_dir = 'L:/rsmith/lab-members/cgoldman/go_no_go/DDM/RL_DDM_Millner/RL_DDM_fits';
    % note that if ddm_mapping.thresh, bias, or drift is set, then a,w, and
    % v should not be fit, respectively
    DCM.field = {'T';'alpha'; 'outcome_sensitivity'; 'beta'; 'pi'; 'a';'w'};
    %DCM.field = {'a'; 'w';'T';'pi'};
    DCM.ddm_mapping.drift = {'qval'; 'pav'; 'go'};
    DCM.ddm_mapping.thresh = {};
    DCM.ddm_mapping.bias = {};
    
else
    root = '/media/labs';
    subjects = cellstr(strsplit(getenv('SUBJECTS'),","));
    results_dir = getenv('RESULTS');
    fit_hierarchically = strcmp(getenv('FIT_HIERARCHICALLY'),1);
    DCM.field = cellstr(strsplit(getenv('FIELD'),","));
    DCM.ddm_mapping.thresh = cellstr(strsplit(getenv('THRESH_MAPPING'),","));
    DCM.ddm_mapping.bias = cellstr(strsplit(getenv('BIAS_MAPPING'),","));
    DCM.ddm_mapping.drift = cellstr(strsplit(getenv('DRIFT_MAPPING'),","));
    if strcmp(DCM.ddm_mapping.thresh,''); DCM.ddm_mapping.thresh={};end
    if strcmp(DCM.ddm_mapping.drift,''); DCM.ddm_mapping.drift={};end
    if strcmp(DCM.ddm_mapping.bias,''); DCM.ddm_mapping.bias={};end
end    
addpath([root '/rsmith/all-studies/util/spm12/']);
addpath([root '/rsmith/all-studies/util/spm12/toolbox/DEM/']);

% set model type
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
disp(['Parameters Fit: ' strjoin(DCM.field)]);
if use_ddm
    disp(['Mapping to Drift: ' strjoin(DCM.ddm_mapping.drift)]);
    disp(['Mapping to Decision Threshold: ' strjoin(DCM.ddm_mapping.thresh)]);
    disp(['Mapping to Starting Bias: ' strjoin(DCM.ddm_mapping.bias)]);
end
disp(['Subjects Fit: ' strjoin(subjects)]);



if SIM
    % number of participants to simulate
    num_sims = 2;
    for i = 1:num_sims
        gen_params.rs = 1;
        gen_params.la = 1;
        gen_params.alpha_win = .5;
        gen_params.alpha_loss = .5;
        gen_params.beta = .5;
        gen_params.zeta = 1;
        gen_params.pi_win = .5;
        gen_params.pi_loss = .5;
        gen_params.T = .25;
        gen_params.a = 2;
        simulation = sim_gonogo(gen_params,use_ddm);
        simulations{i,1} = simulation;
    end
end


if FIT
    disp(['Results Directory: ',results_dir]);
    estimation_prior.rs = 1;
    estimation_prior.la = 1;
    estimation_prior.outcome_sensitivity = 1;
    estimation_prior.alpha_win = .5;
    estimation_prior.alpha_loss = .5;
    estimation_prior.alpha = .5;
    estimation_prior.beta = .5;
    estimation_prior.zeta = .5;
    estimation_prior.pi_win = .5;
    estimation_prior.pi_loss = .5;
    estimation_prior.pi = .5;
    estimation_prior.T = .25;
    estimation_prior.a = 2;
    estimation_prior.w = .5;
    estimation_prior.v = .5;
    estimation_prior.contaminant_prob = 0;
    DCM.MDP = estimation_prior;
    DCM.use_ddm = use_ddm;
    DCM.model_type = model_type;
    DCM.Y = [];

    if SIM
        for i = 1:length(simulations)
            GCM{i,1} = DCM;
            data.trial_type = simulations{i,1}.trial_type;
            data.c = simulations{i,1}.choices' - 1;
            data.r = simulations{i,1}.observations';
            data.rt = simulations{i,1}.rt';
            data.N = length(data.c);
            data.subject = string(i);
            GCM{i,1}.subject = string(i);
            GCM{i,1}.U = data;
        end
        
        
    else
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
                fileName = "";
                k = k+1;
            catch e
                disp(['Could not load' fileName]);
            end
        end
        % determine which RTs to exclude
        GCM = analyze_RTs(GCM);
    end
    fprintf('Fitting GCM of length %d\n',length(GCM));
    [fit_results,gcm,peb,m] = fit_gonogo_laplace(GCM,plot);

    % close the parallel pool if still running
    poolobj = gcp('nocreate');
    if ~isempty(poolobj)
        delete(poolobj);
    end


    save([results_dir '/hierarchichal_fit_results'], 'fit_results');
    save([results_dir '/hierarchichal_gcm'], 'gcm');
    save([results_dir '/hierarchichal_m'], 'm');
    if fit_hierarchically
        save([results_dir '/hierarchichal_peb'], 'peb');
    end

    clear all; clf;


end
