import os
import shutil

ori_system = os.system
def _system(cmd: str):
    ret = ori_system(cmd)
    if ret != 0:
        raise Exception('Error executing cmd '+cmd + 'with error code ' + str(ret))
os.system = _system


if __name__ == '__main__':
    os.makedirs('build/windows/', exist_ok=True)
    shutil.copyfile('deps/ANGLE.7z', 'build/windows/ANGLE.7z')
    shutil.copyfile('deps/mpv-dev-x86_64-20230825-git-c0fb9b4.7z', 'build/windows/mpv-dev-x86_64-20230825-git-c0fb9b4.7z')
    os.system('flutter pub get')
    os.system('flutter build windows --release')
    shutil.copyfile('deps/sqlite3.dll', 'build/windows/runner/Release/sqlite3.dll')
    os.system('iscc pack.iss')

