// --- Interfaces (Defined in Application/Domain) ---
public interface IOpportunityRepository { Opportunity getOppWithDetails(Id oppId); /*...*/ }
public interface IContractRepository { void saveContract(Contract contract); /*...*/ }
public interface IInvoiceRepository { void saveInvoice(Invoice__c invoice); /*...*/ }
public interface INotificationService { void notifyFinance(Platform_Event__e eventData); } // Interface for event publishing
public interface IERPService { void updateERPSalesOrder(Opportunity opp, Contract cont); } // Interface for callout
public interface IInvoiceGenerator { Blob generateInvoicePdf(Opportunity opp, Contract cont); } // Interface for PDF generation
public interface IUnitOfWork { // Represents Unit of Work capabilities
    void registerNew(SObject record);
    void registerDirty(SObject record);
    void registerPublishEvent(SObject event);
    void commitWork();
}

// --- Application Layer (Use Case) ---
public class WinOpportunityUseCase {
    private IOpportunityRepository oppRepo;
    private IContractRepository contractRepo;
    private IInvoiceRepository invoiceRepo;
    private INotificationService notificationService; // Injected implementation handles EventBus.publish
    private IERPService erpService; // Injected implementation handles HTTP callout
    private IInvoiceGenerator invoiceGenerator; // Injected implementation handles PDF logic
    private IUnitOfWork uow; // Injected Unit of Work instance

    // Constructor for Dependency Injection
    public WinOpportunityUseCase(IOpportunityRepository or, IContractRepository cr, IInvoiceRepository ir,
                                 INotificationService ns, IERPService es, IInvoiceGenerator ig, IUnitOfWork uowInstance) {
        this.oppRepo = or; this.contractRepo = cr; this.invoiceRepo = ir;
        this.notificationService = ns; this.erpService = es; this.invoiceGenerator = ig;
        this.uow = uowInstance;
     }

    public void execute(Id opportunityId) {
        Opportunity opp = oppRepo.getOppWithDetails(opportunityId);
        // Logic to create Contract and Invoice (could use Domain Entities/Services)
        Contract newContract = createContractFromOpp(opp);
        Invoice__c newInvoice = createInvoiceFromOpp(opp, newContract);
        Platform_Event__e financeEvent = createFinancePlatformEvent(newInvoice); // Create event data

        // Register work with UoW
        uow.registerDirty(newContract); // Assuming contract might exist and be updated
        uow.registerNew(newInvoice);
        // Delegate event publishing to the notification service via UoW if supported,
        // or handle separately after commit if UoW doesn't manage events directly.
        // For simplicity, let's assume UoW handles it:
        uow.registerPublishEvent(financeEvent); // Register event data with UoW

        // Generate PDF
        Blob invoicePdf = invoiceGenerator.generateInvoicePdf(opp, newContract);
        // Attaching PDF likely involves DML, so might need to be registered with UoW
        // or handled in a subsequent transaction depending on complexity and atomicity needs.

        // Commit DB changes and publish event transactionally
        uow.commitWork();

        // Perform callout AFTER successful commit
        erpService.updateERPSalesOrder(opp, newContract);
    }

    // Private helper methods to create Contract, Invoice, Event data...
    private Contract createContractFromOpp(Opportunity opp) { /*... */ return new Contract(); }
    private Invoice__c createInvoiceFromOpp(Opportunity opp, Contract c) { /*... */ return new Invoice__c(); }
    private Platform_Event__e createFinancePlatformEvent(Invoice__c inv) { /*... */ return new Finance_Notification__e(); } // Example event type
}