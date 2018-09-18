// NOTE: code taken from github.com/marler8997/mar
enum Syscall
{
    write = 1,
    exit  = 60,
}
extern (C) void _start()
{
    asm
    {
        naked;
        xor RBP,RBP;  // zero the frame pointer register
                      // I think this helps backtraces know the call stack is over
        //
        // set argc
        //
        pop RDI;      // RDI(first arg to 'main') = argc
        //
        // set argv
        //
        mov RSI,RSP;  // RSI(second arg to 'main) = argv (pointer to stack)
        //
        // set envp
        //
        mov RDX,RDI;  // first put the argc count into RDX (where envp will go)
        add RDX,1;    // add 1 to value from argc (handle one NULL pointer after argv)
        shl RDX, 3;   // multiple argc by 8 (get offset of envp)
        add RDX,RSP;  // offset this value from the current stack pointer
        //
        // prepare stack for main
        //
        add RSP,-8;   // move stack pointer below argc
        and SPL, 0xF8; // align stack pointer on 8-byte boundary
        call main;
        //
        // exit syscall
        //
        mov RDI, RAX;  // syscall param 1 = RAX (return value of main)
        mov RAX, Syscall.exit;
        syscall;
    }
}
extern (C) size_t sys_write(int fd, const(void)* buf, size_t n)
{
    asm
    {
        naked;
        mov EAX, Syscall.write;
        syscall;
        ret;
    }
}
extern (C) int main(int argc, char** argv, char** envp)
{
    const msg = "Hello, World!\n";
    sys_write(1, msg.ptr, msg.length);
    return 0;
}
