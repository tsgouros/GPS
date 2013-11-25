function varargout = gpsa_granger_sigtests(varargin)
% Do tests on the significance
%
% Author: A. Conrad Nied
%
% Changelog:
% 2012.12.13 - Created
% 2013.02.04 - Multiple changes, relatively stable program at this time
% 2013.02.18 - Timecourse routines
% 2013.03.21 - Some cleanup and bug fixes (setting the divider right)
% 2013.04.11 - GPS 1.8, Updated the status check to the new system
% 2013.04.24 - Fixed labeling of sources and sinks in getting data
% 2013.04.25 - Changed subset design to condition hierarchy

%% Input

[state, operation] = gpsa_inputs(varargin);

%% Prepare a report on the type or progress of the data

if(~isempty(strfind(operation, 't')))
    report.spec_subj = 0; % Subject specific?
    report.spec_cond = 3; % Condition specific?
end

%% Execute the process

if(~isempty(strfind(operation, 'c')))
    
    study = gpsa_parameter(state, state.study);
    condition = gpsa_parameter(state, state.condition);
    state.function = 'gpsa_granger_sigtests';
    tbegin = tic;
    
    flag_flatthresh = false & false;
    flag_decor_do = 0 + 0;
    
    if(flag_flatthresh)
        if(strcmp(condition.name, 'Endpoint_PTBcons'))
            flatthresh = 0.14;
        else % Ambiguous
            flatthresh = 0.17;
        end
    end
    
    if(~study.granger.singlesubject)
        state.subject = study.average_name;
    end
    
    warning('off', 'MATLAB:getframe:RequestedRectangleExceedsFigureBounds');
    
    %% Load Data
    
    % Determine filenames
    inputfilename = gpsa_granger_filename(state, 'result');
    folder = inputfilename(1:find(inputfilename == '/', 1, 'last'));
    outputfilename = sprintf('%s_significance*.mat', inputfilename(1:end-4));
    outputfilename = dir(outputfilename);
    outputfilename = [folder outputfilename(end).name];
    cond1 = load(outputfilename);
    
    % Get second condition
    state2 = state;
    state2.condition = [state.condition(1:end-4) 'incons'];
    inputfilename = gpsa_granger_filename(state2, 'result');
    folder = inputfilename(1:find(inputfilename == '/', 1, 'last'));
    outputfilename = sprintf('%s_significance*.mat', inputfilename(1:end-4));
    outputfilename = dir(outputfilename);
    outputfilename = [folder outputfilename(end).name];
    cond2 = load(outputfilename);
    
    %% Get P-Values
    N_comp = 2000;
    
    % Get p-values for our comparisons
    g1.act = cond1.data;
    g1.results = cond1.granger_results;
    g1.srcs = cond1.src_ROIs;
    if(isfield(cond1, 'sink_ROIs')); cond1.snk_ROIs = cond1.sink_ROIs; end
    g1.snks = cond1.snk_ROIs;
    g1.p_values = zeros(size(g1.results));
    p_values = squeeze(mean(...
        repmat(g1.results(g1.snks, g1.srcs, :), [1 1 1 N_comp])...
        >= cond1.total_control_granger, 4));
    g1.p_values(g1.snks, g1.srcs, :) = p_values;
    g1.perc95 = zeros(size(g1.results));
    perc95 = quantile(cond1.total_control_granger, 0.95, 4);
    g1.perc95(g1.snks, g1.srcs, :) = perc95;
    
    g2.act = cond2.data;
    g2.results = cond2.granger_results;
    g2.srcs = cond2.src_ROIs;
    if(isfield(cond2, 'sink_ROIs')); cond2.snk_ROIs = cond2.sink_ROIs; end
    g2.snks = cond2.snk_ROIs;
    g2.p_values = zeros(size(g2.results));
    p_values = squeeze(mean(...
        repmat(g2.results(g2.snks, g2.srcs, :), [1 1 1 N_comp])...
        >= cond2.total_control_granger, 4));
    g2.p_values(g2.snks, g2.srcs, :) = p_values;
    g2.perc95 = zeros(size(g2.results));
    perc95 = quantile(cond2.total_control_granger, 0.95, 4);
    g2.perc95(g2.snks, g2.srcs, :) = perc95;
    
    clear cond1 cond2;
    
    %% Get relations
    
    if(sum(condition.name == '_'))
        subtype = condition.name(1:find(condition.name == '_', 1, 'first')-1);
    else
        subtype = 'Ambiguous';
    end
    
    % Time settings
    times = 200:400;
    N_time = length(times);
    time_index = 201:401;
    
    % Select Certain ROIs
    srcs_names = {'L-MTG', 'L-SMG', 'L-ParaHip', 'L-ParsOper', 'L-ParsOrb', 'L-ParsTri'};
    snks_names = {'L-STG'};
    
    % Get ROI names
    rois = sprintf('%s/rois/%s/*.label', study.granger.dir, condition.cortex.roiset);
    rois = dir(rois);
    rois = {rois.name};
    rois_area = rois;
    N_rois = length(rois);
    
    curarea = '';
    srcs_index = zeros(N_rois, 1);
    snks_index = zeros(N_rois, 1);
    
    % Format names and find ROI pairs
    for i_roi = N_rois:-1:1
        roi = rois{i_roi};
        roi(roi == '_') = '-';
        divider = find(roi == '-', 1, 'last');
        roi(divider : end) = [];
        divider = find(roi == '-', 1, 'last');
        
        % Format the number in area at the end (or remove)
        newarea = roi(1 : divider - 1);
        if(strcmp(newarea, curarea))
            roi(divider) = '_';
        else
            curarea = newarea;
            if(strcmp(roi(divider + 1 : end), '1'))
                roi(divider : end) = [];
            else
                roi(divider) = '_';
            end % if this is the only of the area you can omit the _1
        end
        rois{i_roi} = roi;
        rois_area{i_roi} = newarea;
        
        % Add to list of select interactions
        if(sum(strcmp(srcs_names, newarea)))
            srcs_index(i_roi) = 1;
        end
        if(sum(strcmp(snks_names, newarea)))
            snks_index(i_roi) = 1;
        end
    end % for each ROI
    
