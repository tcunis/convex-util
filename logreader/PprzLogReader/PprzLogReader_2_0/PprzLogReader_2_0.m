% ---------------PprzLogReader_2_0.m--------------------------------------%
% PprzLogReader_2_0.m is for reading Paparazzi log files into the mathlab
% workspace.
% Author: Torbjoern Cunis, <t.cunis@tudelft.nl>
% Date: 2015/10/16
%
% Based on:
%   PprzLogReader_1_0.m is for reading Paparazzi log file into the matlab 
%   workspace. All the log data is converted into different matrice.  
%   Author: Haiyang Chao 
%   Date: 2009/04/11
function LineCount = PprzLogReader_2_0( log, messages )
    display( '*******Log Reader for Paparazzi begins**************' );
    fprintf( 'Log folder: %s;\n', log.folder );
    fprintf( 'Reads log "%s" in module %s...\n', log.get_name(), log.get_path );

    % The user need to specify where the log file is.
    %fid = fopen('.\FlighLog20090321_MZN\09_03_19__15_03_14.data','r');
    %fid = fopen('D:\Projekte\TUDelft\paparazzi\tcunis_logs\dfiawt\20151008_195017__position_pidctrl_10_0_0\15_10_08__19_50_17.data','r');

    fid = log.open();
    if fid == -1
        display('Error in opening the file! ');
        display('Please modify the script to give pprz log file name and directory.');
        %exit;
    end

    LineCount = 0; 
    %h=1;i=1;j=1;k=1;l=1;m=1;n=1;
    
    while feof(fid) == 0
       tline = fgetl(fid);
       LineCount = LineCount+1;
       
       for msg = messages
           if msg.scan_line( tline )
               break; %for-loop
           end
       end
       
%        if  (length(findstr(tline, 'GPS_SOL'))) > 0    
%            GPS_SOL(h,:) = textscan(tline,'%f %*d %*s %d %d %d %d',1);
%            h = h+1;
%            continue;
%        else
%             if ( length(findstr(tline, 'GPS')) ) > 0
%                 GPS(i,:) = textscan(tline,'%f %*d %*s %d %d %d %d %d %d %d %d %d %d',1);
%                 i = i+1;
%                 continue;
%             end
%        end
% 
%        if ( length(findstr(tline, 'PPRZ_MODE')) ) > 0
%             PPRZ_MODE(j,:) = textscan(tline,'%4f32 %*d %*s %d %d %d %d %d %d');
%             j=j+1;
%             continue;
%        end
% 
%        if ( length(findstr(tline, 'DESIRED')) ) > 0
%             DESIRED(k,:) = textscan(tline,'%f %*d %*s %f %f %f %f %f %f %f',1);
%             k=k+1;
%             continue;
%        end
% 
%        if ( length(findstr(tline, 'ATTITUDE')) ) > 0
%             ATTITUDE(l,:) = textscan(tline,'%f %*d %*s %d %d %d',1);
%             l=l+1;
%             continue;
%        end 
% 
%        if  ( length(findstr(tline, 'NAVIGATION_REF')) ) == 0    
%             if ( length(findstr(tline, 'NAVIGATION')) ) > 0
%                 NAVIGATION(m,:) = textscan(tline,'%f %*d %*s %d %d %d %d %f %f',1);
%                 m = m+1;
%                 continue;
%             end
%        else
%             continue;
%        end
% 
%        if ( length(findstr(tline, 'COMMANDS')) ) > 0
%             COMMANDS(n,:) = textscan(tline,'%f %*d %*s %d,%d,%d,%*d',1);
%             n=n+1;
%             continue;
%        end
    end

    fclose(fid);
    fprintf( 'Read %d lines', LineCount );
    for msg = messages
        fprintf( ', %2$d messages "%1$s"', msg.name, msg.row_count );
    end
    fprintf( '.\n' );

    display('*******Log Reader for Paparazzi ends**************');
end