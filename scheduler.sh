# Run any Docker image on your local system, simulate some load and if the cpu utilization is more than x% then another container should get spinned up. In similar fashion you can implement de scaling as well

#scheduler.sh <id> <image> <min> <desired> <max> <scaling percentage>
#scheduler.sh app nginx 1 2 5 80

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
    CONTAINER_NAME=$2

    executeInstruction "docker run -d --rm --name ${CONTAINER_NAME} ${IMAGE_NAME}"
}

launchInstance nginx sandy4