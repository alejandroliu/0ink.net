---
title: Using 7z for benchmarks
date: "2024-02-19"
author: alex
---
[toc]
***
![7z]({static}/images/2025/7-Zip_Logo.png)

[7zip][7zip] comes with a `b` (Benchmark) command. [7zip][7zip] usually is packaged as
`p7z` or similar...

This command measures speed of the CPU.  Its execution also can be used to check RAM for errors.

# Syntax

```bash
b [number_of_iterations] [-mmt{N}] [-md{N}] [-mm={Method}]
```
Options:

* `-md{N}` : change the upper dictionary size to increase memory usage.
* `-mmt{N}` : n change the number of threads.  Default will use all available cores.
* `-mm=*` : run complex 7-Zip benchmark.


The LZMA benchmark is default benchmark for benchmark command.

There are two tests for LZMA benchmark:

1. Compressing with LZMA method
2. Decompressing with LZMA method

```bash
$ 7z b

7-Zip (z) 24.08 (x64) : Copyright (c) 1999-2024 Igor Pavlov : 2024-08-11
 64-bit locale=en_US.UTF-8 Threads:16 OPEN_MAX:1024

Compiler:  ver:13.2.0 GCC 13.2.0 : SSE2
Linux : 6.6.56_2 : #1 SMP PREEMPT_DYNAMIC Tue Oct 15 02:54:10 UTC 2024 : x86_64
PageSize:4KB THP:madvise hwcap:178BFBFF hwcap2:2
AMD Ryzen 7 5800U with Radeon Graphics
(A50F00) 

1T CPU Freq (MHz):  4361  4408  4409  4421  4422  4421  4417
8T CPU Freq (MHz): 796% 4246   797% 4175  
16T CPU Freq (MHz): 1419% 3623   1569% 3987  

RAM size:   15412 MB,  # CPU hardware threads:  16
RAM usage:   3559 MB,  # Benchmark threads:     16

                       Compressing  |                  Decompressing
Dict     Speed Usage    R/U Rating  |      Speed Usage    R/U Rating
         KiB/s     %   MIPS   MIPS  |      KiB/s     %   MIPS   MIPS

22:      41524  1462   2763  40395  |     633594  1547   3491  54026
23:      36519  1426   2609  37209  |     596376  1531   3370  51591
24:      34094  1404   2612  36658  |     595727  1556   3360  52270
25:      32470  1379   2689  37074  |     578205  1547   3326  51443
----------------------------------  | ------------------------------
Avr:     36152  1418   2668  37834  |     600975  1545   3387  52333
Tot:            1481   3028  45083

```


The LZMA benchmark shows a rating in MIPS (million instructions per second). The rating value
is calculated from the measured speed, and it is normalized with results of Intel Core 2 CPU
with multi-threading option switched off. So if you have modern CPU from Intel or AMD, rating
values in single-thread mode must be close to real CPU frequency.

The **Dict** column shows dictionary size. For example, 21 means 2^21 = 2 MB.

The **Usage** column shows the percentage of time the processor is working. It's normalized for a
one-thread load. For example, 180% CPU Usage for 2 threads can mean that average CPU usage is
about 90% for each thread.

The **R / U** column shows the rating normalized for 100% of CPU usage. That column shows
the performance of one average CPU thread.

**Avr** shows averages for different dictionary sizes.

**Tot** shows averages of the compression and decompression ratings.

The test data that is used for compression in that test is produced with special algorithm,
that creates data stream that has some properties of real data, like text or execution code.
Note that the speed of LZMA for real data can be slightly different.

# LZMA benchmark details

**Compression speed** strongly depends from memory (RAM) latency, Data Cache size/speed
and TLB. Out-of-Order execution feature of CPU is also important for that test.

**Decompression speed** strongly depends on CPU integer operations. The most important things
for that test are: branch misprediction penalty (the length of pipeline) and the latencies of
32-bit instructions ("multiply", "shift", "add" and other). The decompression test has very
high number of unpredictable branches. Note that some CPU architectures (for example, 32-bit
ARM) support instructions that can be conditionally executed. So such CPUs can work without
branches (and without pipeline flushing) in many cases in LZMA decompression code. And such
CPUs can have some speed advantages over other architectures that don't support complex
conditionally execution. Out-of-Order execution capability is not so important for LZMA
Decompression.

