# Run any Docker image on your local system, simulate some load and if the cpu utilization is more than x% then another container should get spinned up. In similar fashion you can implement de scaling as well

#scheduler.sh <id> <image> <min> <desired> <max> <scaling percentage>
#scheduler.sh empui nginx 1 2 5 80

# Operations
#    - Launch instances as per desired count
#    - Check the CPU utilization of the instances for the specific app
#    - Update desired count as per scaling policy

#!/bin/bash


function executeInstruction() {
    INSTRUCTION=$1
    echo $INSTRUCTION
    bash -c "$INSTRUCTION"
}

function launchInstance() {
    IMAGE_NAME=$1
    APP_ID=$2

    executeInstruction "docker run -d --rm -l ${APP_ID} ${IMAGE_NAME}"
}

function getAppContainers {
    APP_ID=$1
    result=`docker ps --filter "label=${APP_ID}" --format "\"{{.Names}}\","`
    echo $result
}

function getContainerCPUUtilization {
    CONTAINER_NAME=$1
    docker stats --no-stream  ${CONTAINER_NAME} --format "{{.CPUPerc}}"
}

launchInstance nginx empui
launchInstance nginx empui
launchInstance nginx empui

getAppContainers empui