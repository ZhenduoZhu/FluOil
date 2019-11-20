function h=BreakPlot(x,y,y_break_start,y_break_end,break_type,y_arbitrary_scaling_factor)
%BreakPlot(x,y,y_break_start,y_break_end,break_type)
%Produces a plot who's y-axis skips to avoid unnecessary blank space

% INPUT
% x
% y
% y_break_start
% y_break_end
% break_type
%    if break_type='RPatch' the plot will look torn
%       in the broken space
%    if break_type='Patch' the plot will have a more
%       regular, zig-zag tear
%    if break_plot='Line' the plot will merely have
%       some hash marks on the y-axis to denote the
%       break

figure;
subplot(4,4,[1:2 5:6]);
BreakPlot(rand(1,21),[1:10,40:50],10,40,'Line');
subplot(4,4,[3:4 7:8]);
BreakPlot(rand(1,21),[1:10,40:50],10,40,'Patch');
subplot(4,4,[9:10 13:14]);
BreakPlot(rand(1,21),[1:10,40:50],10,40,'RPatch');
x=rand(1,21);y=[1:10,40:50];
subplot(4,4,11:12);plot(x(y>=40),y(y>=40),'.');
set(gca,'XTickLabel',[]);
subplot(4,4,15:16);plot(x(y<=20),y(y<=20),'.');