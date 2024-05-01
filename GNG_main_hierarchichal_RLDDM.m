% MAIN HIERARCHICHAL GO NO GO WRAPPER
clear all;
rng(23);
dbstop if error

plot = false;
SIM = true;
FIT = true;
use_ewma_rt_filter = false; % indicate if want to use exponentially weighted moving average to filter out fast/inaccurate RTs
load_in_GCM = true;

% load the data in
if ispc
    root = 'L:';
    %subjects = ["BC312"];
    subjects = ["BC312","AB434"];
    fit_hierarchically = true;
    results_dir = 'L:/rsmith/lab-members/cgoldman/go_no_go/DDM/RL_DDM_Millner/RL_DDM_fits';
    % note that if ddm_mapping.thresh, bias, or drift is set, then a,w, and
    % v should not be fit, respectively
    %DCM.field = {'T','alpha','outcome_sensitivity','beta','pi','w','v'};
    DCM.field = {'w','beta'};

    %DCM.field = {'a'; 'w';'T';'pi'};
    use_ddm = true;
    DCM.ddm_mapping.drift = {};
    DCM.ddm_mapping.thresh = {'qval','pav','go'};
    DCM.ddm_mapping.bias = {};
    use_parfor = false;
    
else
    root = '/media/labs';
    subjects = cellstr(strsplit(getenv('SUBJECTS'),","));
    results_dir = getenv('RESULTS');
    fit_hierarchically = strcmp(getenv('FIT_HIERARCHICALLY'),'1');
    DCM.field = cellstr(strsplit(getenv('FIELD'),","));
    use_ddm = strcmp(getenv('USE_DDM'),'1');
    if use_ddm
        DCM.ddm_mapping.thresh = cellstr(strsplit(getenv('THRESH_MAPPING'),","));
        DCM.ddm_mapping.bias = cellstr(strsplit(getenv('BIAS_MAPPING'),","));
        DCM.ddm_mapping.drift = cellstr(strsplit(getenv('DRIFT_MAPPING'),","));
    else
        DCM.ddm_mapping.drift = {};
        DCM.ddm_mapping.thresh = {};
        DCM.ddm_mapping.bias = {};
    end
    if strcmp(DCM.ddm_mapping.thresh,''); DCM.ddm_mapping.thresh={};end
    if strcmp(DCM.ddm_mapping.drift,''); DCM.ddm_mapping.drift={};end
    if strcmp(DCM.ddm_mapping.bias,''); DCM.ddm_mapping.bias={};end
    use_parfor = strcmp(getenv('USE_PARFOR'),'1');
end    
addpath([root '/rsmith/all-studies/util/spm12/']);
addpath([root '/rsmith/all-studies/util/spm12/toolbox/DEM/']);

if FIT
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
    DCM.model_type = model_type;
else
    if use_ddm 
        model_type = 'RLDDM simmed';
    else
        model_type = 'RL simmed';
    end
end
    



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
estimation_prior.T = .25;
estimation_prior.a = 2;
estimation_prior.w = .5;
estimation_prior.v = 0;
estimation_prior.contaminant_prob = .10;

DCM.prior_variance = 1/2;

% uncomment if want to use PEB (group-level model) to fit from winning model
load([root '/rsmith/lab-members/cgoldman/go_no_go/DDM/RL_DDM_Millner/RL_DDM_CMG-hierarchichal/helpful_matlab_objects/peb_params_winning_model.mat']);
DCM.prior_variance = .2607;
peb_fields = fieldnames(peb_params_winning_model);
for k=1:length(peb_fields)
    estimation_prior.(peb_fields{k}) = peb_params_winning_model.(peb_fields{k});
end



DCM.MDP = estimation_prior;
DCM.use_ddm = use_ddm;
DCM.fit_hierarchically = fit_hierarchically;
DCM.use_parfor = use_parfor;
DCM.Y = [];

if load_in_GCM && SIM
    simmed_GCM = load([root '/rsmith/lab-members/cgoldman/go_no_go/DDM/RL_DDM_Millner/RL_DDM_CMG-hierarchichal/helpful_matlab_objects/GCM_winning_model_simmed.mat']);
    simmed_GCM = simmed_GCM.GCM;
    for k=1:length(simmed_GCM)
        GCM{k,1} = DCM;
        GCM{k,1}.subject = simmed_GCM{k}.subject;
        GCM{k,1}.U = simmed_GCM{k}.U;   
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
    if SIM
        GCM = simulate_gonogo(GCM);
    end
    
end

if SIM
    disp('Winning Model Simmed: T,alpha,outcome_sensitivity,beta,pi,w,a');
    if use_ddm
        disp('Mapping to Drift: qval pav go');
        disp('Mapping to Decision Threshold: ');
        disp('Mapping to Starting Bias: ');
    end
    fprintf('Subjects Simmed: %s\n', strjoin(subjects, ', '));
    fprintf('Simming GCM of length %d\n',length(GCM));
end
%save([results_dir '/GCM_winning_model_simmed'], 'GCM')
% 
if FIT
    disp(['Parameters Fit: ' strjoin(DCM.field)]);
    if use_ddm
        disp(['Mapping to Drift: ' strjoin(DCM.ddm_mapping.drift)]);
        disp(['Mapping to Decision Threshold: ' strjoin(DCM.ddm_mapping.thresh)]);
        disp(['Mapping to Starting Bias: ' strjoin(DCM.ddm_mapping.bias)]);
    end
    disp(['Subjects Fit: ' strjoin(subjects)]);
    disp(['Results Directory: ',results_dir]);
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
