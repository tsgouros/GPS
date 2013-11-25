function varargout = gpsa_granger_sigtests(varargin)
% Do tests on the significance
%
% Author: A. Conrad Nied
%
% Changelog:
% 2012.12.13 - Created
% 2013.02.04 - Multiple changes, relatively stable program at this time

%% Input

[state, operation] = gpsa_inputs(varargin);

%% Prepare a report on the type or progress of the data

if(~isempty(strfind(operation, 't')))
    report.spec_subj = 0; % Subject specific?
    report.spec_subs = 1; % Subset specific?
end

%% Execute the process

if(~isempty(strfind(operation, 'c')))
    
    study = gpsa_parameter(state, state.study);
    subset = gpsa_parameter(state, state.subset);
    state.function = 'gpsa_granger_sigtests';
    tbegin = tic;
    
    % Temporary
%     state.subsubset = '_prototype';

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
    state2.subset = [state.subset(1:end-4) 'incons'];
    inputfilename = gpsa_granger_filename(state2, 'result');
    folder = inputfilename(1:find(inputfilename == '/', 1, 'last'));
    outputfilename = sprintf('%s_significance*.mat', inputfilename(1:end-4));
    outputfilename = dir(outputfilename);
    outputfilename = [folder outputfilename(end).name];
    cond2 = load(outputfilename);
    
    %% Get P-Values
    N_comp = 2000;
    
    % Get p-values for our comparisons
    g1.results = cond1.granger_results;
    g1.srcs = cond1.src_ROIs;
    if(isfield(cond1, 'sink_ROIs')); cond1.snk_ROIs = cond1.sink_ROIs; end
    g1.snks = cond1.snk_ROIs;
    g1.p_values = zeros(size(g1.results));
    p_values = squeeze(mean(...
        repmat(g1.results(g1.srcs, g1.snks, :), [1 1 1 N_comp])...
        >= cond1.total_control_granger, 4));
    g1.p_values(g1.srcs, g1.snks, :) = p_values;
    g1.perc95 = zeros(size(g1.results));
    perc95 = quantile(cond1.total_control_granger, 0.95, 4);
    g1.perc95(g1.srcs, g1.snks, :) = perc95;
    
    g2.results = cond2.granger_results;
    g2.srcs = cond2.src_ROIs;
    if(isfield(cond2, 'sink_ROIs')); cond2.snk_ROIs = cond2.sink_ROIs; end
    g2.snks = cond2.snk_ROIs;
    g2.p_values = zeros(size(g2.results));
    p_values = squeeze(mean(...
        repmat(g2.results(g2.srcs, g2.snks, :), [1 1 1 N_comp])...
        >= cond2.total_control_granger, 4));
    g2.p_values(g2.srcs, g2.snks, :) = p_values;
    g2.perc95 = zeros(size(g2.results));
    perc95 = quantile(cond2.total_control_granger, 0.95, 4);
    g2.perc95(g2.srcs, g2.snks, :) = perc95;
    
    clear cond1 cond2;
    
    %% Get relations
    
    if(sum(subset.name == '_'))
        subtype = subset.name(1:find(subset.name == '_', 1, 'first')-1);
    else
        subtype = 'Ambiguous';
    end
    
    % Time settings
    times = 200:400;
    N_time = length(times);
    time_index = 201:401;
    
    % Select Certain ROIs
    srcs_names = {'L-MTG', 'L-SMG'};
    snks_names = {'L-STG'};
    
    % Get ROI names
    rois = sprintf('%s/rois/%s/*.label', study.granger.dir, subset.cortex.roiset);
    rois = dir(rois);
    rois = {rois.name};
    N_rois = length(rois);
    
    curarea = '';
    srcs_index = zeros(N_rois, 1);
    snks_index = zeros(N_rois, 1);
    
    % Format names and find ROI pairs
    for i_roi = N_rois:-1:1
        roi = rois{i_roi};
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
            end % if this is the only of the area you can omit the _1
        end
        rois{i_roi} = roi;
        
        % Add to list of select interactions
        if(sum(strcmp(srcs_names, newarea)))
            srcs_index(i_roi) = 1;
        end
        if(sum(strcmp(snks_names, newarea)))
            snks_index(i_roi) = 1;
        end
    end % for each ROI
    
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
    p1 = zeros(N_comp, N_time);
    p2 = zeros(N_comp, N_time);
    
    for i_src = 1:N_srcs;
        i_src_inrois = srcs_index(i_src);
        for i_snk = 1:N_snks;
            i_snk_inrois = snks_index(i_snk);
            i_comp = (i_src - 1) * N_snks + i_snk;
            src = rois{i_src_inrois};
            snk = rois{i_snk_inrois};
            
            % Format names
            comparisons{i_comp} = sprintf('%s -> %s', src, snk);
            comparisons_fn{i_comp} = sprintf('%sTO%s', lower(src(src ~= '-' && src ~= '_')), lower(snk(snk ~= '-' && snk ~= '_')));
            
            % Gather values
            p1(i_comp, :) = 1 - squeeze(g1.p_values(i_snk_inrois, i_src_inrois, time_index));
            p2(i_comp, :) = 1 - squeeze(g2.p_values(i_snk_inrois, i_src_inrois, time_index));
        end
    end
    
