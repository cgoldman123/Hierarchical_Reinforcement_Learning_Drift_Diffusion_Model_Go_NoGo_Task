function [fit_results,gcm,peb,m] = fit_gonogo_laplace(GCM,plot,fit_hierarchically, use_parfor)
ALL = false;
dbstop if error

% prior expectations and covariance
%--------------------------------------------------------------------------
prior_variance = 4^-1;

% Set up DCM
%--------------------------------------------------------------------------

for k = 1:length(GCM)
    DCM = GCM{k,1};
    for i = 1:length(DCM.field)
        field = DCM.field{i};
        try
            param = DCM.MDP.(field);
            param = double(~~param);
        catch
            param = 1;
        end
        if ALL
            pE.(field) = zeros(size(param));
            pC{i,i}    = diag(param);
        else
            if strcmp(field,'prior_a')
                pE.(field) = DCM.MDP.prior_a;             % don't transform prior_a
                pC{i,i}    = prior_variance;
            elseif strcmp(field,'rs')
                pE.(field) = log(DCM.MDP.rs);             % in log-space (to keep positive)
                pC{i,i}    = prior_variance;
            elseif strcmp(field,'la')
                pE.(field) = log(DCM.MDP.la);             % in log-space (to keep positive)
                pC{i,i}    = prior_variance;   
            elseif strcmp(field,'outcome_sensitivity')
                pE.(field) = log(DCM.MDP.outcome_sensitivity);             % in log-space (to keep positive)
                pC{i,i}    = prior_variance;  
            elseif strcmp(field,'pi_win')
                pE.(field) = log(DCM.MDP.pi_win);             % in log-space (to keep positive)
                pC{i,i}    = prior_variance;
            elseif strcmp(field,'pi_loss')
                pE.(field) = log(DCM.MDP.pi_loss);             % in log-space (to keep positive)
                pC{i,i}    = prior_variance;  
            elseif strcmp(field,'pi')
                pE.(field) = log(DCM.MDP.pi);             % in log-space (to keep positive)
                pC{i,i}    = prior_variance;   
            elseif strcmp(field,'zeta')
                pE.(field) = log(DCM.MDP.zeta/(1-DCM.MDP.zeta));      % in logit-space - bounded between 0 and 1!
                pC{i,i}    = prior_variance;
            elseif strcmp(field,'eta_win')
                pE.(field) = log(0.5/(1-0.5));      % in logit-space - bounded between 0 and 1!
                pC{i,i}    = prior_variance;
            elseif strcmp(field,'eta_loss')
                pE.(field) = log(0.5/(1-0.5));      % in logit-space - bounded between 0 and 1!
                pC{i,i}    = prior_variance;
            elseif strcmp(field,'beta')
                pE.(field) = log(DCM.MDP.beta);                % in log-space (to keep positive)
                pC{i,i}    = prior_variance;
            elseif strcmp(field,'a')
                pE.(field) = log(DCM.MDP.a);                % in log-space (to keep positive)
                pC{i,i}    = prior_variance;
            elseif strcmp(field,'alpha_win')
                pE.(field) = log(DCM.MDP.alpha_win/(1-DCM.MDP.alpha_win));      % in logit-space - bounded between 0 and 1!
                pC{i,i}    = prior_variance;
            elseif strcmp(field,'alpha_loss')
                pE.(field) = log(DCM.MDP.alpha_loss/(1-DCM.MDP.alpha_loss));      % in logit-space - bounded between 0 and 1!
                pC{i,i}    = prior_variance;
            elseif strcmp(field,'alpha')
                pE.(field) = log(DCM.MDP.alpha/(1-DCM.MDP.alpha));      % in logit-space - bounded between 0 and 1!
                pC{i,i}    = prior_variance;
            elseif strcmp(field,'T')
                pE.(field) = log(DCM.MDP.T/(1.5-DCM.MDP.T));   % BOUND BETWEEN 0 AND 1.5
                pC{i,i}    = prior_variance;
            else
                fprintf("Warning: one of parameters not being properly transformed. See inversion_gonogo_laplace");
                pE.(field) = 0;
                pC{i,i}    = prior_variance;
            end
        end
    end

    pC      = spm_cat(pC);
    M.L     = @(P,M,U,Y)spm_mdp_L(P,M,U,Y);  % log-likelihood function
    M.pE    = pE;                            % prior means (parameters)
    M.pC    = pC;                            % prior variance (parameters)
    M.use_ddm = DCM.use_ddm;                 % indicate if want to use ddm
    M.fit_hierarchically = fit_hierarchically;% indicate if want to fit hierarchichally
    M.use_parfor = use_parfor; % indicate if want to use parallel forloop
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
        if (strcmp(field{i},'alpha_win') || strcmp(field{i},'alpha_loss') || strcmp(field{i},'alpha'))
            posterior.(field{i}) = 1/(1+exp(-DCM.Ep.(field{i})));
        elseif strcmp(field{i},'zeta')
            posterior.(field{i}) = 1/(1+exp(-DCM.Ep.(field{i})));       
        elseif strcmp(field{i},'T')
            posterior.(field{i}) = 1.5*exp(DCM.Ep.(field{i})) / (exp(DCM.Ep.(field{i}))+1);
        elseif (strcmp(field{i},'beta') || strcmp(field{i},'a') || strcmp(field{i},'rs') || ...
            strcmp(field{i},'la') || strcmp(field{i},'pi_win') || strcmp(field{i},'pi_loss') || ...
            strcmp(field{i},'pi') || strcmp(field{i},'outcome_sensitivity'))
            posterior.(field{i}) = exp(DCM.Ep.(field{i})); 
        else
            fprintf("Warning: Was not expecting this prior/posterior field name. See fit_gonogo_laplace");
            disp(field{i});
            posterior.(field{i}) = exp(DCM.Ep.(field{i}));
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
    U.field = field;
    [lik,latents] = likfun_gonogo(params, U,DCM.use_ddm);
    % if plot
    %     model_output.action_probabilities = latents.action_probabilities;
    %     model_output.observations = latents.r;
    %     model_output.choices = latents.c;
    %     model_output.P = latents.P;
    %     states_block = latents.trial_type;
    %     plot_gonogo(model_output,states_block);
    % end

    avg_action_probability = mean(latents.action_probabilities);
    fit_results(k).subject = DCM.subject;
    fit_results(k).avg_action_probability = avg_action_probability;
    fit_results(k).model_accuracy = sum(latents.action_probabilities > .5)/length(latents.action_probabilities);
    fit_results(k).latents = latents;
    fit_results(k).prior = prior;
    fit_results(k).posterior = posterior;
    fit_results(k).task_data = DCM.U;
    fit_results(k).F = DCM.F;
    fit_results(k).Cp = DCM.Cp;
    fit_results(k).pC = DCM.pC;
    fit_results(k).model_type = DCM.model_type;
end








