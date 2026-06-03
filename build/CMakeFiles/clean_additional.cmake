# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "CMakeFiles/meoui_module_autogen.dir/AutogenUsed.txt"
  "CMakeFiles/meoui_module_autogen.dir/ParseCache.txt"
  "CMakeFiles/meoui_moduleplugin_autogen.dir/AutogenUsed.txt"
  "CMakeFiles/meoui_moduleplugin_autogen.dir/ParseCache.txt"
  "meoui_module_autogen"
  "meoui_moduleplugin_autogen"
  )
endif()
