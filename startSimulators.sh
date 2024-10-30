#!/bin/sh

echo "Start the Modbus Simulator"
docker run -d --rm -v ${PWD}/sim_files:/sim_files -p 50103:50103 --name modbus-sim iotechsys/pymodbus-sim:1.0.4 --profile /sim_files/084B4084_17x.json --script /sim_files/update-cc-values.py --comm serial --serial_over_tcp_port 50103

sleep 2

echo "Start socat"
sudo socat pty,link=/dev/virtualport,raw,echo=0,mode=666 tcp:172.17.0.1:50103
