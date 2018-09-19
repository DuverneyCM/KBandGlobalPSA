library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity KbandPairwiseInCtrlLogic is
	port(
		-- clk and reset interface
		clk, reset													:	in		std_logic;
		--Streamming Sink Interface
		din_startOfPacket, din_endOfPacket		:	in		std_logic;
		din_Ready													:	out	std_logic;
		din_Valid														:	in		std_logic;
		din_Data														:	in		std_logic_vector(8 downto 1);
		--interLogic Ports
		iWait, iKBandEndProcess								:	in		std_logic;
		oADNh, oADNv											:	out	std_logic_vector(2 downto 0);
		oADNen, oDirection									:	out	std_logic
		
	);
end KbandPairwiseInCtrlLogic;

architecture rtl of KbandPairwiseInCtrlLogic  is
COMPONENT FifoKBandIN IS
	PORT
	(
		aclr		: IN STD_LOGIC ;
		clock		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdreq		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		empty		: OUT STD_LOGIC ;
		full		: OUT STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		usedw		: OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
	);
END COMPONENT;

type state_type is (s0, s1, s2, s3);
signal state   : state_type;

signal	sDinData, sFifoDataOut, shReg	:	std_logic_vector(8 downto 1);
signal	sFifoCount	:	std_logic_vector(6 downto 0);
signal	sFifoRead, sFifoWrite, sFifoEmpty, sFifoFull, ssFifoEmpty	:	std_logic;
signal	sLoadShReg, shr	:	std_logic;
signal	cnt	:	std_logic_vector(3 downto 0);
signal	adquirir, procesar	:	std_logic;

begin
	uFIFOin	:	FifoKBandIN
	port map(
		aclr			=>	reset,
		clock		=>	clk,
		data		=>	sDinData,
		rdreq		=>	sFifoRead,
		wrreq		=>	sFifoWrite,
		empty		=>	sFifoEmpty,
		full			=>	sFifoFull,
		q				=>	sFifoDataOut,
		usedw		=>	sFifoCount
	);
	
	--Shift Register
--	process(reset, clk) is 
--	begin 
--		if(reset = '1') then
--			shReg		<= (others => '0');
--		elsif(rising_edge(clk)) then
--			if (iWait = '0') then
--				if (sLoadShReg = '1') then
--					shReg		<= sFifoDataOut;
--				elsif (shr = '1') then
--					shReg		<= "00000000" & shReg(32 downto 9);
--				end if;
--			end if;
--		end if;
--	end process;
	
	--Counter Control ShReg
	process(reset, clk) is 
	begin 
		if(reset = '1') then
			cnt		<= (others => '0');
		elsif(rising_edge(clk)) then
			if (iWait = '0') then
				if (sLoadShReg = '1' ) then
					cnt	<= "0000";
				elsif (cnt(3) = '0') then -- or adquirir = '0'
					cnt	<= cnt + 1;
				end if;
			end if;
		end if;
	end process;
	
	--Retardos
	process(reset, clk) is 
	begin 
		if(reset = '1') then
			sLoadShReg	<= '0';
			ssFifoEmpty	<= '0';
			sDinData		<=	(others => '0');
		elsif(rising_edge(clk)) then
			if (iWait = '0') then
				sLoadShReg	<=	sFifoRead;
				ssFifoEmpty	<=	sFifoEmpty;
			end if;
			sDinData		<=	din_Data;
		end if;
	end process;
	
	--logica de estados para controlar la salida habilitada
	process (clk, reset)
	begin
		if reset = '1' then
			state <= s0;
		elsif (rising_edge(clk)) then
			case state is
				when s0=>
					if din_startOfPacket = '1' then
						state <= s1;
					else
						state <= s0;
					end if;
				when s1=>
					if din_endOfPacket = '1' then
						state <= s2;
					else
						state <= s1;
					end if;
				when s2 =>
					if iKBandEndProcess = '0' then
						state <= s3;
					else
						state <= s2;
					end if;
				when s3 =>
					if iKBandEndProcess = '1' then
						state <= s0;
					else
						state <= s3;
					end if;
			end case;
		end if;
	end process;
	--Logica de salida
	process (state)
	begin
		case state is
			when s0 =>
				adquirir	<=	'1';
				procesar	<=	'0';
			when s1 =>
				adquirir	<=	'1';
				procesar <=	'1';
			when s2 =>
				adquirir	<=	'0';
				procesar <= 	'1';
			when s3 =>
				adquirir	<=	'0';
				procesar <= 	'1';
		end case;
	end process;
	
	--Se toman datos del FIFO cuando no esté vacio y se deban cargar datos en el ShiftReg
	sFifoRead	<=	'1' when (cnt >= 6 and (sFifoEmpty = '0'  or adquirir = '0') and sLoadShReg = '0') else '0'; -- or iKBandEndProcess = '0' 

	--Se desplazan los datos en el registro de desplazamiento luego de que se lean los dos datos, 2 ciclos de reloj
	shr <= '1' when cnt(0) = '1' else '0';
	--Datos de las bases. Deben permanecer constantes por al menos 2 ciclos de reloj
	oADNh		<=	shReg(3 downto 1);
	oADNv		<=	shReg(7 downto 5);
	--Indica cual de las bases debe ser cargada en el sistolico
	oDirection	<=	cnt(0);
	--Indica que el FIFO está listo para almacenar más datos
	din_Ready	<=	not sFifoFull and adquirir;
	sFifoWrite	<=	din_Valid and not sFifoFull;
	oADNen		<=	(not cnt(3) and procesar) and (not iWait);
end rtl;