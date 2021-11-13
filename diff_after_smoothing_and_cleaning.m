function [Vnorm,V] = diff_after_smoothing_and_cleaning(X0,sf,t,plotting_flag)

dt = 1./sf;

X = X0;
for d=1:size(X,2)
    % Smooth by a third of a second. With the mov ave method this
    % kills everything above 3 Hz. With sgolay above 5 Hz.
    X(:,d) = smooth(X(:,d),round(sf/3),'sgolay');
end

% Also, verify that individual markers from the array do not disappear,
% making the average jump by a few mm. Such small glitches in the raw 3D 
% cause huge differences in difference-based vars such as speed and accel.
V0 = [[0 0 0];diff(X)]./dt;
%spikes = any(abs(V0)>1e3,2); % Not a good idea here, apparently.
V = V0;
%V(spikes,:)=nan;
for d=1:size(V0,2)
    % Smooth by a third of a second. With the mov ave method this
    % kills everything above 3 Hz. With sgolay above 5 Hz.
    V(:,d) = smooth(V(:,d),round(sf/3),'sgolay');
end
Vnorm = dot(V,V,2).^.5;

% Verify that there aren't spikes and nans remaining by accident.
% Did we do a good job cleaning and filtering without killing v?
% Compare v_temp (pure diff) w/ v after rem nans, lin interp, smooth.
if plotting_flag == 1
    figure(138361)
    subplot(3,1,1)
    plot(t,X0,'linewidth',2)
    hold on
    plot(t,X,'--','linewidth',2)
    hold off
    subplot(3,1,2)
    plot(t,V0,'-','linewidth',2)
    hold on
    plot(t,V,'--','linewidth',2)
    hold off
    legend('V0x','V0y','V0z','Vx','Vy','Vz')
    subplot(3,1,3)
    plot(t,Vnorm,'-','linewidth',2)
    pause
end
