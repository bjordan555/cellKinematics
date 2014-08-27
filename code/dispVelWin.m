%% function to analyze the displacements and filter the results
function [u2dWin v2dWin] = dispVelSin(cX,cY,imWin)

%% Global toolbar object
% changes made from any function to tb are shared
global tb

%% Init the Stack Analysis
tb.i1=1;        % image counter
tb.imName='Initializing...';
tb.pars=[0 0 0 ];
tb.parName{1}='';
tb.parName{2}='';
tb.parName{3}='';
tb.statusStr='Analyzing Displacements';
% step through init automatically.
tb.userStep=1;
upTb();
tb.userStep=0;

while tb.i1<=tb.numSt && tb.userStop==0 && tb.userNext==0
    
    %% Computing displacements and velocities
    % assign params
    tb.imName='Finding Displacements with Feature Window';
    tb.pars=[0 0 0];
    tb.parName{1}='';
    tb.parName{2}='';
    tb.parName{3}='';
    
    while tb.userStep==0 && tb.userNext==0 && tb.userStop==0
        
        % init the graph objs
        run(strcat('./initGraphs.m'));
        
        if tb.i1==1
            % init the 2d displacement matricies
            u2d{1}=zeros(length(pathC2d),tb.numSt);
            u2d{2}=zeros(length(pathC2d),tb.numSt);
            % init the 3d displacement matricies
            u3d{1}=zeros(length(pathC3d),tb.numSt);
            u3d{2}=zeros(length(pathC3d),tb.numSt);
            u3d{3}=zeros(length(pathC3d),tb.numSt);
            % init the 2d velocity matricies
            v2d{1}=zeros(length(pathC2d),tb.numSt);
            v2d{2}=zeros(length(pathC2d),tb.numSt);
            % init the 3d velocity matricies
            v3d{1}=zeros(length(pathC3d),tb.numSt);
            v3d{2}=zeros(length(pathC3d),tb.numSt);
            v3d{3}=zeros(length(pathC3d),tb.numSt);
            
        end
        
        % 2D displacements
        for i2=1:1:length(pathC2d)
            if tb.i1==1
                u2d{1}(i2,tb.i1)=0;
                u2d{2}(i2,tb.i1)=0;
            elseif tb.i1>1 && pathC2d(i2,tb.i1-1)~=0
                u2d{1}(i2,tb.i1)=cX{tb.i1}(pathC2d(i2,tb.i1))-cX{1}(pathC2d(i2,1));
                u2d{2}(i2,tb.i1)=cY{tb.i1}(pathC2d(i2,tb.i1))-cY{1}(pathC2d(i2,1));
            end
        end
        
        % 3D displacements
        for i2=1:1:length(pathC3d)
            if tb.i1==1
                u3d{1}(i2,tb.i1)=0;
                u3d{2}(i2,tb.i1)=0;
                u3d{3}(i2,tb.i1)=0;
            elseif tb.i1>1 && pathC3d(i2,tb.i1-1)~=0
                u3d{1}(i2,tb.i1)=cX{tb.i1}(pathC3d(i2,tb.i1))-cX{1}(pathC3d(i2,1));
                u3d{2}(i2,tb.i1)=cY{tb.i1}(pathC3d(i2,tb.i1))-cY{1}(pathC3d(i2,1));
                u3d{3}(i2,tb.i1)=cZ{tb.i1}(pathC3d(i2,tb.i1))-cZ{1}(pathC3d(i2,1));
            end
        end
        
        % 2D velocities
        for i2=1:1:length(pathC2d)
            if tb.i1==1
                v2d{1}(i2,tb.i1)=0;
                v2d{2}(i2,tb.i1)=0;
            elseif tb.i1>1 && pathC2d(i2,tb.i1-1)~=0
                v2d{1}(i2,tb.i1)=(cX{tb.i1}(pathC2d(i2,tb.i1))-cX{tb.i1-1}(pathC2d(i2,tb.i1-1)))./tb.steptFl;
                v2d{2}(i2,tb.i1)=(cY{tb.i1}(pathC2d(i2,tb.i1))-cY{tb.i1-1}(pathC2d(i2,tb.i1-1)))./tb.steptFl;
            end
        end
        
        % 3D velocities
        for i2=1:1:length(pathC3d)
            if tb.i1==1
                v3d{1}(i2,tb.i1)=0;
                v3d{2}(i2,tb.i1)=0;
                v3d{3}(i2,tb.i1)=0;
            elseif tb.i1>1 && pathC3d(i2,tb.i1-1)~=0
                v3d{1}(i2,tb.i1)=(cX{tb.i1}(pathC3d(i2,tb.i1))-cX{tb.i1-1}(pathC3d(i2,tb.i1-1)))./tb.steptFl;
                v3d{2}(i2,tb.i1)=(cY{tb.i1}(pathC3d(i2,tb.i1))-cY{tb.i1-1}(pathC3d(i2,tb.i1-1)))./tb.steptFl;
                v3d{3}(i2,tb.i1)=(cZ{tb.i1}(pathC3d(i2,tb.i1))-cZ{tb.i1-1}(pathC3d(i2,tb.i1-1)))./tb.steptFl;
            end
        end
        
        % call image update subroutine
        imUp(imNow,gr);
        
    end
    
    %% Between Steps...
    % update the imPast after step
    imPast=imNow;
    % reset step status
    tb.userStep=0;
    
    %% PLotting the displacements for each centroid
    % assign params
    tb.imName='Plotting Paths';
    tb.pars=[0 0 0];
    tb.parName{1}='';
    tb.parName{2}='';
    tb.parName{3}='';
    
    while tb.userStep==0 && tb.userNext==0 && tb.userStop==0
        
        % skip the last step, since there is no path from the last step.
        if tb.i1<tb.numSt
            
            % init the graph objs
            run(strcat('./initGraphs.m'));
            
            % Plot the displacements from the current step to the next step
            % plot every pltStp lines
            pltStp=1;
            pltCnt=1;
            % plot the lines from centroids to min curve
            
            % 2D displacements plots
            for i2=1:pltStp:length(u2d{1})
                if pathC2d(i2,tb.i1)~=0
                    gr.xData{pltCnt}=[cX{1}(pathC2d(i2,1)) cX{1}(pathC2d(i2,1))+u2d{1}(i2,tb.i1)];
                    gr.yData{pltCnt}=[cY{1}(pathC2d(i2,1)) cY{1}(pathC2d(i2,1))+u2d{2}(i2,tb.i1)];
                    gr.zData{pltCnt}=[];
                    gr.plOpts{pltCnt}='-k';
                    pltCnt=pltCnt+1;
                end
            end
            
            %             % 3D displacements
            %             for i2=1:pltStp:length(pathC3d)
            %                 if pathC3d(i2,tb.i1)~=0
            %                     gr.xData{pltCnt}=[cX{1}(pathC3d(i2,1)) cX{1}(pathC3d(i2,1))+u3d{1}(i2,tb.i1)];
            %                     gr.yData{pltCnt}=[cY{1}(pathC3d(i2,1)) cY{1}(pathC3d(i2,1))+u3d{2}(i2,tb.i1)];
            %                     gr.zData{pltCnt}=[cZ{1}(pathC3d(i2,1)) cZ{1}(pathC3d(i2,1))+u3d{3}(i2,tb.i1)];
            %                     gr.plOpts{pltCnt}='-b';
            %                     pltCnt=pltCnt+1;
            %                 end
            %             end
        end
        
        % call image update subroutine
        imUp(imNow,gr);
        
    end
    
    %% Between Steps...
    % update the imPast after step
    imPast=imNow;
    % reset step status
    tb.userStep=0;
    
    %% BEN _ TEMP FOR FILTER DISPLACEMENTS AND VELOCITIES
    % assign params
    tb.imName='Plotting Paths';
    tb.pars=[0 0 0];
    tb.parName{1}='';
    tb.parName{2}='';
    tb.parName{3}='';
    
    while tb.userStep==0 && tb.userNext==0 && tb.userStop==0
        
        % u2d
            % x
            u2d{1}(:,tb.i1)=(u2d{1}(:,tb.i1)>=mean(u2d{1}(:,tb.i1))-std(u2d{1}(:,tb.i1))).*u2d{1}(:,tb.i1);
            u2d{1}(:,tb.i1)=(u2d{1}(:,tb.i1)<=mean(u2d{1}(:,tb.i1))+std(u2d{1}(:,tb.i1))).*u2d{1}(:,tb.i1);
            % y
            u2d{2}(:,tb.i1)=(u2d{2}(:,tb.i1)>=mean(u2d{2}(:,tb.i1))-std(u2d{2}(:,tb.i1))).*u2d{2}(:,tb.i1);
            u2d{2}(:,tb.i1)=(u2d{2}(:,tb.i1)<=mean(u2d{2}(:,tb.i1))+std(u2d{2}(:,tb.i1))).*u2d{2}(:,tb.i1);

        
        % call image update subroutine
        imUp(imNow,gr);
    end
    
    %% Finishing steps for this stack number
    procFin();
    
    
end