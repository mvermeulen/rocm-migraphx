/opt/rocm/miopen/bin/MIOpenDriver conv -n 1 -c 3 -H 232 -W 232 -k 32 -y 9 -x 9 -p 0 -q 0 -u 1 -v 1 -l 1 -j 1 -m conv -g 1 -F 1 -t 1
/opt/rocm/miopen/bin/MIOpenDriver conv -n 1 -c 32 -H 226 -W 226 -k 64 -y 3 -x 3 -p 0 -q 0 -u 2 -v 2 -l 1 -j 1 -m conv -g 1 -F 1 -t 1
/opt/rocm/miopen/bin/MIOpenDriver conv -n 1 -c 64 -H 114 -W 114 -k 128 -y 3 -x 3 -p 0 -q 0 -u 2 -v 2 -l 1 -j 1 -m conv -g 1 -F 1 -t 1
