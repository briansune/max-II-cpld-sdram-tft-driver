
//              Timing Parameters for -7E (CL = 3)
parameter tCK              =     7.0; // tCK    ns    Nominal Clock Cycle Time
parameter tCK3_min         =     7.0; // tCK    ns    Nominal Clock Cycle Time
parameter tCK2_min         =     7.5; // tCK    ns    Nominal Clock Cycle Time
parameter tCK1_min         =     0.0; // tCK    ns    Nominal Clock Cycle Time
parameter tAC3             =     5.4; // tAC3   ns    Access time from CLK (pos edge) CL = 3
parameter tAC2             =     5.4; // tAC2   ns    Access time from CLK (pos edge) CL = 2
parameter tAC1             =     0.0; // tAC1   ns    Parameter definition for compilation - CL = 1 illegal for sg75
parameter tHZ3             =     5.4; // tHZ3   ns    Data Out High Z time - CL = 3
parameter tHZ2             =     5.4; // tHZ2   ns    Data Out High Z time - CL = 2
parameter tHZ1             =     0.0; // tHZ1   ns    Parameter definition for compilation - CL = 1 illegal for sg75
parameter tOH              =     2.7; // tOH    ns    Data Out Hold time
parameter tMRD             =     2.0; // tMRD   tCK   Load Mode Register command cycle time (2 * tCK)
parameter tRAS             =    37.0; // tRAS   ns    Active to Precharge command time
parameter tRC              =    60.0; // tRC    ns    Active to Active/Auto Refresh command time
parameter tRFC             =    66.0; // tRFC   ns    Refresh to Refresh Command interval time
parameter tRCD             =    15.0; // tRCD   ns    Active to Read/Write command time
parameter tRP              =    15.0; // tRP    ns    Precharge command period
parameter tRRD             =     2.0; // tRRD   tCK   Active bank a to Active bank b command time (2 * tCK)
parameter tWRa             =     7.0; // tWR    ns    Write recovery time (auto-precharge mode - must add 1 CLK)
parameter tWRm             =    14.0; // tWR    ns    Write recovery time

// Size Parameters based on Part Width
parameter ADDR_BITS        =      12; // Set this parameter to control how many Address bits are used
parameter ROW_BITS         =      12; // Set this parameter to control how many Row bits are used
parameter COL_BITS         =       8; // Set this parameter to control how many Column bits are used
parameter DQ_BITS          =      16; // Set this parameter to control how many Data bits are used
parameter DM_BITS          =       2; // Set this parameter to control how many DM bits are used
parameter BA_BITS          =       2; // Bank bits

// Other Parameters
parameter mem_sizes = 2**(ROW_BITS+COL_BITS) - 1;