The test code doesn't use FPU and SSE. Most of the code is 32-bit integer code. Only some
minor part in compression code uses also 64-bit integers. RAM and Cache bandwidth are not
so important for these tests. The _latencies are much more important_.

The CPU's IPC (Instructions per cycle) rate is not very high for these tests. The estimated
value of test's IPC is 1 (one instruction per cycle) for modern CPU. The compression test
has big number of random accesses to RAM and Data Cache. So big part of execution time the
CPU waits the data from Data Cache or from RAM. The decompression test has big number of
pipeline flushes after mispredicted branches. Such low IPC means that there are some
unloaded CPU resources. But the CPU with Hyper-Threading feature can load these CPU
resources using two threads. So Hyper-Threading provides pretty big improvement in these tests.

# LZMA benchmark in multithreading mode

When you specify (N * 2) threads for test, the program creates N copies of LZMA encoder,
and each LZMA encoder instance compresses separated block of test data. Each LZMA encoder
instance creates 3 unsymmetrical execution threads: two big threads and one small thread.
The total CPU load for these 3 threads can vary from 140% to 200%. To provide better CPU
load during compression, you can test the mode, where the number of benchmark threads is
larger than the number of hardware threads.

Each LZMA encoder instance in multithreading mode divides the task of compression into 3
different tasks, where each task is executed in separated thread. Each of these tasks is
simpler than original task, and it uses less memory. So each thread uses the data cache
and TLB more effectively in multithreading mode. And LZMA encoder is slightly more effective
in multithreading mode in value of "the Speed" divided to "CPU usage".

Note that there is some data traffic between 3 threads of LZMA encoder. So data exchange
bandwidth via memory between CPU threads is also can be important, especially in multi-core
system with big number of cores or CPUs.

All LZMA decoder threads are symmetrical and independent. So the decompression test uses all
hardware threads, if the number of hardware threads is used.

# 7-Zip benchmark

![icon]({static}/images/2025/benchmark.png)


With `-mm=*` switch you can run a complex benchmark for 7-Zip code. It tests hash calculation
methods, compression and encryption codecs of 7-Zip. Note that the tests of LZMA have big
weight in "total" results. And the results are normalized with AMD K8 cpu in that complex
benchmark.

