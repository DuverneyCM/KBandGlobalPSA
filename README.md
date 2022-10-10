# KBandGlobalPSA
Software and Hardware design for Pairwise Sequence Alignment (PSA) using Needleman-Wunsch algorithm, KBand method and both Linear and Affine gap score scheme. Highlight:
- PEs are designed using modular arithmetic, proocessing sequences of any length (e.g. 3-GB, a complete human genome) and maximaxing the PE density (1024 PEs on a Cyclone-V with 115K ALMs).
- Processors work at 50-MHz internally, which allow process the forward process on sequences of 25 millions of bases in 1s, e.g. a Human Chromosome Y.
- However, the bottleneck of the codesign system is the AXI bus of 256 bits at 200-MHz, besides the software components, limiting the speed of the whole solution, and reaching speed ups more of 50x for linear gap and more of 400x for affine gap, compared with the software equivalent simulator implemented on Wolfram Mathematica.
...
