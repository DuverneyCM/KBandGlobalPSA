/*
 * Copyright (c) 2013, Altera Corporation <www.altera.com>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the distribution.
 * - Neither the name of the Altera Corporation nor the
 *   names of its contributors may be used to endorse or promote products
 *   derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL ALTERA CORPORATION BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

// bring in the view from the processor
#include "hps_0.h"
#include "socal/hps.h"
/////////////////////////#include "KBandIP_custom_macros.h"
// bring in the view from the dmas
#include "soc_system.h"

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include "sgdma_dispatcher.h"
#include "descriptor_regs.h"
#include <sys/mman.h>
#include <math.h>
#include "string.h"


//////////////////////////
	//FPGA_SLAVES
	#define FPGA_SLAVES_BASE 	0xC0000000
	//#define FPGA_SLAVES_SPAN  0x3C000000 //960MB
	#define FPGA_SLAVES_SPAN 	0x00040000 //256KB, 2Mb
	#define FPGA_SLAVES_END  	0xFB111111
	//LigthWeigth
	//#define ALT_LWFPGASLVS_OFST       0xff200000	//"socal/hps.h"
	#define ALT_LWFPGASLVS_SPAN			0x00200000	//2MB, 16Kb		//4KB, 32Mb
	#define ALT_LWFPGASLVS_END			0xff3fffff

/* 
#define KBANDIP_KBANDINPUT_1_CSR_BASE 0x90000
#define KBANDIP_KBANDINPUT_1_CSR_SPAN 32
#define KBANDIP_KBANDINPUT_1_CSR_END 0x9001f
#define KBANDIP_KBANDINPUT_1_DESCRIPTOR_SLAVE_BASE 0x90060
#define KBANDIP_KBANDINPUT_1_DESCRIPTOR_SLAVE_SPAN 16
#define KBANDIP_KBANDINPUT_1_DESCRIPTOR_SLAVE_END 0x9006f

#define KBANDIP_KBANDOUTPUT_CSR_BASE 0x90040
#define KBANDIP_KBANDOUTPUT_CSR_SPAN 32
#define KBANDIP_KBANDOUTPUT_CSR_END 0x9005f
#define KBANDIP_KBANDOUTPUT_DESCRIPTOR_SLAVE_BASE 0x90080
#define KBANDIP_KBANDOUTPUT_DESCRIPTOR_SLAVE_SPAN 16
#define KBANDIP_KBANDOUTPUT_DESCRIPTOR_SLAVE_END 0x9008f

#define KBANDIP_ONCHIP_MEMORY2_0_BASE 0x80000
#define KBANDIP_ONCHIP_MEMORY2_0_SPAN 65536
#define KBANDIP_ONCHIP_MEMORY2_0_END 0x8ffff
 */
 
//HPS point of view
#define KBANDIP_ONCHIP_MEM_LW_BASE 0x80000
#define KBANDIP_ONCHIP_MEM_LW_SPAN 4096
#define KBANDIP_ONCHIP_MEM_LW_END 0x8ffff
#define KBANDIP_ONCHIP_MEM_SLAVE_BASE 0x000000
#define KBANDIP_ONCHIP_MEM_SLAVE_SPAN 262144
#define KBANDIP_ONCHIP_MEM_SLAVE_END  0x3ffff
//DMA point of view (redefined in soc_system.h)
#define DMA_KBANDIP_ONCHIP_MEM_LW_BASE 0x00000
#define DMA_KBANDIP_ONCHIP_MEM_LW_SPAN 4096
#define DMA_KBANDIP_ONCHIP_MEM_LW_END 0x0ffff
#define DMA_KBANDIP_ONCHIP_MEM_SLAVE_BASE 0x000000
#define DMA_KBANDIP_ONCHIP_MEM_SLAVE_SPAN 262144
#define DMA_KBANDIP_ONCHIP_MEM_SLAVE_END  0x3ffff

//////////////////////////



#define KBANDINPUT_1_CSR_BASE ((int)mappedBaseLW + KBANDIP_KBANDINPUT_1_CSR_BASE)
#define KBANDINPUT_1_DESCRIPTOR_SLAVE_BASE ((int)mappedBaseLW + KBANDIP_KBANDINPUT_1_DESCRIPTOR_SLAVE_BASE)
#define KBANDOUTPUT_CSR_BASE ((int)mappedBaseLW + KBANDIP_KBANDOUTPUT_CSR_BASE)
#define KBANDOUTPUT_DESCRIPTOR_SLAVE_BASE ((int)mappedBaseLW + KBANDIP_KBANDOUTPUT_DESCRIPTOR_SLAVE_BASE)

#define offsetOUTPUT 0x1000 //0.004MB 	4KB
#define DATA_BASE (KBANDIP_ONCHIP_MEM_LW_BASE + (int)mappedBaseLW) // 0.04MB //mappedBaseLW)
#define RESULT_BASE (KBANDIP_ONCHIP_MEM_SLAVE_BASE + (int)mappedBaseSLAVE)// 2.56MB //mappedBaseLW + 400//(KBANDIP_ONCHIP_MEMORY2_0_SPAN/2))

