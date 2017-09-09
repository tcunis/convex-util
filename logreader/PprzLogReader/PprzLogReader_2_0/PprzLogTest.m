clear;

extlog = PprzExtLog();
extlog.folder = 'D:\Projekte\TUDelft\paparazzi\tcunis_logs';
extlog.module = 'dfiawt';
extlog.date = [ 2015, 10, 08, 18, 04, 27 ];
extlog.desc = 'position_pidctrl_05_02_0';

extlog.get_name()
extlog.get_abs_file()


log = PprzLog();
log.folder = 'D:\Projekte\TUDelft\paparazzi\tcunis_logs\dfiawt\20151008_180427__position_pidctrl_05_02_0';
log.date = [2015, 10, 08, 18, 04, 27 ];

log.get_name()
log.get_abs_file()

msg1 = PprzLogMsg( 'WINDTUNNEL', '%f %f %f %f %f %f' );
msg1.set_coltitle( { 'wind_velocity [m/s]', 'wind_velocity_x [m/s]', 'wind_velocity_y [m/s]', ...
                    'navigation_target_x [m]', 'navigation_target_y [m]', 'time_moving [s]' } );

%msg2 = PprzLogMsg( 'POS_CTRL', '%f %f %f %f %f %f %f %d %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f' );

PprzLogReader_2_0( log, msg1 );