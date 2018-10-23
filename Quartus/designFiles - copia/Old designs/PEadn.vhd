library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;

entity PEadn is
	generic(
		dimH		: 	natural  :=	8;
		dimADN	:	natural  :=	3
	);
	port
	(	
		-- Input ports (parameters)
		iMatch, iMisMatch, iW	:	in std_logic_vector(3 downto 0);
		-- Input ports
		CLOCK_50		:	in	std_logic;
		reset			:	in std_logic;
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
		oH				:	out std_logic_vector(dimH-1 downto 0);
		oArrow		:	out std_logic_vector(1 downto 0)
	);
end PEadn;


architecture rtl of PEadn is
	constant	W										:	std_logic_vector(dimADN-1 downto 0)	:=	std_logic_vector(to_unsigned(2,dimADN));
	signal	LUTadn								:	std_logic_vector(2 downto 0);
	signal 	addressT								:	std_logic_vector(2*dimADN-1 downto 0);
	signal	ORiADN, ANDauxA, ANDauxB		:	std_logic_vector(dimADN-1 downto 0);
	signal	Hdiag, Hup, Hleft					:	std_logic_vector(dimH-1 downto 0);
	signal	funcionDiag, funcionUp, funcionLeft	:	std_logic_vector(dimH-1 downto 0);
	signal	mayorT, mayorAux, sHinvalid	:	std_logic_vector(dimH-1 downto 0);
	signal	Resta1, Resta0		:	std_logic_vector(dimH-1 downto 0);
	signal	andADN, datoInvalidoAux	:	std_logic;
	signal	C	:	std_logic_vector(2 downto 0);
	
begin
	--puentes
	oADNa	<=	iADNa;
	oADNb	<=	iADNb;
	
	--Mapeo distinto (100, 101, 110, 111, 011)
	--ADN 5 simbolos, 3 bits por simbolo, 3 bits por peso:		LUT DE PESOS
	addressT	<=	iADNa & iADNb;
	with addressT select
	LUTadn	<= "011" when "100100",	--		match = 3	
					"111" when "100101",	--		missmatch = -1
					"111" when "100110",
					"111" when "100111",
					"111" when "100011",
					
					"111" when "101100",
					"011" when "101101",
					"111" when "101110",
					"111" when "101111",
					"111" when "101011",
					
					"111" when "110100",
					"111" when "110101",
					"011" when "110110",
					"111" when "110111",
					"111" when "110011",
					
					"111" when "111100",
					"111" when "111101",
					"111" when "111110",
					"011" when "111111",
					"111" when "111011",
					
					"111" when "011100",
					"111" when "011101",
					"111" when "011110",
					"111" when "011111",
					"011" when "011011",
					"000" when others;
				
		
	--detecta si hay elementos de secuencia para alinear. Datos invalidos se indica con 1
--	ORiADN		<= iADNa or iADNb;
--	ANDaux(0)	<=	ORiADN(0);
--	ANDbit:
--	for i in 1 to dimADN-1 generate
--		ANDaux(i)	<=	ANDaux(i-1) and ORiADN(i);
--	end generate;
--	andADN <= ANDaux(dimADN-1);
	
	ANDauxA(0)	<=	not iADNa(0);
	ANDauxB(0)	<=	not iADNb(0);
	ANDbit:
	for i in 1 to dimADN-1 generate
		ANDauxA(i)	<=	ANDauxA(i-1) and not iADNa(i);
		ANDauxB(i)	<=	ANDauxB(i-1) and not iADNb(i);
	end generate;
	andADN <= ANDauxA(dimADN-1) or ANDauxB(dimADN-1); -- 1 = dato invalido
	
	--Señales de entrada
	Hdiag	<=	iHd;
	Hup	<=	iHu;
	Hleft	<=	iHl;
	--funcion de decisión
	funcionUp		<=	Hup - W; --porque concatenar el 0? no se úede restar y ya?
	funcionLeft		<=	Hleft - W;
	funcionDiag		<=	Hdiag + ( (dimH-1 downto 3 => LUTadn(2)) & LUTadn );
	--Comparaciones
	c3	:	C(2)	<=	'1' when funcionDiag >= funcionUp	else '0';
	c2	:	C(1)	<=	'1' when funcionDiag >= funcionLeft else '0';
	c1	:	C(0)	<=	'1' when funcionUp	>= funcionLeft else '0';
	
	with C select
	mayorT	<=	funcionLeft	when	"000",	
					funcionUp	when	"001",	
					--funcionDiag	when	"010",		--combinacion imposible
					funcionUp	when	"011",	
					funcionLeft	when	"100",	
					--funcionLeft	when	"101",		--combinacion imposible
					funcionDiag	when	"110",
					funcionDiag	when	"111",
					funcionDiag when	others;
	
