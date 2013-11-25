function gpsa_plv_python_collection(varargin)
% This function writes routines for the python processing of PLV
%
% Author: A. Conrad Nied
% 
% Changelog:
% 2013.05.20 - Created to batch study analyses
% 2013.05.23 - Continual updates to improve analysis / map to SLaparc17

% Get variables
[state, ~] = gpsa_inputs(varargin);

study = gpsa_parameter(state, state.study);
condition = gpsa_parameter(state, state.condition);
local_state = state;

names = importdata('node_names.txt');
% names = importdata('SLaparc17_names.txt');
N_subjects = length(study.subjects);
N_regions = length(names);
plv = zeros(N_regions, N_regions, N_subjects);
coh = zeros(N_regions, N_regions, N_subjects);
wpli = zeros(N_regions, N_regions, N_subjects);

for i_subject = 1:N_subjects
    local_state.subject = study.subjects{i_subject};
    gpsa_plv_python(local_state)
    folder = sprintf('%s/Python/%s/%s', study.plv.dir, condition.name, local_state.subject);
    unix_command = sprintf('python %s/%s_%s_commands.py', folder, local_state.subject, condition.name);
    fprintf('%s\n', unix_command);
%     unix(unix_command);
    
    filename = sprintf('%s/%s_%s_gamma_plv.txt', folder, local_state.subject, condition.name);
    plv(:, :, i_subject) = load(filename);
    filename = sprintf('%s/%s_%s_gamma_coh.txt', folder, local_state.subject, condition.name);
    coh(:, :, i_subject) = load(filename);
    filename = sprintf('%s/%s_%s_gamma_wpli.txt', folder, local_state.subject, condition.name);
    wpli(:, :, i_subject) = load(filename);
end

%% Phase Locking Values

% Get PLV data
plv = mean(plv, 3);
plv = plv + plv' + eye(N_regions);

% Form clusters - find a functional order
figure(135315)
Z = linkage(plv);
[~, ~, order] = dendrogram(Z, N_regions);
filename = sprintf('%s/Python/%s/%s_plv_dendrogram.png', study.plv.dir, condition.name, condition.name);
set(gca, 'XTickLabel', names(order))
xticklabel_rotate
saveas(gcf, filename, 'png');
filename = sprintf('%s/Python/%s/%s_plv_matrix.png', study.plv.dir, condition.name, condition.name);
imwrite(plv(order, order), filename);

% Save Tables
filename = sprintf('%s/Python/%s/%s_plv_mean.csv', study.plv.dir, condition.name, condition.name);
csvwrite(filename, plv);
filename = sprintf('%s/Python/%s/%s_plv_mean_ordered.csv', study.plv.dir, condition.name, condition.name);
csvwrite(filename, plv(order, order));

% Save names
fid         = fopen(sprintf('%s/Python/%s/%s_plv_names.txt', study.plv.dir, condition.name, condition.name), 'w');
fid_ordered = fopen(sprintf('%s/Python/%s/%s_plv_names_ordered.txt', study.plv.dir, condition.name, condition.name), 'w');
for i_region = 1:length(names)
    fprintf(fid, '%s\n', names{i_region});
    fprintf(fid_ordered, '%s\n', names{order(i_region)});
end
fclose(fid);
fclose(fid_ordered);

%% Display on Cortex
state.subject = study.average_name;
brain = gps_brain_get(state);

% FS Desikan Aparc Version


% Speech Lab Version
sources = {'PT-lh', 'pSTg-lh', 'vIFt-lh', 'pMTg-lh', 'pSMg-lh', 'STG',...
    'superiortemporal-lh', 'parstriangularis-lh'};

for i_source = 1:length(sources)
    source = sources{i_source};
    i_region_source = find(strcmp(source, names));
    if(~isempty(i_region_source))
        
        % Map PLV to the cortex
        regions = load('aparc_labels2.mat');
        
        % Map the PLV to the cortex
        plv_cortex = zeros(brain.N, 1);
%         i_region_source = 61; % L-STG
        for i_vertex = 1:brain.N
            i_region = brain.aparcI(i_vertex) * 2 - (i_vertex <= brain.N_L);
            if(~isempty(regions.regions{i_region, 5}))
                plv_cortex(i_vertex) = plv(i_region_source, regions.regions{i_region, 5});
            end
        end
%         plv_cortex = zeros(brain.N, 1);
%         for i_vertex = 1:brain.N
%             hemi = '-lh';
%             if(i_vertex > brain.N_L); hemi = '-rh'; end
%             region = [brain.SLaparc17.text{brain.SLaparc17.I(i_vertex)} hemi];
%             i_region = find(strcmp(region, names));
%             if(~isempty(i_region))
%                 plv_cortex(i_vertex) = plv(i_region_source, i_region);
%             end
%         end % For each vertex
%         
        % Set the visualization
        brain.plv.v = [0 .2 .5 1.0];
        brain.plv.data = plv_cortex;
        
        figure(4516)
        clf
        set(gcf, 'Units', 'Pixels');
        set(gcf, 'Position', [10, 10, 800, 600]);
        set(gca, 'Units', 'Normalized');
        set(gca, 'Position', [0, 0, 1, 1]);
        
        options.overlays.name = 'plv';
        options.overlays.percentiled = 'v';
        options.overlays.decimated = 0;
        options.overlays.coloring = 'hot';
        options.shading = 1;
        options.curvature = 'bin';
        options.sides = {'ll', 'rl', 'lm', 'rm'};
        options.fig = gcf;
        options.axes = gca;
        
        gps_brain_draw(brain, options);
        set(options.fig, 'Name', 'PLV');
        set(options.fig, 'NumberTitle', 'off');
        
        % Save
        frame = getframe(gcf);
        filename = sprintf('%s/Python/%s/%s_%s_plv_%s_cortex.png', study.plv.dir, condition.name, study.name, condition.name, source);
        imwrite(frame.cdata, filename);
        
        w.vertices = brain.decIndices;
        w.data = plv_cortex;
        filename = sprintf('%s/Python/%s/%s_%s_plv_%s.w', study.plv.dir, condition.name, study.name, condition.name, source);
        mne_write_w_file(filename, w);
    end % if the source exists
end % for all sources

%% Other Metrics

% Save the other metrics
coh = mean(coh, 3);
coh = coh + coh' + eye(size(coh, 1));
filename = sprintf('%s/Python/%s/%s_coh_mean.csv', study.plv.dir, condition.name, condition.name);
csvwrite(filename, coh);

wpli = mean(wpli, 3);
wpli = wpli + wpli' + eye(size(coh, 1));
filename = sprintf('%s/Python/%s/%s_wpli_mean.csv', study.plv.dir, condition.name, condition.name);
csvwrite(filename, wpli);

end % function