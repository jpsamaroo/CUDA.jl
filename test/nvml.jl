using CUDA.NVML

@testset "system" begin
    @test NVML.version() isa VersionNumber
    @test NVML.driver_version() isa VersionNumber
    @test NVML.cuda_driver_version() == CUDA.version()
end

@testset "devices" begin
    dev = NVML.Device(0)
    @test dev == first(NVML.devices())

    cuda_dev = CuDevice(0)
    nvml_dev = NVML.Device(uuid(cuda_dev))

    @test NVML.uuid(nvml_dev) == uuid(cuda_dev)
    NVML.brand(nvml_dev)
    @test NVML.name(nvml_dev) == name(cuda_dev)
    try
        NVML.serial(nvml_dev)
    catch err
        (isa(err, NVMLError) && err.code == NVML.ERROR_NOT_SUPPORTED) || rethrow()
    end

    NVML.power_usage(nvml_dev)
    NVML.energy_consumption(nvml_dev)

    NVML.memory_info(nvml_dev)

    NVML.compute_mode(nvml_dev)
    @test NVML.compute_capability(nvml_dev) == capability(cuda_dev)
    context()
    # FIXME: https://github.com/NVIDIA/gpu-monitoring-tools/issues/63
    #@test getpid() in keys(NVML.compute_processes(dev))
    @test !isempty(NVML.compute_processes(dev))
end