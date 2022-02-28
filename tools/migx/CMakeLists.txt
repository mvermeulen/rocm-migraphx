cmake_minimum_required(VERSION 3.5)
project (MIGraphX_driver)

set (MIGRAPHX_FOLDER /src/AMDMIGraphX)
set (MIGRAPHX_BUILD ${MIGRAPHX_FOLDER}/build)
#set (CMAKE_CXX_COMPILER /opt/rocm/bin/hcc)
set (CMAKE_CXX_STANDARD 17)
set (MIOPEN_LIBS /opt/rocm/miopen/lib)
set (HIP_LIBS /opt/rocm/hip/lib)

find_package(OpenCV)
IF(OpenCV_FOUND)
  set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DOPENCV")
ELSE()
  set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -UOPENCV")
ENDIF()
  


include_directories(${MIGRAPHX_FOLDER}/src/include
		    ${MIGRAPHX_FOLDER}/src/targets/gpu/include
		    ${MIGRAPHX_FOLDER}/src/targets/ref/include
		    ${OpenCV_INCLUDE_DIRS}
		    inc)

link_directories(${MIGRAPHX_BUILD}/src/onnx
                 ${MIGRAPHX_BUILD}/src/tf
                 ${MIGRAPHX_BUILD}/src
                 ${MIGRAPHX_BUILD}/src/targets/gpu
                 ${MIGRAPHX_BUILD}/src/targets/ref
		 ${MIGRAPHX_BUILD}/lib
		 ${MIOPEN_LIBS}
		 ${HIP_LIBS})

file(GLOB SRC_FILES "/src/rocm-migraphx/tools/migx/src/*.cpp")
set(bin_name migx)
add_executable(${bin_name} ${SRC_FILES})
target_link_libraries(${bin_name} migraphx migraphx_ref migraphx_device migraphx_gpu migraphx_onnx migraphx_tf MIOpen ${OpenCV_LIBS})
