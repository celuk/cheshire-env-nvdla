define trace_logger
    if $argc < 2
        printf "Usage: trace_logger <filename> <count>\n"
    else
        set pagination off
        set logging file $arg0
        set logging overwrite on
        set logging redirect on
        set logging on
        
        printf "Time(ns)   Cycle      PC               InstrHex   Disassembly\n"
        
        set $i = 0
        set $max = $arg1
        set $period_ns = 20
        
        while $i < $max
            set $time = $i * $period_ns
            set $instr_hex = *(unsigned int*)$pc
            
            printf "%-10d %-10d 0x%016x %08x ", $time, $i, $pc, $instr_hex
            x/1i $pc
            
            stepi
            
            set $i = $i + 1
        end
        
        set logging off
        set logging redirect off
        printf "Trace finished. Written to %s\n", $arg0
    end
end
