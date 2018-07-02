
include_guard()

# All the things that are not required to use the same values as USD
set(LABCMD_LOCATION ${LOCAL_ROOT})
set(LABRENDER_LOCATION ${LOCAL_ROOT})
set(LABPHYSICS_LOCATION ${LOCAL_ROOT})

link_directories(${LOCAL_ROOT}/lib)

find_package(LabCmd)
find_package(LabRender)
find_package(LabPhysics)
find_package(LabText)
