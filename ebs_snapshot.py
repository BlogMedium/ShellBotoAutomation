import boto3


ec = boto3.client('ec2')
def lambda_handler():

    reservations = ec.describe_instances(
        Filters=[
            {'Name': 'tag-key', 'Values': ['backup', 'Backup']},
        ]
    ).get(
        'Reservations', []
    )
    #print(reservations)
    for reservation in reservations:
        for instance in reservation['Instances']:
            for block_device_mapping in instance['BlockDeviceMappings']:
                volume_id = block_device_mapping['Ebs']['VolumeId']
                print("VolumeId:", volume_id)
                response = ec.create_snapshot(
                    VolumeId=volume_id
                )
                status_code = response['ResponseMetadata']['HTTPStatusCode']
                snapshot_id = response['SnapshotId']
                # check if status_code was 200 or not to ensure the snapshot was created successfully
                if status_code == 200:
                    print("snapshotcreated succesfully")
                    return snapshot_id

lambda_handler()
