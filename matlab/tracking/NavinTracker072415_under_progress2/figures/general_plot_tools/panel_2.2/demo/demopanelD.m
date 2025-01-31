
% Panel interacts with other graphics objects apart from figures and axes.
%
% (a) Create a figure a uipanel.
% (b) Attach a panel to it.
% (c) Select another uipanel into one of the sub-panels.
% (d) Attach a callback.



%% (a)

% create the figure
clf

% create a uipanel
set(gcf, 'units', 'normalized');
u1 = uipanel('units', 'normalized', 'position', [0.1 0.1 0.8 0.8]);



%% (b)

% create a 2x3 grid in one of the uipanels
p = panel(u1);
p.pack(2, 3);




%% (c)

% create another uipanel
u2 = uipanel();

% but let panel manage its size
p(2, 2).select(u2);

% select all other panels in the grid as axes
p.select('data')




%% (d)

% hook in to the resize event of u2
p(2, 2).setCallback(@demopanel_callback);



