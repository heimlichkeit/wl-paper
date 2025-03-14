function [pR] = fast263models(allMDMS,paramsBGLS,sigmas,bias)

% Simulation parameters
dt = 11/85;
temporalDiscretization = 100;
maxClength = 15;

pR = NaN(size(allMDMS,1),1);
% Loop over trials
for idx = 1:size(allMDMS,1)
    
    % Sequence
    jnan = isnan(allMDMS(idx,:));
    C = allMDMS(idx,~jnan);
    [~,pR(idx)] = ...
        stochastic15models_BGLS_mex(paramsBGLS,dt,C,maxClength,1,sigmas,...
        temporalDiscretization,1,bias);
    
end


end