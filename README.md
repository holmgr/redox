# redox
Small X86 operating system written in Rust, just for fun

This is my work following along with a @phil-opp's blog post series "A minimal x86 kernel"

## Linux dependencies
- nasm: assembler
- grub: creates the bootable iso
- xorriso: required by grub, filesystem manipulator
- QEMU: x86 computer emulator
- Nightly Rust compiler installed (see multirust package for example)