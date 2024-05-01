public with sharing class OpportunityTriggerHandler extends TriggerHandler{
    private List<Opportunity> newOppList;
    private List<Opportunity> oldOppList;
    private Map<Id, Opportunity> newOppMap;
    private Map<Id, Opportunity> oldOppMap;


    public OpportunityTriggerHandler() {
        this.newOppList = (List<Opportunity>)Trigger.new;
        this.oldOppList = (List<Opportunity>)Trigger.old;
        this.newOppMap = (Map<Id, Opportunity>)Trigger.newMap;
        this.oldOppMap = (Map<Id, Opportunity>)Trigger.oldMap;
    }

    public override void beforeInsert(){
        for (Opportunity opp : this.newOppList){
            if (opp.Type == null){
                opp.Type = 'New Customer';
            }
        }
    }

    public override void beforeUpdate(){
        Set<Id> accountIds = new Set<Id>();
        List<Opportunity> oppsGettingUpdate = new List<Opportunity>();
        for(Opportunity opp : this.newOppList){
            accountIds.add(opp.AccountId);
            if(opp.Amount < 5000){
                opp.addError('Opportunity amount must be greater than 5000');
            } 
        }
        Map<Id, Contact> contacts = new Map<Id, Contact>  ([SELECT Id, FirstName, AccountId 
                                                                FROM Contact 
                                                                WHERE AccountId IN :accountIds AND Title = 'CEO' ORDER BY FirstName ASC]);
        Map<Id, Contact> accountIdToContact = new Map<Id, Contact>();
        for (Contact cont : contacts.values()) {
            accountIdToContact.put(cont.AccountId, cont);
        }
        for(Opportunity opp : this.newOppList){
            Opportunity oldOpp = this.oldOppMap.get(opp.Id);
            if (opp.StageName != oldOpp.StageName){
                opp.description += ('Stage Change:' + opp.StageName + ':' + DateTime.now().format());
            }else if(opp.Primary_Contact__c == null){
                if (accountIdToContact.containsKey(opp.AccountId)){
                    opp.Primary_Contact__c = accountIdToContact.get(opp.AccountId).Id;
                } 
            }
        }
    }

    public override void afterInsert(){
        List<Task> tasksToInsert = new List<Task>();
        for (Opportunity opp : this.newOppList){
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

    public override void afterUpdate(){
  
        } 

    public override void beforeDelete(){
        for (Opportunity oldOpp : this.oldOppList){
            if (oldOpp.IsClosed){
                oldOpp.addError('Cannot delete closed opportunity');
            }    
        }
    }

    public override void afterDelete(){
        Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, Industry FROM Account WHERE Id IN (SELECT AccountId FROM Opportunity WHERE Id IN :this.oldOppList)]);
        for(Opportunity opp : this.oldOppList){
            if(opp.StageName == 'Closed Won'){
                if(accounts.get(opp.AccountId).Industry == 'Banking'){
                    opp.addError('Cannot delete a closed won opportunity for a banking account');
                }
            }
        }
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Opportunity> opportunities = [SELECT Id, OwnerId, Owner.email, Name FROM Opportunity WHERE Id in :this.oldOppList];
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

    public override void afterUndelete(){
        Set<Id> accts = new Set<Id>();
        For (Opportunity opp : this.newOppMap.values()){
            accts.add(opp.AccountId);
        }  
        Map<Id, Contact> contactsByAcct = new Map<Id, Contact>();
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, Name, AccountId, Title 
                                                            FROM Contact
                                                            WHERE Title LIKE 'VP Sales' AND Contact.AccountId IN :accts]);

        For(Contact acctContact : contactMap.values()){
            contactsByAcct.put(acctContact.AccountId, acctContact);
        }
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        for (Opportunity opp : this.newOppMap.values()){
            if (opp.Primary_Contact__c == null){
                Contact newPrimary = contactsByAcct.get(opp.AccountId);
                Opportunity oppToUpdate = new Opportunity(Id = opp.Id);
                oppToUpdate.Primary_Contact__C = newPrimary.Id;
                oppMap.put(oppToUpdate.Id, oppToUpdate);
            }
        }        
        update oppMap.values();
    }
}
