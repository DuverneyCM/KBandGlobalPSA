library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity PEadnModAffine is
	generic(
		dimH		: 	natural  :=	4;
		dimADN	:	natural  :=	3;
		dimLUT	:	natural  :=	3
	);
	port
	(
		-- Input ports (parameters)
		iMatch, iMisMatch, iOG, iEG	:	in std_logic_vector(dimLUT-1 downto 0);

		--	Input ports
		iADNa			:	in std_logic_vector(dimADN-1 downto 0);
		iADNb			:	in std_logic_vector(dimADN-1 downto 0);
		iHd			:	in std_logic_vector(dimH-1 downto 0);
		iHu			:	in std_logic_vector(dimH-1 downto 0);
		iHl			:	in std_logic_vector(dimH-1 downto 0);
		iADNFinish	:	in	std_logic;
		iDirGap		:	in	std_logic;
		iGapDiag		:	in std_logic_vector(dimH-1 downto 0);
		iGapUp		:	in std_logic_vector(dimH-1 downto 0);
		iGapLeft		:	in std_logic_vector(dimH-1 downto 0);
		iGedge		:	in std_logic_vector(dimH-1 downto 0);

		-- Output ports
		oGap			:	out std_logic_vector(dimH-1 downto 0);
		oDirGap		:	out	std_logic;
		oADNa			:	out std_logic_vector(dimADN-1 downto 0);
		oADNb			:	out std_logic_vector(dimADN-1 downto 0);
		oHGDiagEqual	:	out std_logic;
		oValid		:	out std_logic;
		oH				:	out std_logic_vector(dimH-1 downto 0);
		oArrow		:	out std_logic_vector(1 downto 0)
	);
end PEadnModAffine;


architecture rtl of PEadnModAffine is
	constant	W										:	std_logic_vector(dimADN-1 downto 0)	:=	std_logic_vector(to_unsigned(2,dimADN));
	signal	LUTadn								:	std_logic_vector(dimLUT-1 downto 0);
	signal 	addressT								:	std_logic_vector(2*dimADN-1 downto 0);
	signal	ORiADN, ANDauxA, ANDauxB		:	std_logic_vector(dimADN-1 downto 0);
	signal	Hdiag, Hup, Hleft, HdiagScore	:	std_logic_vector(dimH-1 downto 0);
	signal	HGdiag,  HGdiagScore, sGedge	:	std_logic_vector(dimH-1 downto 0);
	signal	funcionDiag, funcionUp, funcionLeft	:	std_logic_vector(dimH-1 downto 0);
	signal	mayorHUL, mayorT, Htotal 	:	std_logic_vector(dimH-1 downto 0);
	signal	mayorOG, mayorEG, mayorGapUL, mayorGapTotal	:	std_logic_vector(dimH-1 downto 0);
	signal	Resta1, Resta2, Resta3, Resta4	:	std_logic_vector(dimH-1 downto 0);
	signal	orADN, andADN, datoInvalidoAux	:	std_logic;
	signal	C	:	std_logic_vector(2 downto 0);
	signal	MSb	:	std_logic_vector(4 downto 1);
	signal	sHGDiagEqual	:	std_logic;

begin
	--puentes
	oADNa	<=	iADNa;
	oADNb	<=	iADNb;

	--Mapeo distinto (100, 101, 110, 111, 011)
	--ADN 5 simbolos, 3 bits por simbolo, 3 bits por peso:		LUT DE PESOS
	addressT	<=	iADNa & iADNb;
	with addressT select
	LUTadn	<= iMatch 		when "100100",	--		match = 3
					iMisMatch	when "100101",	--		missmatch = -1
					iMisMatch	when "100110",
					iMisMatch	when "100111",
					iMisMatch	when "100011",

					iMisMatch	when "101100",
					iMatch		when "101101",
					iMisMatch	when "101110",
					iMisMatch	when "101111",
					iMisMatch	when "101011",

					iMisMatch	when "110100",
					iMisMatch	when "110101",
					iMatch		when "110110",
					iMisMatch	when "110111",
					iMisMatch	when "110011",

					iMisMatch	when "111100",
					iMisMatch 	when "111101",
					iMisMatch 	when "111110",
					iMatch 		when "111111",
					iMisMatch 	when "111011",

					iMisMatch 	when "011100",
					iMisMatch 	when "011101",
					iMisMatch 	when "011110",
					iMisMatch 	when "011111",
					iMatch 		when "011011",
					(others => '0') when others;

	--detecta si hay elementos de secuencia para alinear. Datos invalidos se indica con 0
	--orADN	<=	'0' when LUTadn = (LUTadn'range => '0') else '1';
	orADN	<=	'0' when iADNa = (iADNa'range => '0') or iADNb = (iADNb'range => '0') else '1';
	datoInvalidoAux	<=	sHGDiagEqual;--orADN;
	oValid	<=	orADN;--datoInvalidoAux;
	--Señales de entrada
	Hdiag	<=	iHd;
	Hup	<=	iHu;
	Hleft	<=	iHl;


	--Comparaciones
	Resta1	<=	Hup - Hleft;
	MSb(1)	<=	Resta1(dimH-1);
	mayorHUL	<=	Hup when MSb(1) = '0' else Hleft;
	mayorOG	<= mayorHUL - iOG;

	Resta2	<=	iGapUp - iGapLeft;
	MSb(2)	<=	Resta2(dimH-1);	--0:up	1:left
	mayorGapUL	<=	iGapUp when MSb(2) = '0' else iGapLeft;
	mayorEG	<= mayorGapUL - iEG;

	Resta3	<=	mayorOG - mayorEG;	--0:ex	1:op
	MSb(3)	<=	Resta3(dimH-1);
	mayorGapTotal	<=	mayorOG when MSb(3) = '0' else mayorEG;	--value
	--Gap Output
	sGedge	<=	mayorGapTotal;
	oGap	<=	mayorGapTotal;
	oDirGap	<=	MSb(1) when MSb(3) = '0' else MSb(2);		--direction

	--Resta4	<=	HdiagScore - mayorGapTotal;--iGapDiag;
	Resta4	<=	Hdiag - iGapDiag	;--iGapDiag;
	MSb(4)	<=	Resta4(dimH-1);
	HGdiag	<=	Hdiag when MSb(4) = '0' else iGapDiag;
	sHGDiagEqual	<=	'1' when Hdiag = iGapDiag or orADN = '0' else '0';
	oHGDiagEqual	<=	sHGDiagEqual;
	
	--Apply score function
	HGdiagScore	<=	HGdiag + ( (dimH-1 downto dimLUT => LUTadn(dimLUT-1)) & LUTadn );

	--edge effect NW (-w, -2w, -3w ...)
	mayorT	<=	HGdiagScore when (orADN = '1')  else sGedge; --datoInvalidoAux

	--Filtering invalid data
	oH			<=	mayorT;--mayorT when iADNFinish = '0' else (others => '0');

	--Arrows
	oArrow	<=	"00" when datoInvalidoAux = '0' else
					"11" when MSb(4) ='0' else
					"01" when iDirGap = '0' else
					"10" when iDirGap = '1';


end rtl;
