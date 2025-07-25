% extract fit results from .mat object for RL-DDM fit hierarchically
% optionally also extract fits for simulated data for parameter
% recoverability/identifiability

% REMEMBER TO CHANGE THE INPUT
function extractparams()
extract_simulated_parameters = true; % if set to true, also set the name of a file to pass in fits for simulated data
% input files
fit_file = 'L:\rsmith\lab-members\cgoldman\go_no_go\DDM\RL_DDM_Millner\RL_DDM_fits\test\Simfit_RLDDM_fit_nonhierarchically_results.mat';
% load a file called fit_results. If load_simfit_data==true, this file will
% be called simfit_results so we will rename it.
load(fit_file);
if extract_simulated_parameters
    % These are the parameters used to simulate data that was fit in
    % simfit_results
    fit_results = simfit_results; 
    % If using the full reasonable distribution of params to simulate, this
    % file should be called sim_gcm_params_full_range or something of that
    % sort
    simmed_file = 'L:\rsmith\lab-members\cgoldman\go_no_go\DDM\RL_DDM_Millner\RL_DDM_fits\test\RLDDM_fit_nonhierarchically_results.mat';
end

results_dir = 'L:\rsmith\lab-members\cgoldman\go_no_go\r_stats\model_results\model_recoverability_hierarchical_full_range.csv';
results_table = table;
for i = 1:length(fit_results)
    % For each struct, extract its fields into separate variables
    results_table.subject(i) = fit_results(i).subject;
    results_table.model_type(i) = {fit_results(i).model_type};
    results_table.avg_action_probability(i) = fit_results(i).avg_action_probability;
    results_table.model_accuracy(i) = fit_results(i).model_accuracy;
    results_table.F(i) = fit_results(i).F;
    
    % Extract the 'prior' struct and convert it to a table
    prior_fields = fieldnames(fit_results(i).prior);
    for k = 1:length(prior_fields)
        prior_value = fit_results(i).prior.(prior_fields{k});
        % Create new column name for the prior field
        column_name = sprintf('prior_%s', prior_fields{k});
        results_table.(column_name)(i) = prior_value;
    end
    % Extract the 'posterior' struct and convert it to a table
    posterior_fields = fieldnames(fit_results(i).posterior);
    for k = 1:length(posterior_fields)
        posterior_value = fit_results(i).posterior.(posterior_fields{k});
        % Create new column name for the posterior field
        column_name = sprintf('posterior_%s', posterior_fields{k});
        results_table.(column_name)(i) = posterior_value;
    end

end

% Extract the parameters used to simulate the behavior that was fit
if extract_simulated_parameters
    % load a file called 
    load(simmed_file); % This will either be a .mat object called sim_gcm_params_full_range or fit_results depending on whether the full range of parameter values or parameter estimates from actual data were used to simulate behavior
    % If using the full reasonable distribution of parameters, look inside sim_gcm_params_full_range
    if exist('sim_gcm_params_full_range', 'var')
        for i = 1:length(sim_gcm_params_full_range)
            % Extract the 'posterior' struct and convert it to a table
            sim_fields = fieldnames(sim_gcm_params_full_range{i}.fitted_MDP);
            for k = 1:length(sim_fields)
                sim_value = sim_gcm_params_full_range{i}.fitted_MDP.(sim_fields{k});
                % Create new column name for the posterior field
                column_name = sprintf('simmed_%s', sim_fields{k});
                results_table.(column_name)(i) = sim_value;
            end
        end
    else
        % If using parameter estimates from actual data to simulate
        % plausible behavior, look inside fit_results
         for i = 1:length(fit_results)
            % Extract the 'posterior' struct and convert it to a table
            sim_fields = fieldnames(fit_results(i).posterior);
            for k = 1:length(sim_fields)
                sim_value = fit_results(i).posterior.(sim_fields{k});
                % Create new column name for the posterior field
                column_name = sprintf('simmed_%s', sim_fields{k});
                results_table.(column_name)(i) = sim_value;
            end
        end
    end
end



writetable(results_table, results_dir, 'WriteRowNames',true);




