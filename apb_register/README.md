# APB Register Module

This is a simple register module that stores data via APB protocol.

## Requirements
- The module has an APB slave interface.
- All registers hold `0` after reset.
- When a write occurs, the corresponding register stores the data until reset or overwritten.
- When a read occurs, the corresponding register returns the stored data.
- Read and write require no wait states (always ready).
- `PADDR` must be in the address space. Out-of-range address raises an error.
- `PADDR` must be word-aligned. Unaligned address raises an error.

## Customization
The size and address can be adjusted with the `NumWords` and `BaseAddr` parameters.
The address space is `4 * NumWords` bytes (since there are 4 bytes in a word), starting from `BaseAddr`.
For example, for `NumWords = 64` and `BaseAddr = 32'h4000_1000`, the address space ranges
from `32'h4000_1000` to `32h4000_10FF` (256 bytes).

`BaseAddr` must be aligned to the address space.
For example, if `NumWords = 64` (256 bytes address space), then the last 8 bits of `BaseAddr` must be `0`.
This means `32h4000_0100` is a valid `BaseAddr` while `32h4000_0010` is invalid.

