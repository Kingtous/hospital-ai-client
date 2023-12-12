import os
import subprocess
import sys
print('思易Daemon守护程序, 请勿关闭')
exe_path = r'C:\Program Files (x86)\智能AI监控平台\hospital_ai_client.exe'
proc = subprocess.Popen([exe_path])
while True:
    print('Start app..')
    proc.wait()
    proc = subprocess.Popen([exe_path], stdout=sys.stdout, stderr=sys.stderr)