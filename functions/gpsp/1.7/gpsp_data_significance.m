function gpsp_data_significance(state)
% Computes thresholds based on significance
% 
% Author: Conrad Nied
%
% Changelog:
% 2012.12.17 - Created based on functions from plot_wave and GPS_plot

if(~exist('state', 'var'))
    state = gpsp_get;
end % If they didn't specify the state

granger = gpsp_get('granger');

if(isfield(granger, 'nullhypotheses'));
    % Compute the p values of the granger results
    if(~isfield(granger, 'p_values'));
        N_comp = size(granger.nullhypotheses, 4);
        
        if(granger.null_selective) % If the null hypotheses are not all data
            granger.p_values = zeros(size(granger.results));
            p_values = squeeze(mean(...
                repmat(granger.results(granger.null_srcs, granger.null_snks, :), [1 1 1 N_comp])...
                >= granger.nullhypotheses, 4));
            granger.p_values(granger.null_srcs, granger.null_snks, :) = p_values;
        else
            granger.p_values = squeeze(mean(repmat(granger.results, [1 1 1 N_comp]) >= granger.nullhypotheses, 4));
        end
    end
    
    % Compute the p values of the uniform GCI threshold
    threshold = str2double(get(state.cause_threshold, 'String'));
    if(~isfield(granger, 'uniformthreshold_p_values') || ~isfield(granger, 'threshold') || granger.threshold ~= threshold);
        granger.threshold = threshold;
        
        if(granger.null_selective) % If the null hypotheses are not all data
            granger.uniformthreshold_p_values = zeros(size(granger.results));
            uniformthreshold_p_values = squeeze(mean(threshold >= granger.nullhypotheses, 4));
            granger.uniformthreshold_p_values(granger.null_srcs, granger.null_snks, :) = uniformthreshold_p_values;
        else
            granger.uniformthreshold_p_values = squeeze(mean(threshold >= granger.nullhypotheses, 4));
        end
    end
    
    % Compute the alpha vlaues of the granger results
    threshold = str2double(get(state.cause_quantile, 'String'));
    if(~isfield(granger, 'alpha_values') || ~isfield(granger, 'quantile') || granger.quantile ~= threshold);
        granger.quantile = threshold;
        
        if(granger.null_selective) % If the null hypotheses are not all data
            granger.alpha_values = zeros(size(granger.results));
            alpha_values = quantile(granger.nullhypotheses, threshold, 4);
            granger.alpha_values(granger.null_srcs, granger.null_snks, :) = alpha_values;
        else
            granger.alpha_values = quantile(granger.nullhypotheses, threshold, 4);
        end
    end
    
    % Save
    gpsp_set(granger);
    
end % if there is a null hypothesis

end % function