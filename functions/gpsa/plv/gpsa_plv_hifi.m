function varargout = gpsa_plv_hifi(varargin)
% Template function for all other functions
%
% Author: A. Conrad Nied
%
% Changelog:
% 2013.01.15 - Created and adjusted dependent functions
% 2013.04.24 - GPS1.8 Changed subset/subsubset to condition/subset

%% Input

[state, operation] = gpsa_inputs(varargin);

%% Prepare a report on the type or progress of the data

if(~isempty(strfind(operation, 't')))
    report.spec_subj = 1; % Subject specific?
    report.spec_cond = 1; % Condition specific?
end

%% Execute the process

if(~isempty(strfind(operation, 'c')))
    
%     study = gpsa_parameter(state.study);
%     subject = gpsa_parameter(state.subject);
%     condition = gpsa_parameter(state.condition);
    state.function = 'gpsa_plv_hifi';
    tbegin = tic;
    
    state.plvflag = 1;
    state.override = 1;
    
    %% MRI/Surface computations
    
    % Compute new Source Space
    fprintf('\t Source Space');
    gpsa_mri_srcspace(state);
    
    % Compute new BEM
    fprintf('\t Boundary Element Model');
    gpsa_mri_bem(state);
    
    % Transfer BEM to .fif
    fprintf('\t BEM to .fif');
    gpsa_mri_bemmne(state);
    
    %% Minimum norm estimate maps
    
    % Compute new forward solution
    % Compute new inverse solution
    % Compute subject STCs with this higher resolution
    
    
    % Record the process
    gpsa_log(state, toc(tbegin));
    
end % If we should do the function

%% Add to the report concerning the progress

if(~isempty(strfind(operation, 'p')))
    subject = gpsa_parameter(state.subject);
    condition = gpsa_parameter(state.condition);
    if(~isempty(subject))
        % Predecessor: GPSr and mri_brain2mat
        report.ready = (double(~isempty(dir([condition.cortex.plvrefdir '/*.label']))) + ...
            double(exist(sprintf('%s/brain.mat', subject.mri.dir), 'file') == 2)) / 2;
        filename = sprintf('%s/%s/%s*plvref.mat', condition.cortex.plvrefdir,...
            subject.name, subject.name);
        report.progress = ~isempty(dir(filename));
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