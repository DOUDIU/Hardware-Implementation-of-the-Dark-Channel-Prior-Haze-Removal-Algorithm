onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /haze_removal_tb/u_haze_removal_top/clk
add wave -noupdate /haze_removal_tb/u_haze_removal_top/rst_n
add wave -noupdate /haze_removal_tb/u_haze_removal_top/pre_frame_vsync
add wave -noupdate /haze_removal_tb/u_haze_removal_top/pre_frame_href
add wave -noupdate /haze_removal_tb/u_haze_removal_top/pre_frame_clken
add wave -noupdate /haze_removal_tb/u_haze_removal_top/pre_img
add wave -noupdate /haze_removal_tb/u_haze_removal_top/post_frame_vsync
add wave -noupdate /haze_removal_tb/u_haze_removal_top/post_frame_href
add wave -noupdate /haze_removal_tb/u_haze_removal_top/post_frame_clken
add wave -noupdate /haze_removal_tb/u_haze_removal_top/post_img
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 328
configure wave -valuecolwidth 198
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {893 ps}
