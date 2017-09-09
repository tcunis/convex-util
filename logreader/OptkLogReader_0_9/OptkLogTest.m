clear;

log = OptkLog();
log.folder = 'D:\Eigene Dateien\TUDelft\MAVlab\Logs\FlightTest1';
log.file = 'Take 2015-10-22 07.32.52 PM DelFly ATT_Z.csv';

msg = OptkLogMsg('OptiTrack');

log.get_name()
log.get_abs_file()

OptkLogReader_0_9( log, msg );