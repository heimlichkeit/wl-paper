function [bias,sigmas,paramsBGLS,listPars] = getParams_stochasticBGLS_263models(x,modelName,whichAreSet,paramsSet)

listPars = {'bias';'sigma2a';'sigma2i';'sigma2s'};

if ismember(1,whichAreSet)
    bias = paramsSet(1);
    paramsSet(1) = [];
else
    bias = x(1);
    x(1) = [];
end
% sigmas = [sigma2a sigma2i sigma2s] 
for idxSigma = 1:3
    if ismember(idxSigma+1,whichAreSet)
        sigmas(idxSigma) = paramsSet(1);
        paramsSet(1) = [];
    else
        sigmas(idxSigma) = x(1);
        x(1) = [];
    end
end


paramsBGLS = NaN*ones(6,numel(x));%NaN*ones(4,2);
% I assume here that polynomials order would require one number
% (i.e. < 10)
%         modelName = 'B2G1L3S5x4x3'; %example
mechanisms = {'B';'G';'L';'S'};
for idx = 1:size(mechanisms,1)
    k = strfind(modelName,char(mechanisms(idx)));
    if ~isempty(k)
        order = str2double(modelName(k+1));
        paramsBGLS(idx,1:order+1) = x(1:order+1);
        x(1:order+1) = [];
        for ii = 1:order+1
            switch char(mechanisms(idx))
                case 'S'
                    listPars(end+1) = {['H(same) order' num2str(ii-1) ' coeff.']};
                otherwise
                    listPars(end+1) = {[char(mechanisms(idx)) ' order' num2str(ii-1) ' coeff.']};
            end
        end
    end
end
mechanisms2 = {'H(opp)';'H(new)'};
k = strfind(modelName,'x');
if ~isempty(k)
    for idxk = 1:numel(k)
        order = str2num(modelName(k(idxk)+1));
        paramsBGLS(4 + idxk,1:order+1) = x(1:order+1);
        x(1:order+1) = [];
        for ii = 1:order+1
            listPars(end+1) = {[char(mechanisms2(idxk)) ' order' num2str(ii-1) ' coeff.']};
        end
    end
end


end