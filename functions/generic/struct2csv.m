function struct2csv(struct, filename)
% Converts a structure with a plurality of elements to a CSV file
% 
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2013-03-27 Created as part of GPS
% 2013-07-12 GPS1.8 handles logical and character entries

% Open the file
fileID = fopen(filename, 'w');

% Write the field names
struct_fields = fields(struct);

for i_field = 1:length(struct_fields);
    if(i_field > 1)
        fprintf(fileID, ', ');
    end
    fprintf(fileID, struct_fields{i_field});
end

% Write entries
for i_entry = 1:length(struct)
    fprintf(fileID, '\n');
    for i_field = 1:length(struct_fields);
        if(i_field > 1)
            fprintf(fileID, ', ');
        end
        
        entry = struct(i_entry).(struct_fields{i_field});
        if(isnumeric(entry) || islogical(entry))
            entry = num2str(entry);
        elseif(iscell(entry))
            entry = gpse_convert_string(entry);
            entry(entry == ',') = ';';
        end
        fprintf(fileID, entry);
    end
end

% Close the file
fclose(fileID);