```bash
$ 7z b -mm=*

7-Zip (z) 24.08 (x64) : Copyright (c) 1999-2024 Igor Pavlov : 2024-08-11
 64-bit locale=en_US.UTF-8 Threads:16 OPEN_MAX:1024

 m=*
Compiler:  ver:13.2.0 GCC 13.2.0 : SSE2
Linux : 6.6.56_2 : #1 SMP PREEMPT_DYNAMIC Tue Oct 15 02:54:10 UTC 2024 : x86_64
PageSize:4KB THP:madvise hwcap:178BFBFF hwcap2:2
AMD Ryzen 7 5800U with Radeon Graphics
(A50F00) 

1T CPU Freq (MHz):  4404  4313  4421  4426  4405  4422  4415
8T CPU Freq (MHz): 799% 4259   797% 4175  
16T CPU Freq (MHz): 1434% 3653   1573% 4002  

RAM size:   15412 MB,  # CPU hardware threads:  16
RAM usage:   3647 MB,  # Benchmark threads:     16


Method           Speed Usage    R/U Rating   E/U Effec
                 KiB/s     %   MIPS   MIPS     %     %

CPU                     1564   4061  63537
CPU                     1574   3944  62086
CPU                     1560   3921  61174   103  1600

LZMA:x1          81225  1491   2009  29943    53   783
                642809  1554   3308  51409    87  1345
LZMA:x3          39193  1442   1670  24080    44   630
                581692  1499   3255  48803    85  1276
LZMA:x5:mt1      29052  1489   2437  36294    64   949
                582429  1523   3223  49106    84  1284
LZMA:x5:mt2      30660  1507   2541  38304    66  1002
                580898  1531   3199  48977    84  1281
Deflate:x1      559275  1548   4589  71015   120  1857
               2071309  1557   4132  64349   108  1683
Deflate:x5      174091  1484   4516  67029   118  1753
               2045737  1532   4144  63501   108  1661
Deflate:x7       64640  1542   4646  71619   122  1873
               2071119  1548   4152  64262   109  1681
Deflate64:x5    157003  1505   4507  67846   118  1774
               2056814  1528   4209  64326   110  1682
BZip2:x1         82001  1549   3198  49542    84  1296
                517893  1510   3718  56136    97  1468
BZip2:x5         36407  1441   2108  30384    55   795
                197521  1504   2577  38765    67  1014
BZip2:x5:mt2     32927  1515   1814  27480    47   719
                191315  1510   2486  37547    65   982
BZip2:x7         17540  1518   2994  45442    78  1189
                195467  1506   2545  38329    67  1002
PPMD:x1          58411  1552   3894  60412   102  1580
                 46787  1551   3552  55097    93  1441
PPMD:x5          31269  1520   3486  52994    91  1386
                 26949  1511   3342  50501    87  1321
Swap4        411409038  1525   1726  26330    45   689
             407703538  1531   1704  26093    45   682
Delta:4       19134561  1550   3794  58781    99  1537
              11982527  1545   3177  49080    83  1284
BCJ           21499405  1554   2833  44031    74  1152
              21507528  1563   2819  44047    74  1152
ARM64         30825468  1560   2024  31565    53   826
              30076127  1552   1984  30798    52   806
RISCV         20395348  1547   1350  20885    35   546
              16120110  1557   1060  16507    28   432
AES256CBC:1    1482399  1562   2332  36431    61   953
               1370916  1550   2174  33692    57   881
AES256CBC:2   11935671  1526   6407  97777   168  2557
              42505953  1544   2818  43526    74  1138
AES256CBC:3   11619172  1509   6307  95184   165  2490
              74469288  1512   2521  38128    66   997
CRC32:12      24817472  1541   1649  25413    43   665
CRC32:32    
CRC32:64    
CRC64         20803049  1537   1386  21302    36   557
XXH64         84786144  1565   1387  21705    36   568
SHA256:1       1864713  1565   2431  38040    64   995
SHA256:2      20485066  1547   2755  42609    72  1114
SHA1:1         3175442  1567   1897  29722    50   777
SHA1:2        20937576  1546   2644  40870    69  1069
BLAKE2sp:1     3329474  1562   3491  54550    91  1427
BLAKE2sp:2     8505983  1558   2236  34841    58   911
BLAKE2sp:3    16257632  1538   2165  33296    57   871

CPU                     1563   3391  53000
------------------------------------------------------
Tot:                    1518   2916  44317    76  1159

```

The **CPU** rows show CPU frequency. It's measured for sequence of simple CPU instructions.
Note: It can be inaccurate, if hyper-threading is used.

The **Effec** column shows Efficiency - the Rating normalized to CPU frequency.

The **E / U** column shows the Efficiency normalized for 100% of CPU usage.

# Examples

- run benchmarking
  ```bash
  7z b
  ```
- run benchmarking with one thread and 64 MB dictionary.
  ```bash
  7z b -mmt1 -md26
  ```
- run benchmarking for 30 iterations. It can be used to check RAM for errors.
  ```bash
  7z b 30
  ```
- run complex 7-Zip benchmark.
  ```bash
  7z b -mm=*
  ```
- run complex 7-Zip benchmark for different number of threads : (1, max/2, max), where
  max is number of available hardware threads. So it can test 3 main modes: single-thread,
  multi-thread without hyper-threading, multi-thread with hyper-threading. 
  ```bash
  7z b -mm=* -mmt=*
  ```

# References

- [7-zip home page][7zip]
- https://7-zip.opensource.jp/chm/cmdline/commands/bench.htm

  [7zip]: https://7-zip.org/

