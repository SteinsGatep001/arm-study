//
// Init VM1
//
.global Image$$VM1_TT_S2$$ZI$$Base
MOV      X0, XZR                               // Reset address: 0x0
MOV      X1, #0                                // Execution state: AArch32
MOV      X2, #0xC0000000                       // Physical memory for VM
LDR      X3, =vm1                              // Data structure of VM context
LDR      X4, =Image$$VM1_TT_S2$$ZI$$Base       // Load address of second stage 
                                               // first level table
LDR      X5, =0x80010203                       // Affinity: 0.1.2.3
LDR      X6, =0x411FD073                       // MIDR: Cortex-A57
BL       init_vm


//
// Init VM0
//
.global Image$$VM0_TT_S2$$ZI$$Base
MOV      X0, XZR                               // Reset address: 0x0
MOV      X1, #1                                // Execution state: AArch64
MOV      X2, #0x80000000                       // Physical memory for VM
LDR      X3, =vm0                              // Data structure of VM context
LDR      X4, =Image$$VM0_TT_S2$$ZI$$Base       // Load address of second stage first level table
LDR      X5, =0x80000000                       // Affinity: 0.0.0.0
LDR      X6, =0x410FD034                       // MIDR: Cortex-A53
BL       init_vm

. . . 

// HCR_EL1
MOV      X8, #1                                // VM==1: Second stage 
                                               // translation enable
ORR      X8, X8, #(0x7 << 3)                   // Set FMO/IMO/AMO => physical 
                                               // async exceptions routed to 
                                               // EL2
ORR      X8, X8, X1, LSL #31                   // RW: based on passed in args
STR      X8, [X3]
MSR      HCR_EL2, X8
. . . 