--	arrow(1)
--	000	0
--	100	4
--	110	6
--	111	7
--	
--	arrow(0)
--	001	1
--	011	3
--	110	6
--	111	7
	
	--c2	:	C(1)	<=	'0' when funcionDiag >= funcionUp else '1';
	--Resta1	<=	("0"&funcionDiag) - ("0"&funcionUp); C(1)	<=	Resta1(dimH-1);
	--Resta1	<=	funcionUp - funcionDiag;	C(1)	<=	not(Resta1(dimH-1));
	--mayorAux	<= funcionDiag when C(1) = '0' else	funcionUp;
	--c1	:	C(0)	<=	'0' when mayorAux >= funcionLeft else '1';
	--Resta0	<=	("0"&mayorAux) - ("0"&funcionLeft);	C(0)	<=	Resta0(dimH-1) ;
	--Resta0	<=	funcionLeft - mayorAux;	C(0)	<=	not(Resta0(dimH-1));
	--mayorT	<= mayorAux when C(0) = '0' else funcionLeft;
	--asignacion de resultados a las salidas
	
--	with C select
--	MayorT	<= funcionLeft	when "00", -- left = 10
--					funcionUp	when "01", -- up   = 01
--					funcionDiag	when "10", -- diag = 11
--					funcionDiag	when "11"; -- diag = 11
		
	datoInvalidoAux	<=	not(andADN);
	oH						<=	sHinvalid when iADNFinish = '0' else (others => '0');
	sHinvalid			<=	mayorT when	datoInvalidoAux = '1' else iH1 - W;--(others => '0');
	--funcionLeft(7 downto 0);--mayorT(7 downto 0);--
	--oArrow.
	oArrow(1)	<= ( C(0) 		or C(1) )	and ( datoInvalidoAux );
	oArrow(0)	<= ( not(C(0))	or C(2) )	and ( datoInvalidoAux );
	
	--oArrow(0)	<= 			 	not(C(0))	and ( datoInvalidoAux );
	--oArrow(1)	<= ( not(C(1)) or (C(0)) ) and ( datoInvalidoAux );	
	--oArrow(0)	<= ( (C(1)) xnor (C(0)) )	and ( datoInvalidoAux );
	--oArrow(1)	<= ( (C(1)) nand (C(0)) ) and ( datoInvalidoAux );

end rtl;


--	LUTadn	<= "000" when address = "000000" else
--					"000" when address = "000001" else
--					"000" when address = "000010" else
--					"000" when address = "000011" else
--					"000" when address = "000100" else
--					
--					"000" when address = "001000" else
--					"000" when address = "001001" else
--					"000" when address = "001010" else
--					"000" when address = "001011" else
--					"000" when address = "001100" else
--					
--					"000" when address = "010000" else
--					"000" when address = "010001" else
--					"000" when address = "010010" else
--					"000" when address = "010011" else
--					"000" when address = "010100" else
--					
--					"000" when address = "011000" else
--					"000" when address = "011001" else
--					"000" when address = "011010" else
--					"000" when address = "011011" else
--					"000" when address = "011100" else
--					
--					"000" when address = "100000" else
--					"000" when address = "100001" else
--					"000" when address = "100010" else
--					"000" when address = "100011" else
--					"000" when address = "100100" else

--	LUTadn	<= "011" when "000000",	--		match = 3	
--					"111" when "000001",	--		missmatch = -1
--					"111" when "000010",
--					"111" when "000011",
--					"111" when "000100",
--					
--					"111" when "001000",
--					"011" when "001001",
--					"111" when "001010",
--					"111" when "001011",
--					"111" when "001100",
--					
--					"111" when "010000",
--					"111" when "010001",
--					"011" when "010010",
--					"111" when "010011",
--					"111" when "010100",
--					
--					"111" when "011000",
--					"111" when "011001",
--					"111" when "011010",
--					"011" when "011011",
--					"111" when "011100",
--					
--					"111" when "100000",
--					"111" when "100001",
--					"111" when "100010",
--					"111" when "100011",
--					"011" when "100100",
--					"111" when others;