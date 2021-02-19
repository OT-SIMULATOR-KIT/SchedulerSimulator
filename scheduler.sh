# Run any Docker image on your local system, simulate some load and if the cpu utilization is more than x% then another container should get spinned up. In similar fashion you can implement de scaling as well

#scheduler.sh <id> <image> <min> <desired> <max> <scaling percentage>
#scheduler.sh app nginx 1 2 5 80

#!/bin/bash