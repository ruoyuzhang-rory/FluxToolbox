function h = WaveSummaryPlotResearch(W, name, Tunit)
%WAVESUMMARYPLOTRESEARCH Plot the research wavelet-flux diagnostics together.
%   h = WaveSummaryPlotResearch(W, name, Tunit) creates one linked figure
%   with normalized time series, wavelet power, and flux time series.
%
%   W     is the structure returned by WaveletFlux or ECFlux.
%   name  is an optional figure-name prefix.
%   Tunit is either 'time' (default) or 'dist'.
%
%   The output h is a structure containing figure and axes handles.

if nargin < 2 || isempty(name), name = ''; end
if nargin < 3 || isempty(Tunit), Tunit = 'time'; end

cfg = localPlotConfig();
[T, Tlab, F, COI] = localCoordinate(W, Tunit, cfg);
[w_plot, x_plot, w_recon_plot, x_recon_plot, has_recon] = localNormalizedSignals(W);
ECflux = localECFlux(W);
wx_smooth = localSmoothedInstantFlux(W, cfg.smoothWindowPoints);

h = localCreateFigure(name);
localPlotSignals(h.ax(1), T, x_plot, w_plot, x_recon_plot, w_recon_plot, has_recon, cfg);
localPlotPower(h.ax(2), T, F, COI, W, cfg);
localPlotFlux(h.ax(3), T, Tlab, W, ECflux, wx_smooth, cfg);
linkaxes(h.ax, 'x');

end

function cfg = localPlotConfig()
cfg.timeOffsetHours = 0;
cfg.smoothWindowPoints = 150;
cfg.fontName = 'Arial';
cfg.fontSize = 15;
cfg.axisLineWidth = 1.1;
cfg.showSignificanceContour = false;
cfg.signalLegendPosition = [0.72, 0.74, 0.24, 0.14];
cfg.fluxLegendPosition = [0.72, 0.07, 0.26, 0.17];
cfg.signalColors = struct( ...
    'xOriginal', [120, 205, 198] / 255, ...
    'wOriginal', [190, 160, 235] / 255, ...
    'xRecon', [33, 120, 118] / 255, ...
    'wRecon', [96, 63, 128] / 255);
cfg.fluxColors = struct( ...
    'waveNoCoi', [136, 193, 34] / 255, ...
    'wave', [248, 177, 113] / 255, ...
    'ec', [0, 177, 207] / 255, ...
    'zero', [0.5, 0.5, 0.5], ...
    'mask', [0.8, 0.8, 0.8]);
cfg.powerColors = [35, 4, 191; ...
                   83, 178, 255; ...
                   255, 255, 255; ...
                   248, 177, 113; ...
                   213, 22, 46] / 255;
end

