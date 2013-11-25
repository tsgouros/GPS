function gpsa_mne_avesubj_special()
% Averages the MNE data for all subjects
%
% Author: A. Conrad Nied, Reid Vancelette
%
% Changelog: aspects
% 2011.12.29 - Originally created as GPS1.6(-)/ave_mne.m
% 2012.09.13 - Last modified in GPS1.6(-)
% 2012.10.09 - Updated to GPS1.7 format
% 2013.02.19 - Adapted to create average max/median subject brains
% 2013.03.01 - Generalized for any subject

segments = {'Verb', 'VerbM', 'Noun', 'End', 'Start'};

state.study = 'MPS1';
state.dir = '/autofs/cluster/dgow/GPS1.7';
study = gpsa_parameter(state, state.study);

% Start subject at 0 if you want to do the average subject
fprintf('Consolidating conditions for MPS1\n'); 

for i_subject = 1:length(study.subjects)
    if(i_subject == 0)
        state.subject = study.average_name;
    else
        state.subject = study.subjects{i_subject};
    end
    fprintf('\t%s Reading Brain', state.subject);
    brain = gps_brain_get(state);
    
    for i = 1:length(segments)
        segment = segments{i};
        
        if(i_subject == 0) % Average
            ssR_l = sprintf('%s/average/MPS1_average_ss%sR_mne-lh.stc', study.meg.dir, segment);
            ssR_r = sprintf('%s/average/MPS1_average_ss%sR_mne-rh.stc', study.meg.dir, segment);
            soR_l = sprintf('%s/average/MPS1_average_so%sR_mne-lh.stc', study.meg.dir, segment);
            soR_r = sprintf('%s/average/MPS1_average_so%sR_mne-rh.stc', study.meg.dir, segment);
            ssI_l = sprintf('%s/average/MPS1_average_ss%sI_mne-lh.stc', study.meg.dir, segment);
            ssI_r = sprintf('%s/average/MPS1_average_ss%sI_mne-rh.stc', study.meg.dir, segment);
            soI_l = sprintf('%s/average/MPS1_average_so%sI_mne-lh.stc', study.meg.dir, segment);
            soI_r = sprintf('%s/average/MPS1_average_so%sI_mne-rh.stc', study.meg.dir, segment);
        else
            ssR_l = sprintf('%s/%s/averages_covariances/%s_ss%sR_mne-lh.stc', study.meg.dir, state.subject, state.subject, segment);
            ssR_r = sprintf('%s/%s/averages_covariances/%s_ss%sR_mne-rh.stc', study.meg.dir, state.subject, state.subject, segment);
            soR_l = sprintf('%s/%s/averages_covariances/%s_so%sR_mne-lh.stc', study.meg.dir, state.subject, state.subject, segment);
            soR_r = sprintf('%s/%s/averages_covariances/%s_so%sR_mne-rh.stc', study.meg.dir, state.subject, state.subject, segment);
            ssI_l = sprintf('%s/%s/averages_covariances/%s_ss%sI_mne-lh.stc', study.meg.dir, state.subject, state.subject, segment);
            ssI_r = sprintf('%s/%s/averages_covariances/%s_ss%sI_mne-rh.stc', study.meg.dir, state.subject, state.subject, segment);
            soI_l = sprintf('%s/%s/averages_covariances/%s_so%sI_mne-lh.stc', study.meg.dir, state.subject, state.subject, segment);
            soI_r = sprintf('%s/%s/averages_covariances/%s_so%sI_mne-rh.stc', study.meg.dir, state.subject, state.subject, segment);
        end
        
        fprintf('. Read stc files');
        ssR_l = mne_read_stc_file1(ssR_l);
        ssR_r = mne_read_stc_file1(ssR_r);
        soR_l = mne_read_stc_file1(soR_l);
        soR_r = mne_read_stc_file1(soR_r);
        ssI_l = mne_read_stc_file1(ssI_l);
        ssI_r = mne_read_stc_file1(ssI_r);
        soI_l = mne_read_stc_file1(soI_l);
        soI_r = mne_read_stc_file1(soI_r);
        ssR = [ssR_l.data; ssR_r.data];
        soR = [soR_l.data; soR_r.data];
        ssI = [ssI_l.data; ssI_r.data];
        soI = [soI_l.data; soI_r.data];
        
        cat_all = cat(3, ssR, soR, ssI, soI);
        
        fprintf('. Determine averages');
%         average_all = mean(cat_all, 3);
%         max_all = max(cat_all, [], 3);
        median_all = median(cat_all, 3);
        
        if(i_subject) % Regular subject
            folder = sprintf('%s/%s/stcs', study.meg.dir, state.subject);
            if(~exist(folder, 'dir')); mkdir(folder); end
            if(~exist([folder '/pictures'], 'dir')); mkdir([folder '/pictures']); end
            median_l = sprintf('%s/%s_%s_median_mne-lh.stc', folder, state.subject, segment);
            median_r = sprintf('%s/%s_%s_median_mne-rh.stc', folder, state.subject, segment);
        else % Average
            folder = sprintf('%s/%s/average_stc', study.meg.dir, state.subject);
            if(~exist(folder, 'dir')); mkdir(folder); end
            if(~exist([folder '/pictures'], 'dir')); mkdir([folder '/pictures']); end
