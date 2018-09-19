-- new_component.vhd

-- This file was auto-generated as a prototype implementation of a module
-- created in component editor.  It ties off all outputs to ground and
-- ignores all inputs.  It needs to be edited to make it do something
-- useful.
-- 
-- This file will not be automatically regenerated.  You should check it in
-- to your version control system if you want to keep it.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY KBandIP21 is
	generic(
		NoCell		: 	natural  :=	32;
		dimH			: 	natural  :=	8;
		dimSymbol	:	natural	:=	32;
		dimADN		: 	natural  :=	3;
		bitsOUT		:	natural	:=	64; --Source data width
		widthu		:	natural	:=	6 --2**w = #regs
	);
	port (
		clock_ext    : in  std_logic  := '0';             --  clock.clk
		clock_int    : in  std_logic  := '0';             --  clock.clk
		reset_reset  : in  std_logic  := '0';             --  reset.reset
		-- Qsys sink 1 y 2
		iADN1_data   : in  std_logic_vector(dimSymbol-1 downto 0)	:= (others => '0'); --  iADN1.data
		oADN1_ready  : out std_logic;                                        --       .ready
		iADN1_valid  : in  std_logic	:= '0';             --       .valid
		--iADN2_data   : in  std_logic_vector(dimSymbol-1 downto 0)	:= (others => '0'); --  iADN2.data
		--oADN2_ready  : out std_logic;                                        --       .ready
		--iADN2_valid  : in  std_logic  := '0';             --       .valid
		-- Qsys source
		oArrow_data  : out std_logic_vector(bitsOUT-1 downto 0);                    -- oArrow.data
		iArrow_ready : in  std_logic  := '0';             --       .ready
		oArrow_valid : out std_logic;                                         --       .valid
		--pruebas
		oADN1, oADN2	:	out std_logic_vector(dimADN-1 downto 0);
		oDirection		:	out std_logic
		
	);
END ENTITY KBandIP21;

ARCHITECTURE rtl OF KBandIP21 IS

	signal	sADN1, sADN2			:	std_logic_vector(dimADN downto 1);
	signal	sDirection, sProcesar:	std_logic;
	signal	sADNfinish, sADNvalid, sflag	:	std_logic;
	signal	sArrows					:	std_logic_vector(2*NoCell-1 downto 0);
	signal	sFIFOfullKBsrc			:	std_logic;
	signal	sArrow_data  			:	std_logic_vector(bitsOUT-1 downto 0);
	
	signal	sArrow_valid			: std_logic;
	signal	sSink1Empty, sFinalPacket	: std_logic; --sFinalPacket ¿De donde saco esta señal?
	signal	sSourceEmpty			: std_logic;
	signal	sSinkRead, sSourceWrite		: std_logic;
	signal	sSourceSendDirection	:	std_logic;
	signal	sResetSync	:	std_logic;
	signal	sTransmitir	:	std_logic;
	

	component KbandSink is
		generic(
			dimSymbol	:	natural	:=	8;
			dimADN		:	natural	:=	3
		);
		port(
			-- clk and reset interface
			clk_ext, clk_int, reset									:	in		std_logic;
			--Streamming Sink Interface
			dout_Ready													:	out	std_logic;
			din_Valid													:	in		std_logic;
			din_Data														:	in		std_logic_vector(dimSymbol downto 1);
			--interLogic Ports
			iRead															:	in		std_logic;
			oEmpty														:	out	std_logic;
			oFinalPacket												:	out	std_logic;
			oADN1, oADN2												:	out	std_logic_vector(dimADN downto 1)
			
		);
	end component;

	component SystolicFordward is
		generic(
			NoCell		: 	natural  :=	64;
			dimH			: 	natural  :=	8;
			dimADN		: 	natural  :=	3
		);
		port(
			-- Input ports (parameters)
			iMatch, iMisMatch, iW	:	in std_logic_vector(3 downto 0);
			-- Input ports
			CLOCK_50		:	in	std_logic;
			reset			:	in std_logic;
			inDireccion	:	in std_logic;	--0 vertical, 1 horizontal
			iADNh			:	in std_logic_vector(dimADN-1 downto 0);
			iADNv			:	in std_logic_vector(dimADN-1 downto 0);
			iEnable		:	in std_logic;
			iADNFinish	:	in std_logic;
			-- Output ports
			oADNfinish, oADNvalid	:	out std_logic;
			flag							:	out	std_logic;
			oArrows						:	out std_logic_vector(2*NoCell-1 downto 0)
		);
	end component;

	component KbandSource is
		generic(
			NoCell		: 	natural  :=	1024;	--MULTIPLOS DE 16
			dimADN		: 	natural  :=	3;
			bitsOUT		: 	natural  :=	64;	--32
			widthu		: 	natural  :=	6		--#regs
			--NoCell/bitsOUT < 16	Si >32, causa error
		);
		port(
			-- clk and reset interface
			clk_ext, clk_int, reset															:	in		std_logic;
			--Streamming Source Interface
			din_Ready															:	in		std_logic;
			dout_Valid															:	out	std_logic;
			dout_Data															:	out	std_logic_vector(bitsOUT downto 1);	
			--interLogic Ports
			iSendDirection, iDirection										:	in	std_logic;
			iWrite																:	in	std_logic;
			iTransmitir															:	in	std_logic;
			oFIFOfull															:	out	std_logic;
			oFIFOEmpty															:	out	std_logic;
			iArrows																:	in	std_logic_vector(2*NoCell downto 1)
		);
	end component;
	
	component KbandControl is
		port(
			-- clk and reset interface
			clk, reset						:	in		std_logic;
			-- Sink control
			oSinkRead						:	out	std_logic;
			iSinkFIFOempty1				:	in		std_logic;
			iFinalPacket					:	in		std_logic;
			-- Systolic Control
			oDirection						:	out	std_logic;
			oSystolicProcesar				:	out	std_logic;
			iSystolicFinish				:	in		std_logic;
			oResetSync						:	out	std_logic;
			-- Source Control
			oSourceWrite					:	out	std_logic;
			oTransmitir						:	out	std_logic;
			oSourceSendDirection			:	out	std_logic;
			iSourceFIFOfull				:	in		std_logic;
			iSourceFIFOEmpty				:	in		std_logic
		);
	end component;

