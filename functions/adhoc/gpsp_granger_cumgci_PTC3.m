function gpsp_granger_cumgci_PTC3
% Get Cumulative GCI data and saves it as figures
%
% Author: Conrad Nied
%
% Changelog:
% 2012.10.19 Created

%% Set parameters

state.dir = gps_dir;
state.study = 'PTC3';
state.subject = 'average';

study = gpsa_parameter(state, state.study);

%% Gather Data

cd '/autofs/space/norbert_001/users/conrad/PTC3/Granger/results';

for i_subset = 1:19
    subset = study.subsets{i_subset + 5};
    data = load([subset '.mat']);
    tostg = squeeze(data.granger_results([5 6 7 8], 18, :));
    cumgci.(subset).tostg = sum(tostg(tostg(:) > 0.2) - 0.2);
    fromstg = squeeze(data.granger_results(18, [5 6 7 8], :));
    cumgci.(subset).fromstg = sum(fromstg(fromstg(:) > 0.2) - 0.2);
end

%% Make Visuals

cd '/autofs/space/norbert_001/users/conrad/PTC3/Granger/results/GCI Cumulative';

figure(1)

colormap(flipud(jet))

bar([cumgci.NW_HD_AP.tostg cumgci.NW_HD_AP.fromstg; cumgci.NW_LD_AP.tostg cumgci.NW_LD_AP.fromstg]')
ylabel('Cumulative Granger Causality (GCI)')
set(gca, 'XTickLabel',{'Top-Down', 'Bottom-Up'});
ylim([0 20]);
legend({'High Density', 'Low Density'}, 'Location', 'NorthEast')
frame = getframe(gcf);
imwrite(frame.cdata, 'PTC3_NW_HDvLD_cumgci_rstg1.png');

bar([cumgci.NW_AD_HP.tostg cumgci.NW_AD_HP.fromstg; cumgci.NW_AD_LP.tostg cumgci.NW_AD_LP.fromstg]')
ylabel('Cumulative Granger Causality (GCI)')
set(gca, 'XTickLabel',{'Top-Down', 'Bottom-Up'});
ylim([0 20]);
legend({'High Probability', 'Low Probability'}, 'Location', 'NorthEast')
frame = getframe(gcf);
imwrite(frame.cdata, 'PTC3_NW_HPvLP_cumgci_rstg1.png');

bar([cumgci.RW_AD_HP.tostg cumgci.RW_AD_HP.fromstg; cumgci.RW_AD_LP.tostg cumgci.RW_AD_LP.fromstg]')
ylabel('Cumulative Granger Causality (GCI)')
set(gca, 'XTickLabel',{'Top-Down', 'Bottom-Up'});
ylim([0 20]);
legend({'High Probability', 'Low Probability'}, 'Location', 'NorthEast')
frame = getframe(gcf);
imwrite(frame.cdata, 'PTC3_RW_HPvLP_cumgci_rstg1.png');

bar([cumgci.RW_HD_AP.tostg cumgci.RW_HD_AP.fromstg; cumgci.RW_LD_AP.tostg cumgci.RW_LD_AP.fromstg]')
ylabel('Cumulative Granger Causality (GCI)')
set(gca, 'XTickLabel',{'Top-Down', 'Bottom-Up'});
ylim([0 20]);
legend({'High Density', 'Low Density'}, 'Location', 'NorthEast')
frame = getframe(gcf);
imwrite(frame.cdata, 'PTC3_RW_HDvLD_cumgci_rstg1.png');

save('cumgci_20121019.mat', 'cumgci');

end % function