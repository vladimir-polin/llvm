// Tests CUDA kernel arguments get copied by value when targeting SPIR-V, even with
// destructor, copy constructor or move constructor defined by user.

// RUN: %clang -emit-llvm --cuda-device-only --offload=spirv32 \
// RUN:   -nocudalib -nocudainc %s -o %t.bc -c 2>&1
// RUN: llvm-dis -opaque-pointers %t.bc -o %t.ll
// RUN: FileCheck %s --input-file=%t.ll

// RUN: %clang -emit-llvm --cuda-device-only --offload=spirv64 \
// RUN:   -nocudalib -nocudainc %s -o %t.bc -c 2>&1
// RUN: llvm-dis -opaque-pointers %t.bc -o %t.ll
// RUN: FileCheck %s --input-file=%t.ll

class GpuData {
 public:
  __attribute__((host)) __attribute__((device)) GpuData(int* src) {}
  __attribute__((host)) __attribute__((device)) ~GpuData() {}
  __attribute__((host)) __attribute__((device)) GpuData(const GpuData& other) {}
  __attribute__((host)) __attribute__((device)) GpuData(GpuData&& other) {}
};

// CHECK: define
// CHECK-SAME: spir_kernel void @_Z6kernel7GpuData(ptr noundef byval(%class.GpuData) align

__attribute__((global)) void kernel(GpuData output) {}
