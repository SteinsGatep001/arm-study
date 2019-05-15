void map_frame(unsigned long physical_addr, unsigned long attributes)
{
  unsigned long top_half = physical_addr >> 21; // 27 bits
  unsigned long bottom_half = (physical_addr >> 12) & 0x1ff; // 9 bits

  if(physical_addr == 0x3b000) {
    // Raw value shows up as 0x00400000090004c3
    el2_pt_level1[bottom + (top_half << 9)] = 0x9000000 | (XN_UXN_PXN | ACCESSED |
      S2AP_READ | S2AP_WRITE | VALID | ENTRY_PTR);
    return;
  } else if (physical_addr > 0x3bfff) {
    print_log("[VMM] Invalid IPA\n");
    panic();
  } else {
    if (physical_addr <= 0xbfff && (attributes & S2AP_WRITE)) {
      print_log("[VMM] try to map writable pages in RO protected area\n"); 
      panic();
    }
    // no XN, yet it's writable
    if (attributes == S2AP_WRITE) {
      print_log("[VMM] RWX pages are not allowed\n");
      panic();
    }
    unsigned long entry = physical_addr + 0x40000000;
    entry |= attributes;
    el2_pt_level1[bottom + (top_half << 9)] = entry;
  }
}