BEGIN


	STSink	:	KbandSink
	generic map( dimSymbol, dimADN )
	port map(
		clk_ext		=>	clock_ext,
		clk_int		=>	clock_int,
		reset			=>	reset_reset,	
		--Streamming Sink Interface
		dout_Ready	=>	oADN1_ready,
		din_Valid	=>	iADN1_valid,
		din_Data		=>	iADN1_data,
		--interLogic Ports
		iRead			=>	sSinkRead,
		oEmpty		=>	sSink1Empty,
		oFinalPacket	=>	sFinalPacket,
		oADN1			=>	sADN1,
		oADN2			=>	sADN2
	);
	
	
	uSystolicKBand	: SystolicFordward
	generic map(
		NoCell		=>	NoCell,
		dimH			=>	dimH,
		dimADN		=>	dimADN
	)
	port map(
		-- Input ports (parameters)
		iMatch		=>	"0101",	--	3+2
		iMisMatch	=>	"0001",	--	-1+2
		iW			=>	"0010",	--	2
		-- Input ports
		CLOCK_50		=>	clock_int,
		reset			=>	reset_reset,
		inDireccion	=>	sDirection,
		iADNh			=>	sADN1,
		iADNv			=>	sADN2,
		iEnable		=>	sProcesar,
		iADNFinish	=>	sADNfinish,
		-- Output ports
		oADNfinish		=>	sADNfinish,--sArrowEn,
		oADNvalid		=>	sADNvalid,
		flag				=>	sFlag,
		oArrows			=>	sArrows
	);
	
	STSource	:	KbandSource
	generic map(
		NoCell		=>	NoCell,
		dimADN		=>	dimADN,
		bitsOUT		=>	bitsOUT,
		widthu		=>	widthu
	)
	port map(
		-- clk and reset interface
		clk_ext		=>	clock_ext,
		clk_int		=>	clock_int,
		reset			=>	reset_reset,
		--Streamming Source Interface
		din_Ready	=>	iArrow_ready,
		dout_Valid	=>	sArrow_valid,
		dout_Data	=>	sArrow_data,
		--interLogic Ports
		iSendDirection	=>	sSourceSendDirection,
		iDirection		=>	sFlag,--sDirection,
		iWrite		=>	sSourceWrite,
		iTransmitir	=>	sTransmitir,
		oFIFOfull	=>	sFIFOfullKBsrc,
		oFIFOEmpty	=>	sSourceEmpty,
		iArrows		=>	sArrows
	);
	
	STControl	:	KbandControl
	port map(
		clk						=> clock_int,
		reset						=> reset_reset,
		oSinkRead				=>	sSinkRead,
		iSinkFIFOempty1		=>	sSink1Empty,
		iFinalPacket			=>	sFinalPacket,
		oDirection				=>	sDirection,
		oSystolicProcesar		=> sProcesar,
		iSystolicFinish		=>	sADNfinish,
		oResetSync				=>	sResetSync,
		oSourceWrite			=>	sSourceWrite,
		oTransmitir				=>	sTransmitir,
		oSourceSendDirection	=>	sSourceSendDirection,
		iSourceFIFOfull		=>	sFIFOfullKBsrc,
		iSourceFIFOEmpty		=>	sSourceEmpty
	);


	-- TODO: Auto-generated HDL template

	oADN1			<=	sADN1;
	oADN2			<=	sADN2;
	oDirection	<=	sDirection;
	--oADN1_ready <= '0';

	--oADN2_ready <= '0';

	oArrow_valid <= sArrow_valid;

	oArrow_data <= sArrow_data;

END ARCHITECTURE rtl; -- of KBandIP21
