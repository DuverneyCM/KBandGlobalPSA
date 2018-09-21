library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity KbandPairwiseOutCtrlLogic is
	port(
		-- clk and reset interface
		clk, reset															:	in		std_logic;
		--Streamming Source Interface
		dout_startOfPacket, dout_endOfPacket		:	out	std_logic;
		dout_Ready														:	in		std_logic;
		dout_Valid															:	out	std_logic;
		dout_Data															:	out	std_logic_vector(32 downto 1);	
		--interLogic Ports
		iADNen, iADNfinish											:	in	std_logic;
		oFIFOfull															:	out	std_logic;
		iArrows																:	in	std_logic_vector(2*64 downto 1);
		iFlag																	:	in	std_logic
	);
end KbandPairwiseOutCtrlLogic;

architecture rtl of KbandPairwiseOutCtrlLogic  is
component FifoKBandOUT IS
	PORT(
		aclr		: IN STD_LOGIC  := '0';
		data		: IN STD_LOGIC_VECTOR (127 DOWNTO 0);
		rdclk		: IN STD_LOGIC ;
		rdreq		: IN STD_LOGIC ;
		wrclk		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		rdempty		: OUT STD_LOGIC ;
		wrfull		: OUT STD_LOGIC 
	);
END component;

signal	sFifoDataIn, shReg	:	std_logic_vector(128 downto 1);
signal	sFifoCount	:	std_logic_vector(6 downto 0);
signal	sFifoRead, sFifoWrite, sFifoEmpty, sFifoFull	:	std_logic;
signal	sLoadShReg, shr	:	std_logic;
signal	cnt	:	std_logic_vector(3 downto 0);
signal	sStartOfPacket, sEndOfPacket	:	std_logic;

	type state_type is (s0, s1, s2, s3);
	signal state   : state_type;
	
begin
	sFifoDataIn	<=	iArrows;
	sFIfoRead		<=	dout_Ready and not sFifoEmpty;
	sFifoWrite		<=	iADNen and not sFifoFull;
	oFIFOfull		<=	sFifoFull;
	sStartOfPacket		<=	not sFifoEmpty;
	sEndOfPacket		<=	(iADNfinish and sFifoEmpty);
	
		--logica de estados para controlar la salida habilitada
	process (clk, reset)
	begin
		if reset = '1' then
			state <= s0;
		elsif (rising_edge(clk)) then
			case state is
				when s0=>
					if sStartOfPacket = '1' then
						state <= s1;
					else
						state <= s0;
					end if;
				when s1=>
						state <= s2;
				when s2=>
					if sEndOfPacket = '1' then
						state <= s3;
					else
						state <= s2;
					end if;
				when s3 =>
					state <= s0;
			end case;
		end if;
	end process;
	--Logica de salida
	process (state)
	begin
		case state is
			when s0 =>
				dout_startOfPacket	<=	'0';
				dout_endOfPacket	<=	'0';
			when s1 =>
				dout_startOfPacket	<=	'1';
				dout_endOfPacket	<=	'0';
			when s2 =>
				dout_startOfPacket	<=	'0';
				dout_endOfPacket	<=	'0';
			when s3 =>
				dout_startOfPacket	<=	'0';
				dout_endOfPacket	<=	'1';
		end case;
	end process;
	
		--Retardos
	process(reset, clk) is 
	begin 
		if(reset = '1') then
			dout_Valid	<= '0';
		elsif(rising_edge(clk)) then
			dout_Valid	<=	sFifoRead;
		end if;
	end process;
	
	uFIFOout	:	FifoKBandOUT
	port map(
		aclr			=>	reset,
		data		=>	sFifoDataIn,
		rdclk		=>	clk,
		rdreq		=>	sFifoRead,
		wrclk		=>	clk,
		wrreq		=>	sFifoWrite,
		q				=>	dout_Data,
		rdempty	=>	sFifoEmpty,
		wrfull		=>	sFifoFull
	);
end rtl;