%     srcs_index = find(srcs_index);
    srcs_index = find(srcs_index);
    snks_index = find(snks_index);
    
    if(isempty(srcs_index) && isempty(snks_index))
        fprintf('\n\tDid not find any sources or sinks, aborting this comparison\n\n');
        return
    elseif(isempty(srcs_index))
        fprintf('\n\tDid not find any sources, aborting this comparison\n\n');
        return
    elseif(isempty(snks_index))
        fprintf('\n\tDid not find any sinks, aborting this comparison\n\n');
        return
    end
    
    % Build comparison list
    N_srcs = length(srcs_index);
    N_snks = length(snks_index);
    N_comp = N_srcs * N_snks;
    comparisons = cell(N_comp, 1);
    comparisons_fn = cell(N_comp, 1); % for filenames
    gci1 = zeros(N_comp, N_time);
    gci2 = zeros(N_comp, N_time);
    perc1 = zeros(N_comp, N_time);
    perc2 = zeros(N_comp, N_time);
    pval1 = zeros(N_comp, N_time);
    pval2 = zeros(N_comp, N_time);
    
    all_p = ones(N_rois, N_rois);
    all_pdir = ones(N_rois, N_rois);
    all_spikes = zeros(N_rois, N_rois, 2);
    all_area = zeros(N_rois, N_rois, 2);
    comp_isrcsnks = zeros(N_comp, 2);
    
    for i_src = 1:N_srcs;
        i_src_inrois = srcs_index(i_src);
        for i_snk = 1:N_snks;
            i_snk_inrois = snks_index(i_snk);
            i_comp = (i_src - 1) * N_snks + i_snk;
            comp_isrcsnks(i_comp, 1) = i_src_inrois;
            comp_isrcsnks(i_comp, 2) = i_snk_inrois;
            
            % Format names
            src = rois{i_src_inrois};
            snk = rois{i_snk_inrois};
            comparisons{i_comp} = sprintf('%s -> %s', src, snk);
            comparisons_fn{i_comp} = sprintf('%sto%s', src(src ~= '-' & src ~= '_'), snk(snk ~= '-' & snk ~= '_'));
            
            % Gather values
%             act1_src(i_comp, :) = squeeze(mean(g1.act(:, i_src_inrois, :), 1));
%             act2_src(i_comp, :) = squeeze(mean(g2.act(:, i_src_inrois, :), 1));
%             act1_snk(i_comp, :) = squeeze(mean(g1.act(:, i_snk_inrois, :), 1));
%             act2_snk(i_comp, :) = squeeze(mean(g2.act(:, i_snk_inrois, :), 1));
            gci1(i_comp, :) = squeeze(g1.results(i_snk_inrois, i_src_inrois, time_index));
            gci2(i_comp, :) = squeeze(g2.results(i_snk_inrois, i_src_inrois, time_index));
            perc1(i_comp, :) = squeeze(g1.perc95(i_snk_inrois, i_src_inrois, time_index));
            perc2(i_comp, :) = squeeze(g2.perc95(i_snk_inrois, i_src_inrois, time_index));
            pval1(i_comp, :) = 1 - squeeze(g1.p_values(i_snk_inrois, i_src_inrois, time_index));
            pval2(i_comp, :) = 1 - squeeze(g2.p_values(i_snk_inrois, i_src_inrois, time_index));
        end
    end
    
    %% Plot Activity
    
    folder = sprintf('%s/images/%s', state.dir, datestr(now, 'yymmdd'));
    if(~exist([folder '/0_act'], 'dir'))
        mkdir([folder '/0_act']);
    end
    
    for i_roi = 1:N_rois
        roi = rois{i_roi};
        
        % Only if they are a useful source or sink ROI
        if(sum(srcs_index == i_roi) || sum(snks_index == i_roi))
            act1 = squeeze(mean(g1.act(:, i_roi, 1:401), 1));
            act2 = squeeze(mean(g2.act(:, i_roi, 1:401), 1));
            
            figure(324)
            clf(324)
            plot(0:400, act1, 'b');
            hold on;
            plot(0:400, act2, 'r');
            titlestr = sprintf('%s Average Activation', roi);
            title(titlestr);
            xlabel('Time (ms)')
            ylabel('Cortical Activity')
            xlim([0, 400])
            legend('Lawful', 'Unlawful');
            
            frame = getframe(324);
            filename = sprintf('%s/0_act/%s_%s_CvI_act_%s_tc.png', folder, study.name, subtype, roi);
            imwrite(frame.cdata, filename, 'png');
        end
    end % for each ROI
    
    %% Plot brain strength
    
    if(~exist(folder, 'dir'))
        mkdir(folder);
    end
    if(~exist([folder '/1_bubble'], 'dir'))
        mkdir([folder '/1_bubble']);
    end
    if(~exist([folder '/2_tc'], 'dir'))
        mkdir([folder '/2_tc']);
    end
    if(~exist([folder '/3_ptest'], 'dir'))
        mkdir([folder '/3_ptest']);
    end
    if(~exist([folder '/4_sigcort'], 'dir'))
        mkdir([folder '/4_sigcort']);
    end
    
    brain = gps_brain_get(state);
    points = sprintf('%s/rois/%s/%s/%s_rois.mat', study.granger.dir, condition.cortex.roiset, state.subject, state.subject);
    points = load(points);
    points = points.rois;
    
    % Plot Sink Charts
    for i_snk = 1:length(snks_index)
        i_snk_inrois = snks_index(i_snk);
        
        for i_opp = 1:2
            switch i_opp
                case 1
                    spectype = 'Cons';
                    draw.values = squeeze(g1.results(i_snk_inrois, :, time_index));
                    if(flag_flatthresh)
                        draw.criteria = ones(size(draw.values)) * flatthresh;
                    else
                        draw.criteria = squeeze(g1.perc95(i_snk_inrois, :, time_index));
                    end
                case 2
                    spectype = 'Incons';
                    draw.values = squeeze(g2.results(i_snk_inrois, :, time_index));
                    if(flag_flatthresh)
                        draw.criteria = ones(size(draw.values)) * flatthresh;
                    else
                        draw.criteria = squeeze(g2.perc95(i_snk_inrois, :, time_index));
                    end
            end
            
            spikes = sum(draw.values >= draw.criteria, 2);
            all_spikes(i_snk_inrois, :, i_opp) = spikes;
            
            
            % Timeseries for all influencers
            
            filter = draw.values >= draw.criteria;
            area = zeros(size(draw.values, 1), 1);
