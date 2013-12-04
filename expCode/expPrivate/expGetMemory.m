function r = expGetMemory(v)

 s = whos('v');
 r = s.bytes;