#!/bin/bash
#This script to create VPC and Subnet in My test A/C
Vpc() {
read -p "Please enter the VPC and CIDR Block (Ex 11.0.0.0/16) : " CIRD
aws ec2 create-vpc --cidr-block $CIRD >> $LOG
}

Subnet () {
S=`aws ec2 describe-vpcs  --query  'Vpcs[0].VpcId'`
SUB=`echo $S | tr -d '"'`
read -p "please enter the Subnet and CIDR Block (Ex. 11.0.1.0/24) :" NET
aws ec2 create-subnet --vpc-id $SUB --cidr-block $NET >>$LOG

}
Public () {
echo "Creating You Internet Gatway"
aws ec2 create-internet-gateway >> $LOG
I=`aws ec2 describe-internet-gateways --query 'InternetGateways[0]'.'InternetGatewayId'`
IG=`echo $I | tr -d '"'`
aws ec2 attach-internet-gateway --vpc-id $SUB --internet-gateway-id $IG >>$LOG
echo "Creating Route Table for you VPC $SUB"
aws ec2 create-route-table --vpc-id $SUB >>$LOG
R=`aws ec2 describe-route-tables --query 'RouteTables[0]'.'RouteTableId'`
RT=`echo $R | tr -d '"'`
echo "Attaching your Route table t You internet Gatway - $IG"
aws ec2 create-route --route-table-id $RT --destination-cidr-block 0.0.0.0/0 --gateway-id $IG >>$LOG
aws ec2 describe-route-tables --route-table-id $RT >>$LOG
echo ""
echo  "Please choose the Subnet Which you want to make as Public ?"
echo ` aws ec2 describe-subnets --query 'Subnets[*]'.'SubnetId' --filter "Name=vpc-id,Values=$SUB"`
read -p "Please Enter the Subnet ID here (Without quotes): " FORPUB
aws ec2 associate-route-table  --subnet-id $FORPUB --route-table-id $RT >> $LOG
}
#****************Function END************
#Script Starts
read -p "Please Enter the File Name to Store the Logs: " LOG
Vpc #Calling the First Function

read -p "How Many Subnet You Want to Create ? " ANS
COUNT=1
while [ $COUNT -le $ANS ]
do
Subnet #Calling the Second Function 
COUNT=`expr $COUNT + 1`
done 
echo "You are susseccfully created $ANS Subnet(s)"
read -p "Do You Want to Make You Subnet  as Public Subnet ? (Y/y)" PUB

if [ "$PUB" == "Y" ] || [ "$PUB" == "y" ]
then 
Public #Calling Thrid Fun
read -p "Do You want Enable Public IP assign Automatically (Y/y)? " AUTO
if [ "$AUTO" == "Y" ] || [ "$AUTO" == "y" ]
then
aws ec2 modify-subnet-attribute --subnet-id $FORPUB  --map-public-ip-on-launch
else
echo "You Have Not choosen Y so You have to assign EIP for you Instance"
fi
fi
echo "================"

echo "Thank you"
echo "Creating Logs are Stored in $LOG have a look t for More information"
