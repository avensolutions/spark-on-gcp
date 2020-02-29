**spark-on-gcp**
==============
Demostration of the different ways Apache Spark can be deployed on the Google Cloud Platform.  Including Cloud DataProc, Spark Standalone deployed on GKE and Spark on Kubernetes.  

This repository accompanies the [Spark in the Google Cloud Platform Part 1](https://www.cloudywithachanceofbigdata.com/spark-in-the-google-cloud-platform-part-1/) and [Spark in the Google Cloud Platform Part 2](https://www.cloudywithachanceofbigdata.com/spark-in-the-google-cloud-platform-part-2/) blogs.  

```powershell
PS > .\run.ps1 private-network apply <<gcp-project>> <<region>>
PS > .\run.ps1 gke apply <<gcp-project>> <<region>> 
```