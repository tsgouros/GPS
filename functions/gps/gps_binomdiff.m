function output = gps_binomdiff(A, B, varargin)
% Computes the chance two time series are different
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2013-07-09 Created as separate function from the GPS1.8/gpsa_granger series
% 2013-08-12 Fixed missing values when same

%% Defaults and parameters
threshold = 0.5;
above_threshold = 1;
N_simulations = 20000;

% plot_timecourse = 0;
% plot_parametric = 0;
% plot_probdistribtion = 0;

% Scan input for arguments
for i_argin = 3:nargin
    argument = varargin{i_argin - 2};
    if(isnumeric(argument))
        threshold = argument;
    elseif(ischar(argument))
        switch lower(argument)
            case 'above'
                above_threshold = 1;
            case 'below'
                above_threshold = 0;
%             case 'plot_timecourse'
%                 plot_timecourse = 6759001;
%             case 'plot_parametric'
%                 plot_parametric = 6759002;
%             case 'plot_probdistribution'
%                 plot_probdistribution = 6759003;
%             case 'plot_all'
%                 plot_timecourse = 6759001;
%                 plot_parametric = 6759002;
%                 plot_probdistribution = 6759003;
        end
    else
        error('Unrecognized argument %d', i_argin);
    end
end

%% Compute

% Threshold the data
if(above_threshold)
    A = A >= threshold;
    B = B >= threshold;
else
    A = A <= threshold;
    B = B <= threshold;
end

% Get event counts
N_events = length(A) * 2;
if(N_events ~= length(A) + length(B));
    error('The timecourses have different numbers of data');
end
N_sig_A = sum(A);
N_sig_B = sum(B);
N_sig = N_sig_A + N_sig_B;
N_diff = N_sig_A - N_sig_B;
a_greater = N_diff >= 0;

if(abs(N_diff) > 0)
    % Compute chance overlaps
    arrangement = [ones(N_sig, 1); zeros(N_events - N_sig, 1)];
    diffs = zeros(N_simulations, 1);
    for i_sim = 1:N_simulations
        model = reshape(arrangement(randperm(N_events)), [], 2);
        diffs(i_sim) = sum(model(:, 1)) - sum(model(:, 2));
    end
    
    % Manual Histogram
    diff_bins = min(diffs):max(diffs);
    diff_density = zeros(1, length(diff_bins));
    for i = 1:length(diff_bins)
        diff_density(i) = mean(diffs == diff_bins(i));
    end
%     [diff_bins; diff_density]
    prob_same = sum(diff_density(abs(diff_bins) >= abs(N_diff)));
else
    diff_bins = 0;
    diff_density = 1;
    prob_same = 1;
end

output.p = prob_same;
output.a_greater = a_greater;
output.N_events = N_events;
output.N_sig_A = N_sig_A;
output.N_sig_B = N_sig_B;
output.N_sig = N_sig;
output.N_diff = N_diff;
output.diff_bins = diff_bins;
output.diff_density = diff_density;

end % function, later is old function with pictures

