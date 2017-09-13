% ---------------OptkLogReader_0_9.m--------------------------------------%
% OptkXLogReader_0_9.m is for reading OptiTrack log files into the mathlab
% workspace.
% Author: Torbjoern Cunis, <t.cunis@tudelft.nl>
% Date: 2016/02/18
%
% Based on:
%   OptkLogReader_0_9.m
%   Author: Torbjoern Cunis, <t.cunis@tudelft.nl>
%   Data: 2015/10/29
%
% Based on:
%   optitrack_log_processing.m
%   Author: Matej Karasek, <m.karasek@tudelft.nl>
%   Date: 
function xmsg = OptkXLogReader_0_9( log, xmsg )

    data = log.csvread(7,0);

    openedFile = log.open();
    
    for i=1:7
        line=fgetl(openedFile);
        lineString=regexp(line, ',', 'split');

        switch i
            case 1
                fps=str2double(lineString(8));
                date=lineString(10);
                Nframes=str2double(lineString(12));
        end
    end

    time=data(:,2);

    % position
    posx=data(:,9); % OptiTrack z
    posy=data(:,7); % OptiTrack x
    posz=data(:,8); % OptiTrack y

    % orientation in OptiTrack definition -  pitch, then yaw (opposite), then roll
    qx=data(:,3);
    qy=data(:,4);
    qz=data(:,5);
    qw=data(:,6);

    % set to NaN if untracked
    for i=1:Nframes
        if posx(i)==0 && posy(i)==0 && posz(i)==0
            posx(i)=NaN;
            posy(i)=NaN;
            posz(i)=NaN;        
            qx(i)=NaN;
            qy(i)=NaN;
            qz(i)=NaN;
            qw(i)=NaN;        
        end
    end

    yaw=NaN(size(time));
    roll=NaN(size(time));
    pitch=NaN(size(time));

    for i=1:Nframes
        % rotation matrix from OptiTrack quaternion
        R=[1-2*(qy(i)^2+qz(i)^2)        2*(qx(i)*qy(i)-qz(i)*qw(i))  2*(qx(i)*qz(i)+qy(i)*qw(i))
             2*(qx(i)*qy(i)+qz(i)*qw(i))  1-2*(qx(i)^2+qz(i)^2)        2*(qy(i)*qz(i)-qx(i)*qw(i))
             2*(qx(i)*qz(i)-qy(i)*qw(i))  2*(qy(i)*qz(i)+qx(i)*qw(i))  1-2*(qx(i)^2+qy(i)^2)      ];


        % orientation from OptiTrack log (roll around OptiTrack Z, pitch around
        % OptiTrack X, Yaw around OptiTrack Y)
        roll(i,1)=atan2(R(2,1),R(2,2));
        pitch(i,1)=atan2(-R(2,3),real(sqrt(1-R(2,3)^2))); % real added to avoid complex numbers (most likely due to rounding errors)
        yaw(i,1)=atan2(R(1,3),R(3,3));

        % making yaw continuous
        if i>1 && yaw(i,1)-yaw(i-1,1)>pi
            yaw(i,1)=yaw(i,1)-2*pi;
        elseif i>1 && yaw(i,1)-yaw(i-1,1)<-pi
            yaw(i,1)=yaw(i,1)+2*pi;
        end
    end

    % mean marker error
    if size(data, 2) > 9
        mean_error = data(:,10);
    else
        mean_error = NaN(size(data,1), 1);
    end
    
    if ( xmsg == 0 )
        xmsg = OptkXLogMsg(log.get_name());
    end
    
    xmsg.add_time(time);
    
    xmsg.add_column('pos_x', 'm', posx);
    xmsg.add_column('pos_y', 'm', posy);
    xmsg.add_column('pos_z', 'm', posz);
    xmsg.add_column('rot_yaw',   'rad', yaw  );
    xmsg.add_column('rot_pitch', 'rad', pitch);
    xmsg.add_column('rot_roll',  'rad', roll );
    xmsg.add_column('rot_yaw',   'deg', (yaw*180/pi)  );
    xmsg.add_column('rot_pitch', 'deg', (pitch*180/pi));
    xmsg.add_column('rot_roll',  'deg', (roll*180/pi) );
    
    xmsg.set_temp_data();
    xmsg.mean_error = mean_error;

end