param systemTopicName string = 'systopic-${uniqueString(resourceGroup().id)}'
param RGCreationEventSubscriptionName string = 'RGCreation'
param VMCreationEnrollVMintoBackupEventSubscriptionName string = 'VMCreation-EnrollVMintoBackup'
param VMCreationEnrollVMintoMonitoringEventSubscriptionName string = 'VMCreation-EnrollVMintoMonitoring'
param functionAppName string
param CreateRSVandBackupPoliciesFunctionName string = 'CreateRSVandBackupPolicies'
param EnrollVMintoBackupFunctionName string = 'EnrollVMintoBackup'
param EnrollVMintoMonitoringFunctionName string = 'EnrollVMintoMonitoring'

var CreateRSVandBackupPoliciesFunctionId = '${resourceGroup().id}/providers/Microsoft.Web/sites/${functionAppName}/functions/${CreateRSVandBackupPoliciesFunctionName}'
var EnrollVMintoBackupFunctionId = '${resourceGroup().id}/providers/Microsoft.Web/sites/${functionAppName}/functions/${EnrollVMintoBackupFunctionName}'
var EnrollVMintoMonitoringFunctionId = '${resourceGroup().id}/providers/Microsoft.Web/sites/${functionAppName}/functions/${EnrollVMintoMonitoringFunctionName}'

resource systemTopic 'Microsoft.EventGrid/systemTopics@2022-06-15' = {
  name: systemTopicName
  location: 'global'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    source: subscription().id
    topicType: 'Microsoft.Resources.Subscriptions'
  }
}

resource RGCreationEventSubscription 'Microsoft.EventGrid/systemTopics/eventSubscriptions@2022-06-15' = {
  name: RGCreationEventSubscriptionName
  parent: systemTopic
  properties: {
    destination: {
      properties: {
        resourceId: CreateRSVandBackupPoliciesFunctionId
        maxEventsPerBatch: 1
        preferredBatchSizeInKilobytes: 64
      }
      endpointType: 'AzureFunction'
    }
    filter: {
      subjectBeginsWith: '${subscription().id}/resourceGroups/'
      includedEventTypes: [
        'Microsoft.Resources.ResourceWriteSuccess'
      ]
      enableAdvancedFilteringOnArrays: true
      advancedFilters: [
        {
          values: [
            'Microsoft.Resources/subscriptions/resourceGroups/write'
          ]
          operatorType: 'StringContains'
          key: 'data.operationName'
        }
        {
          values: [
            '/sap-'
          ]
          operatorType: 'StringContains'
          key: 'subject'
        }
      ]
    }
    labels: []
    eventDeliverySchema: 'EventGridSchema'
    retryPolicy: {
      maxDeliveryAttempts: 30
      eventTimeToLiveInMinutes: 1440
    }    
  }
}

resource VMCreationEnrollVMintoBackupEventSubscription 'Microsoft.EventGrid/systemTopics/eventSubscriptions@2022-06-15' = {
  name: VMCreationEnrollVMintoBackupEventSubscriptionName
  parent: systemTopic
  properties: {
    destination: {
      properties: {
        resourceId: EnrollVMintoBackupFunctionId
        maxEventsPerBatch: 1
        preferredBatchSizeInKilobytes: 64
      }
      endpointType: 'AzureFunction'
    }
    filter: {
      subjectBeginsWith: '${subscription().id}/resourceGroups/'
      includedEventTypes: [
        'Microsoft.Resources.ResourceWriteSuccess'
      ]
      enableAdvancedFilteringOnArrays: true
      advancedFilters: [
        {
          values: [
            'Microsoft.Compute/virtualMachines/write'
          ]
          operatorType: 'StringContains'
          key: 'data.operationName'
        }
        {
          values: [
            '/sap-'
          ]
          operatorType: 'StringContains'
          key: 'subject'
        }
      ]
    }
    labels: []
    eventDeliverySchema: 'EventGridSchema'
    retryPolicy: {
      maxDeliveryAttempts: 30
      eventTimeToLiveInMinutes: 1440
    }    
  }
}

resource VMCreationEnrollVMintoMonitoringEventSubscription 'Microsoft.EventGrid/systemTopics/eventSubscriptions@2022-06-15' = {
  name: VMCreationEnrollVMintoMonitoringEventSubscriptionName
  parent: systemTopic
  properties: {
    destination: {
      properties: {
        resourceId: EnrollVMintoMonitoringFunctionId
        maxEventsPerBatch: 1
        preferredBatchSizeInKilobytes: 64
      }
      endpointType: 'AzureFunction'
    }
    filter: {
      subjectBeginsWith: '${subscription().id}/resourceGroups/'
      includedEventTypes: [
        'Microsoft.Resources.ResourceWriteSuccess'
      ]
      enableAdvancedFilteringOnArrays: true
      advancedFilters: [
        {
          values: [
            'Microsoft.Compute/virtualMachines/write'
          ]
          operatorType: 'StringContains'
          key: 'data.operationName'
        }
        {
          values: [
            '/sap-'
          ]
          operatorType: 'StringContains'
          key: 'subject'
        }
      ]
    }
    labels: []
    eventDeliverySchema: 'EventGridSchema'
    retryPolicy: {
      maxDeliveryAttempts: 30
      eventTimeToLiveInMinutes: 1440
    }    
  }
}
