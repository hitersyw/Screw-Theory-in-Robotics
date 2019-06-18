%% Screw Theory - DIFFERENTIAL Kinematics - KUKAIIWA14 - INVERSE + FORWARD.
% GEOMETRIC Jacobian.
%
% For the exercise of the Screw Theory for Robotics Handbook, the aim is to
% demonstrate the differential kinematics formulations (inv + for).
% FIRST goal is to calculate the INVERSE (Joint Thetap Velocities) for
% Diferential Kinematics, based on the known or desired Tool Velocities.
% SECOND goal is to calculate the FORWARD (Tool Velocities) for
% Diferential Kinematics, based on the known or desired Joint Velocities.
% by Dr. Pardos-Gotor ST24R "Screw Theory Toolbox for Robotics" MATLAB.
%
%
% Copyright (C) 2003-2019, by Dr. Jose M. Pardos-Gotor.
%
% This file is part of The ST24R "Screw Theory Toolbox for Robotics" MATLAB
% 
% ST24R is free software: you can redistribute it and/or modify
% it under the terms of the GNU Lesser General Public License as published
% by the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% ST24R is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU Lesser General Public License for more details.
% 
% You should have received a copy of the GNU Lesser General Public License
% along with ST24R.  If not, see <http://www.gnu.org/licenses/>.
%
% http://www.preh
%
% CHANGES:
% Revision 1.1  2019/02/11 00:00:01
% General cleanup of code: help comments, see also, copyright
% references, clarification of functions.
%
%% E782_STR_DIFFERENTIALKin_KUKAIIWA14_GeoJacInvFor
%
clear;
clc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mechanical characteristics of the Robot (AT REF HOME POSITION):
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Joints TWISTS definition and TcP at home.
Twist = [0   -0.3600         0    0.7800         0   -1.1800         0;
         0         0         0         0         0         0         0;
         0         0         0         0         0         0         0;
         0         0         0         0         0         0         0;
         0    1.0000         0   -1.0000         0    1.0000         0;
    1.0000         0    1.0000         0    1.0000         0     1.000];
Hst0 = [1 0 0 0; 0 1 0 0; 0 0 1 1.38; 0 0 0 1];
% Motion RANGE for the robot joints POSITION rad, (by catalog).
% Thmax = pi/180*[170 120 170 120 170 120 175];
% Thmax = -pi/180*[170 120 170 120 170 120 175];
% Maximum SPEED for the robot joints rad/sec, (by catalog).
% Thpmax = pi/180*[85 85 100 75 130 135 135];
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%
% INPUTS
%%%%%%%%%%%%%%%%%%%%%%
% The desired velocity for Tool Pose in spatial frame (S) rad/s.
VtS = [rand rand rand rand rand rand]'
%
% We get a random point t1 of Tool TRAJECTORY defined by "u" (1x6) vector
% which constains Traslation X+Y+Z and Rotation X+Y+Z.
t1goal = [rand-0.5 rand-0.5 1.25*rand 2*pi*rand-pi 2*pi*rand-pi 2*pi*rand-pi]
% t1goal = [-0.25 0.125 0.4 pi/2 0 pi/2]
%
% Solve Inverse Kinematics to get a set of possible solutions for joint
% positions (exact or approximate). Theta Set has 16 solutions (16x7)
ThetaSet =  Fcn_ST24R_IIWA14_IK_Upright(t1goal);
% From the set of solutions we choose only one to proceed.
Theta = ThetaSet(7,:)
%
% Apply Forward Kinematics to check wether the point in trajectory is 
% in the workspace of the robot.
TwMag = [Twist; Theta];
noap = ForwardKinematicsPOE(TwMag) * Hst0;
t1real = [noap(1:3,4)' tform2eul(noap,'XYZ')]
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Solve the INVERSE DIFFERENTIAL KINEMATICS.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Velocity for the Joints of the Robot with inverse GEOMETRIC JACOBIAN.
JstS = GeoJacobianS(TwMag);
% Using the "\" MATLAB function
ThetapMAT = JstS\[VtS(1:3)-axis2skew(VtS(4:6))*t1real(1:3)'; VtS(4:6)]
% Using Moore-Penrose generalized inverse of JstS 
ThetapMPG = JstS'*((JstS*JstS')\[VtS(1:3)-axis2skew(VtS(4:6))*t1real(1:3)'; VtS(4:6)])
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Solve the FORWARD DIFFERENTIAL KINEMATICS.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Tool SPATIAL VELOCITY in terms of the screw theory VstS, with the
% The Manipulator GEOMETRIC JACOBIAN by DEFINITION.
VstSMAT = JstS * ThetapMAT;
% Tool carthesian Velocity in the Spatial frame VtS by MATLAB "\" function
VtSMAT = [VstSMAT(1:3)+axis2skew(VstSMAT(4:6))*t1real(1:3)'; VstSMAT(4:6)]
%
VstSMPG = JstS * ThetapMPG;
% Tool carthesian Velocity in Spatial frame VtS by Moore-Penrose JstS^-1.
VtSMPG = [VstSMPG(1:3)+axis2skew(VstSMPG(4:6))*t1real(1:3)'; VstSMPG(4:6)]
%