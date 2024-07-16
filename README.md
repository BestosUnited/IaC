# IaC
Infrastructure as Code Repository to lift the resources in Azure

## How to use

### Prerequisites
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

### Deployment
1. Clone the repository
2. Login to Azure CLI
    ```bash
    az login
    ```
3. Change to the directory `iac`
    ```bash
    cd iac
    ```
4. Initialize the Terraform working directory
    ```bash
    terraform init
    ```
5. Create an execution plan
    ```bash
    terraform plan
    ```
6. Apply the changes
    ```bash
    terraform apply
    ```

### Destroy
1. Change to the directory `iac`
    ```bash
    cd iac
    ```
2. Destroy the resources
    ```bash
    terraform destroy
    ```

### Resources
- [Azure](https://azure.microsoft.com/en-us/)

### References
- [Terraform](https://www.terraform.io/)
- [Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

### License
This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

### Author
- [Jorge Rubiano](https://jorger.dev/)

### Acknowledgments
- [HashiCorp](https://www.hashicorp.com/)
- [Microsoft](https://www.microsoft.com/)
- [Azure](https://azure.microsoft.com/)
- [GitHub](