//mappedBaseSLAVE


// the FFT csr register from the point of view of the processor
// control status registers (CSR)
#define FFT_CSR_BASE ((int)mappedBaseLW + FFT_SUB_FFT_STADAPTER_0_BASE)

// this is the onchip ram base from the DMA's point of view
#define  DMA_DATA_BASE  DMA_KBANDIP_ONCHIP_MEM_LW_BASE
#define  DMA_RESULT_BASE  (DMA_KBANDIP_ONCHIP_MEM_SLAVE_BASE)

// memoria reservada ADN vista desde el hps
#define hps_DATAin1	(DATA_BASE)
#define hps_DATAout	(RESULT_BASE)
// memoria reservada ADN vista desde el dma
#define DMA_DATAin1	(DMA_DATA_BASE)
#define DMA_DATAout	(DMA_RESULT_BASE)


// this is the physical address of lw bridge.
//#define BASE_ADDRESS 0xff200000
//mappedBaseLW is the linux view of the same.

// main creates 2 files. the input value and the real part of the fft.
// these are used in the web browser app.

void const *g_preparser_strings[] = {
        "FILE=" __FILE__,
        "DATE=" __DATE__,
        "TIME=" __TIME__
};

int main(int argc, char **argv)
{
	int i;
	int mem;
	//int waveform = 0;
	volatile unsigned int *valuei;//, real, image;
	volatile unsigned int *valueo;//  output
	
	//char dataIn1[] = "GAATTCCTATTTATACTTCAAGATCCAGCTTCAACGCTACCTCCTTATTTAAAATTGATCAACTGATTAATTCAATAAAGAGTTCATGAGAGGCTCTTCC";//"TAGTAAGGGTGG";
	//char dataIn2[] = "GAATTCCAGGTGGGTGCTCTAACTTTTGGACCATACTCTGAGATTGGCATCTTACAAGGCCAAGATGGTAGTGCCTGTCTTTGTGCCTGATATAGACTTT";//"GTATGTGGG   ";
	
	
	//unsigned int *dataOut;
	//unsigned int temp;
	void *mappedBaseLW;	// where linux sees the lw bridge.
	void *mappedBaseSLAVE;
	//Definir archivos a utilizar, tanto fuentes como destinos
	FILE *fseqA;
	FILE *fseqB;
		FILE *farrows;

	sgdma_standard_descriptor descriptorIN1, /* descriptorIN2, */ descriptorOUT;

	printf("\n\nHello from SoC FPGA to everyone!\n");
	printf("This program was called with \"%s\".\n", argv[0]);
	
	int NoPEs = atoi(argv[1]); //64, 128, 256, 512, 1024, 2048
	int NoRegsFila = NoPEs*2/32;
	//////ABRIR ARCHIVOS
	fseqA =		fopen(argv[2],"r+");
	fseqB =		fopen(argv[3],"r+");
	farrows =	fopen(argv[4],"wb"); //"arrowsHPS.bin"
	printf("No PEs = %d\n", NoPEs);

	//////CARGAR SECUENCIAS DE ENTRADA Y SALIDA, MANEJADAS CON VARIABLES
	//identificar tamaño de seqA y seqB
		int dimSeqMAX;
		fseek(fseqA, 0, SEEK_END);
		int dimSeqA = ftell(fseqA);
		fseek(fseqB, 0, SEEK_END);
		int dimSeqB = ftell(fseqB);
		//Pasar las secuencias A y B a variables
		fseek(fseqA, 0, SEEK_SET);
		fseek(fseqB, 0, SEEK_SET);
		char dataIn1[dimSeqA + 1]; //VseqA
		char dataIn2[dimSeqB + 1]; //VseqB
		fread(&dataIn2,1,dimSeqB,fseqB);
		fread(&dataIn1,1,dimSeqA,fseqA);
		dataIn1[dimSeqA] = '\0';
		dataIn2[dimSeqB] = '\0';
			printf("dimSeqA = %d\n",dimSeqA);
			//printf("SeqA = %s\n\n",dataIn1);
			printf("dimSeqB = %d\n",dimSeqB);
			//printf("SeqB = %s\n\n",dataIn2);
		//char dataIn1[] = VseqA;
		//char dataIn2[] = VseqB;
		if (dimSeqA > dimSeqB) dimSeqMAX = dimSeqA;
			else	dimSeqMAX = dimSeqB;
		
			
	
	//////MAPEAR IP EN ESPACIO DE MEMORIA HPS
	// need to open a file.
	/* Open /dev/mem */
	if ((mem = open("/dev/mem", O_RDWR | O_SYNC)) == -1)
		fprintf(stderr, "Cannot open /dev/mem\n"), exit(1);
	// now map it into lw bridge space
	mappedBaseLW = mmap(0, ALT_LWFPGASLVS_SPAN, PROT_READ | PROT_WRITE, MAP_SHARED, mem, ALT_LWFPGASLVS_OFST);
	mappedBaseSLAVE = mmap(0, FPGA_SLAVES_SPAN, PROT_READ | PROT_WRITE, MAP_SHARED, mem, FPGA_SLAVES_BASE);

	if (mappedBaseLW == (void *)-1) {
		printf("Memory map failed. error %i\n", (int)mappedBaseLW);
		perror("mmap");
	}
	if (mappedBaseSLAVE == (void *)-1) {
		printf("Memory map failed. error %i\n", (int)mappedBaseSLAVE);
		perror("mmap");
	}
	// now that the fpga space is mapped we need to clear out the onchip ram so it is ready for data

	
	//////COPIAR DATOS DE ENTRADA A LA MEMORIA ONCHIP DEL IP
	valuei = (unsigned int *)((int)hps_DATAin1);
	//valueo = (unsigned int *)((int)hps_DATAin2);
	unsigned int a, seqA, seqB, csrControl;
	for (i=0; i<dimSeqMAX; i++) { /////////4 simbolos por byte
		if (i<dimSeqA)	seqA = ( (((unsigned int)dataIn1[i])<<24) );//| (((unsigned int)dataIn1[i])<<8) );
			else	seqA = 0;
		if (i<dimSeqB)	seqB = ( (((unsigned int)dataIn2[i])<<16) );//| (((unsigned int)dataIn2[i])<<0) );
			else	seqB = 0;
		csrControl = ( (255<<8) | (255<<0) );
		a = ( seqA | seqB | csrControl );
		//a = ( (((unsigned int)dataIn1[i])<<24) | (((unsigned int)dataIn2[i])<<16) | (((unsigned int)dataIn1[i])<<8) | (((unsigned int)dataIn2[i])<<0) );
		valuei[i]  = a;
		//alt_write_word((volatile uint32_t)(DATA_BASE + 4*i),wave);
		//printf("%X ", i);
		//printf("%08X\r\n", valuei[i]);
		//printf("%08X\r\n", valueo[i]);
	}
	
		
	//valueo = (unsigned int *)((int)RESULT_BASE);

	// now do the real work
	construct_standard_mm_to_st_descriptor(&descriptorIN1, (alt_u32 *) DMA_DATAin1, /*data_length*/dimSeqMAX * 4, DESCRIPTOR_CONTROL_GENERATE_SOP_MASK | DESCRIPTOR_CONTROL_GENERATE_EOP_MASK);
	construct_standard_st_to_mm_descriptor(&descriptorOUT, (alt_u32 *) DMA_DATAout, /*data_length*/(2*dimSeqMAX) *4*NoRegsFila, DESCRIPTOR_CONTROL_END_ON_EOP_MASK);
	// now write the constructors to memory
	write_standard_descriptor(KBANDINPUT_1_CSR_BASE, KBANDINPUT_1_DESCRIPTOR_SLAVE_BASE, &descriptorIN1);
	write_standard_descriptor(KBANDOUTPUT_CSR_BASE, KBANDOUTPUT_DESCRIPTOR_SLAVE_BASE, &descriptorOUT);
	
	// could just poll here
		usleep(500);
		if ((unsigned int)read_csr_status(KBANDINPUT_1_CSR_BASE) != 2)
			printf("ERROR sgdma to fft sgdma status 0x%x ( should be 2)\n", (unsigned int)read_csr_status(KBANDINPUT_1_CSR_BASE));
		if ((unsigned int)read_csr_status(KBANDOUTPUT_CSR_BASE) != 2)
			printf("ERROR sgdma from fft sgdma status 0x%x ( should be 2)\n", (unsigned int)read_csr_status(KBANDOUTPUT_CSR_BASE));

	// now read the results from memory
	for (i=0; i<(2)*NoRegsFila; i++) {
		a = 0;
		fwrite(&a, sizeof(int), 1, farrows);
	}
	valueo = (unsigned int *)((int)hps_DATAout);
	for (i=0; i<(2*dimSeqMAX)*NoRegsFila; i++) {
		//dataOut[i] = valueo[i];
		a = valueo[i];
		//printf("%X ", i);
		//printf("%x\r\n", valueo[i]);
		//printf("%08X\r\n", valueo[i]);
		fwrite(&a, sizeof(int), 1, farrows);
		//fprintf(farrows, valueo[i]);
	}

	valueo = (unsigned int *)((int)mappedBaseLW + SYSID_QSYS_BASE);

	//cerrar archivos
	fclose(farrows);
	fclose(fseqA);
	fclose(fseqB);
	//Liberar memoria
	munmap(mappedBaseLW, ALT_LWFPGASLVS_SPAN);//0x1f0000);
	munmap(mappedBaseSLAVE, FPGA_SLAVES_SPAN);
	close(mem);
	
	

	return 0;
}

