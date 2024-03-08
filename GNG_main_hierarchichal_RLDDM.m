% MAIN HIERARCHICHAL GO NO GO WRAPPER
clear all;
rng(23);
dbstop if error

plot = true;
use_ddm = false;
SIM = false;
FIT = true;
use_parfor = false;

% load the data in
if ispc
    root = 'L:';
    subjects = ["AY841","AB050"];
    %subjects = ["AB050", "AG134","AO679", "BB483", "BC903"];
    fit_hierarchically = false;
    results_dir = 'L:/rsmith/lab-members/cgoldman/go_no_go/DDM/RL_DDM_Millner/RL_DDM_fits';
    DCM.field = {'alpha'; 'outcome_sensitivity'};
    
else
    root = '/media/labs';
    subjects = getenv('SUBJECTS');
    subjects = strsplit(subjects,",");
    results_dir = getenv('RESULTS');
    fit_hierarchically = strcmp(getenv('FIT_HIERARCHICALLY'),1);
    DCM.field = cellstr(strsplit(getenv('FIELD'),","));
end
disp(DCM.field);
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
disp(subjects);
disp(model_type);
if SIM
    % number of participants to simulate
    num_sims = 2;
    for i = 1:num_sims
        gen_params.rs = 1;
        gen_params.la = 1;
        gen_params.alpha_win = .5;
        gen_params.alpha_loss = .5;
        gen_params.beta = .5;
        gen_params.zeta = .5;
        gen_params.pi_win = .5;
        gen_params.pi_loss = .5;
        gen_params.T = .25;
        gen_params.a = 2;
        simulation = sim_gonogo(gen_params,use_ddm);
        simulations{i,1} = simulation;
    end
end


if FIT
    disp(['results_dir: ',results_dir]);
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
                fileName = "";
                k = k+1;
            catch e
                disp(['Could not load' fileName]);
            end
        end
    end
    fprintf('Fitting GCM of length %d\n',length(GCM));
    [fit_results,gcm,peb,m] = fit_gonogo_laplace(GCM,plot,fit_hierarchically, use_parfor);

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
