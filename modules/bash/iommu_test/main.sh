#!/bin/sh
# Checks if system support IOMMU

if [ $(dmesg | grep ecap | wc -l) -eq 0 ]; then
  echo "No interrupt remapping support found"
  exit 1
fi

for i in $(dmesg | grep ecap | awk '{print $NF}'); do
  if [ $(( (0x$i & 0xf) >> 3 )) -ne 1 ]; then
    echo "Interrupt remapping not supported"
    exit 1
  fi
done