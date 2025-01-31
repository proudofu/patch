function showStateAvgSpeeds(stateTracks, date, states)
bin = 0;
if (nargin < 3)
    states = {'dwelling' 'roaming'};
elseif isnumeric(states)
    bin = states;
    states = {'dwelling' 'roaming'};
end

strains = fields(stateTracks.(states{1}));
for sT = 1:length(states)
    if bin ~= 0
        for s = 1:length(strains)
            stateTracks.(states{sT}).(strains{s}) = nanbinSpeed(stateTracks.(states{sT}).(strains{s}),bin);
        end
    end
    figure;
    title(sprintf('%s %s \n %s; %s %i', 'Average Linear Speeds while', states{sT}, date, 'bin size(sec) =', (bin/3)));
    hold on;
    bar(arrayfun(@(strain) nanmean([stateTracks.(states{sT}).(char(strain)).Speed]), strains));
    set(gca,'XTickLabel',strains);
    set(gca,'XTick',[1:length(strains)]);
    h = errorbar(arrayfun(@(strain) nanmean([stateTracks.(states{sT}).(char(strain)).Speed]), strains),...
        arrayfun(@(strain) std([stateTracks.(states{sT}).(char(strain)).Speed], 'omitnan')/sqrt(length([stateTracks.(states{sT}).(char(strain)).Speed])), strains));
    h.LineStyle = 'none';
end
end
% /sqrt(length([stateTracks.(states{sT}).(char(strain)).Speed]))