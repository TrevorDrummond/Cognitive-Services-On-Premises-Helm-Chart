# On-premises Cognitive Service
On-premises Cognitive（henceforth referred to as **Cognitive-onprem**) Service enable customer to build one Cognitive service that is optmized to take advantage of both robust cloud capabilities and edge locality, based on customer's on-premises requirements. This **Cognitive-onprem** service supports component services **Speech-to-text**, **text-to-Speech**, **Text Analytics** and **Text Translation**, which customers can choose to enable any or all of them.

## Introduction
This chart deploys [Cognitive Service containers](https://docs.microsoft.com/en-us/azure/cognitive-services/Cognitive-service/Cognitive-container-howto) on a [Kubernetes](http://kubernetes.io) by [Helm](https://helm.sh).<br/>
This chart supports the deployment of multiple services: <br/>
* **Speech-to-text**
* **text-to-Speech**
* **Text Analytics**
* **Text Translation**

User is able to deploy any or all services. <br/>

This chart supports `helm test` command. User is able to apply this command to verify Cognitive service is running properly.
## Prerequisites
- Helm 2.12.3, Kubernetes 1.12.2
- Helm 2.14.0, Kubernetes 1.14.1

## Resources Required
Please read [Cognitive Service container computing resource](https://docs.microsoft.com/en-us/azure/cognitive-services/Cognitive-service/Cognitive-container-howto#the-host-computer) as a reference.

This Helm chart automatically calculates CPU and memory requirements base on how many decodes (concurrent requests) that user specifies and also whether optimization for audio/text input is enabled. <br/>
This Helm chart sets 2 concurrent requests and optimization disabled as default.

|Service| CPU/container | Memory/container|
|---|---|---|
|Cognitive-to-text| 1 decoder requires minimum 1250 milli cores <br/> If optimization is enabled, requires 2150 milli cores| Request: 4GB<br/> Limited: 8GB|
|Text-to-Cognitive| 1 concurrency requires minimum 600 milli cores<br> If optimization is enabled, requires 1200 milli cores| Request: 2GB<br/> Limited: 3GB|

## Installing the Chart
1. To deploy Cognitive Service in kubernetes cluster, two sample files are provided as a reference under dir `Cognitive-onprem/tests`<br/>

   * `sample-deployment.yaml`<br/>
   * `multi-decoders-sample-deployment.yaml`<br/>
   * `serviceannotation-sample-deployment.yaml` <br/>
   * `CognitiveToText-only-plus-sentiment-deployment.yaml` <br/>
   * `CognitiveToText-only-deployment.yaml` <br/>
   * `textToCognitive-only-deployment.yaml` <br/>

2. To install `Cognitive-onprem` helm chart, run
    ```
    helm install <PATH_TO_Cognitive_ONPREM_ON_YOUR_LOCAL> \
             --values <PATH_TO_YOUR_CUSTOMIZED_VALUES_FILE> \
             --name <RELEASE_NAME>
    ```
    To apply your own docker repo secret, use `--set ` argument
    ```
    helm install <PATH_TO_Cognitive_ONPREM_ON_YOUR_LOCAL> \
             --set CognitiveToText.image.pullSecrets={<YOUR_OWN_SECRET_NAME>},textToCognitive.image.pullSecrets={YOUR_OWN_SECRET_NAME} \
             --values <PATH_TO_YOUR_CUSTOMIZED_VALUES_FILE> \
             --name <RELEASE_NAME>
    ```

    i.e. `Cognitive-onprem` helm chart is located under Windows D: drive on my local. Commands below access it via WindowsLinuxSubsystem (WSL). <br/>
    ```
    helm install Cognitive-onprem \
            --values Cognitive-onprem/test/sample-deployment.yaml \
            --name onprem-sample
    ```
    ```
    helm install Cognitive-onprem \
            --set CognitiveToText.image.pullSecrets={my-container-preview},textToCognitive.image.pullSecrets={my-container-preview} \
            --values Cognitive-onprem/test/sample-deployment.yaml \
            --name onprem-sample
    ```

3. This chart supports `helm test` command. It creates `Cognitive-to-text-readiness-test` and `text-to-Cognitive-readiness-test` pods in the cluster to verify `Cognitive-to-text` and `text-to-Cognitive` services are running successfully.
    ```
    helm test <RELEASE_NAME>
    ```
    i.e.
    ```
    helm test onprem-sample
    ```

## Configuration
The Helm chart ships with reasonable defaults. However, since it is named on-premises, it should definitely support customization and configuration overrides.<br/>
To apply customized configurations,
1. override helm values though command: <br/>
[`helm install --set <KEY>=<VALUE> ...`](https://helm.sh/docs/helm/#options-21)
2. create a new separate **values.yaml** file and apply it through command:<br/>
[`helm install --values <YOUR_VALUES_FILE_PATH>`](https://helm.sh/docs/helm/#options-21)

Please check below sections for the details of configurable options of the Helm chart.

> **Note**: configurable options may change in future.

### Cognitive-ONPREM (umbrella chart)
> Values in umbrella chart override the corresponding sub-chart values.<br/>
> Therefore, if user chooses .yaml file to apply on-premises customized values, it should follow one of the methods below:<br/>
> 1. added in umbrella chart values.yaml file. <br/>
> 2. create a new separate .yaml file to override. <br/>
>
> No customized values in sub-chart values.yaml, <br/>
> No customized values in sub-chart values.yaml, <br/>
> No customized values in sub-chart values.yaml. <br/>

|Parameter|Description|Values|Default|
| --- | --- | --- | --- |
|`CognitiveToText.enabled`|Specifies whether enable **Cognitive-to-text** service| true/false| `true` |
|`CognitiveToText.verification.enabled`| Specifies whether enable `helm test` capability for **Cognitive-to-text** service | true/false | `true` |
|`CognitiveToText.verification.image.registry`| Specifies docker image repository that `helm test` uses to test **Cognitive-to-text** service. Helm creates separate pod inside the cluster for testing and pulls the test-use image from this registry| valid docker registry | `docker.io`|
|`CognitiveToText.verification.image.repository`| Specifies docker image repository that `helm test` uses to test **Cognitive-to-text** service. Helm test pod uses this repository to pull test-use image| valid docker image repository |`antsu/on-prem-client`|
|`CognitiveToText.verification.image.tag`| Specifies docker image tag that used `helm test` for **Cognitive-to-text** service. Helm test pod uses this tag to pull test-use image | valid docker image tag | `latest`|
|`CognitiveToText.verification.image.pullByHash`| Specifies whether test-use docker image is pulled by hash.<br/> If `yes`, `CognitiveToText.verification.image.hash` should be added, with valid image hash value. <br/> It's `false` by default.|true/false| `false`|
|`CognitiveToText.verification.image.arguments`| Specifies the arguments to execute test-use docker image. Helm test pod passes these arguments to container when running `helm test`| valid arguments as the test docker image requires |`"./Cognitive-to-text-client"`<br/> `"./audio/whatstheweatherlike.wav"` <br/> `"--expect=What's the weather like"`<br/>`"--host=$(Cognitive_TO_TEXT_HOST)"`<br/>`"--port=$(Cognitive_TO_TEXT_PORT)"`|
|`textToCognitive.enabled`|Specifies whether enable **text-to-Cognitive** service| true/false| `true` |
|`textToCognitive.verification.enabled`| Specifies whether enable `helm test` capability for **text-to-Cognitive** service | true/false | `true` |
|`textToCognitive.verification.image.registry`| Specifies docker image repository that `helm test` uses to test **text-to-Cognitive** service. Helm creates separate pod inside the cluster for testing and pulls the test-use image from this registry| valid docker registry | `docker.io`|
|`textToCognitive.verification.image.repository`| Specifies docker image repository that `helm test` uses to test **text-to-Cognitive** service. Helm test pod uses this repository to pull test-use image| valid docker image repository |*`antsu/on-prem-client`*|
|`textToCognitive.verification.image.tag`| Specifies docker image tag that used `helm test` for **text-to-Cognitive** service. Helm test pod uses this tag to pull test-use image | valid docker image tag | `latest`|
|`textToCognitive.verification.image.pullByHash`| Specifies whether test-use docker image is pulled by hash.<br/> If `yes`, `textToCognitive.verification.image.hash` should be added, with valid image hash value. <br/> It's `false` by default.|true/false| `false`|
|`textToCognitive.verification.image.arguments`| Specifies the arguments to execute test-use docker image. Helm test pod passes these arguments to container when running `helm test`| valid arguments as the test docker image requires |`"./text-to-Cognitive-client"`<br/> `"--input='What's the weather like'"` <br/> `"--host=$(TEXT_TO_Cognitive_HOST)"`<br/>`"--port=$(TEXT_TO_Cognitive_PORT)"`|

### Cognitive-TO-TEXT (subchart: charts/CognitiveToText)
> Again, no customized values in sub-chart values.yaml! <br/>
>
> Add prefix `CognitiveToText.` on any parameter below into your own .yaml file/umbrella chart's values.yaml can override the corresponding values here. <br/>
> i.e. `CognitiveToText.numberOfConcurrentRequest` overrides `numberOfConcurrentRequest`.<br/>

|Parameter|Description|Values|Default|
| --- | --- | --- | --- |
|`enabled`| Specifies whether enable **Cognitive-to-text** service| true/false| `false`|
|`numberOfConcurrentRequest`| Specifies how many concurrent requests for **Cognitive-to-text** service.<br/> This chart automatically calculate CPU and memory resources, based on this value.| int | `2` |
|`optimizeForAudioFile`| Specifies if service needs to optimize for audio input via audio file. <br/> If `yes`, this chart will allocate more CPU resource to service. <br/> Default is `false`| true/false |`false`|
|`image.registry`| Specifies the **Cognitive-to-text** docker image registry| valid docker image registry| |
|`image.repository`| Specifies the **Cognitive-to-text** docker image repository| valida docker image repository| |
|`image.tag`| Specifies the **Cognitive-to-text** docker image tag| valid docker image tag| |
|`image.pullSecrets`| Specifies the image secrets for pulling **Cognitive-to-text** docker image| valida secrets name| |
|`image.pullByHash`| Specifies if pulling docker image by hash.<br/> If `yes`, `image.hash` is required to have as well.<br/> If `no`, set it as 'false'. Default is `false`.| true/false| `false`|
|`image.hash`| Specifies **Cognitive-to-text** docker image hash. Only use it when `image.pullByHash:true`.| valid docker image hash | |
|`image.args.eula`| One of the required arguments by **Cognitive-to-text** container, which indicates you've accepted the license.<br/> The value of this option must be: accept| `accept`, if you want to use the container | |
|`image.args.billing`| One of the required arguments by **Cognitive-to-text** container, which specifies the billing endpoint URI<br/> The billing endpoint URI value is available on the Azure portal's Cognitive Overview page.|valid billing endpoint URI||
|`image.args.apikey`| One of the required arguments by **Cognitive-to-text** container, which is used to track billing information.| valid apikey||
|`service.type`| Specifies the type of **Cognitive-to-text** service in Kubernetes. <br/> [Kubernetes Service Types Instruction](https://kubernetes.io/docs/concepts/services-networking/service/)<br/> Default is `LoadBalancer` (please make sure you cloud provider supports) | valid Kuberntes service type | `LoadBalancer`|
|`service.port`| Specifies the port of **Cognitive-to-text** service| int| `80`|
|`service.annotations`| The annotations user can add to **Cognitive-to-text** service metadata. For instance:<br/> **annotations:**<br/>`   ` **some/annotation1: value1**<br/>`  ` **some/annotation2: value2** | annotations, one per each line| |
|`serivce.autoScaler.enabled`| Specifies if enable [Horizontal Pod Autoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)<br/> If enabled, `Cognitive-to-text-autoscaler` will be deployed in the Kubernetes cluster | true/false| `true`|
|`service.podDisruption.enabled`| Specifies if enable [Pod Disruption Budget](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/)<br/> If enabled, `Cognitive-to-text-poddisruptionbudget` will be deployed in the Kubernetes cluster| true/false| `true`|

####Text Analytics Support
From Cognitive-to-text onprem container 2.2.0, it supports sentiment analysis feature. This feature is back supported by Text Analytics service. <br/>
In order to support such feature in Cognitive Onprem Helm Chart, below parameters are added to Cognitive-To-Text subchart. <br/>

|Parameter|Description|Values|Default|
| --- | --- | --- | --- |
|`textanalytics.enabled`| Specifies whether enable **text-analytics** service| true/false| `false`|
|`textanalytics.image.registry`| Specifies the **text-analytics** docker image registry| valid docker image registry| |
|`textanalytics.image.repository`| Specifies the **text-analytics** docker image repository| valida docker image repository| |
|`textanalytics.image.tag`| Specifies the **text-analytics** docker image tag| valid docker image tag| |
|`textanalytics.image.pullSecrets`| Specifies the image secrets for pulling **text-analytics** docker image| valida secrets name| |
|`textanalytics.image.pullByHash`| Specifies if pulling docker image by hash.<br/> If `yes`, `image.hash` is required to have as well.<br/> If `no`, set it as 'false'. Default is `false`.| true/false| `false`|
|`textanalytics.image.hash`| Specifies **text-analytics** docker image hash. Only use it when `image.pullByHash:true`.| valid docker image hash | |
|`textanalytics.image.args.eula`| One of the required arguments by **text-analytics** container, which indicates you've accepted the license.<br/> The value of this option must be: accept| `accept`, if you want to use the container | |
|`textanalytics.image.args.billing`| One of the required arguments by **text-analytics** container, which specifies the billing endpoint URI<br/> The billing endpoint URI value is available on the Azure portal's Cognitive Overview page.|valid billing endpoint URI||
|`textanalytics.image.args.apikey`| One of the required arguments by **text-analytics** container, which is used to track billing information.| valid apikey||
|`textanalytics.cpuRequest`| Specifies the requested CPU for **text-analytics** container| int| `3000m`|
|`textanalytics.cpuLimit`| Specifies the limited CPU for **text-analytics** container| | `8000m`|
|`textanalytics.memoryRequest`| Specifies the requested memory for **text-analytics** container| | `6Gi`|
|`textanalytics.memoryLimit`| Specifies the limited memory for **text-analytics** container| | `8Gi`|
|`textanalytics.service.sentimentURISuffix`| Specifies sentiment analysis URI suffix, the whole URI is in format "http://`<service>`:`<port>`/`<sentimentURISuffix>`". | | `text/analytics/v3.0-preview/sentiment`|
|`textanalytics.service.type`| Specifies the type of **text-analytics** service in Kubernetes. <br/> [Kubernetes Service Types Instruction](https://kubernetes.io/docs/concepts/services-networking/service/)<br/> Default is `LoadBalancer` (please make sure you cloud provider supports) | valid Kuberntes service type | `LoadBalancer`|
|`textanalytics.service.port`| Specifies the port of **text-analytics** service| int| `50085`|
|`textanalytics.service.annotations`| The annotations user can add to **text-analytics** service metadata. For instance:<br/> **annotations:**<br/>`   ` **some/annotation1: value1**<br/>`  ` **some/annotation2: value2** | annotations, one per each line| |
|`textanalytics.serivce.autoScaler.enabled`| Specifies if enable [Horizontal Pod Autoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)<br/> If enabled, `text-analytics-autoscaler` will be deployed in the Kubernetes cluster | true/false| `true`|
|`textanalytics.service.podDisruption.enabled`| Specifies if enable [Pod Disruption Budget](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/)<br/> If enabled, `text-analytics-poddisruptionbudget` will be deployed in the Kubernetes cluster| true/false| `true`|

### TEXT-TO-Cognitive (subchart: charts/textToCognitive)
> Again, no customized values in sub-chart values.yaml! <br/>
>
> Add prefix `textToCognitive.` on any parameter below into your own .yaml file/umbrella chart's values.yaml can override the corresponding values here. <br/>
> i.e. `textToCognitive.numberOfConcurrentRequest` overrides `numberOfConcurrentRequest`.<br/>

|Parameter|Description|Values|Default|
| --- | --- | --- | --- |
|`enabled`| Specifies whether enable **text-to-Cognitive** service| true/false| `false`|
|`numberOfConcurrentRequest`| Specifies how many concurrent requests for **text-to-Cognitive** service.<br/> This chart automatically calculate CPU and memory resources, based on this value.| int | `2` |
|`optimizeForTurboMode`| Specifies if service needs to optimize for high usage. <br/> If `yes`, this chart will allocate more CPU resource to service. <br/> Default is `false`| true/false |`false`|
|`image.registry`| Specifies the **text-to-Cognitive** docker image registry| valid docker image registry| |
|`image.repository`| Specifies the **text-to-Cognitive** docker image repository| valida docker image repository| `|
|`image.tag`| Specifies the **text-to-Cognitive** docker image tag| valid docker image tag| |
|`image.pullSecrets`| Specifies the image secrets for pulling **text-to-Cognitive** docker image| valida secrets name||
|`image.pullByHash`| Specifies if pulling docker image by hash.<br/> If `yes`, `image.hash` is required to have as well.<br/> If `no`, set it as 'false'. Default is `false`.| true/false| `false`|
|`image.hash`| Specifies **text-to-Cognitive** docker image hash. Only use it when `image.pullByHash:true`.| valid docker image hash | |
|`image.args.eula`| One of the required arguments by **text-to-Cognitivet** container, which indicates you've accepted the license.<br/> The value of this option must be: accept| `accept`, if you want to use the container | |
|`image.args.billing`| One of the required arguments by **text-to-Cognitive** container, which specifies the billling endpoint URI<br/> The billing endpoint URI value is available on the Azure portal's Cognitive Overview page.|valid billing endpoint URI||
|`image.args.apikey`| One of the required arguments by **text-to-Cognitive** container, which is used to track billing information.| valid apikey||
|`service.type`| Specifies the type of **text-to-Cognitive** serivce in Kubernetes. <br/> [Kubernetes Service Types Instruction](https://kubernetes.io/docs/concepts/services-networking/service/)<br/> Default is `LoadBalancer` (please make sure you cloud provider supports) | valid Kuberntes service type | `LoadBalancer`|
|`service.port`| Specifies the port of **text-to-Cognitive** service| int| `80`|
|`service.annotations`| The annotations user can add to **text-to-Cognitive** service metadata. For instance:<br/> **annotations:**<br/>`   ` **some/annotation1: value1**<br/>`  ` **some/annotation2: value2** | annotations, one per each line| |
|`serivce.autoScaler.enabled`| Specifies if enable [Horizontal Pod Autoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)<br/> If enabled, `text-to-Cognitive-autoscaler` will be deployed in the Kubernetes cluster | true/false| `true`|
|`service.podDisruption.enabled`| Specifies if enable [Pod Disruption Budget](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/)<br/> If enabled, `text-to-Cognitive-poddisruptionbudget` will be deployed in the Kubernetes cluster| true/false| `true`|

## Helm Test
A test-purpose docker image has been created and is available at [docker.io/antsu/on-prem-client:latest](https://hub.docker.com/r/antsu/on-prem-client). <br/>
User can create your own customized test docker image based (or not) on it to add more testing features if you want.<br/>
<br/>
To modify the existing `helm test` feature inside helm chart, or to apply your own customized test docker image, follow the `CognitiveToText.verification` and `textToCognitive.verification` sections in umbrella chart's `values.yaml` as a sample. Those values are open to replace by yours. <br/>
<br/>
To get Helm tests run, please read [Helm Test Command Instruction](https://helm.sh/docs/helm/#helm-test). Basically, the command should be:<br/>
```
helm test <RELEASE_NAME>
```

## Uninstalling the Chart
To uninstall or delete `Cognitive-onprem` completely, run:<br/>
```
helm del --purge <RELEASE_NAME>
```