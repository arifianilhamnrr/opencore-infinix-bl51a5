/*
 * SSDT-CPUR for AMD Ryzen CPUs
 * Required by AMDRyzenCPUPowerManagement.kext for C-states
 */
DefinitionBlock ("", "SSDT", 2, "CpuRef", "CPUR    ", 0x00001000)
{
    External (_SB_.PCI0, DeviceObj)

    Scope (_SB.PCI0)
    {
        Device (CPUR)
        {
            Name (_HID, "ACPI0010")  // Processor Aggregator Device
            Name (_UID, Zero)
        }
    }
}