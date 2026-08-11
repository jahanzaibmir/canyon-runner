# canyon-runner

Canyon Runner is an endless runner game built entirely from scratch in pure x86-64 Assembly (NASM) for Windows. Designed to showcase low-level graphics and event driven game logic, it directly utilizes Win32 GDI and kernel APIs without relying on external game engines or heavy standard libraries. Featuring smooth gameplay, responsive controls, dynamic obstacles, and a lightweight binary footprint, Canyon Runner highlights high performance software design close to the bare metal.

# Requirements

nasm 
gcc 

# How to compile
```bash
git clone https://github.com/jahanzaibmir/canyon-runner.git

cd canyon-runner/

nasm -f win64 canyon_runner.asm -o canyon_runner.obj

gcc canyon_runner.obj -o canyon_runner.exe -lkernel32 -luser32 -lgdi32 -mwindows -nostartfiles -e start
canyon_runner.exe
```

*** After the compilation .exe file is generated, double-click the .exe file and Enjoy the game!!***

# Author

Jahanzaib Ashraf Mir 

Cybersec | Hacker | Developer

