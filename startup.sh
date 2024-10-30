#!/bin/sh

# Update the command to use the full path for docker-compose
DOCKER_COMPOSE="/usr/local/bin/docker-compose"

execute_command_until_success(){
  max_attempts="$1"
  shift
  expect_resp="$1"
  shift
  cmd="$@"
  attempts=0
  cmd_status=1
  cmd_resp=""
  until [ $cmd_status -eq 0 ] && [ "$cmd_resp" = "$expect_resp" ]
  do 
    if [ ${attempts} -eq ${max_attempts} ]; then
      echo "max attempts reached"
      exit 1
    elif [ ${attempts} -ne 0 ]; then
      sleep 5s
    fi

    cmd_resp=$($cmd)
    cmd_status=$?
    attempts=$(($attempts + 1)) 
    
    echo "   cmd_status: $cmd_status, cmd_resp: $cmd_resp, attempts: $attempts"  
  done
  echo "   execute command successfully"
}

echo "Launching EdgeX"
execute_command_until_success 10 200 $DOCKER_COMPOSE up -d

echo "Checking the Metadata Service is running, max retries=10..."
execute_command_until_success 10 200 curl -s -o /dev/null -w "%{http_code}" http://localhost:59881/api/v3/ping

echo "Checking the Modbus Device Service is registered, max retries=10..."
execute_command_until_success 10 200 curl -s -o /dev/null -w "%{http_code}" http://localhost:59881/api/v3/deviceservice/name/device-modbus

echo "Uploading Case Controller device profile..."
execute_command_until_success 1 201 curl -s -o /dev/null -w "%{http_code}" -X POST http://localhost:59881/api/v3/deviceprofile/uploadfile -F "file=@sim_files/084B4084_17x.json"

# Note that the payload should not contain any spaces
echo "Onboarding Case Controller Device..."
execute_command_until_success 1 207 curl -s -o /dev/null -w "%{http_code}" -X POST http://localhost:59881/api/v3/device -H "Content-Type:application/json" -d '[{"apiVersion":"v3","device":{"name":"Danfoss-AK-CC55","adminState":"UNLOCKED","operatingState":"UP","protocols":{"modbus-rtu":{"Address":"/dev/virtualport","BaudRate":19200,"DataBits":8,"Parity":"N","StopBits":1,"UnitID":1}},"serviceName":"device-modbus","properties":{"IOTech_ProtocolName":"modbus-rtu"},"profileName":"084B4084_017x","autoEvents":[{"interval":"1s","onChange":false,"sourceName":"u20_s2_temp"},{"interval":"1s","onChange":false,"sourceName":"u79_s2_temp_b"},{"interval":"1s","onChange":false,"sourceName":"u88_s2_temp_c"},{"interval":"1s","onChange":false,"sourceName":"u16_s4_air_temp"},{"interval":"1s","onChange":false,"sourceName":"u76_s4_temp_b"},{"interval":"1s","onChange":false,"sourceName":"u85_s4_temp_c"},{"interval":"1s","onChange":false,"sourceName":"u23_akv_od_pc"},{"interval":"1s","onChange":false,"sourceName":"u82_akv_od_pc_b"},{"interval":"1s","onChange":false,"sourceName":"u91_akv_od_pc_c"},{"interval":"1s","onChange":false,"sourceName":"u72_food_temp"},{"interval":"2s","onChange":false,"sourceName":"r12_main_switch"},{"interval":"2s","onChange":false,"sourceName":"a13_highlim_air"},{"interval":"2s","onChange":false,"sourceName":"a14_lowlim_air"},{"interval":"2s","onChange":false,"sourceName":"d02_defstoptemp"},{"interval":"2s","onChange":false,"sourceName":"minus_def_start"},{"interval":"2s","onChange":false,"sourceName":"minus_standby_mode"},{"interval":"2s","onChange":false,"sourceName":"minus_door_alarm"},{"interval":"2s","onChange":false,"sourceName":"minus_co2_alarm"},{"interval":"2s","onChange":false,"sourceName":"minus_refgleak"},{"interval":"2s","onChange":false,"sourceName":"minus_high_temp_c"},{"interval":"2s","onChange":false,"sourceName":"minus_low_temp_c"}]}}]'

echo "Launching Application Service to export data to Influx..."
edgecentral up app-service -p app-services/influx.yaml

echo "Configuring the Grafana InfluxDB datasource..."
execute_command_until_success 1 200 curl -s -o /dev/null -w "%{http_code}" -X POST -H "Content-Type:application/json" http://admin:admin@localhost:3000/api/datasources -d '{"name":"InfluxDB","type":"influxdb","url":"http://influxdb:8086","access":"proxy","basicAuth":false,"isDefault":true,"jsonData":{"organization":"my-org","defaultBucket":"my-bucket","version":"Flux"},"secureJsonData":{"to
