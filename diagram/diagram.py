from diagrams import Cluster, Diagram
from diagrams.aws.general import Client
from diagrams.aws.compute import EC2
from diagrams.onprem.network import Nginx

with Diagram("TFE Valid certs", show=False, direction="TB"):
    
    client = Client("Client")

    with Cluster("AWS"):
        tfe_instance = [EC2("Terraform Enterprise")]

    terraform_web = Nginx("registry.terraform.io")

    client >> tfe_instance >> terraform_web