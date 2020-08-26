% EE332: Plantwide Process Control: Semester Project
%
% ----------------- FLUID CATALYTIC CRACKING (FCC) UNIT ------------------
%
echo on
if (exist ('Project.dry') == 2 ) delete('Project.dry'); end
diary Project.dry
% 
% Picking Manipulated variables and Process Variables using SVD Analysis
%
% Process has 6 Inputs (Manipulated varibles - u1 to u6) and 7 Outputs 
% (Process Variables - y1 to y7).
%
k = [0.0970 -0.0870 -0.0920  0.0260 -0.0740  0.0000;
     0.0000  0.5500  0.5500  0.0000  0.7400  0.3600;
     0.0000  0.1400  0.1400  0.0000  0.2700  0.0150;
     0.0000  0.2000  0.2000  0.0000  0.5600  0.0632;
     0.0000  0.7920  0.7920 -1.0800  1.2000 -0.6480;
     0.0000 -0.8400 -0.9000  0.3500 -1.0000  0.2300;
     0.0000  0.8100  0.9000 -0.3500  0.8000 -0.2600];
%
%  Now do SVD on full system and check condition numbers
%
[u,s,v] = svd (k)
cn2 = s(1,1)/s(2,2)
cn3 = s(1,1)/s(3,3)
cn4 = s(1,1)/s(4,4)
cn5 = s(1,1)/s(5,5)
cn6 = s(1,1)/s(6,6)
%
% The decision is difficult for this problem. 
% Best condition number for 2x2 ,3x3 system, but 4x4 is also okay. 5x5 and 
% 6x6 is probably not needed.  The final decision between 2x2, 3x3 and 4x4 
% will depend on the dynamics of the process and possibly other factors
% such as importance of controlling certain of the variables.
%
% In general, use as many manipulated variables as possible, so start
% with 4x4.
%
% ------------------------------------------------------------------------ 
%
% Assuming 4x4, find four best inputs to use for manipulated variables.
%
% Find SVD for 15 sets of Manipulated Variable Quadruples and
% Picking best one.
%
% u3, u4, u5, u6 (eliminate u1,u2)(1)
k1 = k(:,[3 4 5 6]);
[u,s,v] = svd(k1)
cn=s(1,1)/s(4,4)

% u2, u4, u5, u6 (eliminate u1,u3)
k1 = k(:,[2 4 5 6]);
[u,s,v] = svd(k1)
cn=s(1,1)/s(4,4)

% u2, u3, u5, u6 (eliminate u1,u4)
k1 = k(:,[2 3 5 6]);
[u,s,v] = svd(k1);
cn=s(1,1)/s(4,4)

% u2, u3, u4, u6 (eliminate u1,u5)
k1 = k(:,[2 3 4 6]);
[u,s,v] = svd(k1);
cn=s(1,1)/s(4,4)

% u2, u3, u4, u5 (eliminate u1,u6)
k1 = k(:,[2 3 4 5]);
[u,s,v] = svd(k1);
cn=s(1,1)/s(4,4)

% u1, u4, u5, u6 (eliminate u2,u3)
k1 = k(:,[1 4 5 6]);
[u,s,v] = svd(k1);
cn=s(1,1)/s(4,4)

% u1, u3, u5, u6 (eliminate u2,u4)
k1 = k(:,[1 3 5 6]);
[u,s,v] = svd(k1);
cn=s(1,1)/s(4,4)

% u1, u3, u4, u6 (eliminate u2,u5)
k1 = k(:,[1 3 4 6]);
[u,s,v] = svd(k1);
cn=s(1,1)/s(4,4)

% u1, u3, u4, u5 (eliminate u2,u6)
k1 = k(:,[1 3 4 5]);
[u,s,v] = svd(k1);
cn=s(1,1)/s(4,4)

% u1, u2, u5, u6 (eliminate u3,u4)
k1 = k(:,[1 2 5 6]);
[u,s,v] = svd(k1);
cn=s(1,1)/s(4,4)

% u1, u2, u4, u6 (eliminate u3,u5)
k1 = k(:,[1 2 4 6]);
[u,s,v] = svd(k1);
cn=s(1,1)/s(4,4)

% u1, u2, u4, u5 (eliminate u3,u6)
k1 = k(:,[1 2 4 5]);
[u,s,v] = svd(k1);
cn=s(1,1)/s(4,4)

% u1, u2, u3, u6 (eliminate u4,u5)
k1 = k(:,[1 2 3 6]);
[u,s,v] = svd(k1);
cn=s(1,1)/s(4,4)

% u1, u2, u3, u5 (eliminate u4,u6)
k1 = k(:,[1 2 3 5]);
[u,s,v] = svd(k1);
cn=s(1,1)/s(4,4)

% u1, u2, u3, u4 (eliminate u5,u6)(15)
k1 = k(:,[1 2 3 4]);
[u,s,v] = svd(k1);
cn=s(1,1)/s(4,4)

%
% ------------------------------------------------------------------------ 
%
% Manipulated Variable Set (u2, u4, u5, u6) looks best, 
% but the set (u3, u4, u5, u6) a close second.
%
% ------------------------------------------------------------------------ 
%
% For u2, u4, u5, u6 selection, best choice for sensors appears
% to be y5, y2, y7, y4.
% SVD Pairings u5-y5, u6-y2, u2-y7, u4-y4
%
k1 = k(:,[5 6 2 4]);
k2 = k1([5 2 7 4], :);
[u,s,v] = svd(k2)
%
% Checking condition number 
%
cn=s(1,1)/s(4,4)
rga=k2.*(inv(k2)')
%
% Checking stability for SVD Pairing
%
diag=1;
for i=1:4, diag=diag*k2(i,i);, end;
check = det(k2)/diag
%
% --- UNSTABLE! ---
%
% Checking Stability with RGA pairings
%
k2= k([5 2 7 4],[4 6 2 5]);
diag=1;
for i=1:4, diag=diag*k2(i,i);, end;
check = det(k2)/diag
%
% --- NOT UNSTABLE (RGA Pairings). --- CAN BE USED WITH RGA PAIRINGS
%
% ------------------------------------------------------------------------ 
%
% For u3, u4, u5, u6 selection, best choice for sensors appears
% to be y5, y2, y7, y4.
% SVD pairings u5-y5, u6-y2, u3-y7, u4-y4
%
k1 = k(:,[5 6 3 4]);
k2 = k1([5 2 7 4], :);
[u,s,v] = svd(k2)
%
% Checking condition number
%
cn=s(1,1)/s(4,4)
rga=k2.*(inv(k2)')
%
% Checking stability for SVD pairing
%
diag=1;
for i=1:4, diag=diag*k2(i,i);, end;
check = det(k2)/diag
%
% --- UNSTABLE! ---
%
% Checking Stability with RGA pairings
%
k2= k([5 2 7 4],[4 6 3 5]);
diag=1;
for i=1:4, diag=diag*k2(i,i);, end;
check = det(k2)/diag
%
% --- NOT UNSTABLE (RGA Pairings). --- CAN BE USED WITH RGA PAIRINGS
% (SECOND OPTION)
% ------------------------------------------------------------------------
%
diary off
