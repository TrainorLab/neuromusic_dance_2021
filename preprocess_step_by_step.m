clear

%% Where's my data?
data_folder = input('Where is my data? '); % i.e. '/home/dobri/mcmc/neuromusic_dance'
library_folder = input('Where are my scripts? ');
addpath library_folder
addpath(fullfile(library_folder,'wavelet-coherence'))

plotting_flag = input('To visualize data along the way? Type 1 or just Enter for yes: ');
if isempty(plotting_flag);plotting_flag = 1;end


%% Import each trial.
cd(data_folder)
filename = dir('trial*.tsv');
for trial = 1:numel(filename)
    fprintf('%s\n',filename(trial).name)
    RAWDATA{trial} = import_tsv_from_qtm_to_matlab(filename(trial));
end
sr = RAWDATA{trial}.sf;


%% These are the markers we would like to process.
bodies_labels = {'a','s'};
wanted_segments{1} = {'h1','h2','h3'};
wanted_segments{2} = {'kri'};
wanted_segments{3} = {'kre'};


%% Select markers to process. Then show NaNs, fill, smooth, and dot-dot.
% Then speed and acceleration.
clear DATA
for trial = 1:numel(RAWDATA)
    t = RAWDATA{trial}.T(:,2);
    for b = 1:numel(bodies_labels)
        for s = 1:numel(wanted_segments)
            marker_index = [];
            for ss = 1:numel(wanted_segments{s})
                marker_label = [bodies_labels{b} wanted_segments{s}{ss}];
                for m = 1:numel(RAWDATA{trial}.col_names)
                    % Find the column indices of the needed markers.
                    if strcmp(RAWDATA{trial}.col_names{m},marker_label)
                        fprintf('Trial %1.f. Marker %s.\n',trial,marker_label)
                        marker_index(ss) = m;
                    end
                end
            end
            X = RAWDATA{trial}.X(:,:,marker_index);
            N = X*0;

            % Inspect how much nans there are, before and after gap-filling
            for d = 1:size(X,3)
                for dd = 1:size(X,2)
                    % the first fills nan up to a certain limit, say 1 s.
                    % it also returns the remaining nans index. important.
                    % the second one fills all the rest.
                    X(:,dd,d) = fill_nans_by_lin_interp(X(:,dd,d),sr,1,plotting_flag);
                    N(:,dd,d) = isnan(X(:,dd,d));
                    X(:,dd,d) = fill_nans_by_lin_interp(X(:,dd,d),sr,inf,plotting_flag);
                    if isnan(X(1,dd,d));X(1:(find(~isnan(X(:,dd,d)),1,'first')-1),dd,d) = X(find(~isnan(X(:,dd,d)),1,'first'),dd,d);end
                    if isnan(X(end,dd,d));X((find(~isnan(X(:,dd,d)),1,'last')+1):end,dd,d) = X(find(~isnan(X(:,dd,d)),1,'last'),dd,d);end
                end
            end
            % We don't need all head markers. Average across them.
            X = nanmean(X,3);

            if numel(wanted_segments{s})>1
                marker_label = [bodies_labels{b} wanted_segments{s}{ss}(1:end-1)];
            end
            DATA{trial}.marker_labels{b,s} = marker_label;
            
            % Speed and accel. by difference/dt, but with smoothing first.
            [DATA{trial}.S(:,s,b),V] = diff_after_smoothing_and_cleaning(X,sr,t,plotting_flag);
            DATA{trial}.Snan(:,s,b) = DATA{trial}.S(:,s,b);
            DATA{trial}.Snan(logical(N(:,dd,d)),s,b) = nan;
            DATA{trial}.A(:,s,b) = diff_after_smoothing_and_cleaning(V,sr,t,plotting_flag);
            DATA{trial}.Anan(:,s,b) = DATA{trial}.A(:,s,b);
            DATA{trial}.Anan(logical(N(:,dd,d)),s,b) = nan;
            DATA{trial}.N(:,s,b) = N(:,dd,d);
            DATA{trial}.T = t;
        end
    end
end

% save(['cleaned_speed_and_acc_' datestr(now,'yyyy-mm-dd') '.mat'],'DATA')