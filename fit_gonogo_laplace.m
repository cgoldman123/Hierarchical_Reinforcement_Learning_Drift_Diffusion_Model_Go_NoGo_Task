function [fit_results,gcm,peb,m] = fit_gonogo_laplace(GCM,plot)
ALL = false;
dbstop if error

% prior expectations and covariance
%--------------------------------------------------------------------------
prior_variance = 2^-1;

% Set up DCM
%--------------------------------------------------------------------------

for k = 1:length(GCM)
    DCM = GCM{k,1};
    for i = 1:length(DCM.field)
        field = DCM.field{i};
        if (strcmp(field,'alpha_win') || strcmp(field,'alpha_loss') || strcmp(field,'alpha')...
                || strcmp(field,'w') || strcmp(field,'zeta') || strcmp(field,'contaminant_prob'))
            pE.(field) = log(DCM.MDP.(field)/(1-DCM.MDP.(field)));      % in logit-space - bounded between 0 and 1!
            pC{i,i}    = prior_variance;
        elseif strcmp(field,'T')
            pE.(field) = log(DCM.MDP.(field)/(1.5-DCM.MDP.(field)));   % BOUND BETWEEN 0 AND 1.5
            pC{i,i}    = prior_variance;
%         elseif (strcmp(field,'beta') || strcmp(field,'a') || strcmp(field,'rs') || ...
%                 strcmp(field,'la') || strcmp(field,'pi_win') || strcmp(field,'pi_loss') || ...
%                 strcmp(field,'pi') || strcmp(field,'outcome_sensitivity') || strcmp(field,'v'))
%             pE.(field) = log(DCM.MDP.(field));             % in log-space (to keep positive)
%             pC{i,i}    = prior_variance;
        elseif strcmp(field,'a') || strcmp(field,'rs') ||  strcmp(field,'v') ||...
                strcmp(field,'la')|| strcmp(field,'outcome_sensitivity') 
            pE.(field) = log(DCM.MDP.(field));             % in log-space (to keep positive)
            pC{i,i}    = prior_variance;
        elseif (strcmp(field,'beta') || strcmp(field,'pi_win') || strcmp(field,'pi_loss') || ...
                strcmp(field,'pi'))
            pE.(field) = (DCM.MDP.(field));             % in log-space (to keep positive)
            pC{i,i}    = prior_variance;
        else
            fprintf("Warning: one of parameters not being properly transformed. See inversion_gonogo_laplace");
            error("error");
        end
        
    end

    pC      = spm_cat(pC);
    M.L     = @(P,M,U,Y)spm_mdp_L(P,M,U,Y);  % log-likelihood function
    M.pE    = pE;                            % prior means (parameters)
    M.pC    = pC;                            % prior variance (parameters)
    M.use_ddm = DCM.use_ddm;                 % indicate if want to use ddm
    M.fit_hierarchically = DCM.fit_hierarchically;% indicate if want to fit hierarchichally
    M.use_parfor = DCM.use_parfor; % indicate if want to use parallel forloop
    M.priors = DCM.MDP;
    DCM.M = M;
    GCM{k,1} = DCM;
    clear pC
end

[gcm,peb,m] = GNG_dcm_peb_fit(GCM,M);



%% 6.3 Check deviation of prior and posterior means & posterior covariance:
%==========================================================================

%--------------------------------------------------------------------------
% re-transform values and compare prior with posterior estimates
%--------------------------------------------------------------------------
for k = 1:length(gcm)
    DCM = gcm{k};
    field = fieldnames(DCM.Ep);
    for i = 1:length(field)
        if (strcmp(field{i},'alpha_win') || strcmp(field{i},'alpha_loss') || strcmp(field{i},'alpha')...
                || strcmp(field{i},'w') || strcmp(field{i},'zeta') || strcmp(field{i},'contaminant_prob')) 
            posterior.(field{i}) = 1/(1+exp(-DCM.Ep.(field{i})));  
        elseif strcmp(field{i},'T')
            posterior.(field{i}) = 1.5*exp(DCM.Ep.(field{i})) / (exp(DCM.Ep.(field{i}))+1);
%         elseif (strcmp(field{i},'beta') || strcmp(field{i},'a') || strcmp(field{i},'rs') || ...
%             strcmp(field{i},'la') || strcmp(field{i},'pi_win') || strcmp(field{i},'pi_loss') || ...
%             strcmp(field{i},'pi') || strcmp(field{i},'outcome_sensitivity') || strcmp(field{i},'v'))
%             posterior.(field{i}) = exp(DCM.Ep.(field{i})); 
        elseif strcmp(field{i},'a') || strcmp(field{i},'rs') || ...
            strcmp(field{i},'la') || strcmp(field{i},'v') || strcmp(field{i},'outcome_sensitivity')
            posterior.(field{i}) = exp(DCM.Ep.(field{i})); 
        elseif strcmp(field{i},'beta') || strcmp(field{i},'pi_win') || strcmp(field{i},'pi_loss') || ...
            strcmp(field{i},'pi') 
            posterior.(field{i}) = (DCM.Ep.(field{i})); 
        else
            fprintf("Warning: one of parameters not being properly transformed. See inversion_gonogo_laplace");
            error("error");
        end
    end
    params = posterior;
    prior = DCM.M.priors;
    % make sure the params that are not being fit are still passed into
    % the likelihood function and loaded into priors
    priors_names = fieldnames(prior);
    for i = 1:length(priors_names)
        if ~isfield(params, priors_names{i})
            params.(priors_names{i}) = prior.(priors_names{i});
        end
    end
    U = DCM.U;
    settings.field = field;
    settings.use_ddm = DCM.use_ddm;
    settings.ddm_mapping = DCM.ddm_mapping;
    [lik,latents] = likfun_gonogo(params, U,settings);
    % if plot
    %     model_output.action_probabilities = latents.action_probabilities;
    %     model_output.observations = latents.r;
    %     model_output.choices = latents.c;
    %     model_output.P = latents.P;
    %     states_block = latents.trial_type;
    %     plot_gonogo(model_output,states_block);
    % end
    fit_results(k).subject = DCM.subject;
    % get non-nan action probs/model acc
    non_nan_action_prob = latents.action_probabilities(~isnan(latents.action_probabilities));
    fit_results(k).avg_action_probability = mean(non_nan_action_prob);
    fit_results(k).model_accuracy = sum(non_nan_action_prob > .5)/length(non_nan_action_prob);
    fit_results(k).latents = latents;
    fit_results(k).prior = prior;
    fit_results(k).posterior = posterior;
    fit_results(k).task_data = DCM.U;
    fit_results(k).F = DCM.F;
    fit_results(k).Cp = DCM.Cp;
    fit_results(k).pC = DCM.pC;
    fit_results(k).model_type = DCM.model_type;
    fit_results(k).drift_mapping = strjoin(DCM.ddm_mapping.drift);
    fit_results(k).thresh_mapping = strjoin(DCM.ddm_mapping.thresh);
    fit_results(k).bias_mapping = strjoin(DCM.ddm_mapping.bias);
end








