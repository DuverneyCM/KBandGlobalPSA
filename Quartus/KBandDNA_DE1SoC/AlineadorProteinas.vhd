library IEEE;
use work.Proteinas_pck.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;

entity AlineadorProteinas is
	generic(
		dimH		: 	natural  :=	8;
		NoCell	: 	natural  :=	8
	);
	port
	(
		-- Input ports
		CLOCK_50		:	in	std_logic;
		reset			:	in std_logic;
		inAminoH		:	in std_logic_vector(dimAmino-1 downto 0);
		inAminoV		:	in std_logic_vector(dimAmino-1 downto 0);
		inHdiag		:	in std_logic_vector(dimH-1 downto 0);
		inHup			:	in std_logic_vector(dimH-1 downto 0);
		inHleft		:	in std_logic_vector(dimH-1 downto 0);

		-- Output ports
		outH				:	out std_logic_vector(dimH-1 downto 0);
		outDireccion	:	out std_logic_vector(1 downto 0)
	);
end AlineadorProteinas;


architecture rtl of AlineadorProteinas is
	--MATRIZ PAM70 de aminoacidos
	component MatrizSustitucion IS
		PORT(
			address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
			clock		: IN STD_LOGIC  := '1';
			q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
		);
	END component;

	signal	S	:	std_logic_vector(7 downto 0);
	signal	Hdiag, Hup, Hleft	:	std_logic_vector(dimH-1 downto 0);
	signal	HdiagAux, HupAux, HleftAux	:	std_logic_vector(dimH-1 downto 0);
	signal	funcionDiag, funcionUp, funcionLeft,
				resta0, resta1, mayorAux, mayorT:	std_logic_vector(dimH downto 0);
	signal	addressS, andS		:	std_logic_vector(dimAmino-1 downto 0);
	signal	addressAux	:	std_logic_vector(2*dimAmino-1 downto 0);
	signal	Cout0, Cout1, datoInvalido, datoInvalidoAux, datoInvalidoAux2	:	std_logic;
	signal	and_amino, and_aminoAux		:	std_logic;
	signal	W	:	std_logic_vector(NoCell-1 downto 0)	:=	std_logic_vector(to_unsigned(2,NoCell));
	

begin
	--AND anidada
	and_aminoAux	<=	inAminoH(dimAmino-1) or inAminoV(dimAmino-1);
	and_amino	<=	and_aminoAux;
	andS	<=	(others => and_amino);
	--datoInvalido	<=	and_amino;
	
	--addressS	<=	std_logic_vector(to_unsigned(inAminoH*NoAmino, dimAmino));
	addressAux	<=	inAminoH*std_logic_vector(to_unsigned(NoAmino,dimAmino));--(a-1)*23 + (b-1) -- linea no escalable
	addressS		<=	(addressAux(dimAmino-1 downto 0) + inAminoV) or andS;
	u_MatrizS:	MatrizSustitucion
	port map(
		address	=>	addressS,
		clock		=>	CLOCK_50,
		q			=>	S			
	);
	
	--asignacion de las entradas a las señales
	process(reset, CLOCK_50) is 
	begin 
		if(reset = '1') then
			datoInvalido	<=	'0';
			--datoInvalidoAux	<=	'0';
			--datoInvalidoAux2	<=	'0';
			--and_amino		<=	'0';
		elsif(rising_edge(CLOCK_50)) then
			datoInvalido	<=	and_amino;
			--datoInvalidoAux2	<=	datoInvalido;
			--datoInvalidoAux	<=	datoInvalidoAux2;
			--and_amino	<=	and_aminoAux;
		end if;
	end process;
	Hdiag	<=	inHdiag;
	Hup	<=	inHup;
	Hleft	<=	inHleft;
	--datoInvalido	<=	inAminoH(dimAmino-1) or inAminoV(dimAmino-1);
	
	--funcion de decisión
	funcionUp		<=	("0"& Hup) - ("0"& W);
	funcionLeft		<=	("0"& Hleft) - ("0"& W);
	funcionDiag		<=	("0"& Hdiag) + S;
	
	--Comparaciones mediante restas
	Resta1	<=	("0"& funcionDiag(dimH-1 downto 0)) - ("0"& funcionUp(dimH-1 downto 0));
	Cout1		<=	Resta1(7);
	mayorAux	<= funcionDiag when Cout1 = '0' else
					funcionUp;
					
	Resta0	<=	("0"& mayorAux(dimH-1 downto 0)) - ("0"& funcionLeft(dimH-1 downto 0));
	Cout0		<=	Resta0(7);
	mayorT	<= mayorAux when Cout0 = '0' else
					funcionLeft;
	
	--asignacion de resultados a las salidas
			datoInvalidoAux	<=	datoInvalido;
			outH					<=	mayorT(7 downto 0);--funcionLeft(7 downto 0);--mayorT(7 downto 0);--
			outDireccion(0)	<= (Cout1 and not(Cout0)) OR ( datoInvalidoAux );
			outDireccion(1)	<= Cout0 OR ( datoInvalidoAux );
	
end rtl;
