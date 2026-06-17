function [p, f] = quadPlot(wprime, xprime)
%QUADPLOT Generate a quadrant plot for scalar covariance.
%
% INPUTS:
% wprime: instantaneous deviation of vertical wind speed from mean.
% xprime: instantaneous deviation of scalar from mean.
%
% OUTPUTS:
% p: percentage of points in each quadrant.
% f: flux calculated in each quadrant.
%
% 20130920 GMW

q = cell(1, 4);
q{1} = wprime > 0 & xprime > 0;
q{2} = wprime < 0 & xprime > 0;
q{3} = wprime < 0 & xprime < 0;
q{4} = wprime > 0 & xprime < 0;

n = cellfun(@sum, q);
p = n ./ sum(n) * 100;
f = cellfun(@(idx) mean(wprime(idx) .* xprime(idx), 'omitnan'), q);

wl = localAxisLimit(wprime);
xl = localAxisLimit(xprime);

pointColors = [0.0000, 0.4470, 0.7410; ...
               0.8500, 0.3250, 0.0980; ...
               0.4660, 0.6740, 0.1880; ...
               0.9290, 0.6940, 0.1250];

figure('Color', 'white');
hold on;
box on;

localDrawQuadrantBackground(wl, xl, pointColors, 0.10);
for k = 1:4
    scatter(wprime(q{k}), xprime(q{k}), 16, pointColors(k, :), ...
        'filled', ...
        'MarkerFaceAlpha', 0.20);
end

plot([-wl, wl], [0, 0], 'Color', [0.5, 0.5, 0.5], 'LineWidth', 1);
plot([0, 0], [-xl, xl], 'Color', [0.5, 0.5, 0.5], 'LineWidth', 1);
xlim([-wl, wl]);
ylim([-xl, xl]);
xlabel('w'' (m/s)', 'FontSize', 16, 'FontWeight', 'normal');
ylabel('x'' (#/m^3)', 'FontSize', 16, 'FontWeight', 'normal');
set(gca, ...
    'FontSize', 15, ...
    'FontName', 'Arial', ...
    'LineWidth', 1.2, ...
    'Layer', 'top', ...
    'XColor', [0.3, 0.3, 0.3], ...
    'YColor', [0.3, 0.3, 0.3]);

ax = gca;
if xl > 0
    ax.YAxis.Exponent = floor(log10(xl));
end

localAddQuadrantLabels(wl, xl, p, f);
hold off;

end

function limit = localAxisLimit(values)
limit = max(abs(values(:)), [], 'omitnan') * 1.5;
if isempty(limit) || isnan(limit) || limit == 0
    limit = 1;
end
end

function localDrawQuadrantBackground(wl, xl, colors, faceAlpha)
patch([0, wl, wl, 0], [0, 0, xl, xl], colors(1, :), ...
    'FaceAlpha', faceAlpha, 'EdgeColor', 'none');
patch([0, -wl, -wl, 0], [0, 0, xl, xl], colors(2, :), ...
    'FaceAlpha', faceAlpha, 'EdgeColor', 'none');
patch([0, -wl, -wl, 0], [0, 0, -xl, -xl], colors(3, :), ...
    'FaceAlpha', faceAlpha, 'EdgeColor', 'none');
patch([0, wl, wl, 0], [0, 0, -xl, -xl], colors(4, :), ...
    'FaceAlpha', faceAlpha, 'EdgeColor', 'none');
end

function localAddQuadrantLabels(wl, xl, p, f)
format = '%6.3g';
labelScale = 0.95;
lineOffset = xl * 0.10;

spec = [ 1,  1; ...
        -1,  1; ...
        -1, -1; ...
         1, -1];
horizontal = {'right', 'left', 'left', 'right'};
vertical = {'top', 'top', 'bottom', 'bottom'};

for k = 1:4
    x = spec(k, 1) * labelScale * wl;
    y1 = spec(k, 2) * labelScale * xl;
    y2 = y1 - sign(spec(k, 2)) * lineOffset;
    text(x, y1, ['p = ' num2str(p(k), '%.1f') '%'], ...
        'HorizontalAlignment', horizontal{k}, ...
        'VerticalAlignment', vertical{k}, ...
        'FontSize', 14);
    text(x, y2, ['w''x'' = ' num2str(f(k), format)], ...
        'HorizontalAlignment', horizontal{k}, ...
        'VerticalAlignment', vertical{k}, ...
        'FontSize', 14);
end
end
