library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;

entity pipelineKBandModAffine is
	generic(
		dimH		: 	natural  :=	5;
		dimADN	:	natural  :=	3
	);
	port
	(
		-- Input ports
		CLOCK_50		:	in	std_logic;
		reset			:	in std_logic;
		iEnable		:	in std_logic;
		inDireccion	:	in std_logic;	--0 vertical, 1 horizontal
		iBitCl		:	in std_logic;
		iADNa			:	in std_logic_vector(dimADN-1 downto 0);
		iADNb			:	in std_logic_vector(dimADN-1 downto 0);
		iH				:	in std_logic_vector(dimH-1 downto 0);
		iG				:	in std_logic_vector(dimH-1 downto 0);
		iArrow		:	in std_logic_vector(1 downto 0);
		iDirGap		:	in	std_logic;
		iCero			:	in	std_logic;
		iFinish		:	in	std_logic;
		-- Output ports
		oADNa			:	out std_logic_vector(dimADN-1 downto 0);
		oADNb			:	out std_logic_vector(dimADN-1 downto 0);
		oH1msb		:	out std_logic_vector(1 downto 0);
		oH1			:	out std_logic_vector(dimH-1 downto 0);
		oH2			:	out std_logic_vector(dimH-1 downto 0);
		oG1			:	out std_logic_vector(dimH-1 downto 0);
		oG2			:	out std_logic_vector(dimH-1 downto 0);
		oDirGapDiag	:	out std_logic;
		oArrow		:	out std_logic_vector(1 downto 0)
	);
end pipelineKBandModAffine;


architecture rtl of pipelineKBandModAffine is
signal	sH1, sG1		:	std_logic_vector(dimH-1 downto 0);
signal	sDirGap1, sDirGap2	: std_logic;
begin
	process(reset, CLOCK_50) is 
	begin 
		if(reset = '1') then
			oADNa		<= (others => '0');
			oADNb		<= (others => '0');
			sH1		<= (others => '0');
			oH2		<= (others => '0');
			sG1		<= (others => '0');
			oG2		<= (others => '0');
			oArrow	<= (others => '0');
			sDirGap1	<=	'0';
			sDirGap2	<=	'0';
		elsif(rising_edge(CLOCK_50)) then
			if (iEnable = '1') then
				sH1(dimH-1 downto 0)		<= iH(dimH-1 downto 0);
				sG1(dimH-1 downto 0)		<= iG(dimH-1 downto 0);
			elsif (iCero = '1' or iFinish = '1') then
				sH1	<= (others => '0');
				sG1	<= (others => '0');
			end if;
			if (iEnable = '1') then
				--registros de desplazamiento para aminoH y aminoV, cargan de forma alternada
				if (inDireccion = '0') then
					oADNa		<= iADNa;
				else
					oADNb		<= iADNb;
				end if;
				--sH1(dimH-1 downto 0)		<= iH(dimH-1 downto 0);
				oH2(dimH-1 downto 0)		<= sH1(dimH-1 downto 0);
				oG2(dimH-1 downto 0)		<= sG1(dimH-1 downto 0);
				sDirGap1	<=	iDirGap;
				sDirGap2	<=	sDirGap1;
				
				oArrow	<= iArrow;
			end if;
		end if;
	end process;
	oDirGapDiag	<=	sDirGap2;
	oH1		<=	sH1;
	oG1		<=	sG1;
	oH1msb	<=	sH1(dimH-1 downto dimH-2);
end rtl;