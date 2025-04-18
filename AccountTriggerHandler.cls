// Example: AccountTriggerHandler (Interface Adapter)
public with sharing class AccountTriggerHandler implements ITriggerHandler { // Using interface like [43, 57]

    // Method for a specific trigger context
    public void afterUpdate(List<SObject> oldRecords, List<SObject> newRecords, Map<ID, SObject> oldRecordMap, Map<ID, SObject> newRecordMap) {
        // Cast to specific SObject type
        Map<Id, Account> newAccountMap = (Map<Id, Account>) newRecordMap;
        Map<Id, Account> oldAccountMap = (Map<Id, Account>) oldRecordMap;

        // 1. Determine if the relevant action needs to occur
        //    (e.g., check if specific fields changed)
        Set<Id> accountsToProcess = new Set<Id>();
        for(Id accountId : newAccountMap.keySet()){
            if(shouldProcessAccountUpdate(oldAccountMap.get(accountId), newAccountMap.get(accountId))){
                accountsToProcess.add(accountId);
            }
        }

        if(!accountsToProcess.isEmpty()){
            // 2. Instantiate the appropriate Use Case (using DI/Factory is preferred)
            IUpdateAccountRelatedInfoUseCase useCase = getUseCaseInstance(); // Helper method for instantiation

            // 3. Execute the Use Case, passing only necessary data (e.g., IDs)
            try {
                useCase.execute(accountsToProcess);
            } catch (Exception e) {
                // Handle exceptions - perhaps add errors to records
                // Trigger.newMap.get(anId).addError('Error processing update: ' + e.getMessage());
            }
        }
    }

    // Other ITriggerHandler methods (beforeInsert, afterInsert, etc.) omitted for brevity

    private Boolean shouldProcessAccountUpdate(Account oldAcc, Account newAcc){
        // Logic to determine if the change warrants processing
        return oldAcc.Status__c!= newAcc.Status__c && newAcc.Status__c == 'Active'; // Example condition
    }

    private IUpdateAccountRelatedInfoUseCase getUseCaseInstance() {
        // Placeholder: In a real app, use a factory or DI container
        // return (IUpdateAccountRelatedInfoUseCase) Application.service.newInstance(IUpdateAccountRelatedInfoUseCase.class); // fflib style
        // For simplicity:
        return new UpdateAccountRelatedInfoUseCaseImpl(/* Inject dependencies here */);
    }

    // Interface for the Use Case (defined in Application Layer)
    public interface IUpdateAccountRelatedInfoUseCase {
        void execute(Set<Id> accountIds);
    }
    // Implementation class for Use Case (in Application Layer)
    public class UpdateAccountRelatedInfoUseCaseImpl implements IUpdateAccountRelatedInfoUseCase {
        // Dependencies (e.g., repositories) injected here
        public void execute(Set<Id> accountIds) {
            // Contains the actual business logic for updating related info
            System.debug('Executing Use Case for Accounts: ' + accountIds);
            //... implementation using repositories, etc....
        }
    }
}