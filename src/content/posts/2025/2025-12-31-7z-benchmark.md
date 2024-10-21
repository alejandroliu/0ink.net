---
title: Using 7z for benchmarks
date: "2024-02-19"
author: alex
---
![7z]({static}/images/2024/7-Zip_Logo.png)


- 7z benchmark
  - 7z b _[-mtt4]_
  - _4_ configures the number of threads, leave _-mttX_ out to let it use threads as
    number of CPUs
  - Supposedly test CPU and storage.