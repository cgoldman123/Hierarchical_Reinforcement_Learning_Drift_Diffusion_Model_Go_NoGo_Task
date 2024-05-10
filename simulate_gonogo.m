function GCM = simulate_gonogo(GCM)
    for k=1:length(GCM)
        dcm = GCM{k};
        params = dcm.fitted_MDP;
        U = dcm.U;
        U.r = nan(1,160);
        U.rt = nan(1,160);
        U.c = nan(1,160);
        settings.field = dcm.field;
        settings.use_ddm = dcm.use_ddm;
        settings.ddm_mapping = dcm.ddm_mapping;
        [L,latents] = likfun_gonogo(params,U,settings);
        GCM{k}.U.r = latents.r';
        GCM{k}.U.rt = latents.rt';
        GCM{k}.U.c = latents.c'-1;
    
        fields_to_Remove = {'M', 'Ep', 'Cp','F', 'pC','fitted_MDP'};
        for i = 1:length(fields_to_Remove)
            if isfield(GCM{k}, fields_to_Remove{i})
                % Remove the field
                GCM{k} = rmfield(GCM{k}, fields_to_Remove{i});
            end
        end
    end
end