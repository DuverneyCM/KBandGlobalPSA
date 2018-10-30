library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity PEadnMod is
	generic(
		dimH		: 	natural  :=	4;
		dimADN	:	natural  :=	3;
		dimLUT	:	natural  :=	3
	);
	port
	(
		-- Input ports (parameters)
		iMatch, iMisMatch, iW	:	in std_logic_vector(dimLUT-1 downto 0);

		--	Input ports

		iADNa			:	in std_logic_vector(dimADN-1 downto 0);
		iADNb			:	in std_logic_vector(dimADN-1 downto 0);
		iH1			:	in std_logic_vector(dimH-1 downto 0);
		iHd			:	in std_logic_vector(dimH-1 downto 0);
		iHu			:	in std_logic_vector(dimH-1 downto 0);
		iHl			:	in std_logic_vector(dimH-1 downto 0);
		iADNFinish	:	in	std_logic;

		-- Output ports
		oADNa			:	out std_logic_vector(dimADN-1 downto 0);
		oADNb			:	out std_logic_vector(dimADN-1 downto 0);
		oHGDiagEqual	:	out std_logic;
		oValid		:	out std_logic;
		oH				:	out std_logic_vector(dimH-1 downto 0);
		oArrow		:	out std_logic_vector(1 downto 0)
	);
end PEadnMod;


architecture rtl of PEadnMod is
	constant	W										:	std_logic_vector(dimADN-1 downto 0)	:=	std_logic_vector(to_unsigned(2,dimADN));
	signal	LUTadn								:	std_logic_vector(dimLUT-1 downto 0);
	signal 	addressT								:	std_logic_vector(2*dimADN-1 downto 0);
	signal	ORiADN, ANDauxA, ANDauxB		:	std_logic_vector(dimADN-1 downto 0);
	signal	Hdiag, Hup, Hleft					:	std_logic_vector(dimH-1 downto 0);
	signal	funcionDiag, funcionUp, funcionLeft	:	std_logic_vector(dimH-1 downto 0);
	signal	mayorUL, mayorDUL, mayorT, sHinvalid	:	std_logic_vector(dimH-1 downto 0);
	signal	Resta1, Resta2		:	std_logic_vector(dimH-1 downto 0);
	signal	orADN, andADN, datoInvalidoAux	:	std_logic;
	signal	C	:	std_logic_vector(2 downto 0);
	signal	LessThan	:	std_logic_vector(2 downto 1);
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
					"0000" when others;

	--detecta si hay elementos de secuencia para alinear. Datos invalidos se indica con 0
	--orADN	<=	LUTadn(3) or LUTadn(2) or LUTadn(1) or LUTadn(0);
	--orADN	<=	'0' when LUTadn = (LUTadn'range => '0') else '1';
	orADN	<=	'0' when iADNa = (iADNa'range => '0') or iADNb = (iADNb'range => '0') else '1';
	--datoInvalidoAux	<=	orADN;
	datoInvalidoAux	<=	'0' when sHGDiagEqual='1' or orADN='0' else '1';
	oValid	<=	orADN;--datoInvalidoAux;

	--Señales de entrada
	Hdiag	<=	iHd;
	Hup	<=	iHu;
	Hleft	<=	iHl;

	--funcion de decisión
	funcionDiag		<=	Hdiag + ( (dimH-1 downto dimLUT => LUTadn(dimLUT-1)) & LUTadn );

	--Comparaciones
	Resta1	<=	Hup - Hleft;
	LessThan(1)	<=	Resta1(dimH-1);
	mayorUL	<=	Hup when LessThan(1) = '0' else Hleft;
	Resta2	<=	funcionDiag - mayorUL;
	LessThan(2)	<=	Resta2(dimH-1);
	mayorDUL	<=	funcionDiag when LessThan(2) = '0' else mayorUL;
	sHGDiagEqual	<=	'1' when funcionDiag = mayorUL else '0';
	oHGDiagEqual	<=	sHGDiagEqual; --not datoInvalidoAux;--

	--efecto de borde NW (-w, -2w, -3w ...)
	mayorT		<=	mayorDUL when	(orADN = '1') else iH1;	--(others => '0');
	sHinvalid	<=	mayorT - iW;
	--salida valida
	oH				<=	sHinvalid;-- when iADNFinish = '0' else (others => '0');
	--Flechas
	--oArrow(0)	<= ( not LessThan(2) or LessThan(1) )	and ( datoInvalidoAux );
	--oArrow(1)	<= ( not LessThan(2) or not LessThan(1) )	and ( datoInvalidoAux );
	oArrow	<=	"00" when orADN = '0' else --datoInvalidoAux = '0' else
					"11" when LessThan(2) ='0' else
					"01" when LessThan(1) = '1' else
					"10" when LessThan(1) = '0';

end rtl;
