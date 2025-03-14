function [pR] = get_pRsf_bias(bias,varsf,pulses,lambda,tau,dt)
% VS, 25/06/2022

alpha2 = varsf(1);
sigma2a = varsf(2);
sigma2s = varsf(3);

pR = zeros(1,size(pulses,1));
for i = 1:size(pulses,1)
    C = [0 pulses(i,~isnan(pulses(i,:)))];
    T = numel(C);
    deltaR = sign(C) == 1;
    deltaL = sign(C) == -1;
    
    mu = zeros(1,T);
    s = zeros(1,T);
    nR = zeros(1,T); nL = zeros(1,T);
    var_a = zeros(1,T);
    var_s = zeros(1,T);

    var_a(1) = sigma2a*dt;
    var_s(1) = C(1)^2*dt*sigma2s;
    for t = 2:T
        mu(t) = mu(t-1)*(1 + lambda*dt) + C(t)*dt;
        nR(t) = nR(t-1)*(1 + lambda*dt) + deltaR(t);
        nL(t) = nL(t-1)*(1 + lambda*dt) + deltaL(t);
        s(t) = sqrt(nR(t)^2 + nL(t)^2)*sqrt(alpha2)*dt;
        var_a(t) = var_a(t-1)*(1+lambda*dt)^2 + dt*sigma2a;
        var_s(t) = var_s(t-1)*(1+lambda*dt)^2 + C(t)^2*dt^2*tau*sigma2s;
    end
    % Overall variance:
    sigma2 = s.^2 + var_a + var_s;
    pR(i) = 1 - normcdf(bias,mu(end),sqrt(sigma2(end)));
end