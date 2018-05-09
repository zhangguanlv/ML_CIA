#!/bin/bash

set -e

ln -sf ../../data/ijcnn/ijcnn1.tr
ln -sf ../../data/ijcnn/ijcnn1.val
ln -sf ../../data/ijcnn/ijcnn1.t
ln -sf ../../solvers/ffm_w_linear-train
ln -sf ../../solvers/fm_w_linear-train
ln -sf ../../solvers/linear-train
ln -sf ../../solvers/poly2_w_linear-train
ln -sf ../../util/best.py
ln -sf ../../util/last.py

parallel --no-notice -u ::: \
" ./cvt.ijcnn.py ijcnn1.tr ijcnn.tr.ffm " \
" ./cvt.ijcnn.py ijcnn1.val ijcnn.va.ffm " \
" ./cvt.ijcnn.py ijcnn1.t ijcnn.te.ffm "

for lambda in 0 0.000001 0.00001 0.0001; do 
    echo -n "Linear, lambda = $lambda: "
    ./linear-train -l $lambda -t 200 -p ijcnn.va.ffm ijcnn.tr.ffm > log
    ./best.py log
done

for lambda in 0 0.00001 0.0001 0.001 ; do 
    echo -n "Poly2 w/ linear, lambda = $lambda: "
    ./poly2_w_linear-train -l $lambda -t 200 -p ijcnn.va.ffm ijcnn.tr.ffm > log
    ./best.py log
done

for lambda in 0.00001 0.0001 0.001; do 
    for k in 40 100; do 
        echo -n "FM w/ linear, lambda = $lambda, k = $k: "
        ./fm_w_linear-train -k $k -l $lambda -t 30 -p ijcnn.va.ffm ijcnn.tr.ffm > log
        ./best.py log
    done
done

for lambda in 0.00001 0.0001 0.001; do 
    for k in 4 8; do 
        echo -n "FFM w/ linear, lambda = $lambda, k = $k: "
        ./ffm_w_linear-train -k $k -l $lambda -t 30 -p ijcnn.va.ffm ijcnn.tr.ffm > log
        ./best.py log
    done
done

echo "============test==============="

cp ijcnn.tr.ffm ijcnn.trva.ffm 
chmod +w ijcnn.trva.ffm 
cat ijcnn.va.ffm >> ijcnn.trva.ffm

echo -n "Linear: "
./linear-train -l 0 -t 3 -p ijcnn.te.ffm ijcnn.trva.ffm > log
./last.py log

echo -n "Poly2 w/ linear: "
./poly2_w_linear-train -l 0.00001 -t 198 -p ijcnn.te.ffm ijcnn.trva.ffm > log
./last.py log

echo -n "FM w/ linear: "
./fm_w_linear-train -k 100 -l 0.0001 -t 7 -p ijcnn.te.ffm ijcnn.trva.ffm > log
./last.py log

echo -n "FFM w/ linear: "
./ffm_w_linear-train -k 8 -l 0.0001 -t 29 -p ijcnn.te.ffm ijcnn.trva.ffm > log
./last.py log