// N64 'Bare Metal' CPU CP1/FPU Multiplication Test Demo by krom (Peter Lemon):
arch n64.cpu
endian msb
output "CP1MUL.N64", create
fill 1052672 // Set ROM Size

// Setup Frame Buffer
constant SCREEN_X(640)
constant SCREEN_Y(480)
constant BYTES_PER_PIXEL(4)

// Setup Characters
constant CHAR_X(8)
constant CHAR_Y(8)

origin $00000000
base $80000000 // Entry Point Of Code
include "LIB/N64.INC" // Include N64 Definitions
include "LIB/N64_HEADER.ASM" // Include 64 Byte Header & Vector Table
insert "LIB/N64_BOOTCODE.BIN" // Include 4032 Byte Boot Code

macro PrintString(vram, xpos, ypos, fontfile, string, length) { // Print Text String To VRAM Using Font At X,Y Position
  li a0,{vram}+({xpos}*BYTES_PER_PIXEL)+(SCREEN_X*BYTES_PER_PIXEL*{ypos}) // A0 = Frame Buffer Pointer (Place text at XY Position)
  la a1,{fontfile} // A1 = Characters
  la a2,{string} // A2 = Text Offset
  ori t0,r0,{length} // T0 = Number of Text Characters to Print
  {#}DrawChars:
    ori t1,r0,CHAR_X-1 // T1 = Character X Pixel Counter
    ori t2,r0,CHAR_Y-1 // T2 = Character Y Pixel Counter

    lb t3,0(a2) // T3 = Next Text Character
    addi a2,1

    sll t3,8 // Add Shift to Correct Position in Font (*256: CHAR_X*CHAR_Y*BYTES_PER_PIXEL)
    add t3,a1

    {#}DrawCharX:
      lw t4,0(t3) // Load Font Text Character Pixel
      addi t3,BYTES_PER_PIXEL
      sw t4,0(a0) // Store Font Text Character Pixel into Frame Buffer
      addi a0,BYTES_PER_PIXEL

      bnez t1,{#}DrawCharX // IF (Character X Pixel Counter != 0) DrawCharX
      subi t1,1 // Decrement Character X Pixel Counter

      addi a0,(SCREEN_X*BYTES_PER_PIXEL)-CHAR_X*BYTES_PER_PIXEL // Jump Down 1 Scanline, Jump Back 1 Char
      ori t1,r0,CHAR_X-1 // Reset Character X Pixel Counter
      bnez t2,{#}DrawCharX // IF (Character Y Pixel Counter != 0) DrawCharX
      subi t2,1 // Decrement Character Y Pixel Counter

    subi a0,((SCREEN_X*BYTES_PER_PIXEL)*CHAR_Y)-CHAR_X*BYTES_PER_PIXEL // Jump To Start Of Next Char
    bnez t0,{#}DrawChars // Continue to Print Characters
    subi t0,1 // Subtract Number of Text Characters to Print
}

macro PrintValue(vram, xpos, ypos, fontfile, value, length) { // Print HEX Chars To VRAM Using Font At X,Y Position
  li a0,{vram}+({xpos}*BYTES_PER_PIXEL)+(SCREEN_X*BYTES_PER_PIXEL*{ypos}) // A0 = Frame Buffer Pointer (Place text at XY Position)
  la a1,{fontfile} // A1 = Characters
  la a2,{value} // A2 = Value Offset
  li t0,{length} // T0 = Number of HEX Chars to Print
  {#}DrawHEXChars:
    ori t1,r0,CHAR_X-1 // T1 = Character X Pixel Counter
    ori t2,r0,CHAR_Y-1 // T2 = Character Y Pixel Counter

    lb t3,0(a2) // T3 = Next 2 HEX Chars
    addi a2,1

    srl t4,t3,4 // T4 = 2nd Nibble
    andi t4,$F
    subi t5,t4,9
    bgtz t5,{#}HEXLetters
    addi t4,$30 // Delay Slot
    j {#}HEXEnd
    nop // Delay Slot

    {#}HEXLetters:
    addi t4,7
    {#}HEXEnd:

    sll t4,8 // Add Shift to Correct Position in Font (*256: CHAR_X*CHAR_Y*BYTES_PER_PIXEL)
    add t4,a1

    {#}DrawHEXCharX:
      lw t5,0(t4) // Load Font Text Character Pixel
      addi t4,4
      sw t5,0(a0) // Store Font Text Character Pixel into Frame Buffer
      addi a0,4

      bnez t1,{#}DrawHEXCharX // IF (Character X Pixel Counter != 0) DrawCharX
      subi t1,1 // Decrement Character X Pixel Counter

      addi a0,(SCREEN_X*BYTES_PER_PIXEL)-CHAR_X*BYTES_PER_PIXEL // Jump down 1 Scanline, Jump back 1 Char
      ori t1,r0,CHAR_X-1 // Reset Character X Pixel Counter
      bnez t2,{#}DrawHEXCharX // IF (Character Y Pixel Counter != 0) DrawCharX
      subi t2,1 // Decrement Character Y Pixel Counter

    subi a0,((SCREEN_X*BYTES_PER_PIXEL)*CHAR_Y)-CHAR_X*BYTES_PER_PIXEL // Jump To Start Of Next Char

    ori t2,r0,CHAR_Y-1 // Reset Character Y Pixel Counter

    andi t4,t3,$F // T4 = 1st Nibble
    subi t5,t4,9
    bgtz t5,{#}HEXLettersB
    addi t4,$30 // Delay Slot
    j {#}HEXEndB
    nop // Delay Slot

    {#}HEXLettersB:
    addi t4,7
    {#}HEXEndB:

    sll t4,8 // Add Shift to Correct Position in Font (*256: CHAR_X*CHAR_Y*BYTES_PER_PIXEL)
    add t4,a1

    {#}DrawHEXCharXB:
      lw t5,0(t4) // Load Font Text Character Pixel
      addi t4,4
      sw t5,0(a0) // Store Font Text Character Pixel into Frame Buffer
      addi a0,4

      bnez t1,{#}DrawHEXCharXB // IF (Character X Pixel Counter != 0) DrawCharX
      subi t1,1 // Decrement Character X Pixel Counter

      addi a0,(SCREEN_X*BYTES_PER_PIXEL)-CHAR_X*BYTES_PER_PIXEL // Jump down 1 Scanline, Jump back 1 Char
      ori t1,r0,CHAR_X-1 // Reset Character X Pixel Counter
      bnez t2,{#}DrawHEXCharXB // IF (Character Y Pixel Counter != 0) DrawCharX
      subi t2,1 // Decrement Character Y Pixel Counter

    subi a0,((SCREEN_X*BYTES_PER_PIXEL)*CHAR_Y)-CHAR_X*BYTES_PER_PIXEL // Jump To Start Of Next Char

    bnez t0,{#}DrawHEXChars // Continue to Print Characters
    subi t0,1 // Subtract Number of Text Characters to Print
}

Start:
  include "LIB/N64_GFX.INC" // Include Graphics Macros
  N64_INIT() // Run N64 Initialisation Routine

  ScreenNTSC(640, 480, BPP32|INTERLACE|AA_MODE_2, $A0100000) // Screen NTSC: 640x480, 32BPP, Interlace, Resample Only, DRAM Origin = $A0100000

  lui a0,$A010 // A0 = VRAM Start Offset
  la a1,$A0100000+((SCREEN_X*SCREEN_Y*BYTES_PER_PIXEL)-BYTES_PER_PIXEL) // A1 = VRAM End Offset
  ori t0,r0,$000000FF // T0 = Black
ClearScreen:
  sw t0,0(a0)
  bne a0,a1,ClearScreen
  addi a0,4 // Delay Slot


  PrintString($A0100000,88,8,FontRed,FSFTHEX,10) // Print Text String To VRAM Using Font At X,Y Position
  PrintString($A0100000,232,8,FontRed,FSFTDEC,14) // Print Text String To VRAM Using Font At X,Y Position
  PrintString($A0100000,384,8,FontRed,FDHEX,7) // Print Text String To VRAM Using Font At X,Y Position
  PrintString($A0100000,528,8,FontRed,TEST,10) // Print Text String To VRAM Using Font At X,Y Position


  PrintString($A0100000,0,16,FontBlack,PAGEBREAK,79) // Print Text String To VRAM Using Font At X,Y Position


  PrintString($A0100000,8,24,FontRed,MULD,4) // Print Text String To VRAM Using Font At X,Y Position
  la a0,VALUEDOUBLEA // A0 = Double Data Offset
  ldc1 f0,0(a0)      // F0 = Double Data
  la a0,VALUEDOUBLEB // A0 = Double Data Offset
  ldc1 f1,0(a0)      // F1 = Double Data
  mul.d f0,f1 // Convert To Long Data
  la a0,FDLONG  // A0 = FDLONG Offset
  sdc1 f0,0(a0) // FDLONG = Long Data
  PrintString($A0100000,80,24,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,88,24,FontBlack,VALUEDOUBLEA,7) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString($A0100000,344,24,FontBlack,TEXTDOUBLEA,2) // Print Text String To VRAM Using Font At X,Y Position
  PrintString($A0100000,80,32,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,88,32,FontBlack,VALUEDOUBLEB,7) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString($A0100000,232,32,FontBlack,TEXTDOUBLEB,16) // Print Text String To VRAM Using Font At X,Y Position
  PrintString($A0100000,376,32,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,384,32,FontBlack,FDLONG,7) // Print Text String To VRAM Using Font At X,Y Position
  la a0,FDLONG     // A0 = Long Data Offset
  ld t0,0(a0)      // T0 = Long Data
  la a0,MULDCHECKA // A0 = Long Check Data Offset
  ld t1,0(a0)      // T1 = Long Check Data
  beq t0,t1,MULDPASSA // Compare Result Equality With Check Data
  nop // Delay Slot
  PrintString($A0100000,528,32,FontRed,FAIL,3) // Print Text String To VRAM Using Font At X,Y Position
  j MULDENDA
  nop // Delay Slot
  MULDPASSA:
  PrintString($A0100000,528,32,FontGreen,PASS,3) // Print Text String To VRAM Using Font At X,Y Position
  MULDENDA:

  la a0,VALUEDOUBLEB // A0 = Double Data Offset
  ldc1 f0,0(a0)      // F0 = Double Data
  la a0,VALUEDOUBLEC // A0 = Double Data Offset
  ldc1 f1,0(a0)      // F1 = Double Data
  mul.d f0,f1 // Convert To Long Data
  la a0,FDLONG  // A0 = FDLONG Offset
  sdc1 f0,0(a0) // FDLONG = Long Data
  PrintString($A0100000,80,48,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,88,48,FontBlack,VALUEDOUBLEB,7) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString($A0100000,232,48,FontBlack,TEXTDOUBLEB,16) // Print Text String To VRAM Using Font At X,Y Position
  PrintString($A0100000,80,56,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,88,56,FontBlack,VALUEDOUBLEC,7) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString($A0100000,288,56,FontBlack,TEXTDOUBLEC,9) // Print Text String To VRAM Using Font At X,Y Position
  PrintString($A0100000,376,56,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,384,56,FontBlack,FDLONG,7) // Print Text String To VRAM Using Font At X,Y Position
  la a0,FDLONG     // A0 = Long Data Offset
  ld t0,0(a0)      // T0 = Long Data
  la a0,MULDCHECKB // A0 = Long Check Data Offset
  ld t1,0(a0)      // T1 = Long Check Data
  beq t0,t1,MULDPASSB // Compare Result Equality With Check Data
  nop // Delay Slot
  PrintString($A0100000,528,56,FontRed,FAIL,3) // Print Text String To VRAM Using Font At X,Y Position
  j MULDENDB
  nop // Delay Slot
  MULDPASSB:
  PrintString($A0100000,528,56,FontGreen,PASS,3) // Print Text String To VRAM Using Font At X,Y Position
  MULDENDB:

  la a0,VALUEDOUBLEC // A0 = Double Data Offset
  ldc1 f0,0(a0)      // F0 = Double Data
  la a0,VALUEDOUBLED // A0 = Double Data Offset
  ldc1 f1,0(a0)      // F1 = Double Data
  mul.d f0,f1 // Convert To Long Data
  la a0,FDLONG  // A0 = FDLONG Offset
  sdc1 f0,0(a0) // FDLONG = Long Data
  PrintString($A0100000,80,72,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,88,72,FontBlack,VALUEDOUBLEC,7) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString($A0100000,288,72,FontBlack,TEXTDOUBLEC,9) // Print Text String To VRAM Using Font At X,Y Position
  PrintString($A0100000,80,80,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,88,80,FontBlack,VALUEDOUBLED,7) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString($A0100000,232,80,FontBlack,TEXTDOUBLED,16) // Print Text String To VRAM Using Font At X,Y Position
  PrintString($A0100000,376,80,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,384,80,FontBlack,FDLONG,7) // Print Text String To VRAM Using Font At X,Y Position
  la a0,FDLONG     // A0 = Long Data Offset
  ld t0,0(a0)      // T0 = Long Data
  la a0,MULDCHECKC // A0 = Long Check Data Offset
  ld t1,0(a0)      // T1 = Long Check Data
  beq t0,t1,MULDPASSC // Compare Result Equality With Check Data
  nop // Delay Slot
  PrintString($A0100000,528,80,FontRed,FAIL,3) // Print Text String To VRAM Using Font At X,Y Position
  j MULDENDC
  nop // Delay Slot
  MULDPASSC:
  PrintString($A0100000,528,80,FontGreen,PASS,3) // Print Text String To VRAM Using Font At X,Y Position
  MULDENDC:

  la a0,VALUEDOUBLED // A0 = Double Data Offset
  ldc1 f0,0(a0)      // F0 = Double Data
  la a0,VALUEDOUBLEE // A0 = Double Data Offset
  ldc1 f1,0(a0)      // F1 = Double Data
  mul.d f0,f1 // Convert To Long Data
  la a0,FDLONG  // A0 = FDLONG Offset
  sdc1 f0,0(a0) // FDLONG = Long Data
  PrintString($A0100000,80,96,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,88,96,FontBlack,VALUEDOUBLED,7) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString($A0100000,232,96,FontBlack,TEXTDOUBLED,16) // Print Text String To VRAM Using Font At X,Y Position
  PrintString($A0100000,80,104,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,88,104,FontBlack,VALUEDOUBLEE,7) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString($A0100000,224,104,FontBlack,TEXTDOUBLEE,17) // Print Text String To VRAM Using Font At X,Y Position
  PrintString($A0100000,376,104,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,384,104,FontBlack,FDLONG,7) // Print Text String To VRAM Using Font At X,Y Position
  la a0,FDLONG     // A0 = Long Data Offset
  ld t0,0(a0)      // T0 = Long Data
  la a0,MULDCHECKD // A0 = Long Check Data Offset
  ld t1,0(a0)      // T1 = Long Check Data
  beq t0,t1,MULDPASSD // Compare Result Equality With Check Data
  nop // Delay Slot
  PrintString($A0100000,528,104,FontRed,FAIL,3) // Print Text String To VRAM Using Font At X,Y Position
  j MULDENDD
  nop // Delay Slot
  MULDPASSD:
  PrintString($A0100000,528,104,FontGreen,PASS,3) // Print Text String To VRAM Using Font At X,Y Position
  MULDENDD:

  la a0,VALUEDOUBLEE // A0 = Double Data Offset
  ldc1 f0,0(a0)      // F0 = Double Data
  la a0,VALUEDOUBLEF // A0 = Double Data Offset
  ldc1 f1,0(a0)      // F1 = Double Data
  mul.d f0,f1 // Convert To Long Data
  la a0,FDLONG  // A0 = FDLONG Offset
  sdc1 f0,0(a0) // FDLONG = Long Data
  PrintString($A0100000,80,120,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,88,120,FontBlack,VALUEDOUBLEE,7) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString($A0100000,224,120,FontBlack,TEXTDOUBLEE,17) // Print Text String To VRAM Using Font At X,Y Position
  PrintString($A0100000,80,128,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,88,128,FontBlack,VALUEDOUBLEF,7) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString($A0100000,280,128,FontBlack,TEXTDOUBLEF,10) // Print Text String To VRAM Using Font At X,Y Position
  PrintString($A0100000,376,128,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,384,128,FontBlack,FDLONG,7) // Print Text String To VRAM Using Font At X,Y Position
  la a0,FDLONG     // A0 = Long Data Offset
  ld t0,0(a0)      // T0 = Long Data
  la a0,MULDCHECKE // A0 = Long Check Data Offset
  ld t1,0(a0)      // T1 = Long Check Data
  beq t0,t1,MULDPASSE // Compare Result Equality With Check Data
  nop // Delay Slot
  PrintString($A0100000,528,128,FontRed,FAIL,3) // Print Text String To VRAM Using Font At X,Y Position
  j MULDENDE
  nop // Delay Slot
  MULDPASSE:
  PrintString($A0100000,528,128,FontGreen,PASS,3) // Print Text String To VRAM Using Font At X,Y Position
  MULDENDE:

  la a0,VALUEDOUBLEF // A0 = Double Data Offset
  ldc1 f0,0(a0)      // F0 = Double Data
  la a0,VALUEDOUBLEG // A0 = Double Data Offset
  ldc1 f1,0(a0)      // F1 = Double Data
  mul.d f0,f1 // Convert To Long Data
  la a0,FDLONG  // A0 = FDLONG Offset
  sdc1 f0,0(a0) // FDLONG = Long Data
  PrintString($A0100000,80,144,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,88,144,FontBlack,VALUEDOUBLEF,7) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString($A0100000,280,144,FontBlack,TEXTDOUBLEF,10) // Print Text String To VRAM Using Font At X,Y Position
  PrintString($A0100000,80,152,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,88,152,FontBlack,VALUEDOUBLEG,7) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString($A0100000,224,152,FontBlack,TEXTDOUBLEG,17) // Print Text String To VRAM Using Font At X,Y Position
  PrintString($A0100000,376,152,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,384,152,FontBlack,FDLONG,7) // Print Text String To VRAM Using Font At X,Y Position
  la a0,FDLONG     // A0 = Long Data Offset
  ld t0,0(a0)      // T0 = Long Data
  la a0,MULDCHECKF // A0 = Long Check Data Offset
  ld t1,0(a0)      // T1 = Long Check Data
  beq t0,t1,MULDPASSF // Compare Result Equality With Check Data
  nop // Delay Slot
  PrintString($A0100000,528,152,FontRed,FAIL,3) // Print Text String To VRAM Using Font At X,Y Position
  j MULDENDF
  nop // Delay Slot
  MULDPASSF:
  PrintString($A0100000,528,152,FontGreen,PASS,3) // Print Text String To VRAM Using Font At X,Y Position
  MULDENDF:

  la a0,VALUEDOUBLEA // A0 = Double Data Offset
  ldc1 f0,0(a0)      // F0 = Double Data
  la a0,VALUEDOUBLEG // A0 = Double Data Offset
  ldc1 f1,0(a0)      // F1 = Double Data
  mul.d f0,f1 // Convert To Long Data
  la a0,FDLONG  // A0 = FDLONG Offset
  sdc1 f0,0(a0) // FDLONG = Long Data
  PrintString($A0100000,80,168,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,88,168,FontBlack,VALUEDOUBLEA,7) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString($A0100000,344,168,FontBlack,TEXTDOUBLEA,2) // Print Text String To VRAM Using Font At X,Y Position
  PrintString($A0100000,80,176,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,88,176,FontBlack,VALUEDOUBLEG,7) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString($A0100000,224,176,FontBlack,TEXTDOUBLEG,17) // Print Text String To VRAM Using Font At X,Y Position
  PrintString($A0100000,376,176,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,384,176,FontBlack,FDLONG,7) // Print Text String To VRAM Using Font At X,Y Position
  la a0,FDLONG     // A0 = Long Data Offset
  ld t0,0(a0)      // T0 = Long Data
  la a0,MULDCHECKG // A0 = Long Check Data Offset
  ld t1,0(a0)      // T1 = Long Check Data
  beq t0,t1,MULDPASSG // Compare Result Equality With Check Data
  nop // Delay Slot
  PrintString($A0100000,528,176,FontRed,FAIL,3) // Print Text String To VRAM Using Font At X,Y Position
  j MULDENDG
  nop // Delay Slot
  MULDPASSG:
  PrintString($A0100000,528,176,FontGreen,PASS,3) // Print Text String To VRAM Using Font At X,Y Position
  MULDENDG:


  PrintString($A0100000,8,192,FontRed,MULS,4) // Print Text String To VRAM Using Font At X,Y Position
  la a0,VALUEFLOATA // A0 = Float Data Offset
  lwc1 f0,0(a0)     // F0 = Float Data
  la a0,VALUEFLOATB // A0 = Float Data Offset
  lwc1 f1,0(a0)     // F1 = Float Data
  mul.s f0,f1 // Convert To Word Data
  la a0,FDWORD  // A0 = FDWORD Offset
  swc1 f0,0(a0) // FDWORD = Word Data
  PrintString($A0100000,144,192,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,152,192,FontBlack,VALUEFLOATA,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString($A0100000,344,192,FontBlack,TEXTFLOATA,2) // Print Text String To VRAM Using Font At X,Y Position
  PrintString($A0100000,144,200,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,152,200,FontBlack,VALUEFLOATB,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString($A0100000,296,200,FontBlack,TEXTFLOATB,8) // Print Text String To VRAM Using Font At X,Y Position
  PrintString($A0100000,440,200,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,448,200,FontBlack,FDWORD,3) // Print Text String To VRAM Using Font At X,Y Position
  la a0,FDWORD     // A0 = Word Data Offset
  lw t0,0(a0)      // T0 = Word Data
  la a0,MULSCHECKA // A0 = Word Check Data Offset
  lw t1,0(a0)      // T1 = Word Check Data
  beq t0,t1,MULSPASSA // Compare Result Equality With Check Data
  nop // Delay Slot
  PrintString($A0100000,528,200,FontRed,FAIL,3) // Print Text String To VRAM Using Font At X,Y Position
  j MULSENDA
  nop // Delay Slot
  MULSPASSA:
  PrintString($A0100000,528,200,FontGreen,PASS,3) // Print Text String To VRAM Using Font At X,Y Position
  MULSENDA:

  la a0,VALUEFLOATB // A0 = Float Data Offset
  lwc1 f0,0(a0)     // F0 = Float Data
  la a0,VALUEFLOATC // A0 = Float Data Offset
  lwc1 f1,0(a0)     // F1 = Float Data
  mul.s f0,f1 // Convert To Word Data
  la a0,FDWORD  // A0 = FDWORD Offset
  swc1 f0,0(a0) // FDWORD = Word Data
  PrintString($A0100000,144,216,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,152,216,FontBlack,VALUEFLOATB,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString($A0100000,296,216,FontBlack,TEXTFLOATB,8) // Print Text String To VRAM Using Font At X,Y Position
  PrintString($A0100000,144,224,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,152,224,FontBlack,VALUEFLOATC,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString($A0100000,320,224,FontBlack,TEXTFLOATC,5) // Print Text String To VRAM Using Font At X,Y Position
  PrintString($A0100000,440,224,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,448,224,FontBlack,FDWORD,3) // Print Text String To VRAM Using Font At X,Y Position
  la a0,FDWORD     // A0 = Word Data Offset
  lw t0,0(a0)      // T0 = Word Data
  la a0,MULSCHECKB // A0 = Word Check Data Offset
  lw t1,0(a0)      // T1 = Word Check Data
  beq t0,t1,MULSPASSB // Compare Result Equality With Check Data
  nop // Delay Slot
  PrintString($A0100000,528,224,FontRed,FAIL,3) // Print Text String To VRAM Using Font At X,Y Position
  j MULSENDB
  nop // Delay Slot
  MULSPASSB:
  PrintString($A0100000,528,224,FontGreen,PASS,3) // Print Text String To VRAM Using Font At X,Y Position
  MULSENDB:

  la a0,VALUEFLOATC // A0 = Float Data Offset
  lwc1 f0,0(a0)     // F0 = Float Data
  la a0,VALUEFLOATD // A0 = Float Data Offset
  lwc1 f1,0(a0)     // F1 = Float Data
  mul.s f0,f1 // Convert To Word Data
  la a0,FDWORD  // A0 = FDWORD Offset
  swc1 f0,0(a0) // FDWORD = Word Data
  PrintString($A0100000,144,240,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,152,240,FontBlack,VALUEFLOATC,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString($A0100000,320,240,FontBlack,TEXTFLOATC,5) // Print Text String To VRAM Using Font At X,Y Position
  PrintString($A0100000,144,248,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,152,248,FontBlack,VALUEFLOATD,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString($A0100000,296,248,FontBlack,TEXTFLOATD,8) // Print Text String To VRAM Using Font At X,Y Position
  PrintString($A0100000,440,248,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,448,248,FontBlack,FDWORD,3) // Print Text String To VRAM Using Font At X,Y Position
  la a0,FDWORD     // A0 = Word Data Offset
  lw t0,0(a0)      // T0 = Word Data
  la a0,MULSCHECKC // A0 = Word Check Data Offset
  lw t1,0(a0)      // T1 = Word Check Data
  beq t0,t1,MULSPASSC // Compare Result Equality With Check Data
  nop // Delay Slot
  PrintString($A0100000,528,248,FontRed,FAIL,3) // Print Text String To VRAM Using Font At X,Y Position
  j MULSENDC
  nop // Delay Slot
  MULSPASSC:
  PrintString($A0100000,528,248,FontGreen,PASS,3) // Print Text String To VRAM Using Font At X,Y Position
  MULSENDC:

  la a0,VALUEFLOATD // A0 = Float Data Offset
  lwc1 f0,0(a0)     // F0 = Float Data
  la a0,VALUEFLOATE // A0 = Float Data Offset
  lwc1 f1,0(a0)     // F1 = Float Data
  mul.s f0,f1 // Convert To Word Data
  la a0,FDWORD  // A0 = FDWORD Offset
  swc1 f0,0(a0) // FDWORD = Word Data
  PrintString($A0100000,144,264,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,152,264,FontBlack,VALUEFLOATD,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString($A0100000,296,264,FontBlack,TEXTFLOATD,8) // Print Text String To VRAM Using Font At X,Y Position
  PrintString($A0100000,144,272,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,152,272,FontBlack,VALUEFLOATE,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString($A0100000,288,272,FontBlack,TEXTFLOATE,9) // Print Text String To VRAM Using Font At X,Y Position
  PrintString($A0100000,440,272,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,448,272,FontBlack,FDWORD,3) // Print Text String To VRAM Using Font At X,Y Position
  la a0,FDWORD     // A0 = Word Data Offset
  lw t0,0(a0)      // T0 = Word Data
  la a0,MULSCHECKD // A0 = Word Check Data Offset
  lw t1,0(a0)      // T1 = Word Check Data
  beq t0,t1,MULSPASSD // Compare Result Equality With Check Data
  nop // Delay Slot
  PrintString($A0100000,528,272,FontRed,FAIL,3) // Print Text String To VRAM Using Font At X,Y Position
  j MULSENDD
  nop // Delay Slot
  MULSPASSD:
  PrintString($A0100000,528,272,FontGreen,PASS,3) // Print Text String To VRAM Using Font At X,Y Position
  MULSENDD:

  la a0,VALUEFLOATE // A0 = Float Data Offset
  lwc1 f0,0(a0)     // F0 = Float Data
  la a0,VALUEFLOATF // A0 = Float Data Offset
  lwc1 f1,0(a0)     // F1 = Float Data
  mul.s f0,f1 // Convert To Word Data
  la a0,FDWORD  // A0 = FDWORD Offset
  swc1 f0,0(a0) // FDWORD = Word Data
  PrintString($A0100000,144,288,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,152,288,FontBlack,VALUEFLOATE,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString($A0100000,288,288,FontBlack,TEXTFLOATE,9) // Print Text String To VRAM Using Font At X,Y Position
  PrintString($A0100000,144,296,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,152,296,FontBlack,VALUEFLOATF,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString($A0100000,312,296,FontBlack,TEXTFLOATF,6) // Print Text String To VRAM Using Font At X,Y Position
  PrintString($A0100000,440,296,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,448,296,FontBlack,FDWORD,3) // Print Text String To VRAM Using Font At X,Y Position
  la a0,FDWORD     // A0 = Word Data Offset
  lw t0,0(a0)      // T0 = Word Data
  la a0,MULSCHECKE // A0 = Word Check Data Offset
  lw t1,0(a0)      // T1 = Word Check Data
  beq t0,t1,MULSPASSE // Compare Result Equality With Check Data
  nop // Delay Slot
  PrintString($A0100000,528,296,FontRed,FAIL,3) // Print Text String To VRAM Using Font At X,Y Position
  j MULSENDE
  nop // Delay Slot
  MULSPASSE:
  PrintString($A0100000,528,296,FontGreen,PASS,3) // Print Text String To VRAM Using Font At X,Y Position
  MULSENDE:

  la a0,VALUEFLOATF // A0 = Float Data Offset
  lwc1 f0,0(a0)     // F0 = Float Data
  la a0,VALUEFLOATG // A0 = Float Data Offset
  lwc1 f1,0(a0)     // F1 = Float Data
  mul.s f0,f1 // Convert To Word Data
  la a0,FDWORD  // A0 = FDWORD Offset
  swc1 f0,0(a0) // FDWORD = Word Data
  PrintString($A0100000,144,312,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,152,312,FontBlack,VALUEFLOATF,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString($A0100000,312,312,FontBlack,TEXTFLOATF,6) // Print Text String To VRAM Using Font At X,Y Position
  PrintString($A0100000,144,320,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,152,320,FontBlack,VALUEFLOATG,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString($A0100000,288,320,FontBlack,TEXTFLOATG,9) // Print Text String To VRAM Using Font At X,Y Position
  PrintString($A0100000,440,320,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,448,320,FontBlack,FDWORD,3) // Print Text String To VRAM Using Font At X,Y Position
  la a0,FDWORD     // A0 = Word Data Offset
  lw t0,0(a0)      // T0 = Word Data
  la a0,MULSCHECKF // A0 = Word Check Data Offset
  lw t1,0(a0)      // T1 = Word Check Data
  beq t0,t1,MULSPASSF // Compare Result Equality With Check Data
  nop // Delay Slot
  PrintString($A0100000,528,320,FontRed,FAIL,3) // Print Text String To VRAM Using Font At X,Y Position
  j MULSENDF
  nop // Delay Slot
  MULSPASSF:
  PrintString($A0100000,528,320,FontGreen,PASS,3) // Print Text String To VRAM Using Font At X,Y Position
  MULSENDF:

  la a0,VALUEFLOATA // A0 = Float Data Offset
  lwc1 f0,0(a0)     // F0 = Float Data
  la a0,VALUEFLOATG // A0 = Float Data Offset
  lwc1 f1,0(a0)     // F1 = Float Data
  mul.s f0,f1 // Convert To Word Data
  la a0,FDWORD  // A0 = FDWORD Offset
  swc1 f0,0(a0) // FDWORD = Word Data
  PrintString($A0100000,144,336,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,152,336,FontBlack,VALUEFLOATA,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString($A0100000,344,336,FontBlack,TEXTFLOATA,2) // Print Text String To VRAM Using Font At X,Y Position
  PrintString($A0100000,144,344,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,152,344,FontBlack,VALUEFLOATG,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString($A0100000,288,344,FontBlack,TEXTFLOATG,9) // Print Text String To VRAM Using Font At X,Y Position
  PrintString($A0100000,440,344,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,448,344,FontBlack,FDWORD,3) // Print Text String To VRAM Using Font At X,Y Position
  la a0,FDWORD     // A0 = Word Data Offset
  lw t0,0(a0)      // T0 = Word Data
  la a0,MULSCHECKG // A0 = Word Check Data Offset
  lw t1,0(a0)      // T1 = Word Check Data
  beq t0,t1,MULSPASSG // Compare Result Equality With Check Data
  nop // Delay Slot
  PrintString($A0100000,528,344,FontRed,FAIL,3) // Print Text String To VRAM Using Font At X,Y Position
  j MULSENDG
  nop // Delay Slot
  MULSPASSG:
  PrintString($A0100000,528,344,FontGreen,PASS,3) // Print Text String To VRAM Using Font At X,Y Position
  MULSENDG:


  PrintString($A0100000,0,352,FontBlack,PAGEBREAK,79) // Print Text String To VRAM Using Font At X,Y Position


Loop:
  WaitScanline($1E0) // Wait For Scanline To Reach Vertical Blank
  WaitScanline($1E2)

  ori t0,r0,$00000800 // Even Field
  sw t0,VI_Y_SCALE(a0)

  WaitScanline($1E0) // Wait For Scanline To Reach Vertical Blank
  WaitScanline($1E2)

  li t0,$02000800 // Odd Field
  sw t0,VI_Y_SCALE(a0)

  j Loop
  nop // Delay Slot

MULD:
  db "MUL.D"
MULS:
  db "MUL.S"

FDHEX:
  db "FD (Hex)"
FSFTHEX:
  db "FS/FT (Hex)"
FSFTDEC:
  db "FS/FT (Decimal)"
TEST:
  db "Test Result"
FAIL:
  db "FAIL"
PASS:
  db "PASS"

DOLLAR:
  db "$"

TEXTDOUBLEA:
  db "0.0"
TEXTDOUBLEB:
  db "12345678.67891234"
TEXTDOUBLEC:
  db "12345678.5"
TEXTDOUBLED:
  db "12345678.12345678"
TEXTDOUBLEE:
  db "-12345678.12345678"
TEXTDOUBLEF:
  db "-12345678.5"
TEXTDOUBLEG:
  db "-12345678.67891234"

TEXTFLOATA:
  db "0.0"
TEXTFLOATB:
  db "1234.6789"
TEXTFLOATC:
  db "1234.5"
TEXTFLOATD:
  db "1234.1234"
TEXTFLOATE:
  db "-1234.1234"
TEXTFLOATF:
  db "-1234.5"
TEXTFLOATG:
  db "-1234.6789"

PAGEBREAK:
  db "--------------------------------------------------------------------------------"

align(8) // Align 64-Bit
VALUEDOUBLEA:
  float64 0.0
VALUEDOUBLEB:
  float64 12345678.67891234
VALUEDOUBLEC:
  float64 12345678.5
VALUEDOUBLED:
  float64 12345678.12345678
VALUEDOUBLEE:
  float64 -12345678.12345678
VALUEDOUBLEF:
  float64 -12345678.5
VALUEDOUBLEG:
  float64 -12345678.67891234

MULDCHECKA:
  dd $0000000000000000
MULDCHECKB:
  dd $42E153E20D49258F
MULDCHECKC:
  dd $42E153E20034C517
MULDCHECKD:
  dd $C2E153E1F756E7EA
MULDCHECKE:
  dd $42E153E20034C517
MULDCHECKF:
  dd $42E153E20D49258F
MULDCHECKG:
  dd $8000000000000000

FDLONG:
  dd 0

VALUEFLOATA:
  float32 0.0
VALUEFLOATB:
  float32 1234.6789
VALUEFLOATC:
  float32 1234.5
VALUEFLOATD:
  float32 1234.1234
VALUEFLOATE:
  float32 -1234.1234
VALUEFLOATF:
  float32 -1234.5
VALUEFLOATG:
  float32 -1234.6789

MULSCHECKA:
  dw $00000000
MULSCHECKB:
  dw $49BA0F99
MULSCHECKC:
  dw $49B9FA2B
MULSCHECKD:
  dw $C9B9EBA5
MULSCHECKE:
  dw $49B9FA2B
MULSCHECKF:
  dw $49BA0F99
MULSCHECKG:
  dw $80000000

FDWORD:
  dw 0

insert FontBlack, "FontBlack8x8.bin"
insert FontGreen, "FontGreen8x8.bin"
insert FontRed, "FontRed8x8.bin"