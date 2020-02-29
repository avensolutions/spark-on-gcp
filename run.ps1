#
# Powershell Script to Create Private Networking, GKE and DataProc Infrastructure Using Terraform
#
# Prerequisites:
#	Enable Powershell Scripts by
#		Opening Powershell using the 'Run As Administrator' option
#		Run the following command:
#			Set-ExecutionPolicy unrestricted
#		Exit Powershell
#	Authenticate anc Configure Client Connection to GCP
#		gcloud auth application-default login
#		gcloud config set project <<project>>
#
#
# Usage from Powershell:
#	run.ps1 [module] [apply | plan | destroy]
#		example:
#			run.ps1 private-network (plan only)
#			run.ps1 private-network apply <<project>> <<region>>
#	

$Env:PYTHONIOENCODING = "UTF-8"

$global:terraformloc = "C:\Terraform\terraform"

$module = $args[0]
$action = $args[1]
$project = $args[2]
$region = $args[3]

$cwd = Get-Location

$module_path = "${cwd}\modules\" + $module

Write-Output "Module selected: ${module}"

# Check if module is valid
if (-not (Test-Path $module_path)) {
	Write-Output "Module ${module_path} does not exist!"
	Exit
}

# Check for variables.tfvars file
$global:tfvars_file = "${module_path}\variables.tfvars"
if (-not (Test-Path $tfvars_file -PathType Leaf)) {
	Write-Output "${tfvars_file} file does not exist!"
	Exit
}

# change directory into module path
cd $module_path

function Invoke-TFAction
{
	param([string]$action, [string]$module, [string]$module_path)
	if ($module -eq "dataproc") {
		if ($action -eq "apply") {
			Write-Output "Running gcloud command to deploy dataproc cluster..."
			$values = Get-Content "variables.tfvars" | Out-String | ConvertFrom-StringData
			$cmd = "gcloud beta dataproc clusters create"
			$cmd += " spark-cluster" 
			$cmd += " --enable-component-gateway"
			$cmd += " --bucket " + $values.staging_bucket_name
			$cmd += " --region ${region}"
			$cmd += " --subnet regional-subnet"
			$cmd += " --no-address"
			$cmd += " --zone " + $values.zone
			$cmd += " --master-machine-type " + $values.master_machine_type
			$cmd += " --master-boot-disk-size " + $values.master_boot_disk_size_gb
			$cmd += " --num-workers " + $values.worker_instances 
			$cmd += " --worker-machine-type " + $values.worker_machine_type
			$cmd += " --worker-boot-disk-size " + $values.worker_boot_disk_size_gb
			$cmd += " --image-version 1.3-deb9 "
			$cmd += " --optional-components ANACONDA,JUPYTER"
			$cmd += " --project ${project}"
			$cmd += " --initialization-actions 'gs://dataproc-initialization-actions/stackdriver/stackdriver.sh'"
			Invoke-Expression "${cmd}"
		} else {
			Write-Output "dataproc module only supports the apply action"
		}
	} else {
		# terraform module
		Write-Output "Running terraform init for module [${module}]"
		Invoke-Expression "${terraformloc} init"
		Write-Output "Running terraform $action for module [${module}]"
		Invoke-Expression "${terraformloc} $action -var='project=${project}' -var='region=${region}' -var-file=${tfvars_file} ${module_path}"
	}
}

switch ($action) {
	"plan"  {"plan selected..."; break}
	"apply"   {"apply selected..."; break}
	"destroy" {"destroy selected..."; break}
	default {"incorrect or unsupplied actiion, planing only..."; $action = "plan"; break}
 }

 Invoke-TFAction $action $module $module_path

 cd $cwd