trigger CampaignTrigger on Campaign (after delete, after insert, after undelete,
after update, before delete, before insert, before update) {
  // This should be used in conjunction with the TriggerHandlerComprehensive.cls template
  // The origin of this pattern is http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx

  Boolean disabledTaskTrigger = (boolean)HNC_Utilities.getKeyValue('Boolean', 'HNC_Campaign_Trigger_Disabled'); 

  if(disabledTaskTrigger!=null && disabledTaskTrigger== true) {
    return;
  }


  CampaignTriggerHandler handler = new CampaignTriggerHandler(Trigger.isExecuting, Trigger.size);

  if(Trigger.isInsert && Trigger.isBefore){
    handler.OnBeforeInsert(Trigger.new, Trigger.newMap);
  }
  else if(Trigger.isInsert && Trigger.isAfter){
    handler.OnAfterInsert(Trigger.new, Trigger.newMap);
  }

  else if(Trigger.isUpdate && Trigger.isBefore){
    handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap, Trigger.oldMap);
  }
  else if(Trigger.isUpdate && Trigger.isAfter){
    handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap, Trigger.oldMap);
  }

  else if(Trigger.isDelete && Trigger.isBefore){
    handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
  }
  else if(Trigger.isDelete && Trigger.isAfter){
    handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
  }
  else if(Trigger.isUnDelete){
    handler.OnUndelete(Trigger.new);
  }
}