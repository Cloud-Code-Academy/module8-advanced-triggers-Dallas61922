/*
AnotherOpportunityTrigger Overview

This trigger was initially created for handling various events on the Opportunity object. It was developed by a prior developer and has since been noted to cause some issues in our org.

IMPORTANT:
- This trigger does not adhere to Salesforce best practices.
- It is essential to review, understand, and refactor this trigger to ensure maintainability, performance, and prevent any inadvertent issues.

ISSUES:
Avoid nested for loop - 1 instance
Avoid DML inside for loop - 1 instance
Bulkify Your Code - 1 instance
Avoid SOQL Query inside for loop - 2 instances
Stop recursion - 1 instance

RESOURCES: 
https://www.salesforceben.com/12-salesforce-apex-best-practices/
https://developer.salesforce.com/blogs/developer-relations/2015/01/apex-best-practices-15-apex-commandments
*/
trigger AnotherOpportunityTrigger on Opportunity (before Insert) {
    
    /*Boolean stopTrigger = Trigger_Setting__mdt.getInstance('AnotherOpportunityTrigger')?.Disable_Trigger__c;
    Boolean stopTriggerHelper = OpportunityTriggerHelper.hasRun;
    List<Opportunity> oppsToUpdate = new List<Opportunity>();
    if (stopTrigger = false){
        OpportunityTriggerHelper.hasRun = true;
        if (Trigger.isBefore){
            if (Trigger.isInsert){
                for (Opportunity opp : trigger.new){
                    if (opp.Type == null){
                        opp.Type = 'New Customer';
                    }
                } 
            } else if (Trigger.isDelete){
                // Prevent deletion of closed Opportunities
                 for (Opportunity oldOpp : Trigger.old){
                    if (oldOpp.IsClosed){
                        oldOpp.addError('Cannot delete closed opportunity');
                    } 
                }
            }
        }

    if (Trigger.isAfter){
        if (Trigger.isInsert){
            List<Task> tasksToInsert = new List<Task>();
            // Create a new Task for newly inserted Opportunities
            for (Opportunity opp : Trigger.new){
                Task tsk = new Task();
                tsk.Subject = 'Call Primary Contact';
                tsk.WhatId = opp.Id;
                tsk.WhoId = opp.Primary_Contact__c;
                tsk.OwnerId = opp.OwnerId;
                tsk.ActivityDate = Date.today().addDays(3);
                tasksToInsert.add(tsk);
            }
            insert tasksToInsert; 
        }
        } else if (Trigger.isUpdate){
            // Append Stage changes in Opportunity Description
            List<Opportunity> oppsToUpdate = new List<Opportunity>();
            String newDescription;
            
            for (Opportunity opp : Trigger.new){
                System.debug('Opp to update is: ' + opp);
                Opportunity oldOpp = Trigger.oldMap.get(opp.Id);
                System.debug('Old opp is ' + oldOpp);
                //for (Opportunity oldOpp : Trigger.old){
                    if (oldOpp.StageName != null){
                        System.debug('Old stage name is ' + oldOpp.StageName + ' and New stage name is ' + opp.StageName);
                        newDescription = ('Stage Change:' + opp.StageName + ':' + DateTime.now().format());
                        System.debug('Description variable is ' + newDescription);
                        opp.Description += newDescription;
                        System.debug('New description is ' + opp.Description);
                        oppsToUpdate.add(opp);
                    }
                }                
        }
        // Send email notifications when an Opportunity is deleted 
         else if (Trigger.isDelete){
            notifyOwnersOpportunityDeleted(Trigger.old); 
        } 
        // Assign the primary contact to undeleted Opportunities
        else if (Trigger.isUndelete){
            OpportunityTriggerHandler.assignPrimaryContact(Trigger.newMap);
        }
    

    

    
    //notifyOwnersOpportunityDeleted:
    //- Sends an email notification to the owner of the Opportunity when it gets deleted.
    //- Uses Salesforce's Messaging.SingleEmailMessage to send the email.
    
     private static void notifyOwnersOpportunityDeleted(List<Opportunity> opps) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Opportunity> opportunities = [SELECT Id, OwnerId, Owner.email, Name FROM Opportunity WHERE Id in :opps];
        for (Opportunity opp : opportunities){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {opp.Owner.Email};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Opportunity Deleted : ' + opp.Name);
            mail.setPlainTextBody('Your Opportunity: ' + opp.Name +' has been deleted.');
            mails.add(mail);
        }        
        
        try {
            Messaging.sendEmail(mails);
        } catch (Exception e){
            System.debug('Exception: ' + e.getMessage());
        }
    } 

    
    //assignPrimaryContact:
    //- Assigns a primary contact with the title of 'VP Sales' to undeleted Opportunities.
    //- Only updates the Opportunities that don't already have a primary contact.
    
    private static void assignPrimaryContact(Map<Id,Opportunity> oppNewMap) { 
        //create set of opportunity accounts
        Set<Account> accts = new Set<Account>();
        //populate the set of accounts
        For (Opportunity opp : keySet(oppNewMap)){
            accts.set(opp.AccountId);
        }  
        //create a map of account ids with contact info for VP sales
        Map<Id, Contact> contactsByAcct = new Map<Id, Contact>();
        Map<Id, Account> acctMap = new Map<Id, Account>([SELECT Id, AccountId, Name, Title 
                                                        FROM Account 
                                                        (SELECT Id, Title, Name, AccountId 
                                                        FROM Contacts 
                                                        WHERE Title == 'VP Sales') 
                                                        WHERE Id IN :accts]);
        //update map to have account id to contact
        For(Id acctContact : acctMap.values()){ 
            Id accountId = acctMap.get(acctContact).AccountId; 
            Contact con = acctContact;
            contactsByAcct.put(accountId, acctContact);
        }

        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        for (Opportunity opp : oppNewMap.values()){ 
            if (Primary_Contact__c == null){
                Contact newPrimary = contactsByAcct.get(opp.AccountId);
                Opportunity oppToUpdate = new Opportunity(Id = opp.Id);
                oppToUpdate.Primary_Contact__C = newPrimary.Id;
                oppMap.put(oppToUpdate.Id, oppToUpdate);

            }
        }          
        update oppMap.values();
    }
    moved all this to the opptriggerhandler
}*/
}