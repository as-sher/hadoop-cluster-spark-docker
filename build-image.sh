#!/bin/bash

echo ""

echo -e "\nbuild docker hadoop image\n"
sudo docker build -t kgiann78/ms-thesis-hadoop-spark:1.1 .

echo ""
