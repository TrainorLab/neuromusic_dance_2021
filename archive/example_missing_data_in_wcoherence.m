rng default;
t0 = 0:0.001:2;
x0 = cos(2*pi*10*t).*(t>=0.5 & t<1.1)+ ...
cos(2*pi*50*t).*(t>= 0.2 & t< 1.4)+0.25*randn(size(t));
y0 = sin(2*pi*10*t).*(t>=0.6 & t<1.2)+...
sin(2*pi*50*t).*(t>= 0.4 & t<1.6)+ 0.35*randn(size(t));
x0(1100:1500) = nan;y0(1100:1500) = nan;

non_nan_index = ~isnan(x0);
non_nan_count = find(non_nan_index);

t=t0;
x=x0;
y=y0;

t(isnan(x0)) = [];
y(isnan(x0)) = [];
x(isnan(x0)) = [];

figure(1)
subplot(2,1,1)
plot(t,x,'o')
title('X')
subplot(2,1,2)
plot(t,y,'s')
title('Y')
xlabel('Time (seconds)')

[wcoh,~,period,coi] = wcoherence(x,y,seconds(0.001));
period = seconds(period);
coi = seconds(coi);

coi0 = nan(numel(t0),1);
wcoh0 = nan(numel(period),numel(t0));
coi0(non_nan_count) = coi;
wcoh0(:,non_nan_count) = wcoh;

figure(2)
h = pcolor(t,log2(period),wcoh);
h.EdgeColor = 'none';
ax = gca;
ytick = round(pow2(ax.YTick),3);
ax.YTickLabel = ytick;
ax.XLabel.String = 'Time';
ax.YLabel.String = 'Period';
ax.Title.String = 'Wavelet Coherence';
hcol = colorbar;
hcol.Label.String = 'Magnitude-Squared Coherence';
hold on;
plot(ax,t,log2(coi),'w--','linewidth',2)
hold off

figure(3)
h = pcolor(t0,log2(period),wcoh0);
h.EdgeColor = 'none';
ax = gca;
ytick = round(pow2(ax.YTick),3);
ax.YTickLabel = ytick;
ax.XLabel.String = 'Time';
ax.YLabel.String = 'Period';
ax.Title.String = 'Wavelet Coherence';
hcol = colorbar;
hcol.Label.String = 'Magnitude-Squared Coherence';
hold on;
plot(ax,t0,log2(coi0),'w--','linewidth',2)
hold off
