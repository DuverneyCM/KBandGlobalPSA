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
#include <time.h>


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
/*
#define KBANDIP_ONCHIP_MEMORY2_0_BASE 0x80000
#define KBANDIP_ONCHIP_MEMORY2_0_SPAN 65536
#define KBANDIP_ONCHIP_MEMORY2_0_END 0x8ffff
*/

//HPS point of view
#define KBANDIP_ONCHIP_MEM_LW_BASE 0x80000
#define KBANDIP_ONCHIP_MEM_LW_SPAN 4096
#define KBANDIP_ONCHIP_MEM_LW_END 0x80fff
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

#define CLOCKS_BY_SEC 800000

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
	clock_t beginT = clock();
	int i = 0;
	int a = 0;
	int mem;
	int noFile = 1;

	volatile unsigned int *valuei;//, real, image;
	volatile unsigned int *valueo;//  output




	void *mappedBaseLW;	// where linux sees the lw bridge.
	void *mappedBaseSLAVE;
	//Definir archivos a utilizar, tanto fuentes como destinos
	FILE *fseqA;
	FILE *fseqB;
		FILE *farrows;

	sgdma_standard_descriptor descriptorIN1, descriptorOUT;

	printf("\n\nHello from SoC FPGA to everyone!\n");
	printf("This program was called with \"%s\".\n", argv[0]);


	//////MAPEAR IP EN ESPACIO DE MEMORIA HPS
	// need to open a file.	/* Open /dev/mem */
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


	int NoPEs = atoi(argv[1]); //64, 128, 256, 512, 1024, 2048
		printf("No PEs = %d\n", NoPEs);
	int NoRegsFila = NoPEs*2/32;

	int dimPacket = NoPEs/2;
	char dataIn1[dimPacket + 1]; //VseqA
	char dataIn2[dimPacket + 1]; //VseqB
	//char dataIn1[] = "GAATTCCTATTTATACTTCAAGATCCAGCTTCAACGCTACCTCCTTATTTAAAATTGATCAACTGATTAATTCAATAAAGAGTTCATGAGAGGCTCTTCC";//"TAGTAAGGGTGG";
	//char dataIn2[] = "GAATTCCAGGTGGGTGCTCTAACTTTTGGACCATACTCTGAGATTGGCATCTTACAAGGCCAAGATGGTAGTGCCTGTCTTTGTGCCTGATATAGACTTT";//"GTATGTGGG   ";
		//char dataIn1[dimSeqA + 1]; //VseqA
		//char dataIn2[dimSeqB + 1]; //VseqB

			//////ABRIR ARCHIVOS
	fseqA =		fopen(argv[2],"r+");
	fseqB =		fopen(argv[3],"r+");

	char arrowFILEname[32];	//sprintf(buf, "pre_%d_suff", i);
	//strcpy(arrowFILEname,argv[4]);
	//strcat(arrowFILEname,"");
	//strcat(arrowFILEname,".bin");
	sprintf(arrowFILEname, "%sp%d.bin", argv[4], noFile);
	farrows =	fopen(arrowFILEname,"wb"); //"arrowsHPS.bin"
		//Inicializar Archivo de flechas con 2 filas de ceros
		a = 0;
		for (i=0; i<(2)*NoRegsFila; i++) {	fwrite(&a, sizeof(int), 1, farrows);	}

	//offset de la banda
	int offsetBand = atoi(argv[5]);


	//////CARGAR SECUENCIAS DE ENTRADA Y SALIDA, MANEJADAS CON VARIABLES

	//identificar tamaño de del archivo A y B
	fseek(fseqA, 0, SEEK_END);
	int dimFileSeqA = ftell(fseqA);
	fseek(fseqB, 0, SEEK_END);
	int dimFileSeqB = ftell(fseqB);

	//Buscar la posición del primer enter, solo si es un archivo fasta >
	int SearchPacket, posFirstEnterA, posFirstEnterB = 0;
	if (dimFileSeqA > dimPacket)	SearchPacket = dimPacket;
		else SearchPacket = dimFileSeqA;
	fseek(fseqA, 0, SEEK_SET);
	fread(&dataIn1,1,SearchPacket,fseqA);
	if (dataIn1[0] == '>'){
		for (i=SearchPacket-1; i>=1; i--){
			if (dataIn1[i] == '\n') posFirstEnterA = i;
		}
	}else {
		printf("SeqA no es un archivo con formato fasta\n");
		return 100;
	}

	if (dimFileSeqB > dimPacket)	SearchPacket = dimPacket;
		else SearchPacket = dimFileSeqB;
	fseek(fseqB, 0, SEEK_SET);
	fread(&dataIn1,1,SearchPacket,fseqB);
	if (dataIn1[0] == '>'){
		for (i=SearchPacket-1; i>=1; i--){
			if (dataIn1[i] == '\n') posFirstEnterB = i;
		}
	}else {
		printf("SeqB no es un archivo con formato fasta\n");
		return 100;
	}

