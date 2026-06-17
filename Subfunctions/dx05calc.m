function dx05 = dx05calc(wspd,alt_agl,zi,wstar)
% 1-D 50% footprint width (Karl et al. (2013) and references therein)

dx05 = 0.9.*wspd.*alt_agl.^(2/3).*zi.^(1/3)./wstar;