 function [eta2_context, eta2_steps] = gpsa_meg_behav_eta2_PTC2
 % Computes the eta for the context and steps of the stimuli for PTC2
 %
 % Author: A. Conrad Nied
 %
 % Changelog:
 % 2013.03.11 - Created
 %
 % Location:
 % /autofs/cluster/dgow/GPS1.7/functions/adhoc/gpsa_meg_behav_eta2_PTC2.m
 
 % Load the matrix file that contains all the trials for all the subjects
 load /autofs/space/huygens_001/users/dgow/PTC2/MEG/average/all_subject_behaviorals.mat
 
 % Limit the trial data to just rounds that had liquids (no blanks)
 trialdata = trialdata([trialdata.liquid] == 'r' | [trialdata.liquid] == 'l'); %#ok<NODEF>
 
 % Find the trials that correspond to specific stimuli types. This produces logical (0/1) vectors
 ss = [trialdata.response] == 's'; % times the responded to s
 rs = [trialdata.liquid] == 'r';
 ls = [trialdata.liquid] == 'l';
 s1s = [trialdata.step] == 1;
 s2s = [trialdata.step] == 2;
 s3s = [trialdata.step] == 3;
 s4s = [trialdata.step] == 4;
 s5s = [trialdata.step] == 5;
 
 % Get means for each step & context
 mean_r = mean(ss(rs));
 mean_l = mean(ss(ls));
 mean_context = mean([mean_l, mean_r]);
 mean_1 = mean(ss(s1s));
 mean_2 = mean(ss(s2s));
 mean_3 = mean(ss(s3s));
 mean_4 = mean(ss(s4s));
 mean_5 = mean(ss(s5s));
 mean_steps = mean([mean_1, mean_2, mean_3, mean_4, mean_5]);
 mean_all = mean(ss);
 
 % Compute the sum of squares
 SS_context = sum([sum(ls) sum(rs)] .* power([mean_l, mean_r] - mean_context, 2));
 SS_steps = sum([sum(s1s) sum(s2s) sum(s3s) sum(s4s) sum(s5s)] .* power([mean_1, mean_2, mean_3, mean_4, mean_5] - mean_steps, 2));
 SS_total = sum(power(ss(ls | rs) - mean_all, 2));
 
 % Compute eta squared
 eta2_context = SS_context / SS_total;
 eta2_steps = SS_steps / SS_total;
 
 end % function
