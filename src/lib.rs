#![feature(lang_items)]
#![feature(const_fn, unique)]
#![no_std]

extern crate rlibc;
extern crate spin;

mod vga_buffer;

#[no_mangle]
pub extern fn rust_main() {
    use core::fmt::Write;
    vga_buffer::WRITER.lock().write_str("Hello again");
    write!(vga_buffer::WRITER.lock(), ", some numbers: {} {}", 42, 1.337);
    loop{}
}

#[lang = "eh_personality"] extern fn eh_personality() {}
#[lang = "panic_fmt"] extern fn panic_fmt() -> ! {loop{}}
