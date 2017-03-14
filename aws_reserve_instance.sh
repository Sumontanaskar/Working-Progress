import boto3
import csv
import os
count = 0

Region_name = 'ap-southeast-1'

DeviceName = 0
Value = 0
reserver = 'None'
platform = 0
instance_type = 0
zone = 0
i = 0
client = boto3.resource('ec2',
        aws_access_key_id='xxx',
        aws_secret_access_key='xxx',
        region_name=Region_name)

instances = client.instances.filter(
    Filters=[{'Name': 'instance-state-name', 'Values': ['running']}])

#create CSV file
os.remove("aws_instane_details.csv")
f = open('aws_instane_details.csv', 'a+')
fieldnames = ['Instance_name', 'instance_id', 'instance_type', 'vpc_id', 'Platform', 'State', 'AvailabilityZone','Reserved/On-demand' ]
writer = csv.DictWriter(f, fieldnames=fieldnames)

#Reserved confition check
def if_reserver( instance_type, platform, zone):
    print instance_type, platform, zone
    for j in range(i):
       # print elements[j][0]
        if platform == elements[j][0]:
     #       print 'instance_type, elements[j][1]', instance_type, elements[j][1]
            if instance_type == elements[j][1]:
      #          print 'elements[j][2]zone', zone, elements[j][2]
                if (zone == elements[j][2] or elements[j][2] == 'Region') and (elements[j][3] != 0):
                    int = elements[j][3]
       #             print 'int, elements[j][3]', int, elements[j][3]
                    elements[j][3] = int - 1
                    return 'Reserved'
                else:
                    pass
            else:
                pass

        else:
            pass

#====================================================
#Reserve instance details collection and put it in array

client = boto3.client('ec2',
        aws_access_key_id='xxx',
        aws_secret_access_key='xxx',
        region_name=Region_name)

response = client.describe_reserved_instances(
    Filters=[{'Name': 'state', 'Values': ['active']}])

#print response
elements = []

i = 0

for list in response['ReservedInstances']:
        ProductDescription = list['ProductDescription']
        InstanceType = list['InstanceType']
        State =  list['State']
        Duration = list['Duration']
        InstanceCount = list['InstanceCount']
        Scope = list['Scope']
        Scope = str(Scope)
        if Scope == 'Availability Zone':
            Scope = list['AvailabilityZone']
        else:
            AvailabilityZone = 'None'
       # print ProductDescription, InstanceType, State, Duration, Scope, InstanceCount
        elements.append([])
        global i
        elements[i].append(ProductDescription)
        elements[i].append(InstanceType)
        elements[i].append(Scope)
        elements[i].append(InstanceCount)
        i +=1

print elements
#==================================


#Formatting data
for instance in instances:
    q = instance.state
    p = instance.block_device_mappings
    for data in p:
        DeviceName = data['DeviceName']
   #     print DeviceName

    val = instance.tags
    for list in val:
        Value = list['Value']
    place = instance.placement
    zone = place['AvailabilityZone']
  #  print DeviceName, Value
#instance platform recheck
    platform = str(instance.platform)
    vpc_id = str(instance.vpc_id)
    if platform == 'windows':
        platform = 'Windows'
    else:
        pass
    if (vpc_id=='None' and platform=='None'):
        platform = 'Linux/UNIX'
    elif(vpc_id!='None' and platform == 'None'):
        platform = 'Linux/UNIX (Amazon VPC)'
    else:
        pass
    #Reserved check define here
    reserver = if_reserver( instance.instance_type, platform, zone )

    print(instance.id, instance.instance_type, vpc_id, platform, zone, reserver )

#Storing Data in CSV file
    if count == 0:
        writer.writeheader()
        writer.writerow({'Instance_name': Value, 'instance_id': instance.id, 'instance_type': instance.instance_type, 'vpc_id': vpc_id, 'Platform': platform, 'State': q['Name'], 'AvailabilityZone': zone, 'Reserved/On-demand': reserver})
        count += 1
    else:
        writer.writerow({'Instance_name': Value, 'instance_id': instance.id, 'instance_type': instance.instance_type, 'vpc_id': vpc_id, 'Platform': platform, 'State': q['Name'], 'AvailabilityZone': zone, 'Reserved/On-demand': reserver})
    count += 1
f.close()

