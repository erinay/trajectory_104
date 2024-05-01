clear all
close all

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
        
% % % TRY DELTAS
% partx = diff(partx,1,2);
% party = diff(party,1,2);
% partz = diff(partz,1,2);
        
        


frame = 0;

%for n = firstframe:frameinc:lastframe
for n = lastframe          

          frame = frame + 1;
    
%           t_start = n;
%           if t_start<1
%               t_start=1;
%           end
%           t_end = n;
          tspan=1:n;
    
    
% Construct adjacency and data frequency matrices       
             
                 
                  
                  
                  numparts = size(partx,1);

                  A = zeros(numparts,numparts);
                  
                  for i=1:numparts
                      D=((repmat(partx(i,:),numparts,1)-partx).^2+...
                         (repmat(party(i,:),numparts,1)-party).^2+...
                         (repmat(partz(i,:),numparts,1)-partz).^2).^0.5;
                      A(:,i)=nanstd(D,0,2)./nanmean(D,2);
                      A(i,i)=0;
                  end
                  
              
              
              % Delete rows/colums of zeros (corresponding to particles
              % that do not overlap with any frames of all other particles)
              
              Adegree = sum(A,2);
              Asingular=find(Adegree==0 | isnan(Adegree));
              
              Agoodidx = [1:numel(A(:,1))];
              A(Asingular,:)=[];
              A(:,Asingular)=[];
              Agoodidx(Asingular)=[];
end

save adjacency.mat A Agoodidx