/*
	char * pch;
	int idxToDel, noCharDelete = 0;
	fseek(fseqB, posFirstEnterB + 1, SEEK_SET);
	fseek(fseqA, posFirstEnterA + 1, SEEK_SET);
	pch=strchr(dataIn1,'\n');
	while (pch!=NULL){
		idxToDel = pch-dataIn1+1;
		printf ("found at %d\n",idxToDel);
		pch=strchr(pch+1,'s');
		noCharDelete++;
	}
*/




	//identificar tamaño de seqA y seqB
	int dimSeqA, dimSeqB, dimSeqMAX, diffSeqAB  = 0;
	//fseek(fseqA, 0, SEEK_END);
	//dimSeqA = ftell(fseqA);
	dimSeqA = dimFileSeqA - (posFirstEnterA + 1);
		printf("dimSeqA = %d\n",dimSeqA);
	//fseek(fseqB, 0, SEEK_END);
	//dimSeqB = ftell(fseqB);
	dimSeqB = dimFileSeqB - (posFirstEnterB + 1);
		printf("dimSeqB = %d\n",dimSeqB);
	//Secuencia mas larga, diferencia entre ellas y numero de paquetes
	if (dimSeqA > dimSeqB){
		dimSeqMAX = dimSeqA;
		diffSeqAB = dimSeqA - dimSeqB;
	}else{
		dimSeqMAX = dimSeqB;
		diffSeqAB = dimSeqB - dimSeqA;
	}
	//diferencia de tamaño entre secuencias
	offsetBand = offsetBand + diffSeqAB/2;


	//Calcular # de paquetes
	//noPacketA, noPacketB, noPacket, dimLastPacketA, dimLastPacketB
	int noPacket, noPacketA, noPacketB, dimLastPacketA, dimLastPacketB, dimPacketA, dimPacketB;
	if (dimSeqA > dimSeqB){
		//NoPackets
		if (dimSeqA % dimPacket == 0)					noPacketA = dimSeqA/dimPacket;
		else											noPacketA = dimSeqA/dimPacket + 1;
		if ((dimSeqB + offsetBand) % dimPacket == 0)	noPacketB = (dimSeqB + offsetBand)/dimPacket;
		else											noPacketB = (dimSeqB + offsetBand)/dimPacket + 1;
		//dimension Last Packet
		if (dimSeqA % dimPacket == 0)					dimLastPacketA = dimPacket;
		else											dimLastPacketA = dimSeqA % dimPacket;
		if ((dimSeqB + offsetBand) % dimPacket == 0)	dimLastPacketB = dimPacket;
		else											dimLastPacketB = (dimSeqB + offsetBand) % dimPacket;
	}else{
		//NoPackets
		if ((dimSeqA + offsetBand) % dimPacket == 0)	noPacketA = (dimSeqA + offsetBand)/dimPacket;
		else											noPacketA = (dimSeqA + offsetBand)/dimPacket + 1;
		if (dimSeqB % dimPacket == 0)					noPacketB = dimSeqB/dimPacket;
		else											noPacketB = dimSeqB/dimPacket + 1;
		//dimension Last Packet
		if ((dimSeqA + offsetBand) % dimPacket == 0)	dimLastPacketA = dimPacket;
		else											dimLastPacketA = (dimSeqA + offsetBand) % dimPacket;
		if (dimSeqB % dimPacket == 0)					dimLastPacketB = dimPacket;
		else											dimLastPacketB = dimSeqB % dimPacket;
	}
	if (noPacketA > noPacketB)	noPacket = noPacketA;
	else 						noPacket = noPacketB;

		printf("diffSeqAB = %d\n",diffSeqAB);
		printf("offsetBand = %d\n",offsetBand);
		printf("dimSeqMAX = %d\n",dimSeqMAX);
		printf("noPacket = %d\n",noPacket);
		printf("dimLastPacketA = %d\n",dimLastPacketA);
		printf("dimLastPacketB = %d\n",dimLastPacketB);

	//Flags
	int csrLastPacket = 0;



	//////PAQUETES DE ENTRADA	( DESDE AQUI... FOR )
	unsigned seqA, seqB, seqControl, pack;
	int dimPacketMAX;
	int latenciaKBand = 3*2; //Latency = 6
	int usPause = 200;
	valuei = (unsigned int *)((int)hps_DATAin1);
	valueo = (unsigned int *)((int)hps_DATAout);


	//Primer paquete no genera flechas
	pack = 0;
	// Conf para LastPacket
	if (pack+1 != noPacketA)	dimPacketA = dimPacket;
	else						dimPacketA = dimLastPacketA;
	if (pack+1 != noPacketB)	dimPacketB = dimPacket;
	else						dimPacketB = dimLastPacketB;

	if (dimPacketA > dimPacketB)	dimPacketMAX = dimPacketA;
	else							dimPacketMAX = dimPacketB;
	printf("dimPacketMAX = %d\n",dimPacketMAX);
	int dimPacketMAXout = dimPacketA + dimPacketB;

	//FIRST PACKET
	//Ubicar el file pointer al inicio de las secuencias
	fseek(fseqA, posFirstEnterA+1, SEEK_SET);
	fseek(fseqB, posFirstEnterB+1, SEEK_SET);
	printf("TOKEN\n");
	//Pasar las secuencias A y B a variables
	if (dimSeqA > dimSeqB){
		fread(&(dataIn1),1,dimPacketA,fseqA);
		//fread(&(dataIn2)+offsetBand,1,(dimPacketB-offsetBand),fseqB);
		fread(&(dataIn2),1,(dimPacketB-offsetBand),fseqB);
	}else{
		//fread(&(dataIn1)+offsetBand,1,(dimPacketA-offsetBand),fseqA);
		fread(&(dataIn1),1,(dimPacketA-offsetBand),fseqA);
		fread(&(dataIn2),1,dimPacketB,fseqB);
	}
	printf("TOKEN\n");
	dataIn1[dimPacketA] = '\0';
	dataIn2[dimPacketB] = '\0';
		//printf("dataIn1 = %s\n",dataIn1);
		//printf("dataIn2 = %s\n",dataIn2);

	//Pasar las secuencias A, B y CSR a la OnChip Memory
	valuei = (unsigned int *)((int)hps_DATAin1);
	for (i=0; i<dimPacketMAX; i++) {
		if (dimSeqA > dimSeqB){
			if (i<dimPacketA)	seqA = ( (((unsigned int)dataIn1[i])<<24) );
				else seqA = 0;
			if (i>=offsetBand && i<dimPacketB)	seqB = ( (((unsigned int)dataIn2[i-offsetBand])<<16) );
				else seqB = 0;
		}else{
			if (i>=offsetBand && i<dimPacketA)	seqA = ( (((unsigned int)dataIn1[i-offsetBand])<<24) );
				else seqA = 0;
			if (i<dimPacketB)	seqB = ( (((unsigned int)dataIn2[i])<<16) );
				else seqB = 0;
		}
		seqControl = (csrLastPacket<<7);
		a = ( seqA | seqB | seqControl );
		valuei[i]  = a;
	}
	//END FIRST PACKET
	unsigned int obuffer[(2*dimPacketMAX)*NoRegsFila];//  output

		//printf("lastPairSeq = %x\n", a);
		//printf("lastPairSeq = %x\n", (int)valuei[i]);
		////////////////////////////////////////////////////////////////////////////////////////////
	for (pack=1; pack<=noPacket; pack++) {

		if (pack % 200 == 0){
			fclose(farrows);
			noFile++;
			sprintf(arrowFILEname, "%sp%d.bin", argv[4], noFile);
			printf("%s\n",arrowFILEname);
			farrows =	fopen(arrowFILEname,"wb");

		}
		//printf("tag0 \n");
		construct_standard_mm_to_st_descriptor(&descriptorIN1, (alt_u32 *) DMA_DATAin1, /**/dimPacketMAX * 4, DESCRIPTOR_CONTROL_GENERATE_SOP_MASK | DESCRIPTOR_CONTROL_GENERATE_EOP_MASK);
		write_standard_descriptor(KBANDINPUT_1_CSR_BASE, KBANDINPUT_1_DESCRIPTOR_SLAVE_BASE, &descriptorIN1);

		if ( ( noPacket == 1) ) {
			//Pasar las secuencias A, B y CSR a la OnChip Memory (CEROS)
			valuei = (unsigned int *)((int)hps_DATAin1);
			for (i=0; i<dimPacket; i++) 	valuei[i]  = 0;
			//enviar un paquete de ceros paquete para activar el IP (REVISAR EL offsetBand para un PACK )
			construct_standard_mm_to_st_descriptor(&descriptorIN1, (alt_u32 *) DMA_DATAin1, (latenciaKBand /*+ offsetBand*/) * 4, DESCRIPTOR_CONTROL_GENERATE_SOP_MASK | DESCRIPTOR_CONTROL_GENERATE_EOP_MASK);
			write_standard_descriptor(KBANDINPUT_1_CSR_BASE, KBANDINPUT_1_DESCRIPTOR_SLAVE_BASE, &descriptorIN1);

			construct_standard_mm_to_st_descriptor(&descriptorIN1, (alt_u32 *) DMA_DATAin1, dimPacket * 4, DESCRIPTOR_CONTROL_GENERATE_SOP_MASK | DESCRIPTOR_CONTROL_GENERATE_EOP_MASK);
			write_standard_descriptor(KBANDINPUT_1_CSR_BASE, KBANDINPUT_1_DESCRIPTOR_SLAVE_BASE, &descriptorIN1);
		}

		//Configurar y Enviar descriptores DMA output	- 	HAY QUE RESTARLE A ESTE PAQUETE Y AUMENTARLE AL PAQUETE FINAL
		if (pack == 2) { //primer paquete leido
			construct_standard_st_to_mm_descriptor(&descriptorOUT, (alt_u32 *) DMA_DATAout, /**/(dimPacketMAXout - offsetBand - latenciaKBand) *4*NoRegsFila, DESCRIPTOR_CONTROL_END_ON_EOP_MASK);
			write_standard_descriptor(KBANDOUTPUT_CSR_BASE, KBANDOUTPUT_DESCRIPTOR_SLAVE_BASE, &descriptorOUT);
		}
		if ( (noPacket == 1) ) { //solo un paquete o todos los paquetes menos el primero
			construct_standard_st_to_mm_descriptor(&descriptorOUT, (alt_u32 *) DMA_DATAout, /**/(dimPacketMAXout) *4*NoRegsFila, DESCRIPTOR_CONTROL_END_ON_EOP_MASK);
			write_standard_descriptor(KBANDOUTPUT_CSR_BASE, KBANDOUTPUT_DESCRIPTOR_SLAVE_BASE, &descriptorOUT);
		}
		if ( (pack > 2) ) { //solo un paquete o todos los paquetes menos el primero
			construct_standard_st_to_mm_descriptor(&descriptorOUT, (alt_u32 *) DMA_DATAout, /**/(2*dimPacketMAX) *4*NoRegsFila, DESCRIPTOR_CONTROL_END_ON_EOP_MASK);
			write_standard_descriptor(KBANDOUTPUT_CSR_BASE, KBANDOUTPUT_DESCRIPTOR_SLAVE_BASE, &descriptorOUT);
		}
		//printf("tag1 \n");

	// Conf para LastPacket
		if (pack+1 < noPacketA)		dimPacketA = dimPacket;
		if (pack+1 == noPacketA)	dimPacketA = dimLastPacketA;
		if (pack+1 > noPacketA)		dimPacketA = 0;
		if (pack+1 < noPacketB)		dimPacketB = dimPacket;
		if (pack+1 == noPacketB)	dimPacketB = dimLastPacketB;
		if (pack+1 > noPacketB)		dimPacketB = 0;
		//dimPacketMAXout = dimPacketA + dimPacketB;
	//Pasar las secuencias A y B a variables
		if (dimPacketA != 0) fread(&dataIn1,1,dimPacketA,fseqA);
		if (dimPacketB != 0) fread(&dataIn2,1,dimPacketB,fseqB);
		dataIn1[dimPacketA] = '\0';
		dataIn2[dimPacketB] = '\0';


		//printf("tag2 \n");


	//Packet Process Time = 500us
		if (pack >= 1)	{
			usleep( usPause );
			if ((unsigned int)read_csr_status(KBANDINPUT_1_CSR_BASE) != 2)
			printf("ERROR sgdma to fft sgdma status 0x%x ( should be 2)\n", (unsigned int)read_csr_status(KBANDINPUT_1_CSR_BASE));
		}

		if ((unsigned int)read_csr_status(KBANDOUTPUT_CSR_BASE) != 2)
			printf("ERROR sgdma from fft sgdma status 0x%x ( should be 2)\n", (unsigned int)read_csr_status(KBANDOUTPUT_CSR_BASE));
		else {
		// now read the results from memory
			if (pack == 2) {
				printf("Pack = %d, escribiendo en archivo %d filas\n", pack,(dimPacketMAXout - offsetBand - latenciaKBand) );
				for (i=0; i<(dimPacketMAXout - offsetBand - latenciaKBand)*NoRegsFila; i++) {
					obuffer[i] = valueo[i];
				}
				for (i=0; i<(dimPacketMAXout - offsetBand - latenciaKBand)*NoRegsFila; i++) {
					fwrite(&obuffer[i], sizeof(int), 1, farrows);
				}
			}
			if ( noPacket == 1 ) {
				printf("Pack = %d, write %d filas\n", pack, (dimPacketMAXout) );
				for (i=0; i<(dimPacketMAXout)*NoRegsFila; i++) {
					a = valueo[i];
					fwrite(&a, sizeof(int), 1, farrows);
				}
			}
			if ( pack > 2 ) {
				printf("Pack = %d, write %d filas\n", pack, (2*dimPacketMAX) );
				for (i=0; i<(2*dimPacketMAX)*NoRegsFila; i++) {
					a = valueo[i];
					fwrite(&a, sizeof(int), 1, farrows);
				}
			}
		}
		//printf("tag3 \n");


		//Pasar las secuencias A, B y CSR a la OnChip Memory
		if (dimPacketA > dimPacketB)	dimPacketMAX = dimPacketA;
		else							dimPacketMAX = dimPacketB;
		dimPacketMAXout = dimPacketA + dimPacketB;
		//printf("dimPacketMAX = %d\n",dimPacketMAX);
		//printf("csrLastPacket = %d\n",csrLastPacket);
		if (noPacket != pack) {
			for (i=0; i<dimPacketMAX; i++) {
				if (i<dimPacketA)	seqA = ( (((unsigned int)dataIn1[i])<<24) );
					else seqA = 0;
				if (i<dimPacketB)	seqB = ( (((unsigned int)dataIn2[i])<<16) );
					else seqB = 0;

				seqControl = (csrLastPacket<<7);
				a = ( seqA | seqB | seqControl );
				valuei[i]  = a;
			}
		}
		//printf("tag4 \n");

	}
	/////////////////////////////////////////////////////////////////////////////////////////////

	//Este paquete solo se envía si la secuencia está compuesta de multiples paquetes
	if (noPacket > 1) {

		//PAQUETE COMPLETO
		//Pasar las secuencias A, B y CSR a la OnChip Memory (CEROS)
		valuei = (unsigned int *)((int)hps_DATAin1);
		for (i=0; i<dimPacket; i++) 	valuei[i]  = 0;

		//enviar un paquete de ceros paquete para activar el IP
		construct_standard_mm_to_st_descriptor(&descriptorIN1, (alt_u32 *) DMA_DATAin1, (dimPacket) * 4, DESCRIPTOR_CONTROL_GENERATE_SOP_MASK | DESCRIPTOR_CONTROL_GENERATE_EOP_MASK);
		write_standard_descriptor(KBANDINPUT_1_CSR_BASE, KBANDINPUT_1_DESCRIPTOR_SLAVE_BASE, &descriptorIN1);

		construct_standard_st_to_mm_descriptor(&descriptorOUT, (alt_u32 *) DMA_DATAout, ( 2*dimPacket + offsetBand - diffSeqAB ) *4*NoRegsFila, DESCRIPTOR_CONTROL_END_ON_EOP_MASK);
		write_standard_descriptor(KBANDOUTPUT_CSR_BASE, KBANDOUTPUT_DESCRIPTOR_SLAVE_BASE, &descriptorOUT);
		//wait
		usleep(usPause);
		if ((unsigned int)read_csr_status(KBANDOUTPUT_CSR_BASE) != 2)
			printf("ERROR sgdma from fft sgdma status 0x%x ( should be 2)\n", (unsigned int)read_csr_status(KBANDOUTPUT_CSR_BASE));
		else {
			// read the results from memory
			printf("Pack = %d, escribiendo en archivo %d filas\n", pack, (2*dimPacket + offsetBand - diffSeqAB) );
			for (i=0; i<(2*dimPacket + offsetBand - diffSeqAB)*NoRegsFila; i++) {
				a = valueo[i];
				fwrite(&a, sizeof(int), 1, farrows);
			}
		}

		//PAQUETE DE LATENCIA
		//enviar un paquete de ceros paquete para activar el IP
		construct_standard_mm_to_st_descriptor(&descriptorIN1, (alt_u32 *) DMA_DATAin1, (latenciaKBand) * 4, DESCRIPTOR_CONTROL_GENERATE_SOP_MASK | DESCRIPTOR_CONTROL_GENERATE_EOP_MASK);
		write_standard_descriptor(KBANDINPUT_1_CSR_BASE, KBANDINPUT_1_DESCRIPTOR_SLAVE_BASE, &descriptorIN1);

		construct_standard_st_to_mm_descriptor(&descriptorOUT, (alt_u32 *) DMA_DATAout, (latenciaKBand) *4*NoRegsFila, DESCRIPTOR_CONTROL_END_ON_EOP_MASK);
		write_standard_descriptor(KBANDOUTPUT_CSR_BASE, KBANDOUTPUT_DESCRIPTOR_SLAVE_BASE, &descriptorOUT);
		//wait
		usleep(usPause);
		if ((unsigned int)read_csr_status(KBANDOUTPUT_CSR_BASE) != 2)
			printf("ERROR sgdma from fft sgdma status 0x%x ( should be 2)\n", (unsigned int)read_csr_status(KBANDOUTPUT_CSR_BASE));
		else {
			// read the results from memory
			printf("Pack = %d, escribiendo en archivo %d filas\n", pack, (latenciaKBand) );
			for (i=0; i<(latenciaKBand)*NoRegsFila; i++) {
				a = valueo[i];
				fwrite(&a, sizeof(int), 1, farrows);
			}
		}

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

	clock_t endT = clock();
	double timeSpent = (double)(beginT - endT)/ CLOCKS_BY_SEC;
	printf("timeSpent = %f \n", timeSpent );



	return 0;
}
