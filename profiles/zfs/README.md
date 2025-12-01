# ZFS

## Arc Cache Management

### Clear ZFS Arc Cache

As `root` run

```bash
echo 3 > /proc/sys/vm/drop_caches
```

### ZFS Arc Details

For brief stats

```bash
arcstat
```

For detailed summary

```bash
arc_summary
```

### Get current Arc size

```bash
awk '/^size/ { printf "ARC size: %.2f GB\n", $3/1024/1024/1024; exit }' /proc/spl/kstat/zfs/arcstats
```

or

```bash
arc_summary | head -20
```

and read it off there along with other useful information.

### Monitor Arc efficiency

```bash
awk '/^hits/ { hits=$3 } /^misses/ { misses=$3 } END { printf "Hit rate: %.2f%%\n", hits*100/(hits+misses) }' /proc/spl/kstat/zfs/arcstats
```

anything above 95% is considered good.

## References

- [ZFS ate my RAM: Understanding the ARC cache by Jörg Thalheim](https://blog.thalheim.io/2025/10/17/zfs-ate-my-ram-understanding-the-arc-cache/)
