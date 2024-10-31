#!/bin/sh

echo "Stop the Modbus Simulator"
docker stop modbus-sim

echo "Stop socat"
sudo rmdir /dev/virtualport

echo "Stopping the EdgeX services"
docker compose down -v

