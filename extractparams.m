% extract fit results from .mat object for RL-DDM fit hierarchically
% REMEMBER TO CHANGE THE INPU
function extractparams()
% input file

file = 'L:/rsmith/lab-members/cgoldman/go_no_go/DDM/RL_DDM_Millner/RL_DDM_fits/simfit_winning_model_peb_params_nonhierarchical/model1/hierarchichal_fit_results.mat';
% loads a file called fit_results
load(file);
% results location
results_dir = 'L:\rsmith\lab-members\cgoldman\go_no_go\r_stats\model_results\simfit_winning_model_peb_params_nonhierarchical.csv';
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


writetable(results_table, results_dir, 'WriteRowNames',true);




