function preset = gps_presets(name)
% Returns preset variables. Change this file for a new group
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2012-10-22 Created
% 2013-04-05 Updated for GPS 1.8
% 2013-07-02 Added figure numbers
% 2013-07-08 Added stages
% 2013-08-09 Added images

switch lower(name)
    case {'gpsnum', 'gpsfig', 'menu figure'}
        preset = 6750000;
    case {'gpsanum', 'gpsafig', 'analysis figure'}
        preset = 6754000;
    case {'gpsenum', 'gpsefig', 'edit figure'}
        preset = 6753000;
    case {'gpsrnum', 'gpsrfig', 'region figure'}
        preset = 6752000;
    case {'gpspnum', 'gpspfig', 'plotting figure'}
        preset = 6757000;
    case {'dir', 'directory'}
        preset = '/autofs/cluster/dgow/GPS1.8';
    case {'functions', 'functiondir', 'fdir'}
        preset = '/autofs/cluster/dgow/GPS1.8/functions';
    case {'parameters', 'parameterdir', 'pdir'}
        preset = '/autofs/cluster/dgow/GPS1.8/parameters';
    case {'images', 'imagedir', 'idir'}
        preset = '/autofs/cluster/dgow/GPS1.8/images';
    case {'study'}
        preset = 'PTC3';
    case {'stages'}
        preset = {'util', 'mri', 'meg', 'mne', 'plv', 'granger'};
end % switch

end % function