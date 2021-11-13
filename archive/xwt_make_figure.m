function xwt_make_figure(Wxy,period,scale,coi,sig95,t,sigmax,sigmay)

dt = mean(diff(t));

Args=struct('ArrowDensity',[30 30],...
    'ArrowSize',1,...
    'ArrowHeadSize',1,...
    'Mother','morlet'); % Assume morlet kernel

Args.ArrowSize=Args.ArrowSize*30*.03/mean(Args.ArrowDensity);
Args.ArrowHeadSize=Args.ArrowHeadSize*Args.ArrowSize*220;

Yticks = 2.^(fix(log2(min(period))):fix(log2(max(period))));

    H=imagesc(t,log2(period),log2(abs(Wxy/(sigmax*sigmay))));%#ok
    %logpow=log2(abs(Wxy/(sigmax*sigmay)));
    %[c,H]=contourf(t,log2(period),logpow,[min(logpow(:)):.25:max(logpow(:))]);
    %set(H,'linestyle','none')

    clim=get(gca,'clim'); %center color limits around log2(1)=0
    clim=[-1 1]*max(clim(2),3);
    set(gca,'clim',clim)

    HCB=colorbar;
    set(HCB,'ytick',-7:7);
    barylbls=rats(2.^(get(HCB,'ytick')'));
    barylbls([1 end],:)=' ';
    barylbls(:,all(barylbls==' ',1))=[];
    set(HCB,'yticklabel',barylbls);

    set(gca,'YLim',log2([min(period),max(period)]), ...
        'YDir','reverse', ...
        'YTick',log2(Yticks(:)), ...
        'YTickLabel',num2str(1./Yticks'), ...
        'layer','top')
    %xlabel('Time')
    ylabel('Frequency, Hz')
    hold on

    aWxy=angle(Wxy);

    phs_dt=round(length(t)/Args.ArrowDensity(1)); tidx=max(floor(phs_dt/2),1):phs_dt:length(t);
    phs_dp=round(length(period)/Args.ArrowDensity(2)); pidx=max(floor(phs_dp/2),1):phs_dp:length(period);
    phaseplot(t(tidx),log2(period(pidx)),aWxy(pidx,tidx),Args.ArrowSize,Args.ArrowHeadSize);

    if strcmpi(Args.Mother,'morlet')
        [c,h] = contour(t,log2(period),sig95,[1 1],'k');%#ok
        set(h,'linewidth',2)
    else
        warning('XWT:sigLevelNotValid','XWT Significance level calculation is only valid for morlet wavelet.')
        %TODO: alternatively load from same file as wtc (needs to be coded!)
    end
    tt=[t([1 1])-dt*.5;t;t([end end])+dt*.5];
    hcoi=fill(tt,log2([period([end 1]) coi period([1 end])]),'w');
    set(hcoi,'alphadatamapping','direct','facealpha',.5)
    hold off
end