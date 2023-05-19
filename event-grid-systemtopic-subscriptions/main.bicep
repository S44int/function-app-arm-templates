param systemTopicName string = 'systopic-${uniqueString(resourceGroup().id)}'
param RGCreationEventSubscriptionName string = 'RGCreation'
param functionAppName string = 'func-${uniqueString(resourceGroup().id)}'
param RGCreationFunctionName string = 'RGCreationFunction'

var RGCreationFunctionId = '${resourceGroup().id}/providers/Microsoft.Web/sites/${functionAppName}/functions/${RGCreationFunctionName}'

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
        resourceId: RGCreationFunctionId
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
            '/rgcreation-'
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