%                 figure(3)
%                 clf
%                 set(gcf, 'Units', 'Pixels');
%                 set(gcf, 'Position', [10, 10, 600, 450]);
%                 set(gca, 'Units', 'Pixels');
%                 set(gca, 'Position', [75, 50, 450, 350]);
%                 
%                 fill([0.05 0.05 0 0], [0 1 1 0], [0 1 0.5], 'LineStyle', 'none')
%                 hold on
%                 fill([0 1 1 0], [0.05 0.05 0 0], [0.5 1 0], 'LineStyle', 'none')
%                 fill([0 0.05 0.05 0], [0.05 0.05 0 0], [0.5 1 0.5], 'LineStyle', 'none')
%                 axis([-0.1 1.1 -0.1 1.1])
%                 plot([-1 2], [0.05 0.05], 'g')
%                 plot([0.05 0.05], [-1 2], 'g')
%                 scatter(xr, yr)
%                 xlabel('Phonotactic Bias Consistent P Values')
%                 ylabel('Phonotactic Bias Inconsistent P Values')
%                 title({[subtype ' ' comparisons{i_comp} ' probability values at each timepoint'], 'Green zones represent significant trials'});
%                 
%                 % Extract the significant events
%                 if(flag_flatthresh)
%                     xs = gci1(i_comp,:) >= flatthresh;
%                     ys = gci2(i_comp,:) >= flatthresh;
%                 else
%                     xs = xr <= 0.05;
%                     ys = yr <= 0.05;
%                 end
%                 
%                 % Write in the counts for significant matched events
%                 text(-0.05, -0.05, num2str(sum(xs & ys)), 'FontWeight', 'bold');
%                 text(-0.05,  0.5, num2str(sum(xs & ~ys)), 'FontWeight', 'bold');
%                 text( 0.5, -0.05, num2str(sum(~xs & ys)), 'FontWeight', 'bold');
%                 
%                 % Save the image of matched p values
%                 frame = getframe(3);        options.labels_fontsize = 16;
%                 filename = sprintf('%s/3_ptest/%s_%s_granger_DLT_%s%s_pmatch.png', folder, study.name, subtype, comparisons_fn{i_comp}, corstr);
%                 imwrite(frame.cdata, filename, 'png');
%                 
%                 N_events = length(xs) * 2;
%                 N_sig = sum([xs ys]);
%                 N_diff = sum(xs) - sum(ys);
%                 x_greater = N_diff > 0;
%                 N_simulations = 100000;
%                 arrangement = [ones(N_sig, 1); zeros(N_events - N_sig, 1)];
%                 diffs = zeros(N_simulations, 1);
%                 for i_sim = 1:N_simulations
%                     model = reshape(arrangement(randperm(N_events)), [], 2);
%                     diffs(i_sim) = sum(model(:, 1)) - sum(model(:, 2));
%                 end
%                 
%                 %% Compute p value of difference and plot distribution
%                 
%                 figure(3)
%                 clf
%                 set(gcf, 'Units', 'Pixels');
%                 set(gcf, 'Position', [10, 10, 600, 450]);
%                 set(gca, 'Units', 'Pixels');
%                 set(gca, 'Position', [75, 50, 450, 350]);
%                 
%                 % Manual Histogram
%                 diff_xaxis = min(diffs):max(diffs);
%                 diff_counts = zeros(1, length(diff_xaxis));
%                 for i = 1:length(diff_xaxis)
%                     diff_counts(i) = mean(diffs == diff_xaxis(i));
%                 end
%                 
%                 % Draw the probabilty curve
%                 diff_xaxis(diff_counts == 0) = [];
%                 diff_counts(diff_counts == 0) = [];
%                 %             diff_xaxis = [min(diff_xaxis)-1 diff_xaxis max(diff_xaxis) + 1];
%                 %             diff_counts = [0 diff_counts 0];
%                 
%                 sig_fraction = sum([diff_counts(diff_xaxis <= -abs(N_diff)) diff_counts(diff_xaxis >= abs(N_diff))]) / sum(diff_counts);
%                 all_p(comp_isrcsnks(i_comp, 2), comp_isrcsnks(i_comp, 1)) = sig_fraction;
%                 all_pdir(comp_isrcsnks(i_comp, 2), comp_isrcsnks(i_comp, 1)) = 2 - x_greater;
%                 
%                 bar(diff_xaxis(diff_xaxis <= -abs(N_diff) | diff_xaxis >= abs(N_diff)), diff_counts(diff_xaxis <= -abs(N_diff) | diff_xaxis >= abs(N_diff)), 'FaceColor', 'g');
%                 hold on
%                 bar(diff_xaxis(diff_xaxis > -abs(N_diff) & diff_xaxis < abs(N_diff)), diff_counts(diff_xaxis > -abs(N_diff) & diff_xaxis < abs(N_diff)), 'FaceColor', 'w');
%                 line([N_diff N_diff], [0 max(diff_counts)]);
%                 line(-[N_diff N_diff], [0 max(diff_counts)]);
%                 plot(diff_xaxis, diff_counts, 'k');
%                 
%                 axis([min(diff_xaxis) max(diff_xaxis) 0 max(diff_counts)]);
%                 
%                 % Label and compute p value of difference
%                 text(min(diff_xaxis) * 0.9, max(diff_counts) * 0.9, sprintf('p = %0.3f', sig_fraction));
%                 titlestr = sprintf('Difference between significant events for potential permutations of %d/%d significant events', N_sig, N_events);
%                 if(x_greater)
%                     titlestr2 = sprintf('%s %s Phonotactic Bias Consistent (%d) > Inconsistent (%d), diff = %d', subtype, comparisons{i_comp}, sum(xs), sum(ys), sum(xs) - sum(ys));
%                 else
%                     titlestr2 = sprintf('%s %s Phonotactic Bias Inconsistent (%d) > Consistent (%d), diff = %d', subtype, comparisons{i_comp}, sum(ys), sum(xs), sum(ys) - sum(xs));
%                 end
%                 title({titlestr, titlestr2});
                