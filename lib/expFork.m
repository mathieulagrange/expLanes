function expFork(experimentName, referenceExperimentPath, forkStep, experimentPath)
% expFork create an expLanes experiment
%	expFork(experimentName, referenceExperimentPath)
%	- experimentName: name of the experiment
%	- referenceExperimentPath: path to the reference experiment
%   - forkStep: numeric id specifying at which step the fork is
%   effective
%   - experimentPath: path to the fork experiment 
%
%	Default values and other settings can be set in your configuration file
% 	located in your home in the .expLanes directory. This file serves
%	as the initial config file for your expLanes experiments

%	Copyright (c) 2014 Mathieu Lagrange (mathieu.lagrange@cnrs.fr)
%	See licence.txt for more information.

if ~exist('experimentPath', 'var')
    if~isempty(dir('*Factors.txt'))
        fprintf(2, 'Fork within the directory of an existing experiment is unsafe. Please change current directory or specify an alternative path.\n');
        return;
    end
    experimentPath = '';
end

[p, referenceExperimentName] = fileparts(referenceExperimentPath);
shortReferenceExperimentName = names2shortNames(referenceExperimentName);
shortReferenceExperimentName = shortReferenceExperimentName{1};
expLanesPath = fileparts(mfilename('fullpath'));

referenceConfigFileName = getUserFileName(shortReferenceExperimentName, referenceExperimentName, referenceExperimentPath, expLanesPath);
referenceConfig = expConfigParse(referenceConfigFileName);

shortExperimentName = names2shortNames(experimentName);
shortExperimentName = shortExperimentName{1};

copyfile([referenceExperimentPath '/' shortReferenceExperimentName 'Factors.txt'], [tempdir shortExperimentName 'Factors.txt']);

stepName = expStepName(referenceConfig, referenceExperimentPath, shortReferenceExperimentName);

expCreate(experimentName, stepName, experimentPath, [], {'inputPath', referenceConfig.dataPath, 'forkStep', num2str(forkStep)});


copyfile([tempdir shortExperimentName 'Factors.txt'], [shortExperimentName 'Factors.txt']);