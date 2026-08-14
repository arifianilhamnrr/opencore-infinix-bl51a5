DefinitionBlock ("", "SSDT", 2, "VISUAL", "AMDPNLF", 0x00000000)
{
    External (_SB_.PCI0.GP17, DeviceObj)

    Scope (_SB.PCI0.GP17)
    {
        Device (PNLF)
        {
            Name (_HID, EisaId ("APP0002"))
            Name (_CID, "backlight")
            Name (_UID, 0x12)
            Name (BRTE, 0x028F)

            Method (_STA, 0, NotSerialized)
            {
                If (_OSI ("Darwin"))
                {
                    Return (0x0B)
                }

                Return (Zero)
            }

            Method (_BCL, 0, NotSerialized)
            {
                Return (Package (0x12)
                {
                    0x10,
                    0x028F,
                    0x0353,
                    0x045A,
                    0x05A1,
                    0x07AE,
                    0x0A3D,
                    0x0E14,
                    0x1374,
                    0x1A5E,
                    0x2418,
                    0x31A9,
                    0x4459,
                    0x5E76,
                    0x8311,
                    0xB6C7,
                    0xFF7B,
                    0x64
                })
            }

            Method (_BCM, 1, NotSerialized)
            {
                BRTE = Arg0
            }

            Method (_BQC, 0, NotSerialized)
            {
                Return (BRTE)
            }
        }
    }
}
