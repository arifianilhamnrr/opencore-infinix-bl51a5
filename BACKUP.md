# Backup — Sonoma recovery (working)

State saat recovery **Sonoma** confirmed boot OK di BL51A5.

| Item | Lokasi |
|------|--------|
| Git tag | `sonoma-recovery-working` (commit `a0a0666`) |
| Git branch | `backup/sonoma-recovery-working` |
| Local snapshot | folder backup lokal (opsional, tidak di repo) |

## Restore Sonoma recovery

```bash
git checkout sonoma-recovery-working
# copy EFI/ ke OC-ESP, lalu recovery-sonoma/ ke com.apple.recovery.boot/
```

Recovery image pada `main` tetap **Sequoia**. EFI OpenCore pada `main` merupakan
snapshot yang diuji di **Tahoe 26.5** dan sebelumnya bekerja di **Sequoia 15.7**.
