#!/bin/bash

for k in {at6137,at6923,at6929,at7143,at8285,at9104,at9336,at9503,at9578,at9744,at9762,at9806,at9830,at9847,at9852,at9879,at9883,at990}; do  
    for j in {1..5}; do show-aligns -r /xxx/pairwiseWGA/Col/$k/out_m_i90_l100.delta Chr$j Chr$j >/xxx/pairwiseWGA/Col/$k/out_m_i90_l100.chr$j.aligns ; done ;
done
