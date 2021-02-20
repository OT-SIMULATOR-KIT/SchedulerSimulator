# Run any Docker image on your local system, simulate some load and if the cpu utilization is more than x% then another container should get spinned up. In similar fashion you can implement de scaling as well
#scheduler.sh <id> <image> <min> <desired> <max> <scaling percentage>
#scheduler.sh empui nginx 1 2 5 80

# Operations
#    - Launch instances as per desired count
#    - Check the CPU utilization of the instances for the specific app
#    - Update desired count as per scaling policy

#!/bin/zsh


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
    result=`docker ps --filter "label=${APP_ID}" --format "{{.Names}}"`
    echo $result
}

function getAppAvgCPUUtilization {
    APP_ID=$1
    containers=`getAppContainers ${APP_ID}`
    containersArr=(`echo ${containers}`);
    docker stats --no-stream  ${containersArr} --format "{{.CPUPerc}}"
}

function ensureDesiredState() {
    desiredCount=$1
    APP_ID=$2
    IMAGE=$3
    containers=`getAppContainers ${APP_ID}`
    containersArr=(`echo ${containers}`);
    containersCount=`echo ${#containersArr[@]}`
    if [[ ${containersCount} -gt ${desiredCount} ]]
    then
        delta=$((containersCount-desiredCount))
        echo "Needs to be scaled down by ${delta}"
        for (( containerIndex=$containersCount; containerIndex>$desiredCount; containerIndex-- ))
        do
            containerName=$containersArr[${containerIndex}]
            echo "Deleting container ${containerName%%[*} with index ${containerIndex}"
            executeInstruction "docker rm -f ${containerName%%[*}"
        done
    elif [[ ${containersCount} -lt ${desiredCount} ]]
    then
        delta=$((desiredCount-containersCount))
        echo "Needs to be scaled up by ${delta}"
        for (( containerIndex=$containersCount; containerIndex<$desiredCount; containerIndex++ ))
        do
            echo "Creating container"
            launchInstance ${IMAGE} ${APP_ID}
        done
    else
        echo "We are at desired state"
    fi
}

#launchInstance nginx empui
#launchInstance nginx empui
#launchInstance nginx empui


#getAppAvgCPUUtilization empui
#ensureDesiredState 2 empui nginx
#ensureDesiredState 5 empui nginx

APP_ID=$1
IMAGE=$2
MIN=$3
desiredCount=$4
MAX=$5
threshold=$6
#<id> <image> <min> <desired> <max> <scaling percentage>
#echo "start of execution"
#container_list=$(getAppContainers empui)
#char="_"
#echo "${container_list}" | awk -F"${char}" '{print NF-1}'
#echo "count"

ensureDesiredState $desiredCount $APP_ID $IMAGE
while true
do
if [[ $avgCPU > $threshold && $desiredCount < $MAX ]]
then
  echo "scale up"
  ((desiredCount=desiredCount+1))
  echo $desiredCount
  ensureDesiredState $desiredCount $APP_ID $IMAGE
  sleep 5
elif [[ $avgCPU < $threshold && $desiredCount > $MIN ]]
then
 echo "scale down"
 ((desiredCount=desiredCount-1))
 echo $desiredCount
 ensureDesiredState $desiredCount $APP_ID $IMAGE
 sleep 5
else
  echo "no scaling required"
  sleep 5
fi
done
