add_llvm_component_library(LLVMMipsDesc
  MipsABIInfo.cpp
  MipsABIFlagsSection.cpp
  MipsAsmBackend.cpp
  MipsELFObjectWriter.cpp
  MipsELFStreamer.cpp
  MipsInstPrinter.cpp
  MipsMCAsmInfo.cpp
  MipsMCCodeEmitter.cpp
  MipsMCTargetDesc.cpp
  MipsOptionRecord.cpp
  MipsTargetStreamer.cpp
  MipsWinCOFFObjectWriter.cpp
  MipsWinCOFFStreamer.cpp

  LINK_COMPONENTS
  CodeGenTypes
  MC
  MipsInfo
  Support
  TargetParser

  ADD_TO_COMPONENT
  Mips
  )
