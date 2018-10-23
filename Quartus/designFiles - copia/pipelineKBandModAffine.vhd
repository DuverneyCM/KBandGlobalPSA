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
		iHGDiagEqual:	in std_logic;
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
signal	sH1, sH1mux, sH2, sG1, sG2	:	std_logic_vector(dimH-1 downto 0);
signal	sDirGap1, sDirGap2, sHGDiagEqual	: std_logic;
signal	sArrow		:	std_logic_vector(1 downto 0);
signal	clearH2		:	std_logic;

begin
	process(reset, CLOCK_50) is
	begin
		if(reset = '1') then
			oADNa		<= (others => '0');
			oADNb		<= (others => '0');
			sH1		<= (others => '0');
			sH2		<= (others => '0');
			sG1		<= (others => '0');
			sG2		<= (others => '0');
			sArrow	<= (others => '0');
			sHGDiagEqual	<=	'0';
			sDirGap1	<=	'0';
			sDirGap2	<=	'0';
		elsif(rising_edge(CLOCK_50)) then
			--first delay
			--if (iEnable = '1') then
				--if (iCero = '1') then
					--sH1	<= (others => '0');
					--sG1	<= (others => '0');
				--else
					--sH1		<= iH;
					--sG1		<= iG;
				--end if;
			--end if;
			--Second Delay
			--se podría considerar eliminar este retardo para ahorrar hardware
			if (iEnable = '1') then
		--		if (iCero = '1' or iFinish = '1') then
		--			sH1	<= (others => '0');
		--		else
		--			sH1	<=	iH;
		--		end if;

				sH2		<= sH1mux;
				sH1		<= iH;
			end if;
			--registros de desplazamiento para aminoH y aminoV, cargan de forma alternada
			if (inDireccion = '0' AND iEnable = '1') then
				oADNa		<= iADNa;
			end if;
			if (inDireccion = '1' AND iEnable = '1') then
				oADNb		<= iADNb;
			end if;
			if (iEnable = '1') then
--				if (inDireccion = '0') then
--					oADNa		<= iADNa;
--				else
--					oADNb		<= iADNb;
--				end if;
--				clearH2	<=	iCero or iFinish;--iCero = '1' or iFinish = '1'
				sG2	<= sG1;
				sG1	<= iG;
				sDirGap2	<=	sDirGap1;
				sDirGap1	<=	iDirGap;

				sArrow	<= iArrow;
				sHGDiagEqual	<=	iHGDiagEqual;
			end if;
		end if;
		oDirGapDiag	<=	sDirGap2;
		oH2		<=	sH2;
		clearH2	<=	iCero or iFinish;
		if (clearH2 = '1') then
			sH1mux	<= (others => '0');
		else
			sH1mux	<= sH1;
		end if;
		oH1	<=	sH1mux;

--		if (sHGDiagEqual = '1') then	-- or iFinish = '1'
--			oArrow	<= (others => '0');
--		else
--			oArrow		<= sArrow;
--		end if;
		--sH1		<= iH;
		oG2		<=	sG2;
		oG1		<=	sG1;
		oH1msb	<=	sH1(dimH-1 downto dimH-2);
		--oArrow		<= sArrow;
	end process;
	oArrow		<= (others => '0') when sHGDiagEqual = '1' and clearH2 = '0' else sArrow;
	--oH1		<=	(others => '0') when iCero = '1' or iFinish = '1' else	sH1;
	--sH1		<=	(others => '0') when iCero = '1' or iFinish = '1' else	iH;
end rtl;
