const b = a.b.c.d[0][1];
const x = 1+2*3+4/-c();
const z = D{ .fds = ds};
pub fn nextCodepointSlice(it: *Utf8Iterator) ?[]const u8 {
    if (it.i >= it.bytes.len) 
        return null
    
    else bla;

    const cp_len = utf8ByteSequenceLength(it.bytes[it.i]) catch unreachable;
    it.i += cp_len;
    return it.bytes[it.i - cp_len .. it.i];
}