%     % p171 Fisher's statistic
%     t = -2 * log(prod(p1,2));
%     df = 2 * L;
%     chi2cdf(t, df);
%     
%     % Stouffer 1949 p172
%     z1 = norminv(1-p1);
%     z2 = norminv(1-p2);
%     
%     P1 = 1 - normcdf(1/sqrt(L) * sum(z1,2));
%     P2 = 1 - normcdf(1/sqrt(L) * sum(z2,2));
    
    %% Monte Carlo Algorithm (p174)
    
    for i_comp = 1:N_comp
        
        % Presets
        A = 0; % counter of iteration comparison
        B = 1000; % Iterations
        tau = 0.05; % truncation point
        
        % Comparing the MTG to STG
        pa = p1(i_comp, :);
        pb = p2(i_comp, :);
        
        %% Mark 2013.01.17
        
        x = p1(i_comp,:);
        y = p2(i_comp,:);
        N = length(x);
        
        % We don't like certainty
        x(x==0) = 1e-10;
        x(x==1) = 1-1e10;
        y(y==0) = 1e-10;
        y(y==1) = 1-1e10;
        
%             keyboard
            % Compute covariances
            n_lags = 100; % maximum lags that can be used in xcov, the rest
        % %     should be filled in the circulant as 0
        %     xx = circulan([zeros(1, N - n_lags) xcov(x, n_lags) zeros(1, N - n_lags)]);
        % %     xx = xcov(x, n_lags);
        % %     xx = circulan([zeros(1, N - n_lags) xx(201:-1:101) xx(101:201) zeros(1, N - n_lags)]);
        %     xy = circulan([zeros(1, N - n_lags) xcov(x, y, n_lags) zeros(1, N - n_lags)]);
        %     yy = circulan([zeros(1, N - n_lags) xcov(y, n_lags) zeros(1, N - n_lags)]);
        
            xx = circulan([zeros(1, N - n_lags - 1) xcorr(x-mean(x), n_lags, 'coeff') zeros(1, N - n_lags - 1)]);
%             n_lags = 5;
        %     xx = xcov(x, n_lags);
        %     xx = circulan([zeros(1, N - n_lags) xx(201:-1:101) xx(101:201) zeros(1, N - n_lags)]);
            xy = circulan([zeros(1, N - n_lags - 1) xcorr(x-mean(x), y-mean(y), n_lags, 'coeff') zeros(1, N - n_lags - 1)]);
