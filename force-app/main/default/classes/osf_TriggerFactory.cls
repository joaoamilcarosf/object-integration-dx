public with sharing class osf_TriggerFactory {
    private static final Map<SObjectType, String> SOBJECT_TYPE_TO_CLASS_NAME = new Map<SObjectType, String> {
        osf_Account_Source__c.SObjectType => 'osf_AccountSourceTriggerHandler'
    };

    public static void createHandler(Schema.sObjectType soType) {
		osf_ITrigger handler = getHandler(soType);

		if (handler == null) {
			throw new osf_TriggerException('No Trigger Handler registered for Object Type: ' + soType);
		}

		execute(handler);
	}

    private static void execute(osf_ITrigger handler) {
		if (Trigger.isBefore) {
			handler.bulkBefore();
			
			if (Trigger.isDelete) {
				for (SObject so: Trigger.old) {
					handler.beforeDelete(so);
				}
			} else if (Trigger.isInsert) {
				for (SObject so: Trigger.new) {
					handler.beforeInsert(so);
				}
			} else if (Trigger.isUpdate) {
				for (SObject so: Trigger.old) {
					handler.beforeUpdate(so, Trigger.newMap.get(so.Id));
				}
			}
		} else {
			handler.bulkAfter();
			
			if (Trigger.isDelete) {
				for (SObject so: Trigger.old) {
					handler.afterDelete(so);
				}
			} else if (Trigger.isInsert) {
				for (SObject so: Trigger.new) {
					handler.afterInsert(so);
				}
			} else if (Trigger.isUpdate) {
				for (SObject so: Trigger.old) {
					handler.afterUpdate(so, Trigger.newMap.get(so.Id));
				}
			} else if(Trigger.isUndelete) {
				for(SObject so: Trigger.new) {
					handler.afterUndelete(so);
				}
			}
		}
		
		handler.postProcessing();
	}

    @TestVisible
    private static osf_ITrigger getHandler(Schema.sObjectType soType) {
		if(SOBJECT_TYPE_TO_CLASS_NAME.containsKey(soType)) {
            Type t = Type.forName(SOBJECT_TYPE_TO_CLASS_NAME.get(soType));
            osf_ITrigger sobjectHandler = (osf_ITrigger) t.newInstance();
            
            return sobjectHandler;
        }
        
        return null;
	}
}
