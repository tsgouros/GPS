function gpsa_mri_parc_SpeechLab
% Analyze clusters based on cortical activity
%
% Author: A. Conrad Nied (conrad@martinos.org)
%         Jenn Segawa (jennsegawa@gmail.com)
%
% Changelog:
% 2013.05.22 - Created
% 2013.05.23 - All subjects for a study now

%% Load data

% Basic Parameters
state = gpsa_get;
study = gpsa_parameter(state, state.study);

for i_subject = 1:length(study.subjects);
    subject = gpsr_parameter(state, study.subjects{i_subject});
    
    unix_command = sprintf('mris_ca_label -t /autofs/cluster/dgow/GPS1.8/functions/external/BUSpeechLab/SpeechLabLabels_12_11.txt %s lh sphere.reg /autofs/cluster/dgow/GPS1.8/functions/external/BUSpeechLab/lh.SLaparc17.gcs %s/label/lh.SLaparc17.annot', subject.name, subject.mri.dir);
    unix(unix_command);
    unix_command = sprintf('mris_ca_label -t /autofs/cluster/dgow/GPS1.8/functions/external/BUSpeechLab/SpeechLabLabels_12_11.txt %s rh sphere.reg /autofs/cluster/dgow/GPS1.8/functions/external/BUSpeechLab/rh.SLaparc17.gcs %s/label/rh.SLaparc17.annot', subject.name, subject.mri.dir);
    unix(unix_command);
end % for all subjects

% Average subject
unix_command = sprintf('mris_ca_label -t /autofs/cluster/dgow/GPS1.8/functions/external/BUSpeechLab/SpeechLabLabels_12_11.txt %s lh sphere.reg /autofs/cluster/dgow/GPS1.8/functions/external/BUSpeechLab/lh.SLaparc17.gcs %s/%s/label/lh.SLaparc17.annot', study.average_name, study.mri.dir, study.average_name);
unix(unix_command);
unix_command = sprintf('mris_ca_label -t /autofs/cluster/dgow/GPS1.8/functions/external/BUSpeechLab/SpeechLabLabels_12_11.txt %s rh sphere.reg /autofs/cluster/dgow/GPS1.8/functions/external/BUSpeechLab/rh.SLaparc17.gcs %s/%s/label/rh.SLaparc17.annot', study.average_name, study.mri.dir, study.average_name);
unix(unix_command);

end % function
