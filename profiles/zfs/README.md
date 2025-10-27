# ZFS

## Clear ZFS Arc Cache

As `root` run

```bash
echo 3 > /proc/sys/vm/drop_caches
```

## ZFS Arc Details

For brief stats

```bash
arcstat
```

For detailed summary

```bash
arc_summary
```