function [T, Tlab, F, COI] = localCoordinate(W, Tunit, cfg)
switch lower(Tunit)
    case {'dist', 'distance'}
        T = W.dist(:)';
        Tlab = 'Distance';
        F = W.freq ./ mean(W.data.speed, 'omitnan');
        COI = 1 ./ (W.coi .* mean(W.data.speed, 'omitnan'));
    otherwise
        if isduration(W.time)
            T = hours(W.time(:)');
        else
            T = W.time(:)' / 3600;
        end
        T = T + cfg.timeOffsetHours;
        Tlab = 'Time (h)';
        F = W.freq;
        COI = 1 ./ W.coi;
end
end

function [w_plot, x_plot, w_recon_plot, x_recon_plot, has_recon] = localNormalizedSignals(W)
w0 = W.data.w;
x0 = W.data.x;
w_plot = localNormalize(w0, w0);
x_plot = localNormalize(x0, x0);

has_recon = isfield(W, 'w_recon') && isfield(W, 'x_recon') ...
    && ~isempty(W.w_recon) && ~isempty(W.x_recon);

if has_recon
    w_recon_plot = localNormalize(W.w_recon, w0);
    x_recon_plot = localNormalize(W.x_recon, x0);
else
    w_recon_plot = [];
    x_recon_plot = [];
end
end

function y = localNormalize(x, ref)
mu = mean(ref, 'omitnan');
sigma = std(ref, 'omitnan');
if isnan(sigma) || sigma == 0
    sigma = 1;
end
y = (x - mu) ./ sigma;
end

function ECflux = localECFlux(W)
if isfield(W, 'EC_flux') && ~isempty(W.EC_flux)
    ECflux = W.EC_flux;
    return
end

[cov_wx, lags] = lagCovFFT(W.data.w, W.data.x, []);
ECflux = cov_wx(lags == 0);
end

function wx_smooth = localSmoothedInstantFlux(W, windowPoints)
w0 = W.data.w;
x0 = W.data.x;
wx_inst = (w0 - mean(w0, 'omitnan')) .* (x0 - mean(x0, 'omitnan'));
windowPoints = max(1, min(windowPoints, numel(wx_inst)));
wx_smooth = movmean(wx_inst, windowPoints);
end

function h = localCreateFigure(name)
h.fig = figure('Name', [name ' - Wave Summary'], ...
    'Units', 'normalized', ...
    'Position', [0.01, 0.01, 0.70, 0.90], ...
    'Color', 'white');

left = 0.10;
width = 0.60;
gap = 0.03;
bottomHeight = 0.20;
middleHeight = 0.39;
topHeight = 0.20;
bottomY = 0.06;
middleY = bottomY + bottomHeight + gap;
topY = middleY + middleHeight + gap;

h.ax(1) = axes('Position', [left, topY, width, topHeight]);
h.ax(2) = axes('Position', [left, middleY, width, middleHeight]);
h.ax(3) = axes('Position', [left, bottomY, width, bottomHeight]);
end

function localPlotSignals(ax, T, x_plot, w_plot, x_recon_plot, w_recon_plot, has_recon, cfg)
axes(ax);
cla(ax);
hold(ax, 'on');

plot(ax, T, x_plot, 'Color', localLighten(cfg.signalColors.xOriginal, 0.55), 'LineWidth', 3);
plot(ax, T, w_plot, 'Color', localLighten(cfg.signalColors.wOriginal, 0.55), 'LineWidth', 3);

legendItems = {'x original', 'w original'};
if has_recon
    plot(ax, T, x_recon_plot, 'Color', cfg.signalColors.xRecon, 'LineWidth', 1.2);
    plot(ax, T, w_recon_plot, 'Color', cfg.signalColors.wRecon, 'LineWidth', 1.2);
    legendItems = [legendItems, {'x reconstructed', 'w reconstructed'}];
end

localSetXLimits(ax, T);
ylim(ax, [-3, 3]);
ylabel(ax, 'Normalized (\sigma)', 'FontName', cfg.fontName, 'FontSize', cfg.fontSize);
signalLegend = legend(ax, legendItems, 'Box', 'off');
set(signalLegend, 'Units', 'normalized', 'Position', cfg.signalLegendPosition);
set(ax, ...
    'XTickLabel', [], ...
    'YTick', [-2 0 2], ...
    'FontName', cfg.fontName, ...
    'FontSize', cfg.fontSize, ...
    'Box', 'off', ...
    'Layer', 'top', ...
    'LineWidth', cfg.axisLineWidth);
hold(ax, 'off');
end

function localPlotPower(ax, T, F, COI, W, cfg)
axes(ax);
cla(ax);
hold(ax, 'on');

powerScale = max(abs(W.power(:)));
if powerScale == 0 || isnan(powerScale)
    powerScale = 1;
end
powerNorm = W.power ./ powerScale - 1;
ylog = log10(F);

surface(ax, T, ylog, powerNorm, 'EdgeColor', 'none');
shading(ax, 'interp');
localSetXLimits(ax, T);
ylim(ax, [min(ylog) max(ylog)]);
yTicks = floor(min(ylog)):ceil(max(ylog));
set(ax, ...
    'XTickLabel', [], ...
    'YTick', yTicks, ...
    'YTickLabel', 10.^yTicks, ...
    'TickLength', [0 0], ...
    'FontName', cfg.fontName, ...
    'FontSize', cfg.fontSize, ...
    'Box', 'on', ...
    'Layer', 'top', ...
    'LineWidth', cfg.axisLineWidth);
ylabel(ax, 'Frequency (Hz)', 'FontName', cfg.fontName, 'FontSize', cfg.fontSize);

colormap(ax, interp1([1, 16, 32, 48, 64], cfg.powerColors, (1:64)', 'linear'));
caxis(ax, [-2, 0]);

if cfg.showSignificanceContour && isfield(W, 'power_sig') && ~isempty(W.power_sig)
    power2sig = W.power ./ (W.power_sig' * ones(1, length(T)));
    power2sig(power2sig <= 0) = 0;
    contour(ax, T, ylog, power2sig, [1 1], 'k', 'LineWidth', 1);
end

localPlotCoiMask(ax, T, COI, min(ylog), cfg.fluxColors.mask, 0.60);
hold(ax, 'off');
end

function localPlotFlux(ax, T, Tlab, W, ECflux, wx_smooth, cfg)
axes(ax);
cla(ax);
hold(ax, 'on');

fluxNoCoi = localFieldOrNan(W, 'flux_nocoi', size(W.flux));
allFlux = [W.flux(:); fluxNoCoi(:); wx_smooth(:); ECflux(:)];
yLimits = localDataLimits(allFlux);
ylim(ax, yLimits);
localShadeCoiSegments(ax, T, W.qcoi > 0.5, yLimits, cfg.fluxColors.mask);

hWaveNoCoi = plot(ax, T, fluxNoCoi, '-', 'LineWidth', 2, 'Color', cfg.fluxColors.waveNoCoi);
hWave = plot(ax, T, W.flux, '--', 'LineWidth', 2, 'Color', cfg.fluxColors.wave);
hSmoothedEc = plot(ax, T, wx_smooth, '--', 'LineWidth', 2, 'Color', cfg.fluxColors.ec);
hZero = plot(ax, [min(T), max(T)], [0, 0], '--', 'LineWidth', 1.5, 'Color', cfg.fluxColors.zero);
hMeanEc = plot(ax, [min(T), max(T)], ECflux + [0, 0], ':', 'LineWidth', 1.5, 'Color', cfg.fluxColors.ec);

localSetXLimits(ax, T);
xlabel(ax, Tlab, 'FontName', cfg.fontName, 'FontSize', cfg.fontSize);
ylabel(ax, 'Flux ( # cm^{-3} m s^{-1} )', ...
    'Interpreter', 'tex', ...
    'FontName', cfg.fontName, ...
    'FontSize', cfg.fontSize);
fluxLegend = legend(ax, [hWaveNoCoi, hWave, hSmoothedEc, hZero, hMeanEc], ...
    {'Wave flux without COI', 'Wave flux', 'Smoothed EC flux', 'Zero', 'Mean EC flux'}, ...
    'Box', 'off');
set(fluxLegend, 'Units', 'normalized', 'Position', cfg.fluxLegendPosition);
set(ax, ...
    'FontName', cfg.fontName, ...
    'FontSize', cfg.fontSize, ...
    'Box', 'off', ...
    'Layer', 'top', ...
    'LineWidth', cfg.axisLineWidth);
hold(ax, 'off');
end

function values = localFieldOrNan(S, fieldName, shape)
if isfield(S, fieldName) && ~isempty(S.(fieldName))
    values = S.(fieldName);
else
    values = nan(shape);
end
end

function limits = localDataLimits(values)
values = values(isfinite(values));
if isempty(values)
    limits = [-1, 1];
    return
end

lo = min(values);
hi = max(values);
if lo == hi
    pad = max(abs(lo) * 0.1, 1);
else
    pad = (hi - lo) * 0.08;
end
limits = [lo - pad, hi + pad];
end

function localPlotCoiMask(ax, T, COI, yLower, color, alphaValue)
valid = isfinite(COI(:)) & COI(:) > 0;
if nnz(valid) < 2
    return
end

Tv = T(valid);
Cv = COI(valid);
Tv = Tv(:)';
Cv = Cv(:)';
patch(ax, [Tv, fliplr(Tv)], ...
    [log10(Cv), repmat(yLower, 1, numel(Tv))], ...
    color, ...
    'FaceAlpha', alphaValue, ...
    'EdgeColor', 'none');
plot(ax, Tv, log10(Cv), '--', 'LineWidth', 1.5, 'Color', [0.5, 0.5, 0.5]);
end

function localShadeCoiSegments(ax, T, mask, yLimits, color)
idx = find(mask(:));
if isempty(idx)
    return
end

segmentStarts = idx([true; diff(idx) > 1]);
segmentEnds = idx([diff(idx) > 1; true]);
T = T(:)';

for k = 1:numel(segmentStarts)
    xPatch = [T(segmentStarts(k)), T(segmentEnds(k)), T(segmentEnds(k)), T(segmentStarts(k))];
    yPatch = [yLimits(1), yLimits(1), yLimits(2), yLimits(2)];
    patch(ax, xPatch, yPatch, color, ...
        'FaceAlpha', 0.25, ...
        'EdgeColor', 'none');
end
end

function localSetXLimits(ax, T)
if isempty(T)
    return
end
xlim(ax, [min(T), max(T)]);
end

function color = localLighten(color, amount)
color = color + (1 - color) * amount;
end
