
#[derive(Debug, PartialEq, Eq, PartialOrd, Ord)]
pub struct Frame {
	number: usize,
}

pub const PAGE_SIZE: usize = 4096;

impl Frame {
	fn containing_address(address: usize) -> Frame {
		Frame{ number: address / PAGE_SIZE }
	}
}