%             n_lags = 100;
            yy = circulan([zeros(1, N - n_lags - 1) xcorr(y-mean(y), n_lags, 'coeff') zeros(1, N - n_lags - 1)]);
        %     xy = circulan(xcov(x, y, n_lags));
        %     yy = circulan(xcov(y, n_lags));
            SIGMA = [xx xy; xy' yy];
        
            % Compute the square root of this covariance
            [U, S, V] = svd(SIGMA);
            C = U * power(S, 0.5);
        
%             C = chol(SIGMA);
        
            C_inv = inv(C);
        
            % Compute null hypothesis
            R_gen = @(R_star) 1 - normcdf(C * norminv(1 - R_star));
            R_star_gen = @(R) 1 - normcdf(C_inv * norminv(1 - R)');
            
            
        
        %% Con Marco 2013.01.09
        % Get the correlation
        %     %     SIGMA = corrcoef([pa; pb]);
        % pa(pa==0) = 1e-16;
        % pa(pa==1) = 1-1e16;
        %     SIGMA = circulan(xcov(pa));
        %     C = chol(SIGMA);
        %     C_inv = inv(C);
        %     R_gen = @(R_star) 1 - normcdf(C * norminv(1 - R_star));
        %     R_star_gen = @(R_) 1 - normcdf(C_inv * norminv(1 - R_)');
        %
        %
        %     % Zaykin paper original
        % %     R_pa = R_star_gen(pa);
        %
%             % Iterate evaluating the p value
%         %     W_0 = prod(p1(p1<=tau));
%             W_0 = sum(-log(pa(pa<=tau)));
%             for i = 1:B
%                 R_star = rand(L, 1); % u's
%         %         norminv(1 - R_star)
%                 R = R_gen(R_star);
%         R(R==0) = 1e-16;
%         R(R==1) = 1-1e16;
%                 W = sum(-log(R(R<=tau)));
%                 A = A + double(W <= W_0);
%             end % for B iterations
%         
%             % Get final P value
%             P = A/B;
%             fprintf('The p value is %f\n', P);
% -> Omnibus test for the threshold of Granger causality

%% 2012.01.23 Mark Vangel
sig_level = 0.05;
sel = ((x <= sig_level) & (y >= sig_level)) | ((x >= sig_level) & (y <= sig_level));
[h, p] = ttest(x(sel) - y(sel));

%% Granger Timecourses

        draw.time = 200:400;
        
        % GCIs with dynamic threshold
        draw.values = [squeeze(g1.results(STG, [MTG SMG], 201:401));...
            squeeze(g2.results(STG, [MTG SMG], 201:401))];
        draw.criteria = [squeeze(g1.perc95(STG, [MTG SMG], 201:401));...
            squeeze(g2.perc95(STG, [MTG SMG], 201:401))];
        draw.labels = {['Cons MTG (' num2str(sum(p1(1, :) <= 0.05)) ')'],...
            ['Cons SMG (' num2str(sum(p1(2, :) <= 0.05)) ')'],...
            ['Incons MTG (' num2str(sum(p2(1, :) <= 0.05)) ')'],...
            ['Incons SMG (' num2str(sum(p2(2, :) <= 0.05)) ')']};
        
%         % GCIs with Flat Threshold
%         draw.values = [squeeze(g1.results(STG, [MTG SMG], 201:401));...
%             squeeze(g2.results(STG, [MTG SMG], 201:401))];
%         draw.criteria = ones(size(draw.values)) * 0.2;
%         spikes = sum(draw.values > draw.criteria, 2);
%         draw.labels = {['Cons MTG (' num2str(spikes(1)) ')'],...
%             ['Cons SMG (' num2str(spikes(2)) ')'],...
%             ['Incons MTG (' num2str(spikes(3)) ')'],...
%             ['Incons SMG (' num2str(spikes(4)) ')']};

% P Values
        draw.values = [p1; p2];
        draw.criteria = ones(size(draw.values)) * 0.05;
        draw.labels = {['Cons MTG (' num2str(sum(p1(1, :) <= 0.05)) ')'],...
            ['Cons SMG (' num2str(sum(p1(2, :) <= 0.05)) ')'],...
            ['Incons MTG (' num2str(sum(p2(1, :) <= 0.05)) ')'],...
            ['Incons SMG (' num2str(sum(p2(2, :) <= 0.05)) ')']};
        
        % Reorder
        draw.values = draw.values([0 2] + i_comp, :);
        draw.criteria = draw.criteria([0 2] + i_comp, :);
        draw.labels = draw.labels([0 2] + i_comp);
        
        draw.legend = 'Northeast';
        draw.N_axes = 2;
        draw.fig = 1;
        draw.flag_pvals = 1;
        draw.flag_sigspikes = 0;
        draw.flag_tipsonly = 1;
        draw.flag_logscale = 1;
        draw.title = sprintf('%s Timecourses', subtype);
        
        gpsp_draw_timecourse(draw);
        
        % Look through all POIs for a profile
        for i_roi = 1:N_rois
            draw.values = 1 - squeeze(g2.p_values(:, i_roi, 201:401));
            draw.values(i_roi, :) = 0.05;
            draw.criteria = ones(size(draw.values)) * 0.05;
            draw.labels = rois;
            draw.N_axes = ceil(N_rois / 3);
            draw.title = sprintf('%s Incons %s to ... Granger Causation ', subtype, rois{i_roi});
            draw.legend = 'SoutheastOutside';
            gpsp_draw_timecourse(draw);
            pause;
        end
        
        folder = sprintf('%s/images/%s', state.dir, datestr(now, 'yymmdd'));
        if(~exist(folder, 'dir'))
            mkdir(folder);
        end
        frame = getframe(gcf);
        filename = sprintf('%s/%s_granger_%s_timecourses_pvals.png', folder, subtype, comparisons_fn{i_comp});
        imwrite(frame.cdata, filename, 'png');
        
        %% Significant event comparison
        
        for flag_decor = 0%:1
            
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
            
            figure(2)
            clf
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
            xs = xr <= 0.05;
            ys = yr <= 0.05;
            
            % Write in the counts for significant matched events
            text(-0.05, -0.05, num2str(sum(xs & ys)), 'FontWeight', 'bold');
            text(-0.05,  0.5, num2str(sum(xs & ~ys)), 'FontWeight', 'bold');
            text( 0.5, -0.05, num2str(sum(~xs & ys)), 'FontWeight', 'bold');
            
            % Save the image of matched p values
            folder = sprintf('%s/images/%s', state.dir, datestr(now, 'yymmdd'));
            if(~exist(folder, 'dir'))
                mkdir(folder);
            end
            frame = getframe(gcf);
            filename = sprintf('%s/%s_granger_%s%s_pmatch.png', folder, subtype, comparisons_fn{i_comp}, corstr);
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
            
            figure(3)
            clf
            
            % Manual Histogram
            diff_xaxis = min(diffs):max(diffs);
            diff_counts = zeros(1, length(diff_xaxis));
            for i = 1:length(diff_xaxis)
                diff_counts(i) = mean(diffs == diff_xaxis(i));
            end
            
%             h = interp1(x_out(h ~= 0), h(h ~= 0), x_out);
%             h(isnan(h)) = 0;
%             fill([x_out(x_out <= -abs(N_diff)) -abs(N_diff) min(x_out)], [h(x_out <= -abs(N_diff)) 0 0], [0 1 0], 'LineStyle', 'none');
%             hold on;
%             fill([x_out(x_out >= abs(N_diff)) max(x_out) abs(N_diff)], [h(x_out >= abs(N_diff)) 0 0], [0 1 0], 'LineStyle', 'none');
diff_xaxis(diff_counts == 0) = [];
diff_counts(diff_counts == 0) = [];
bar(diff_xaxis(diff_xaxis <= -abs(N_diff) | diff_xaxis >= abs(N_diff)), diff_counts(diff_xaxis <= -abs(N_diff) | diff_xaxis >= abs(N_diff)), 'FaceColor', 'g');
hold on
bar(diff_xaxis(diff_xaxis > -abs(N_diff) & diff_xaxis < abs(N_diff)), diff_counts(diff_xaxis > -abs(N_diff) & diff_xaxis < abs(N_diff)), 'FaceColor', 'w');
            line([N_diff N_diff], [0 max(diff_counts)]);
            line(-[N_diff N_diff], [0 max(diff_counts)]);
            plot(diff_xaxis, diff_counts, 'k');
            
            axis([min(diff_xaxis) max(diff_xaxis) 0 max(diff_counts)]);
            
            sig_fraction = sum([diff_counts(diff_xaxis <= -abs(N_diff)) diff_counts(diff_xaxis >= abs(N_diff))]) / sum(diff_counts);
            text(min(diff_xaxis) * 0.9, max(diff_counts) * 0.9, sprintf('p = %0.3f', sig_fraction));
            titlestr = sprintf('Difference between significant events for potential permutations of %d/%d significant events', N_sig, N_events);
            if(x_greater)
                titlestr2 = sprintf('%s %s Phonotactic Bias Consistent (%d) > Inconsistent (%d), diff = %d', subtype, comparisons{i_comp}, sum(xs), sum(ys), sum(xs) - sum(ys));
            else
                titlestr2 = sprintf('%s %s Phonotactic Bias Inconsistent (%d) > Consistent (%d), diff = %d', subtype, comparisons{i_comp}, sum(ys), sum(xs), sum(ys) - sum(xs));
            end
            title({titlestr, titlestr2});
            
            frame = getframe(gcf);
            filename = sprintf('%s/%s_granger_%s%s_probtest.png', folder, subtype, comparisons_fn{i_comp}, corstr);
            imwrite(frame.cdata, filename, 'png');
        end
    end % For the two relations
    
    %% Wrap up
    
    % Record the process
    gpsa_log(state, toc(tbegin));
    
end % If we should do the function

%% Add to the report concerning the progress

if(~isempty(strfind(operation, 'p')))
    study = gpsa_parameter(state.study);
    subset = gpsa_parameter(state.subset);
    
    % Temporary
    state.subsubset = '_prototype';
    
    if(~isempty(subset))
        % Predecessor: gpsa_granger_compute
        inputfilename = gpsa_granger_filename(state, 'result');
        outputfilename = sprintf('%s_significance*.mat', inputfilename(1:end-4));
        report.ready = 1;%~isempty(dir(outputfilename));
        
        report.progress = 0;
        report.finished = report.progress == 1;
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