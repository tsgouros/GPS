function trialdata = gpsa_meg_eveproc_AR_readblockfile(blockName)
% Reads in the information of the block specified and makes a structure out
% of it.
%
% Author: A. Conrad Nied
%
% Changelog:
% 2013.06.12 - Created out of GPS1.8/gpsa_meg_eveproc_AR1.m

study = 'AR1'; if(blockName(1) == 'B'); study = 'ARTX1'; end

stimuli_file = sprintf('%s/%s/%s_%s.txt',...
    gps_presets('studyparameters'), study, study, blockName);

if(strcmp(study, 'AR1')) % Treatment Experiment on Chronic Aphasics
    % F43_S_1.aiff	gang	gAN	Slide043.jpg	motorcycle	3
    [stim_phonfile, stim_text, stim_phon, stim_imagfile, stim_imag, stim_code] = textread(stimuli_file, '%s\t%s\t%s\t%s\t%s\t%d');
    
    N_trials = length(stim_imagfile);
    for i_trial = 1:N_trials
        trialdata(i_trial).phonfile = stim_phonfile{i_trial};
        trialdata(i_trial).text     = stim_text{i_trial}; %#ok<*AGROW>
        trialdata(i_trial).phon     = stim_phon{i_trial};
        trialdata(i_trial).imagfile = stim_imagfile{i_trial};
        trialdata(i_trial).imag     = stim_imag{i_trial};
        trialdata(i_trial).code     = stim_code(i_trial);
        trialdata(i_trial).category = 'generic';
        
        phonfile = trialdata(i_trial).phonfile;
        trialdata(i_trial).entrynum = str2double(phonfile(2:(find(phonfile == '_', 1, 'first') - 1)));
        trialdata(i_trial).voice    = phonfile(1);
        foil = phonfile((find(phonfile == '_', 1, 'first') + 1):(find(phonfile == '_', 1, 'last') - 1));
        switch foil
            case 'C1'
                trialdata(i_trial).foil = 'I';
            case 'V'
                trialdata(i_trial).foil = 'V';
            case 'C2'
                trialdata(i_trial).foil = 'F';
            case 'S'
                trialdata(i_trial).foil = 'S';
            case 'ID'
                trialdata(i_trial).foil = 'M';
        end % Switch on the foil type
    end % for each found get particular characteristics
else % Plasticity Recovery Observation experiment on Acute Aphasics
    error('This program isn''t ready yet to process ARTX1');
    % ferry.jpg	ferry.wav	M31	transportation
    [stim_imagfile, stim_phonfile, stim_ID, stim_category] = textread(stimuli_file, '%s\t%s\t%s\t%s');
    
    N_trials_local = length(stim_imagfile);
    stim_text = cell(N_trials_local, 1);
    stim_phon = cell(N_trials_local, 1);
    stim_imag = cell(N_trials_local, 1);
    stim_code = zeros(N_trials_local, 1);
    stim_voice = cell(N_trials_local, 1);
    stim_foil = zeros(N_trials_local, 1);
    stim_entrynum = zeros(N_trials_local, 1);
    stim_foilnum = zeros(N_trials_local, 1);
    stim_catnum = zeros(N_trials_local, 1);
    for i_trial_local = 1:N_trials_local
        stim_text{i_trial_local} = stim_phonfile{i_trial_local}(1:end - 4);
        stim_phon{i_trial_local} = stim_phonfile{i_trial_local}(1:end - 4);
        stim_imag{i_trial_local} = stim_imagfile{i_trial_local}(1:end - 4);
        stim_voice{i_trial_local} = 'T';
        
        trigger = stim_ID{i_trial_local};
        if(strcmp(trigger(1:2), 'PI'))
            stim_foil(i_trial_local) = 'I';
            stim_code(i_trial_local) = 0 + str2double(trigger(3:end));
            stim_entrynum(i_trial_local) = str2double(trigger(3:end));
            stim_foilnum(i_trial_local) = 1;
        elseif(strcmp(trigger(1:2), 'PM'))
            stim_foil(i_trial_local) = 'V';
            stim_code(i_trial_local) = 32 + str2double(trigger(3:end));
            stim_entrynum(i_trial_local) = str2double(trigger(3:end));
            stim_foilnum(i_trial_local) = 2;
        elseif(strcmp(trigger(1:2), 'PF'))
            stim_foil(i_trial_local) = 'F';
            stim_code(i_trial_local) = 64 + str2double(trigger(3:end));
            stim_entrynum(i_trial_local) = str2double(trigger(3:end));
            stim_foilnum(i_trial_local) = 3;
        elseif(strcmp(trigger(1), 'S'))
            stim_foil(i_trial_local) = 'S';
            stim_code(i_trial_local) = 96 + str2double(trigger(2:end));
            stim_entrynum(i_trial_local) = str2double(trigger(2:end));
            stim_foilnum(i_trial_local) = 4;
        elseif(strcmp(trigger(1), 'M'))
            stim_foil(i_trial_local) = 'M';
            stim_code(i_trial_local) = 128 + str2double(trigger(2:end));
            stim_entrynum(i_trial_local) = str2double(trigger(2:end));
            stim_foilnum(i_trial_local) = 5;
        end
        
        % Shorten the category name
        switch stim_category{i_trial_local}
            case 'vegetable'
                stim_cat(i_trial_local) = 'V';
                stim_catnum(i_trial_local) = 1;
            case 'furniture'
                stim_cat(i_trial_local) = 'N';
                stim_catnum(i_trial_local) = 2;
            case 'bird'
                stim_cat(i_trial_local) = 'B';
                stim_catnum(i_trial_local) = 3;
            case 'transportation'
                stim_cat(i_trial_local) = 'T';
                stim_catnum(i_trial_local) = 4;
            case 'clothing'
                stim_cat(i_trial_local) = 'C';
                stim_catnum(i_trial_local) = 5;
            case 'fruit'
                stim_cat(i_trial_local) = 'F';
                stim_catnum(i_trial_local) = 6;
        end
    end
end
