function rez = xwt_and_figs(d10,d20,wtc_flag,xwt_flag,plotting,seriesname,save_fig1_fname,save_fig2_fname,save_fig3_fname)

% prepare to deal with nasty missing data.
non_nan_index = ~any(isnan([d10 d20]),2);
non_nan_count = find(non_nan_index);
nans_found = sum(any(isnan([d10 d20]),2))>0;

d1=d10;
d2=d20;
T=d10(:,1); % assume the same time vector in both series

d1(~non_nan_index,:) = [];
d2(~non_nan_index,:) = [];

%
sig_perc_wtc = nan;
mean_rsq = nan;
sig_perc_wxy = nan;
mean_wxy = nan;
anglestrength = nan;

fsz = 14;
dpi = 200;

maxscale = 4;
minscale = .2;
mc_surr_num = 3e2;

tlim=[min(d1(1,1),d2(1,1)) max(d1(end,1),d2(end,1))];


%% Show the individual WTs, useful to understand and show each trial.
if plotting==1 && nans_found==0
    if ~isempty(save_fig1_fname)
        figure('Visible', 'off')
        set(gcf, 'Position', [1, 1, dpi*4, dpi*3])
        set(gcf, 'InvertHardcopy', 'off')
    else
        figure(145205+1)
    end
    set(gcf, 'Color', [1 1 1]) %set(gcf,'color',[.5 1 .4])
    subplot(2,1,1);
    [~,period] = wt(d1,'Dj',1/4,'S0',minscale,'MaxScale',maxscale*2,'Mother','morlet','MakeFigure',logical(plotting==1));
    set(gca,'fontsize',fsz)
    title(seriesname{1});
    set(gca,'xlim',tlim);
    Yticks = 2.^(fix(log2(min(period))):fix(log2(max(period))));
    set(gca,'YLim',log2([min(period),max(period)]), ...
        'YDir','reverse', ...
        'YTick',log2(Yticks(:)), ...
        'YTickLabel',num2str(Yticks'), ... %'YTickLabel',num2str(1./Yticks'), ...
        'layer','top')
    % ylabel('Frequency, Hz')
    ylabel('Period, s')
    
    subplot(2,1,2)
    [~,period] = wt(d2,'Dj',1/4,'S0',minscale,'MaxScale',maxscale*2,'Mother','morlet','MakeFigure',logical(plotting==1));
    set(gca,'fontsize',fsz)
    title(seriesname{2})
    set(gca,'xlim',tlim)
    Yticks = 2.^(fix(log2(min(period))):fix(log2(max(period))));
    set(gca,'YLim',log2([min(period),max(period)]), ...
        'YDir','reverse', ...
        'YTick',log2(Yticks(:)), ...
        'YTickLabel',num2str(Yticks'), ...
        'layer','top')
    %ylabel('Frequency, Hz')
    ylabel('Period, s')
    
    if ~isempty(save_fig1_fname)
        f=gcf;
        f.Children(1).Position(1)=.8969;
        print('-djpeg','-r300',[save_fig1_fname '_' datestr(now,'yyyy-mm-dd-HHMMSS') '.jpeg'])
        close all
    end
end


%% XWT
if xwt_flag == 1
    if plotting==1
        if ~isempty(save_fig2_fname)
            figure('Visible', 'off')
            set(gcf, 'Position', [1, 1, dpi*4, dpi*3])
            set(gcf, 'InvertHardcopy', 'off')
        else
            figure(145205+2)
        end
        set(gcf, 'Color', [1 1 1]) %set(gcf, 'Color', [.4 1 .5])
        
        subplot(6,1,5)
        plot(d1(:,1),d1(:,2),'-k','linewidth',2)
        set(gca,'xlim',tlim)
        set(gca,'fontsize',fsz)
        
        subplot(6,1,6)
        plot(d2(:,1),d2(:,2),'-k','linewidth',2)
        xlabel('Time, s')
        set(gca,'xlim',tlim)
        set(gca,'fontsize',fsz)
        
        subplot(6,1,1:4)
    end
    [Wxy,period,scale,coi,sig95_power] = ...
        xwt(d1,d2,...
        'Dj',1/4,'S0',minscale,'MaxScale',maxscale,'Mother','morlet',...
        'MakeFigure',logical(plotting==1 && nans_found==0),'ArrowDensity',[10 10],'ArrowSize',0);
    
    COI=sig95_power*0;
    for t=1:size(sig95_power,2)
        COI(scale<coi(t),t)=1;
    end
    mean_wxy = sum(sum(Wxy.*logical(COI)))/sum(sum(COI));
    sig_perc_wxy = sum(sum((sig95_power.*logical(COI))>1))./sum(sum(COI));
    [~,anglestrength,~]=anglemean(angle(Wxy.*logical(COI)));
    WxyCone = Wxy.*logical(COI);
    
    Wxy0 = nan(size(Wxy,1),numel(T));
    Wxy0(:,non_nan_count) = Wxy;
    WxyCone0 = nan(size(WxyCone,1),numel(T));
    WxyCone0(:,non_nan_count) = WxyCone;
    sig95_power0 = nan(size(sig95_power,1),numel(T));
    sig95_power0(:,non_nan_count) = sig95_power;
    coi0 = nan(size(coi,1),numel(T));
    coi0(:,non_nan_count) = coi;
    
    if plotting==1
        if nans_found==1
            xwt_make_figure(Wxy0,period,scale,coi0,sig95_power0,T)
        end
        f=gcf;
        f.Children(1).Position(1)=.8969;
        set(gca,'fontsize',fsz)
        
        Yticks = 2.^(fix(log2(min(scale))):fix(log2(max(scale))));
        set(gca,'YLim',log2([min(scale),max(scale)]), ...
            'YDir','reverse', ...
            'YTick',log2(Yticks(:)), ...
            'YTickLabel',num2str(Yticks'), ...
            'layer','top')
        %ylabel('Frequency, Hz')
        ylabel('Period, s')
        
        if ~isempty(save_fig2_fname)
            print('-djpeg','-r300',[save_fig2_fname '_' datestr(now,'yyyy-mm-dd-HHMMSS') '.jpeg'])
            close all
        else
            title(['XWT: ' seriesname{1} '-' seriesname{2} ] )
        end
    end
end


%% XWTC
if wtc_flag == 1
    if plotting==1
        if ~isempty(save_fig3_fname)
            figure('Visible', 'off')
            set(gcf, 'Position', [1, 1, dpi*4, dpi*3])
            set(gcf, 'InvertHardcopy', 'off')
        else
            figure(145205+3)
        end
        set(gcf, 'Color', [1 1 1]) %set(gcf, 'Color', [1 .4 .5])
        
        subplot(6,1,5)
        plot(d1(:,1),d1(:,2),'-k','linewidth',2)
        set(gca,'xlim',tlim)
        set(gca,'fontsize',fsz)
        
        subplot(6,1,6)
        plot(d2(:,1),d2(:,2),'-k','linewidth',2)
        set(gca,'xlim',tlim)
        set(gca,'fontsize',fsz)
        xlabel('Time, s')
        
        subplot(6,1,1:4)
    end
    [Rsq,period,scale,coi,sig95_coherence] = ...
        wtc(d1,d2,...
        'MonteCarloCount',mc_surr_num,'Dj',1/4,'S0',minscale,'MaxScale',maxscale,'Mother','morlet',...
        'MakeFigure',logical(plotting == 1 && nans_found==0));
    
    COI=sig95_coherence*0;
    for t=1:size(sig95_coherence,2)
        COI(scale<coi(t),t)=1;
    end
    COI=logical(COI);
    
    sig95_coherence=sig95_coherence.*COI;
    RsqCone=Rsq.*COI;
    
    mean_rsq = sum(sum(Rsq))/sum(sum(COI));
    sig_perc_wtc = sum(sum(sig95_coherence>1))./sum(sum(COI));
    
    Rsq0 = nan(size(Rsq,1),numel(T));
    Rsq0(:,non_nan_count) = Rsq;
    RsqCone0 = nan(size(RsqCone,1),numel(T));
    RsqCone0(:,non_nan_count) = RsqCone;
    sig95_coherence0 = nan(size(sig95_coherence,1),numel(T));
    sig95_coherence0(:,non_nan_count) = sig95_coherence;
    coi0 = nan(size(coi,1),numel(T));
    coi0(:,non_nan_count) = coi;
    
    if plotting==1
        if nans_found==1
            wtc_make_figure(Rsq0,period,scale,coi0,sig95_coherence0,T)
        end
        
        f=gcf;
        f.Children(1).Position(1)=.8969;
        set(gca,'fontsize',fsz)
        
        Yticks = 2.^(fix(log2(min(scale))):fix(log2(max(scale))));
        set(gca,'YLim',log2([min(scale),max(scale)]), ...
            'YDir','reverse', ...
            'YTick',log2(Yticks(:)), ...
            'YTickLabel',num2str(Yticks'), ...
            'layer','top')
        %ylabel('Frequency, Hz')
        ylabel('Period, s')
        
        if ~isempty(save_fig3_fname)
            print('-djpeg','-r300',[save_fig3_fname '_' datestr(now,'yyyy-mm-dd-HHMMSS') '.jpeg'])
            close all
        else
            title(['WTC: ' seriesname{1} '-' seriesname{2} ] )
        end
    end
end

rez.T = T;
rez.period = period;
rez.scale = scale;
if xwt_flag == 1
    rez.Wxy = WxyCone0;
    rez.sig95_xwt = sig95_power0;
    rez.sig_perc_wxy = sig_perc_wxy;
    rez.mean_wxy = mean_wxy;
end
if wtc_flag == 1
    rez.Rsq = RsqCone0;
    rez.sig95_xwc = sig95_coherence0;
    rez.mean_rsq = mean_rsq;
    rez.sig_perc_wtc = sig_perc_wtc;
    rez.anglestrength = anglestrength;
end
