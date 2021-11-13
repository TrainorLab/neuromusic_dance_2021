function x = fill_nans_by_lin_interp(x,sr,win,plotting)
%Fill small nan gaps by linearly interpolating.

nanseries = any(isnan(x),2);
if sum(nanseries)==0;return;end
x0=x;

% Be careful with larger gaps! You need to identify them and skip them.
nanstart = find(diff(nanseries)==1)+1;
nanstop = find(diff(nanseries)==-1);
tri = nanstop - nanstart' + 1;
tri(tri<0) = nan;
nanwinlen = min(tri);

if ~isempty(nanstop)
    for k=1:numel(nanstart)
        if nanwinlen(k)<(sr*win)  % skip nan windows > a second
            x(nanstart(k):(nanstart(k)+nanwinlen(k)-1)) = ...
                linspace(x(nanstart(k)-1),x(nanstart(k)+nanwinlen(k)),nanwinlen(k));
        end
    end
end

if plotting == 1
    figure(184804)
    plot(x0,'linewidth',3)
    hold on
    plot(isnan(x0)*max(x)*.5,'linewidth',3)
    plot(x,'linewidth',1)
    plot(isnan(x)*max(x),'linewidth',2)
    hold off
    pause
end