# TCL File Generated by Component Editor 16.1
# Wed May 09 19:47:32 COT 2018
# DO NOT MODIFY


# 
# KBand21 "KBand 2in 1out" v1.0
# Duverney Corrales 2018.05.09.19:47:32
# KBand Needleman-Wunsch Pairwise Sequence Alignment
# 

# 
# request TCL package from ACDS 16.1
# 
package require -exact qsys 16.1


# 
# module KBand21
# 
set_module_property DESCRIPTION "KBand Needleman-Wunsch Pairwise Sequence Alignment"
set_module_property NAME KBand21
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP ADN_Alignment
set_module_property AUTHOR "Duverney Corrales"
set_module_property DISPLAY_NAME "KBand 2in 1out"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL KBandIP21
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file KBandIP21.vhd VHDL PATH KBandIP21.vhd


# 
# parameters
# 
add_parameter NoCell NATURAL 64 ""
set_parameter_property NoCell DEFAULT_VALUE 64
set_parameter_property NoCell DISPLAY_NAME NoCell
set_parameter_property NoCell TYPE NATURAL
set_parameter_property NoCell UNITS None
set_parameter_property NoCell ALLOWED_RANGES 0:2147483647
set_parameter_property NoCell DESCRIPTION ""
set_parameter_property NoCell HDL_PARAMETER true
add_parameter dimH NATURAL 8
set_parameter_property dimH DEFAULT_VALUE 8
set_parameter_property dimH DISPLAY_NAME dimH
set_parameter_property dimH TYPE NATURAL
set_parameter_property dimH UNITS None
set_parameter_property dimH ALLOWED_RANGES 0:2147483647
set_parameter_property dimH HDL_PARAMETER true
add_parameter dimSymbol NATURAL 32 ""
set_parameter_property dimSymbol DEFAULT_VALUE 32
set_parameter_property dimSymbol DISPLAY_NAME dimSymbol
set_parameter_property dimSymbol TYPE NATURAL
set_parameter_property dimSymbol UNITS None
set_parameter_property dimSymbol ALLOWED_RANGES 0:2147483647
set_parameter_property dimSymbol DESCRIPTION ""
set_parameter_property dimSymbol HDL_PARAMETER true
add_parameter dimADN NATURAL 3
set_parameter_property dimADN DEFAULT_VALUE 3
set_parameter_property dimADN DISPLAY_NAME dimADN
set_parameter_property dimADN TYPE NATURAL
set_parameter_property dimADN UNITS None
set_parameter_property dimADN ALLOWED_RANGES 0:2147483647
set_parameter_property dimADN HDL_PARAMETER true
add_parameter bitsOUT NATURAL 128 ""
set_parameter_property bitsOUT DEFAULT_VALUE 128
set_parameter_property bitsOUT DISPLAY_NAME bitsOUT
set_parameter_property bitsOUT TYPE NATURAL
set_parameter_property bitsOUT UNITS None
set_parameter_property bitsOUT ALLOWED_RANGES 0:2147483647
set_parameter_property bitsOUT DESCRIPTION ""
set_parameter_property bitsOUT HDL_PARAMETER true
add_parameter widthu NATURAL 6
set_parameter_property widthu DEFAULT_VALUE 6
set_parameter_property widthu DISPLAY_NAME widthu
set_parameter_property widthu TYPE NATURAL
set_parameter_property widthu UNITS None
set_parameter_property widthu ALLOWED_RANGES 0:2147483647
set_parameter_property widthu HDL_PARAMETER true


# 
# display items
# 


# 
# connection point reset
# 
add_interface reset reset end
set_interface_property reset associatedClock clock_external
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED true
set_interface_property reset EXPORT_OF ""
set_interface_property reset PORT_NAME_MAP ""
set_interface_property reset CMSIS_SVD_VARIABLES ""
set_interface_property reset SVD_ADDRESS_GROUP ""

add_interface_port reset reset_reset reset Input 1


# 
# connection point iADN1
# 
add_interface iADN1 avalon_streaming end
set_interface_property iADN1 associatedClock clock_external
set_interface_property iADN1 associatedReset reset
set_interface_property iADN1 dataBitsPerSymbol 8
set_interface_property iADN1 errorDescriptor ""
set_interface_property iADN1 firstSymbolInHighOrderBits true
set_interface_property iADN1 maxChannel 0
set_interface_property iADN1 readyLatency 0
set_interface_property iADN1 ENABLED true
set_interface_property iADN1 EXPORT_OF ""
set_interface_property iADN1 PORT_NAME_MAP ""
set_interface_property iADN1 CMSIS_SVD_VARIABLES ""
set_interface_property iADN1 SVD_ADDRESS_GROUP ""

add_interface_port iADN1 iADN1_data data Input dimsymbol
add_interface_port iADN1 oADN1_ready ready Output 1
add_interface_port iADN1 iADN1_valid valid Input 1


# 
# connection point oArrow
# 
add_interface oArrow avalon_streaming start
set_interface_property oArrow associatedClock clock_external
set_interface_property oArrow associatedReset reset
set_interface_property oArrow dataBitsPerSymbol 8
set_interface_property oArrow errorDescriptor ""
set_interface_property oArrow firstSymbolInHighOrderBits true
set_interface_property oArrow maxChannel 0
set_interface_property oArrow readyLatency 0
set_interface_property oArrow ENABLED true
set_interface_property oArrow EXPORT_OF ""
set_interface_property oArrow PORT_NAME_MAP ""
set_interface_property oArrow CMSIS_SVD_VARIABLES ""
set_interface_property oArrow SVD_ADDRESS_GROUP ""

add_interface_port oArrow oArrow_data data Output bitsout
add_interface_port oArrow iArrow_ready ready Input 1
add_interface_port oArrow oArrow_valid valid Output 1


# 
# connection point clock_internal
# 
add_interface clock_internal clock end
set_interface_property clock_internal clockRate 50000000
set_interface_property clock_internal ENABLED true
set_interface_property clock_internal EXPORT_OF ""
set_interface_property clock_internal PORT_NAME_MAP ""
set_interface_property clock_internal CMSIS_SVD_VARIABLES ""
set_interface_property clock_internal SVD_ADDRESS_GROUP ""

add_interface_port clock_internal clock_int clk Input 1


# 
# connection point clock_external
# 
add_interface clock_external clock end
set_interface_property clock_external clockRate 250000000
set_interface_property clock_external ENABLED true
set_interface_property clock_external EXPORT_OF ""
set_interface_property clock_external PORT_NAME_MAP ""
set_interface_property clock_external CMSIS_SVD_VARIABLES ""
set_interface_property clock_external SVD_ADDRESS_GROUP ""

add_interface_port clock_external clock_ext clk Input 1

