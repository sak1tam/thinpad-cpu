
# PlanAhead Launch Script for Post-Synthesis pin planning, created by Project Navigator

create_project -name cpux -dir "E:/Learn/cpux/planAhead_run_1" -part xc3s1200efg320-4
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "E:/Learn/cpux/cpu.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {E:/Learn/cpux} }
set_param project.pinAheadLayout  yes
set_property target_constrs_file "cpu.ucf" [current_fileset -constrset]
add_files [list {cpu.ucf}] -fileset [get_property constrset [current_run]]
link_design
