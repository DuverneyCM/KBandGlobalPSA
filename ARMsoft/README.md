#Software Files

**sequences** has test sequences in fasta-format obtained from NCBI. For simplest test of this design, software implementation only support DNA-sequences in fasta-singleline-format, that is, these sequences (fasta) are not supported.

**sequences-singleLine** has supported sequences for this test software implementation (fasta-singleline).

**traceback_hps** has the software implementation (only hps) for running the traceback process.

**WS1_KBandDNA** has the Co-design implementation (hps-fpga) for running the forward process. Compilation must be realized for each FPGA platform as DE1-SoC, DE10nano, SocKit, etc... Therefore, before of compiling, update the **soc_system.sopcinfo** file and the **hps_isw_handoff** folder with the respective board/platform files ( ./Quartus/* )

##Backups WS1_KBandDNA (fpga_fft)
**basic** process input sequences and output arrows using one only packet. This implementation only is useful for short sequences, because memory restrictions. Sequences in text plain format.

**copia** has ligth changes oriented to use two DMA inputs (descarted)

**copia multiples paquetes** allows to process input sequences by packets. Output arrows are all storaged on one only file. This file would reaching high sizes, which cannot be compatible with some filesystem as FAT.

**copia(0211)** Backup

**copia fasta singleline** change text-plain to fasta-singleline format.

**1128** Backup because madness :D

**30112017 viejito** no clear changes :/

**25042018** reduce dimPacket to NoPEs/2. Divide arrows in multiple files.

**20180503** (Best backup) add support for execute-time. Allow to process sequences of unequal length. Add Left/Rigth zeros to shorter sequences. Add new scheme to divide packets. Align the KBand whit the optimal center of the band (a priori). Allow to adjust the center of the KBand.

**ACPwindow** has changes for using the HPS memory by the DMA interfaces. (No fully verified)