%             mean_l = sprintf('%s/MPS1_average_%s_mean_mne-lh.stc', folder, segment);
%             mean_r = sprintf('%s/MPS1_average_%s_mean_mne-rh.stc', folder, segment);
%             max_l = sprintf('%s/MPS1_average_%s_max_mne-lh.stc', folder, segment);
%             max_r = sprintf('%s//MPS1_average_%s_max_mne-rh.stc', folder, segment);
            median_l = sprintf('%s/MPS1_average_%s_median_mne-lh.stc', folder, segment);
            median_r = sprintf('%s/MPS1_average_%s_median_mne-rh.stc', folder, segment);
        end
        
        new_stc_l = ssR_l;
        new_stc_r = ssR_r;
%         new_stc_l.data = average_all(1:size(ssR_l.data, 1), :);
%         new_stc_r.data = average_all(size(ssR_l.data, 1)+1:end, :);
%         mne_write_stc_file1(mean_l, new_stc_l);
%         mne_write_stc_file1(mean_r, new_stc_r);
%         
%         new_stc_l.data = max_all(1:size(ssR_l.data, 1), :);
%         new_stc_r.data = max_all(size(ssR_l.data, 1)+1:end, :);
%         mne_write_stc_file1(max_l, new_stc_l);
%         mne_write_stc_file1(max_r, new_stc_r);
        
        new_stc_l.data = median_all(1:size(ssR_l.data, 1), :);
        new_stc_r.data = median_all(size(ssR_l.data, 1)+1:end, :);
        mne_write_stc_file1(median_l, new_stc_l);
        mne_write_stc_file1(median_r, new_stc_r);
        
        
        fprintf('. Generate Images');
        figure(3)
        clf
        set(gcf, 'Units', 'Pixels');
        set(gcf, 'Position', [300, 300, 800, 600]);
        set(gca, 'Units', 'Pixels');
        set(gca, 'Position', [0, 0, 800, 600]);
        
        % Set parameters
        drawdata = brain;
        drawdata.act.p = [80 90 95];
        options.overlays.name = 'act';
        options.overlays.percentiled = 'p';
        options.overlays.decimated = 1;
        options.overlays.coloring = 'hot';
        options.shading = 1;
        options.curvature = 'bin';
        options.sides = {'ll', 'rl', 'lm', 'rm'};
        options.fig = gcf;
        options.axes = gca;
        
%         % Draw mean activity 300TO500
%         drawdata.act.data = mean(average_all(:, 300:500), 2);
%         gps_brain_draw(drawdata, options);
%         
%         frame = getframe(gcf);
%         filename = sprintf('%s/pictures/%s_%s_300TO500_mean.png', folder, study.name, segment);
%         imwrite(frame.cdata, filename);
%         
%         
%         % Draw mean activity 500TO800
%         drawdata.act.data = mean(average_all(:, 500:800), 2);
%         gps_brain_draw(drawdata, options);
%         
%         frame = getframe(gcf);
%         filename = sprintf('%s/pictures/%s_%s_500TO800_mean.png', folder, study.name, segment);
%         imwrite(frame.cdata, filename);
%         
%         % Draw max activity 300TO500
%         drawdata.act.data = mean(max_all(:, 300:500), 2);
%         gps_brain_draw(drawdata, options);
%         
%         frame = getframe(gcf);
%         filename = sprintf('%s/pictures/%s_%s_300TO500_max.png', folder, study.name, segment);
%         imwrite(frame.cdata, filename);
%         
%         
%         % Draw max activity 500TO800
%         drawdata.act.data = mean(max_all(:, 500:800), 2);
%         gps_brain_draw(drawdata, options);
%         
%         frame = getframe(gcf);
%         filename = sprintf('%s/pictures/%s_%s_500TO800_max.png', folder, study.name, segment);
%         imwrite(frame.cdata, filename);
        
        % Draw median activity 300TO500
        drawdata.act.data = mean(median_all(:, 300:500), 2);
        gps_brain_draw(drawdata, options);
        
        frame = getframe(gcf);
        filename = sprintf('%s/pictures/%s_%s_300TO500_median.png', folder, study.name, segment);
        imwrite(frame.cdata, filename);
        
        
        % Draw median activity 500TO800
        drawdata.act.data = mean(median_all(:, 500:800), 2);
        gps_brain_draw(drawdata, options);
        
        frame = getframe(gcf);
        filename = sprintf('%s/pictures/%s_%s_500TO800_median.png', folder, study.name, segment);
        imwrite(frame.cdata, filename);
        
        fprintf('.\n');
    end % for all subjects
    
end % function
