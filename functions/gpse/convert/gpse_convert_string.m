function out = gpse_convert_string(in, varargin)
% Converts a data structure into or out of a string
%
% Author: A. Conrad Nied
%
% Changelog:
% 2012.10.22 - Created, based on GPS1.7/GPS_edit.m

if(ischar(in))
    % If we are declaring the destination value
    if(nargin == 2)
        to = varargin{1};
    else
        to = 'matrix';
    end

    switch to
        case 'array'
            if(isempty(in)); out = []; return; end
            out = textscan(in, '%d', 'Delimiter', ', ', 'MultipleDelimsAsOne', 1);
            out = out{1};
            if(size(out,1) > 1); out = out'; end
            
        case 'matrix'
            out = [];
            rows = textscan(in, '%s', 'Delimiter', ';');
            rows = rows{1};
            for i = 1:length(rows)
                
                row = textscan(rows{i}, '%d', 'Delimiter', ', ', 'MultipleDelimsAsOne', 1);
                row = row{1};
                out(i,:) = row';
            end
            
        case 'cellstr'
            if(isempty(in)); out = {''}; return; end
            out = textscan(in, '%s', 'Delimiter', ', ', 'MultipleDelimsAsOne', 1);
            out = out{1};
            
        case 'matcell'
            if(isempty(in)); out = cell(1,0); return; end
            semis = strfind(in,';');
            if(isempty(semis)); semis = []; end
            N_rows = length(semis) + 1;
            frame = [0 semis length(in)+1];
            out = cell(N_rows, 1);
            
            for row = 1:N_rows
                section = in((frame(row) + 1):(frame(row + 1) - 1));
                values = textscan(section, '%d', 'Delimiter', ', ', 'MultipleDelimsAsOne', 1);
                out(row) = {values{1}'};
            end
            
    end % switch to
elseif(isnumeric(in) && min(size(in)) == 1) % Array
    if(size(in,1) > 1); in = in'; end
    out = num2str(in);
    
elseif(isnumeric(in)) % Matrix
    if(isempty(in)); out = []; return; end
    out = num2str(in(1,:));
    for i = 2:size(in, 1);
        out = [out ' ; ' num2str(in(i,:))];
    end % For each row of in
    
elseif(iscellstr(in)) % Cell of Strings
    N_rows = length(in);
    out = '';
    
    if(N_rows > 0); out = in{1}; end
    for i_row = 2:N_rows
        out = [out ', ' in{i_row}]; %#ok<*AGROW>
    end
    
elseif(iscell(in)) % Cell of Matrixes (unstable)
    N_rows = length(in);
    out = '';
    
    if(N_rows > 0); out = num2str(in{1}); end
    for i_row = 2:N_rows
        out = [out '; ' num2str(in{i_row})];
    end
    
end % what type of data is this?

end % function