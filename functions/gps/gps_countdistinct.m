function p_value = gps_countdistinct(xs, ys)
% Computes a test to see if two event counts are distinct
%
% Author: A. Conrad Nied
% 
% Changelog:
% 2013.05.08 - Created from GPS1.8/gpsa_granger_sigtests.m

% Get parameters
N_events = length(xs) * 2;
N_sig = sum([xs ys]);
N_diff = sum(xs) - sum(ys);
N_simulations = 100000;

% Do the test
x_greater = N_diff > 0;
arrangement = [ones(N_sig, 1); zeros(N_events - N_sig, 1)];
diffs = zeros(N_simulations, 1);
for i_sim = 1:N_simulations
    model = reshape(arrangement(randperm(N_events)), [], 2);
    diffs(i_sim) = sum(model(:, 1)) - sum(model(:, 2));
end

% Box the counts of differences
diff_xaxis = min(diffs):max(diffs);
diff_counts = zeros(1, length(diff_xaxis));
for i = 1:length(diff_xaxis)
    diff_counts(i) = mean(diffs == diff_xaxis(i));
end

% Compute probability
diff_xaxis(diff_counts == 0) = [];
diff_counts(diff_counts == 0) = [];

p_value = sum([diff_counts(diff_xaxis <= -abs(N_diff)) diff_counts(diff_xaxis >= abs(N_diff))]) / sum(diff_counts);

%% Draw the probabilty curve

% bar(diff_xaxis(diff_xaxis <= -abs(N_diff) | diff_xaxis >= abs(N_diff)), diff_counts(diff_xaxis <= -abs(N_diff) | diff_xaxis >= abs(N_diff)), 'FaceColor', 'g');
% hold on
% bar(diff_xaxis(diff_xaxis > -abs(N_diff) & diff_xaxis < abs(N_diff)), diff_counts(diff_xaxis > -abs(N_diff) & diff_xaxis < abs(N_diff)), 'FaceColor', 'w');
% line([N_diff N_diff], [0 max(diff_counts)]);
% line(-[N_diff N_diff], [0 max(diff_counts)]);
% plot(diff_xaxis, diff_counts, 'k');
% 
% axis([min(diff_xaxis) max(diff_xaxis) 0 max(diff_counts)]);
% 
% % Label and compute p value of difference
% text(min(diff_xaxis) * 0.9, max(diff_counts) * 0.9, sprintf('p = %0.3f', p_value));
% titlestr = sprintf('Difference between significant events for potential permutations of %d/%d significant events', N_sig, N_events);
% if(x_greater)
%     titlestr2 = sprintf('%s %s Phonotactic Bias Consistent (%d) > Inconsistent (%d), diff = %d', subtype, comparisons{i_comp}, sum(xs), sum(ys), sum(xs) - sum(ys));
% else
%     titlestr2 = sprintf('%s %s Phonotactic Bias Inconsistent (%d) > Consistent (%d), diff = %d', subtype, comparisons{i_comp}, sum(ys), sum(xs), sum(ys) - sum(xs));
% end
% title({titlestr, titlestr2});

end % function