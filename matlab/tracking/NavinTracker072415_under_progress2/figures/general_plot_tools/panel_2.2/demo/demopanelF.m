
% You can manage fonts yourself, if you prefer.
%
% Panel, by default, manages fonts for all managed objects,
% and any associated axis labels and titles. If you want to
% manage these individually, you can turn this off by
% passing the flag "no-manage-font" to the panel
% constructor.
%
% (a) Manage fonts globally (default).
% (b) Do not manage fonts.



%% (a)

% create
figure(1)
p = panel();
p.pack(2, 2);
hh = p.select('all');

% create xlabels
for h = hh
	xlabel(h, 'this will render as Arial', 'fontname', 'times');
end

% manage fonts globally
p.fontname = 'Arial';



%% (b)

% create
figure(2)
p = panel('no-manage-font');
p.pack(2, 2);
hh = p.select('all');

% create xlabels
for h = hh
	xlabel(h, 'this will render as Times', 'fontname', 'times');
end

% manage fonts globally
p.fontname = 'Arial';
