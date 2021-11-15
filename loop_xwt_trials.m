clear

%% Where's my data?
data_folder = input('Where is my data? '); % i.e. '/home/dobri/mcmc/neuromusic_dance'
library_folder = input('Where are my scripts? ');
addpath(library_folder)
addpath(fullfile(library_folder,'wavelet-coherence'))

plotting_flag = input('To visualize the cross-wavelet plots along the way? Type 1 or just Enter for yes: ');
if isempty(plotting_flag);plotting_flag = 1;end
save_figs_flag = input('To save the cross-wavelet plots along the way? Type 1 or just Enter for yes: ');
if isempty(save_figs_flag);save_figs_flag = 0;end

cd(data_folder)

fname = dir('cleaned*.mat');
load(fname(end).name)

%%
vars = {'speed' 'acceleration'};
for v = 1:numel(vars)
    for trial = 1:numel(DATA)
        t = DATA{trial}.T;
        for d = 1:size(DATA{trial}.S,2)
            switch vars{v}
                case 'speed'
                    X = squeeze(DATA{trial}.S(:,d,:));
                case 'acceleration'
                    X = squeeze(DATA{trial}.A(:,d,:));
            end
            N = any(squeeze(DATA{trial}.N(:,d,:)),2);
            labels = {DATA{trial}.marker_labels{1,d} DATA{trial}.marker_labels{2,d}};
            if save_figs_flag == 1
                save_fig1_fname = ['indiv-wavelet-power_trial' num2str(trial) '_' DATA{trial}.marker_labels{1,d} '-' DATA{trial}.marker_labels{2,d} '-' vars{v}];
                save_fig2_fname = ['cross-wavelet-power_trial' num2str(trial) '_' DATA{trial}.marker_labels{1,d} '-' DATA{trial}.marker_labels{2,d} '-' vars{v}];
                save_fig3_fname = ['cross-wavelet-coherence_trial' num2str(trial) '_' DATA{trial}.marker_labels{1,d} '-' DATA{trial}.marker_labels{2,d} '-' vars{v}];
            else
                save_fig1_fname = [];
                save_fig2_fname = [];
                save_fig3_fname = [];
            end
            
            REZ{trial,d,v} = xwt_and_figs([t X(:,1)],[t X(:,2)],N,1,1,plotting_flag,labels,save_fig1_fname,save_fig2_fname,save_fig3_fname);
            REZ{trial,d,v}.T = t;
            REZ{trial,d,v}.labels = ['Trial ' num2str(trial) ', markers ' DATA{trial}.marker_labels{1,d} ' and ' DATA{trial}.marker_labels{2,d} '. ' vars{v}];
            if plotting_flag == 1 && save_figs_flag == 0
                pause
            end
        end
    end
end

% save(['xwt_results_from_cleaned_speed_and_acc_' datestr(now,'yyyy-mm-dd') '.mat'],'REZ')

fprintf('%40s\t','_')
fprintf('%18s','Mean xw power','% sig power','Mean xw coherence','% sig coh')
fprintf('\n')
S = [];
for v = 1:size(REZ,3)
    for d = 1:size(REZ,2)
        for trial = 1:size(REZ,1)
            fprintf('%40s\t',REZ{trial,d,v}.labels)
            fprintf('%18.2f',REZ{trial,d,v}.mean_wxy,REZ{trial,d,v}.sig_perc_wxy,REZ{trial,d,v}.mean_rsq,REZ{trial,d,v}.sig_perc_wtc)
            fprintf('\n')
            S = vertcat(S,[v d trial REZ{trial,d,v}.mean_wxy,REZ{trial,d,v}.sig_perc_wxy,REZ{trial,d,v}.mean_rsq,REZ{trial,d,v}.sig_perc_wtc]);
        end
    end
end
