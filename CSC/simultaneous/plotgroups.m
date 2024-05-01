clear all
close all

load adjacency


firstframe = 1;
lastframe = 58;
frameinc = 1;

fnamep=['./swimming_trajectory_019/time_1.dat'];  % name of first file
part = dlmread(fnamep,',');  % read in first file

numparts = numel(unique(part(:,1)));            % number of particles
        
partx = zeros(numparts,floor((lastframe-firstframe+1)/frameinc)); % initialize matrices to hold particle positions
party = zeros(numparts,floor((lastframe-firstframe+1)/frameinc));
partz = zeros(numparts,floor((lastframe-firstframe+1)/frameinc));


        
        tind=0;
        
        
        % read in all particle trajectories and form partx, party, and
        % partz matrices, size (n x t)
        
        for t=firstframe:frameinc:lastframe
            tind=tind+1;
            fnamep=['./swimming_trajectory_019/time_' num2str(t) '.dat'];
            part = dlmread(fnamep,',');
                       
            partx(:,tind) = part(:,2);
            party(:,tind) = part(:,3);
            partz(:,tind) = part(:,4);
        end

        % partx = partx(Agoodidx,:);
        % party = party(Agoodidx,:);
        % partz = partz(Agoodidx,:);
        % 

% g0 = [3
%      6
%      7
%     8
%     9
%     10];

g0 = Agoodidx;

g1 = [2
     3
     8
     14
     16
     18
     23
     24
     25
     26
     27
     28
     29
     30
     31];

figure(1)
colors = colormap(autumn(58));

for traj = 1:numel(g0)
    traj
    for time = 2:58
        plot3(partx(g0(traj),time-1:time),party(g0(traj),time-1:time),partz(g0(traj),time-1:time),'Color',colors(time,:),'linewidth',3)
        hold on
        xlabel('X')
        ylabel('Y')
        zlabel('Z')
    end
end

colors = colormap(winter(58));

for traj = 1:numel(g1)
    traj
    for time = 2:58
        plot3(partx(g1(traj),time-1:time),party(g1(traj),time-1:time),partz(g1(traj),time-1:time),'Color',colors(time,:),'linewidth',3)
        hold on
    end
end


