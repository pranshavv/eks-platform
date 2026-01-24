import boto3
import subprocess
import sys


REGION = "ap-south-1"
TARGET_VPC_ID = "vpc-0465451dfb730f120"

def run(cmd):
    print(f">>> {cmd}")
    r = subprocess.run(cmd, shell=True)
    if r.returncode != 0:
        sys.exit(1)

ec2 = boto3.client("ec2", region_name=REGION)

# --- VPC ---
#print("Importing VPC:", TARGET_VPC_ID)
#run(f"terraform import aws_vpc.main {TARGET_VPC_ID}")

# --- Subnets ---
subnet_map = {
    "10.0.0.0/24": "public_a",
    "10.0.1.0/24": "public_b",
    "10.0.10.0/24": "private_a",
    "10.0.11.0/24": "private_b",
}

subnets = ec2.describe_subnets(
    Filters=[{"Name": "vpc-id", "Values": [TARGET_VPC_ID]}]
)["Subnets"]

for s in subnets:
    cidr = s["CidrBlock"]
    if cidr in subnet_map:
        run(f"terraform import aws_subnet.{subnet_map[cidr]} {s['SubnetId']}")

# --- Internet Gateway ---
igws = ec2.describe_internet_gateways(
    Filters=[{"Name": "attachment.vpc-id", "Values": [TARGET_VPC_ID]}]
)["InternetGateways"]

if igws:
    run(f"terraform import aws_internet_gateway.igw {igws[0]['InternetGatewayId']}")

# --- Route Table ---
route_tables = ec2.describe_route_tables(
    Filters=[
        {"Name": "vpc-id", "Values": [TARGET_VPC_ID]},
        {"Name": "tag:Name", "Values": ["eks-public-rt"]},
    ]
)["RouteTables"]

if route_tables:
    rt = route_tables[0]
    rt_id = rt["RouteTableId"]
    run(f"terraform import aws_route_table.public {rt_id}")

    for assoc in rt["Associations"]:
        if assoc.get("SubnetId"):
            subnet_id = assoc["SubnetId"]
            if subnet_id.endswith("a"):
                tf_assoc = "public_a"
            else:
                tf_assoc = "public_b"

            run(
                f"terraform import aws_route_table_association.{tf_assoc} "
                f"{rt_id}/{subnet_id}"
            )

print("\n✅ Import complete. Next: terraform plan")