%             area = sum(draw.values(filter) - draw.criteria(filter), 2);
            for i_roi = 1:length(rois)
                area(i_roi) = sum(draw.values(i_roi, find(filter(i_roi, :))) - draw.criteria(i_roi, find(filter(i_roi, :)))); %#ok<FNDSB>
                draw.labels{i_roi} = sprintf('%s, S=%d, A=%3.3f', rois{i_roi}, spikes(i_roi), area(i_roi));
            end
            all_area(i_snk_inrois, :, i_opp) = area;
            
%             draw.legend = 'BestOutside';
%             draw.N_axes = length(rois);
%             draw.fig = 2;
%             draw.flag_pvals = 0;
%             draw.flag_sigspikes = 1;
%             draw.flag_tipsonly = 1;
%             draw.flag_logscale = 0;
%             draw.title = sprintf('%s Timecourses to %s', subtype, rois{i_snk_inrois});
%             
%             figure(2)
%             clf
%             set(gcf, 'Units', 'Pixels');
%             set(gcf, 'Position', [10, 10, 600, 800]);
%             set(gca, 'Units', 'Pixels');
%             set(gca, 'Position', [10, 10, 560, 760]);
%             
%             gpsp_draw_timecourse(draw);
%             
%             frame = getframe(gcf);
%             filename = sprintf('%s/2_tc/%s_%s_%s_granger_DLT_%s_influencers_stc.png', folder, study.name, subtype, spectype, rois{i_snk_inrois});
%             imwrite(frame.cdata, filename, 'png');

            % Figure for data
            figure(1)
            clf
            set(gcf, 'Units', 'Pixels');
            set(gcf, 'Position', [10, 10, 600, 450]);
            set(gca, 'Units', 'Pixels');
            set(gca, 'Position', [10, 10, 580, 430]);
            options.fig = gcf;
            options.axes = gca;
            
            % Set parameters
            brain.points = points;
            
            options.shading = 1;
            options.curvature = 'bin';
            options.sides = {'ll', 'rl', 'lm', 'rm'};
            options.centroids = 1;
            options.vertices = 0;
            options.regions = 0;
            options.centroids_color = gps_colorhash((1:length(rois))')/255/4 + 0.25;
            options.centroids_circles = true;
            options.centroids_radius = spikes/5;
            
            options.labels = 0;
            for i_roi = 1:length(rois)
                roicolor = [0 .1 1];
                switch rois{i_roi}
%                     case 'L-MTG'
%                         roicolor = [0 .9 0];
%                     case 'L-SMG'
%                         roicolor = [.9 0 0];
%                     case 'L-STG'
%                         roicolor = [.9 .9 0];
                end
                options.centroids_color(i_roi, :) = roicolor;
            end
            
            gps_brain_draw(brain, options);
            
            frame = getframe(1);
            filename = sprintf('%s/1_bubble/%s_%s_%s_granger_DLT_%s_influencers_cortex_count.png', folder, study.name, subtype, spectype, rois{i_snk_inrois});
            imwrite(frame.cdata, filename, 'png');
            
            
            % Figure of sum
%             figure(1)
%             clf
%             set(gcf, 'Units', 'Pixels');
%             set(gcf, 'Position', [10, 10, 600, 450]);
%             set(gca, 'Units', 'Pixels');
%             set(gca, 'Position', [10, 10, 580, 430]);
%             options.fig = gcf;
%             options.axes = gca;
%             
%             options.centroids_radius = area * 2;
%             
%             gps_brain_draw(brain, options);
%             
%             frame = getframe(1);
%             filename = sprintf('%s/1_bubble/%s_%s_%s_granger_DLT_%s_influencers_cortex_sum.png', folder, study.name, subtype, spectype, rois{i_snk_inrois});
%             imwrite(frame.cdata, filename, 'png');
        end % for each comparing
    end % for each sink
    
    %% Plot sources
    
    for i_src = 1:length(srcs_index)
        i_src_inrois = srcs_index(i_src);
        
        for i_opp = 1:2
            switch i_opp
                case 1
                    spectype = 'Cons';
                    draw.values = squeeze(g1.results(i_src_inrois, :, time_index));
                    if(flag_flatthresh)
                        draw.criteria = ones(size(draw.values)) * flatthresh;
                    else
                        draw.criteria = squeeze(g1.perc95(i_src_inrois, :, time_index));
                    end
                case 2
                    spectype = 'Incons';
                    draw.values = squeeze(g2.results(i_src_inrois, :, time_index));
                    if(flag_flatthresh)
                        draw.criteria = ones(size(draw.values)) * flatthresh;
                    else
                        draw.criteria = squeeze(g2.perc95(i_src_inrois, :, time_index));
                    end
            end
            
            spikes = sum(draw.values >= draw.criteria, 2);

            % Figure for data
            figure(1)
            clf
            set(gcf, 'Units', 'Pixels');
            set(gcf, 'Position', [10, 10, 600, 450]);
            set(gca, 'Units', 'Pixels');
            set(gca, 'Position', [10, 10, 580, 430]);
            options.fig = gcf;
            options.axes = gca;
            
            % Set parameters
            brain.points = points;
            
            options.shading = 1;
            options.curvature = 'bin';
            options.sides = {'ll', 'rl', 'lm', 'rm'};
            options.centroids = 1;
            options.vertices = 0;
            options.regions = 0;
%             options.centroids_color = gps_colorhash((1:length(rois))')/255/4 + 0.25;
            options.centroids_circles = true;
            options.centroids_radius = spikes/5;
            
            options.labels = 0;
            for i_roi = 1:length(rois)
                roicolor = [0 .1 1];
                options.centroids_color(i_roi, :) = roicolor;
            end
            
            gps_brain_draw(brain, options);
            
            frame = getframe(1);
            filename = sprintf('%s/1_bubble/%s_%s_%s_granger_DLT_%s_influencing_cortex_count.png', folder, study.name, subtype, spectype, rois{i_src_inrois});
            imwrite(frame.cdata, filename, 'png');
            
        end % for each comparing
    end % for each sink
    
    %% Comparison Algorithm

    for i_comp = 1 : N_comp
        
        %% Mark 2013.01.17 Decorrelation
        
        x = pval1(i_comp,:);
        y = pval2(i_comp,:);
        N = length(x);
        
        % We don't like certainty
        x(x == 0) = 0 + 1e-10;
        x(x == 1) = 1 - 1e10;
        y(y == 0) = 0 + 1e-10;
        y(y == 1) = 1 - 1e10;
        
        % Compute covariances
        if(flag_decor_do)
            n_lags = 100; % maximum lags that can be used in xcov, the rest
            xx = circulan([zeros(1, N - n_lags - 1) xcorr(x-mean(x), n_lags, 'coeff') zeros(1, N - n_lags - 1)]);
            xy = circulan([zeros(1, N - n_lags - 1) xcorr(x-mean(x), y-mean(y), n_lags, 'coeff') zeros(1, N - n_lags - 1)]);
            yy = circulan([zeros(1, N - n_lags - 1) xcorr(y-mean(y), n_lags, 'coeff') zeros(1, N - n_lags - 1)]);
            SIGMA = [xx xy; xy' yy];
            
            % Compute the square root of this covariance
            [U, S, V] = svd(SIGMA); %#ok<NASGU>
            C = U * power(S, 0.5);
            C_inv = inv(C);
            
            % Compute null-hypothesis maps
            R_gen = @(R_star) 1 - normcdf(C * norminv(1 - R_star)); %#ok<NASGU>
            R_star_gen = @(R) 1 - normcdf(C_inv * norminv(1 - R)'); %#ok<MINV>
        end
        
        %% 2012.01.23 Mark Vangel T Test
%         sig_level = 0.05;
%         sel = ((x <= sig_level) & (y >= sig_level)) | ((x >= sig_level) & (y <= sig_level));
%         [h, p] = ttest(x(sel) - y(sel));
        
        %% Granger Timecourses

        draw.time = 200:400;
        
        % GCIs
        draw.values = [gci1; gci2];
        if(flag_flatthresh)
            draw.criteria = ones(size(draw.values)) * flatthresh; % Flat Threshold
        else
            draw.criteria = [perc1; perc2]; % Dynamic Threshold
        end
        
        % Reorder
        draw.values = draw.values([0 N_comp] + i_comp, :);
        draw.criteria = draw.criteria([0 N_comp] + i_comp, :);
        
        % Labels
        spikes = sum(draw.values >= draw.criteria, 2);
        draw.labels = {sprintf('Cons %s (%d)', comparisons{i_comp}, spikes(1)),...
            sprintf('Incons %s (%d)', comparisons{i_comp}, spikes(2))};
        
        % Colors
        switch rois{comp_isrcsnks(i_comp, 1)}
            case {'L-MTG', 'L-MTG_1', 'L-MTG_2'}
                roicolor = [0 1 0];
            case 'L-SMG'
                roicolor = [1 0 0];
            case {'L-ParaHip', 'L-ParaHip_1'}
                roicolor = [.1 .1 1];
            otherwise
                roicolor = [0 1 1];
        end
        draw.colors_fill = [roicolor; roicolor];
%         draw.colors_line = ones(2, 3)*0.6;
%         draw.colors_line = zeros(2, 3);
        
        % Figure Settings
        draw.legend = 'Northeast';
        draw.N_axes = 2;
        draw.fig = 1;
        draw.flag_pvals = 0;
        draw.flag_sigspikes = 1;
        draw.flag_tipsonly = 1;
        draw.flag_logscale = 0;
        draw.title = sprintf('%s Timecourses', subtype);
        
        figure(2)
        set(gcf, 'Units', 'Pixels');
        set(gcf, 'Position', [10, 10, 600, 450]);
        set(gca, 'Units', 'Pixels');
        set(gca, 'Position', [10, 10, 560, 420]);
        
        gpsp_draw_timecourse(draw);
        
        % Look through all POIs for a profile
%         keyboard
%         for i_roi = 1:N_rois
%             draw.values = 1 - squeeze(g2.p_values(:, i_roi, time_index));
%             draw.values(i_roi, :) = 0.05;
%             draw.criteria = ones(size(draw.values)) * 0.05;
%             draw.labels = rois;
%             draw.N_axes = ceil(N_rois / 3);
%             draw.title = sprintf('%s Incons %s to ... Granger Causation ', subtype, rois{i_roi});
%             draw.legend = 'SoutheastOutside';
%             gpsp_draw_timecourse(draw);
%             pause;
%         end
        
        folder = sprintf('%s/images/%s', state.dir, datestr(now, 'yymmdd'));
        if(~exist(folder, 'dir'))
            mkdir(folder);
        end
        frame = getframe(gcf);
        filename = sprintf('%s/2_tc/%s_%s_granger_DLT_%s_timecourses_gci.png', folder, study.name, subtype, comparisons_fn{i_comp});
        imwrite(frame.cdata, filename, 'png');
        
        draw.title = sprintf('%s Timecourses %s', subtype, comparisons{i_comp});
        draw.fig = 2;
        draw.legend = 'Off';
        draw.flag_sigspikes = 0;
        draw.ylim = [0 1];
        draw.title = sprintf('%s Timecourses', subtype);
        
        figure(2)
        clf
        set(gcf, 'Units', 'Pixels');
        set(gcf, 'Position', [10, 10, 600, 450]);
        set(gca, 'Units', 'Pixels');
        set(gca, 'Position', [10, 10, 560, 420]);
        
        gpsp_draw_timecourse(draw);
        frame = getframe(2);
        filename = sprintf('%s/2_tc/%s_%s_granger_DLT_%s_timecourses_gci_nospikes.png', folder, study.name, subtype, comparisons_fn{i_comp});
        imwrite(frame.cdata, filename, 'png');
        
        %% P Value timecourses
        
        % P Values
        draw.values = [pval1; pval2];
        draw.criteria = ones(size(draw.values)) * 0.05;
        
        % Reorder
        draw.values = draw.values([0 N_comp] + i_comp, :);
        draw.criteria = draw.criteria([0 N_comp] + i_comp, :);
        
        % Figure Settings
        draw.legend = 'Off';
        draw.fig = 2;
        draw.flag_pvals = 1;
        draw.flag_sigspikes = 1;
        draw.flag_tipsonly = 0;
        draw.flag_logscale = 1;
        draw = rmfield(draw, 'ylim');
        draw.title = '';%sprintf('%s Timecourses %s', subtype, comparisons{i_comp});
        
        figure(2)
        clf
        set(gcf, 'Units', 'Pixels');
        set(gcf, 'Position', [10, 10, 600, 450]);
        set(gca, 'Units', 'Pixels');
        set(gca, 'Position', [10, 10, 560, 420]);
        
        gpsp_draw_timecourse(draw);
        if(~exist([folder '/2_tc/pvals'], 'dir')); mkdir([folder '/2_tc/pvals']); end
        frame = getframe(2);
        filename = sprintf('%s/2_tc/pvals/%s_%s_granger_DLT_%s_timecourses_pvals.png', folder, study.name, subtype, comparisons_fn{i_comp});
        imwrite(frame.cdata, filename, 'png');
        
        % Figure Settings
        draw.flag_sigspikes = 0;
        
        figure(2)
        clf
        set(gcf, 'Units', 'Pixels');
        set(gcf, 'Position', [10, 10, 600, 450]);
        set(gca, 'Units', 'Pixels');
        set(gca, 'Position', [10, 10, 560, 420]);
        
        gpsp_draw_timecourse(draw);
        if(~exist([folder '/2_tc/pvals_ns'], 'dir')); mkdir([folder '/2_tc/pvals_ns']); end
        frame = getframe(2);
        filename = sprintf('%s/2_tc/pvals_ns/%s_%s_granger_DLT_%s_timecourses_pvals.png', folder, study.name, subtype, comparisons_fn{i_comp});
        imwrite(frame.cdata, filename, 'png');
        
        %% Significant event comparison
        
        for flag_decor = 0:flag_decor_do
            try
                %% Find comparison values, and decorrate if necessary
                if(flag_decor)
                    rstar = R_star_gen([x y]);
                    xr = rstar(1:(length(rstar)/2));
                    yr = rstar((length(rstar)/2 + 1):end);
                    
                    corstr = '_decorrated';
                else
                    xr = x;
                    yr = y;
                    
                    corstr = '';
                end
                
                %% Plot timepoint comparison
                
                figure(3)
                clf
                set(gcf, 'Units', 'Pixels');
                set(gcf, 'Position', [10, 10, 600, 450]);
                set(gca, 'Units', 'Pixels');
                set(gca, 'Position', [75, 50, 450, 350]);
                
                fill([0.05 0.05 0 0], [0 1 1 0], [0 1 0.5], 'LineStyle', 'none')
                hold on
                fill([0 1 1 0], [0.05 0.05 0 0], [0.5 1 0], 'LineStyle', 'none')
                fill([0 0.05 0.05 0], [0.05 0.05 0 0], [0.5 1 0.5], 'LineStyle', 'none')
                axis([-0.1 1.1 -0.1 1.1])
                plot([-1 2], [0.05 0.05], 'g')
                plot([0.05 0.05], [-1 2], 'g')
                scatter(xr, yr)
                xlabel('Phonotactic Bias Consistent P Values')
                ylabel('Phonotactic Bias Inconsistent P Values')
                title({[subtype ' ' comparisons{i_comp} ' probability values at each timepoint'], 'Green zones represent significant trials'});
                
                % Extract the significant events
                if(flag_flatthresh)
                    xs = gci1(i_comp,:) >= flatthresh;
                    ys = gci2(i_comp,:) >= flatthresh;
                else
                    xs = xr <= 0.05;
                    ys = yr <= 0.05;
                end
                
                % Write in the counts for significant matched events
                text(-0.05, -0.05, num2str(sum(xs & ys)), 'FontWeight', 'bold');
                text(-0.05,  0.5, num2str(sum(xs & ~ys)), 'FontWeight', 'bold');
                text( 0.5, -0.05, num2str(sum(~xs & ys)), 'FontWeight', 'bold');
                
                % Save the image of matched p values
                frame = getframe(3);        options.labels_fontsize = 16;
                filename = sprintf('%s/3_ptest/%s_%s_granger_DLT_%s%s_pmatch.png', folder, study.name, subtype, comparisons_fn{i_comp}, corstr);
                imwrite(frame.cdata, filename, 'png');
                
                % Probability test
                N_events = length(xs) * 2;
                N_sig = sum([xs ys]);
                N_diff = sum(xs) - sum(ys);
                x_greater = N_diff > 0;
                N_simulations = 100000;
                arrangement = [ones(N_sig, 1); zeros(N_events - N_sig, 1)];
                diffs = zeros(N_simulations, 1);
                for i_sim = 1:N_simulations
                    model = reshape(arrangement(randperm(N_events)), [], 2);
                    diffs(i_sim) = sum(model(:, 1)) - sum(model(:, 2));
                end
                
                %% Compute p value of difference and plot distribution
                
                figure(3)
                clf
                set(gcf, 'Units', 'Pixels');
                set(gcf, 'Position', [10, 10, 600, 450]);
                set(gca, 'Units', 'Pixels');
                set(gca, 'Position', [75, 50, 450, 350]);
                
                % Manual Histogram
                diff_xaxis = min(diffs):max(diffs);
                diff_counts = zeros(1, length(diff_xaxis));
                for i = 1:length(diff_xaxis)
                    diff_counts(i) = mean(diffs == diff_xaxis(i));
                end
                
                % Draw the probabilty curve
                diff_xaxis(diff_counts == 0) = [];
                diff_counts(diff_counts == 0) = [];
                %             diff_xaxis = [min(diff_xaxis)-1 diff_xaxis max(diff_xaxis) + 1];
                %             diff_counts = [0 diff_counts 0];
                
                sig_fraction = sum([diff_counts(diff_xaxis <= -abs(N_diff)) diff_counts(diff_xaxis >= abs(N_diff))]) / sum(diff_counts);
                all_p(comp_isrcsnks(i_comp, 2), comp_isrcsnks(i_comp, 1)) = sig_fraction;
                all_pdir(comp_isrcsnks(i_comp, 2), comp_isrcsnks(i_comp, 1)) = 2 - x_greater;
                
                bar(diff_xaxis(diff_xaxis <= -abs(N_diff) | diff_xaxis >= abs(N_diff)), diff_counts(diff_xaxis <= -abs(N_diff) | diff_xaxis >= abs(N_diff)), 'FaceColor', 'g');
                hold on
                bar(diff_xaxis(diff_xaxis > -abs(N_diff) & diff_xaxis < abs(N_diff)), diff_counts(diff_xaxis > -abs(N_diff) & diff_xaxis < abs(N_diff)), 'FaceColor', 'w');
                line([N_diff N_diff], [0 max(diff_counts)]);
                line(-[N_diff N_diff], [0 max(diff_counts)]);
                plot(diff_xaxis, diff_counts, 'k');
                
                axis([min(diff_xaxis) max(diff_xaxis) 0 max(diff_counts)]);
                
                % Label and compute p value of difference
                text(min(diff_xaxis) * 0.9, max(diff_counts) * 0.9, sprintf('p = %0.3f', sig_fraction));
                titlestr = sprintf('Difference between significant events for potential permutations of %d/%d significant events', N_sig, N_events);
                if(x_greater)
                    titlestr2 = sprintf('%s %s Phonotactic Bias Consistent (%d) > Inconsistent (%d), diff = %d', subtype, comparisons{i_comp}, sum(xs), sum(ys), sum(xs) - sum(ys));
                else
                    titlestr2 = sprintf('%s %s Phonotactic Bias Inconsistent (%d) > Consistent (%d), diff = %d', subtype, comparisons{i_comp}, sum(ys), sum(xs), sum(ys) - sum(xs));
                end
                title({titlestr, titlestr2});
                
                % Save Image
                frame = getframe(3);
                filename = sprintf('%s/3_ptest/%s_%s_granger_DLT_%s%s_probtest.png', folder, study.name, subtype, comparisons_fn{i_comp}, corstr);
                imwrite(frame.cdata, filename, 'png');
            catch errormsg
                fprintf('Bug at %s %s %s\n',  subtype, comparisons_fn{i_comp}, corstr);
                errormsg %#ok<NOPRT>
            end % catching errors
        end % if decorrelating
    end % For each comparison
    
    %% Draw final brains showing significant interactions
    
    for i_snk = 1:length(snks_index)
        i_snk_inrois = snks_index(i_snk);
        
        for i_opp = 1:2
            switch i_opp
                case 1
                    spectype = 'Cons';
                case 2
                    spectype = 'Incons';
            end
            
            % Figure of counts
            figure(4)
            clf
            set(gcf, 'Units', 'Pixels');
            set(gcf, 'Position', [10, 10, 600, 450]);
            set(gca, 'Units', 'Pixels');
            set(gca, 'Position', [10, 10, 580, 430]);
            options.fig = gcf;
            options.axes = gca;
            
            options.labels = 0;
            for i_roi = 1:length(rois)
                roicolor = [0 0 .9];
                bordercolor = [0 0 0];
                switch rois{i_roi}
                    case 'L-SMG'
                        roicolor = [.9 0 0];
                    case 'L-STG'
                        roicolor = [.9 .9 0];
                end
                
                if(all_p(i_snk_inrois, i_roi) <= 0.05)
                    if(all_pdir(i_snk_inrois, i_roi) == i_opp)
                        options.labeltext{i_roi} = '*';
                        bordercolor = [1 1 1];
%                         roicolor = roicolor / .9 * .7 + 0.3;
                    else
                        options.labeltext{i_roi} = '-';
                        bordercolor = [1 1 1];
%                         roicolor = roicolor / .9 * .7;
                    end
                else
                    options.labeltext{i_roi} = '';
                end
                
                options.centroids_color(i_roi, :) = roicolor;
                options.centroids_bordercolor(i_roi, :) = bordercolor;
            end
            
            options.labels = 2;
            options.labels_fontsize = 16;
            options.centroids_circles = true;
            options.centroids_radius = squeeze(all_spikes(i_snk_inrois, :, i_opp) / 5)';
            
            gps_brain_draw(brain, options);
            
            frame = getframe(4);
            filename = sprintf('%s/4_sigcort/%s_%s_%s_granger_DLT_%s_influencers_cortex_count_signif.png', folder, study.name, subtype, spectype, rois{i_snk_inrois});
            imwrite(frame.cdata, filename, 'png');
            
            % Figure of sum
            figure(4)
            clf
            set(gcf, 'Units', 'Pixels');
            set(gcf, 'Position', [10, 10, 600, 450]);
            set(gca, 'Units', 'Pixels');
            set(gca, 'Position', [10, 10, 580, 430]);
            options.fig = gcf;
            options.axes = gca;
            
            options.centroids_radius = squeeze(all_area(i_snk_inrois, :, i_opp))'*2;
            
            gps_brain_draw(brain, options);
            
            frame = getframe(4);
            filename = sprintf('%s/4_sigcort/%s_%s_%s_granger_DLT_%s_influencers_cortex_sum_signif.png', folder, study.name, subtype, spectype, rois{i_snk_inrois});
            imwrite(frame.cdata, filename, 'png');
            
        end % for each opposing condition
        
        % Figure of counts
        figure(5)
        clf
        set(gcf, 'Units', 'Pixels');
        set(gcf, 'Position', [10, 10, 600, 450]);
        set(gca, 'Units', 'Pixels');
        set(gca, 'Position', [10, 10, 580, 430]);
        options.fig = gcf;
        options.axes = gca;
        
        options.labels = 0;%2;
        options.centroids_circles = true;
        
        pvals = all_p(i_snk_inrois, :);
%         for i_roi = find(pvals > 0.05); options.labeltext{i_roi} = ''; end
%         for i_roi = find(pvals <= 0.05); options.labeltext{i_roi} = '*'; end
%         for i_roi = find(pvals <= 0.01); options.labeltext{i_roi} = '**'; end
%         for i_roi = find(pvals <= 0.001); options.labeltext{i_roi} = '***'; end

%         pvals = power(pvals, 0.25);
%         red = (1 - pvals) .* (all_pdir(i_snk_inrois, :) == 1);
%         green = pvals.*0;
%         blue = (1 - pvals) .* (all_pdir(i_snk_inrois, :) == 2);
        
        % P Value discrimination by color
        red = (1 - pvals) .* (all_pdir(i_snk_inrois, :) == 1);
        green = pvals.*0;
        blue = (1 - pvals) .* (all_pdir(i_snk_inrois, :) == 2);
        options.centroids_color = [red; green; blue]';
        options.centroids_color = min(options.centroids_color, ones(size(options.centroids_color)));
        options.centroids_color = max(options.centroids_color, zeros(size(options.centroids_color)));
        options.centroids_bordercolor = [1 1 1];
        
        options.centroids_radius = 10;
        
        gps_brain_draw(brain, options);
        
        frame = getframe(5);
        filename = sprintf('%s/4_sigcort/%s_%s_CvI_granger_DLT_%s_influencers_cortex_pvaldiff_color.png', folder, study.name, subtype, rois{i_snk_inrois});
        imwrite(frame.cdata, filename, 'png');
        
        % P Value discrimination by size
        red = (pvals <= 0.05) .* (all_pdir(i_snk_inrois, :) == 1);
        green = zeros(size(pvals));
        blue = (pvals <= 0.05) .* (all_pdir(i_snk_inrois, :) == 2);
        options.centroids_color = [red; green; blue]';
        options.centroids_bordercolor = [1 1 1];
        
        options.labels = 2;
        options.centroids_circles = true;
        options.centroids_radius = 10*(1-pvals)';
        
        gps_brain_draw(brain, options);
        
        frame = getframe(5);
        filename = sprintf('%s/4_sigcort/%s_%s_CvI_granger_DLT_%s_influencers_cortex_pvaldiff_size.png', folder, study.name, subtype, rois{i_snk_inrois});
        imwrite(frame.cdata, filename, 'png');
        
        % Count discrimination by size
        brain2 = brain;
        options2 = options;
        
        brain2.points = brain2.points(pvals <= 0.05 & all_pdir(i_snk_inrois, :) == 1);
        options2.centroids_radius = abs(all_spikes(i_snk_inrois, :, 1) - all_spikes(i_snk_inrois, :, 2))'/2;
        options2.centroids_radius = options2.centroids_radius(pvals <= 0.05 & all_pdir(i_snk_inrois, :) == 1);
        options2.labeltext = options2.labeltext(pvals <= 0.05 & all_pdir(i_snk_inrois, :) == 1);
        options2.centroids_color = options2.centroids_color(pvals <= 0.05 & all_pdir(i_snk_inrois, :) == 1, :);
        options2.centroids_bordercolor = [1 1 1];
        
        gps_brain_draw(brain2, options2);
        figure(5)
        frame = getframe(5);
        filename = sprintf('%s/4_sigcort/%s_%s_CvI_granger_DLT_%s_influencers_cortex_countdiff_size.png', folder, study.name, subtype, rois{i_snk_inrois});
        imwrite(frame.cdata, filename, 'png');
    end % for each sink ROI
    
    % Print out a table of all of the comparisons
    filename = sprintf('%s/%s_%s_granger_DLT_comparisons_signif.txt', folder, study.name, subtype);
    fid = fopen(filename, 'w');
    fprintf(fid, '%s %s\n', study.name, subtype);
    for i_comp = 1:N_comp
        s1 = all_spikes(comp_isrcsnks(i_comp, 2), comp_isrcsnks(i_comp, 1), 1);
        s2 = all_spikes(comp_isrcsnks(i_comp, 2), comp_isrcsnks(i_comp, 1), 2);
        sc = '<' + 2 * (s1 > s2) + (s1 == s2);
        a1 = all_area(comp_isrcsnks(i_comp, 2), comp_isrcsnks(i_comp, 1), 1);
        a2 = all_area(comp_isrcsnks(i_comp, 2), comp_isrcsnks(i_comp, 1), 2);
        p = all_p(comp_isrcsnks(i_comp, 2), comp_isrcsnks(i_comp, 1));
        fprintf(fid, '%20s\tC% 3d %s I% 3d\tp = %0.3f\tA1 = %.2f\tA2 = %.2f\n', comparisons{i_comp}, s1, sc, s2, p, a1, a2);
    end
    fprintf(fid, '\n%s %s Consistent > Inconsistent Significantly\n', study.name, subtype);
    for i_comp = 1:N_comp
        s1 = all_spikes(comp_isrcsnks(i_comp, 2), comp_isrcsnks(i_comp, 1), 1);
        s2 = all_spikes(comp_isrcsnks(i_comp, 2), comp_isrcsnks(i_comp, 1), 2);
        sc = '<' + 2 * (s1 > s2) + (s1 == s2);
        a1 = all_area(comp_isrcsnks(i_comp, 2), comp_isrcsnks(i_comp, 1), 1);
        a2 = all_area(comp_isrcsnks(i_comp, 2), comp_isrcsnks(i_comp, 1), 2);
        p = all_p(comp_isrcsnks(i_comp, 2), comp_isrcsnks(i_comp, 1));
        if(p <= 0.05 && sc == '>')
            fprintf(fid, '%20s\tC% 3d %s I% 3d\tp = %0.3f\tAC = %.2f\tAI = %.2f\n', comparisons{i_comp}, s1, sc, s2, p, a1, a2);
        end
    end
    fprintf(fid, '\n%s %s Inconsistent > Consistent Significantly\n', study.name, subtype);
    for i_comp = 1:N_comp
        s1 = all_spikes(comp_isrcsnks(i_comp, 2), comp_isrcsnks(i_comp, 1), 1);
        s2 = all_spikes(comp_isrcsnks(i_comp, 2), comp_isrcsnks(i_comp, 1), 2);
        sc = '<' + 2 * (s1 > s2) + (s1 == s2);
        a1 = all_area(comp_isrcsnks(i_comp, 2), comp_isrcsnks(i_comp, 1), 1);
        a2 = all_area(comp_isrcsnks(i_comp, 2), comp_isrcsnks(i_comp, 1), 2);
        p = all_p(comp_isrcsnks(i_comp, 2), comp_isrcsnks(i_comp, 1));
        if(p <= 0.05 && sc == '<')
            fprintf(fid, '%20s\tC% 3d %s I% 3d\tp = %0.3f\tAC = %.2f\tAI = %.2f\n', comparisons{i_comp}, s1, sc, s2, p, a1, a2);
        end
    end
    fprintf(fid, '\n');
    fclose(fid);
    
    % Save the important data to a file
    filename = sprintf('%s/%s_%s_granger_stats.mat', folder, study.name, subtype);
    save(filename, 'state', 'N_srcs', 'N_snks', 'N_comp', 'comparisons', 'comparisons_fn', 'gci1', 'gci2', 'perc1', 'perc2', 'pval1', 'pval2', 'all_p', 'all_pdir', 'all_spikes', 'all_area', 'comp_isrcsnks', 'draw', 'brain', 'options');
    
    %% Wrap up
    
    % Record the process
    gpsa_log(state, toc(tbegin));
    
end % If we should do the function

%% Add to the report concerning the progress

if(~isempty(strfind(operation, 'p')))
%     study = gpsa_parameter(state.study);
    condition = gpsa_parameter(state.condition);
    
    if(~isempty(condition))
        % Predecessor: gpsa_granger_compute
        inputfilename = gpsa_granger_filename(state, 'result');
        outputfilename = sprintf('%s_significance*.mat', inputfilename(1:end-4));
        report.ready = ~isempty(dir(outputfilename));
        
        if(sum(condition.name == '_'))
            subtype = condition.name(1:find(condition.name == '_', 1, 'first')-1);
        else
            subtype = 'Ambiguous';
        end
        folder = sprintf('%s/images/%s', state.dir, datestr(now, 'yymmdd'));
        filename = sprintf('%s/%s_granger_*_probtest.png', folder, subtype);
        report.progress = ~isempty(dir(filename));
        report.finished = 0;
    else
        report.ready = 0;
        report.progress = 0;
        report.finished = 0;
    end
end

%% Prepare the report and output

if(nargout == 1 && exist('report', 'var'));
    varargout{1} = report;
end

end % function