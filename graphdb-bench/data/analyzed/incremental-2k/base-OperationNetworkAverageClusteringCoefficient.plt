set autoscale
unset log
unset label
set xtic auto
set ytic auto
set xlabel 'Database'
set ylabel 'Time (ms)'
set style data histogram
set style histogram cluster gap 1
set style fill solid border -1
set key top left

set datafile separator ';'
set output 'base-OperationNetworkAverageClusteringCoefficient.eps'
set terminal postscript enhanced eps color 'Helvetica' 20 size 5,3.5 dl 3

plot\
  '<sed "1,1d" base-OperationNetworkAverageClusteringCoefficient.csv' using 2:xtic(1) title 'base' lc 3, \
  '<sed "1,1d" base-OperationNetworkAverageClusteringCoefficient.csv' using 3:xtic(1) title 'incremental' lc 1