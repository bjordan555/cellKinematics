function data = interpDVel(data)

% display algorithm step entry
display('Interpolating the velocities');

% set the interpolation method
 interpMethod='natural';
% interpMethod='nearest';
% interpMethod='linear';

% loop for each path step in each time frame
for i3=1:1:data.numSt

    % Create the interpolant functions
    vXF{i3} = TriScatteredInterp(data.pathTriRepSpr{i3}.X(:,1),data.pathTriRepSpr{i3}.X(:,2),...
        data.vSprX(:,i3),interpMethod);
    vYF{i3} = TriScatteredInterp(data.pathTriRepSpr{i3}.X(:,1),data.pathTriRepSpr{i3}.X(:,2),...
        data.vSprY(:,i3),interpMethod);

end

% loop for each path step in each time frame
for i3=1:1:data.numSt
    
    % evaluate the interpolant at the evaluation points
    vXGrid=vXF{i3}(data.pSprX(:,i3),data.pSprY(:,i3));
    vYGrid=vYF{i3}(data.pSprX(:,i3),data.pSprY(:,i3));
       
    % assign to strain rate components
    vXInterp(:,i3)=vXGrid;
    vYInterp(:,i3)=vYGrid;
   
end

% store in the data structure
data.vXF=vXF;
data.vYF=vYF;
data.vXInterp=vXInterp;
data.vYInterp=vYInterp;