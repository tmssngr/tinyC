## Linux/SystemV
- arguments in rdi, rsi, rdx, rcx, r8, r9
- return value also in rax
- no 20h shadow space
- stack cleanup from caller
  ```
  push qword 42
  mov rdi, 1
  mov rsi, 2
  call my_function
  add rsp, 8
  ```
- volatile registers: rax, rdi, rsi, rdx, rcx, r8, r9, r10, r11


## Windows
- stack cleanup on Windows:
  ```
  mov rcx, 1
  mov rdx, 2
  mov r8, 3
  mov r9, 4
  push qword 5
  call my_function
  ...

  my_function:
    ...
    ret 8 ; add 8 to rsp
  ```
