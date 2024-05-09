function GCM = simulate_gonogo(GCM)
    for k=1:length(GCM)
        dcm = GCM{k};
        params = dcm.MDP;
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
    end

end