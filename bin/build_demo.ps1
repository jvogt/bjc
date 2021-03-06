<#

.SYNOPSIS
Deploys a Chef Demo environment on a target cloud platform.

.EXAMPLE
./build_demo.ps1 [cloud platform] [demo-version] [customer name or description] [your aws key name] [hours to keep the demo up] [your name] [your department] [your region]

Deploy latest stable version on AWS
./build_demo.ps1 aws stable 'Paper Street' my_key_pair 4 'Tyler Durden' 'Sales' 'NA-East'

Deploy latest stable version on Azure
./build_demo.ps1 azure stable 'Paper Street' my_key_pair 4 'Tyler Durden' 'Sales' 'NA-East'

Depoly a specific version on AWS
./build_demo.ps1 aws 4.5.4 'Paper Street' my_key_pair 4 'Tyler Durden' 'Sales' 'NA-East'

Deploy a specific version on Azure
./build_demo.ps1 azure 4.5.4 'Paper Street' my_key_pair 4 'Tyler Durden' 'Sales' 'NA-East'

.LINK
https://github.com/chef-cft/bjc

#>

[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=1)]
    [string]$cloud,

  [Parameter(Mandatory=$True,Position=2)]
    [string]$version,

  [Parameter(Mandatory=$True,Position=3)]
    [string]$customer,

  [Parameter(Mandatory=$True,Position=4)]
    [string]$ssh_key,

  [Parameter(Mandatory=$True,Position=5)]
    [string]$ttl,

  [Parameter(Mandatory=$True,Position=6)]
    [string]$contact,

  [Parameter(Mandatory=$True,Position=7)]
    [string]$department,

  [Parameter(Mandatory=$True,Position=8)]
    [string]$location
)

# Only supported in us-west-2 for now
$region_aws="us-west-2"
$region_azure="westus"

# Strip spaces from customer name
$customer = $customer -replace '\s','-'

# Calculate and format X-Termination-Date
$utc_date = (Get-Date).ToUniversalTime()
$termination_date = Get-Date($utc_date).AddHours($ttl)
$utc_date = Get-Date -date $utc_date -format "yyyyMMddTHHmmssZ"
$termination_date = Get-Date -date $termination_date -format "yyyy-MM-ddTHH:mm:ssZ"

$stack_name = "$env:USERNAME-$customer-Chef-Demo-$utc_date"

# Here's where we create the stack
switch ($cloud)
{
  'aws'
  {
    write-host "Creating $cloud $version demo..."
    aws cloudformation create-stack --stack-name "$stack_name" --capabilities CAPABILITY_IAM --region $region_aws --tags Key=X-TTL,Value=$ttl Key=TTL,Value=$ttl Key=X-Contact,Value="$contact" Key=X-Dept,Value="$department" Key=X-Customer,Value="$customer" Key=X-Project,Value="BJC-Demo" Key=X-Termination-Date,Value=$termination_date Key=X-Application,Value=$location --template-url https://s3-us-west-2.amazonaws.com/bjcpublic/cloudformation/bjc-demo-$cloud-$version.json --parameters ParameterKey=KeyName,ParameterValue=$ssh_key ParameterKey=TTL,ParameterValue=$ttl
  }
  'azure'
  {
    write-host "Creating $cloud $version demo..."

    az group create -l $region_azure -n "$stack_name" --tags X-TTL=$ttl X-Contact="$contact" X-Dept="$department" X-Customer="$customer" X-Project="BJC-Demo" X-Termination-Date=$termination_date X-Application="$application"

    az group deployment create -g "$stack_name" --template-uri https://s3-us-west-2.amazonaws.com/bjcpublic/cloudformation/bjc-demo-$cloud-$version.json

    #TODO:Push tags from resource group down to all resources
  }
  default
  {
    write-host "$cloud cloud platform is not currently supported"
    write-host "Please submit an issue to https://github/chef-cft/bjc to request a new platform."
  }
}
