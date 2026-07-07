echo Simulator transcript file: %cd%/questa_transcript.log
echo Simulation may take a while to finish. User can review the progress of simulation in Simulator transcript file %cd%/questa_transcript.log
vsim -gui -l questa_transcript.log -do "Assignment1DHL_run_msim_rtl_verilog.do"
