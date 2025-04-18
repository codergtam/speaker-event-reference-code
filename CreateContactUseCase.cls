// --- Application Layer ---
public interface IContactRepository { // Defined here or Domain
    Boolean isEmailUnique(String email);
    void save(Contact contactSObject); // Simplified: passing SObject for brevity
}

public class CreateContactUseCase {
    private IContactRepository contactRepo;
    // Constructor for Dependency Injection
    public CreateContactUseCase(IContactRepository repo) { // Dependency injected here
        this.contactRepo = repo;
    }

    public void execute(String firstName, String lastName, String email) {
        // 1. Use the injected repository via its interface
        if (!contactRepo.isEmailUnique(email)) {
            throw new ApplicationException('Email already exists.');
        }
        // 2. Prepare data (simplified - could involve domain entities)
        Contact newContact = new Contact(
            FirstName = firstName, LastName = lastName, Email = email
        );
        // 3. Save via the repository interface
        contactRepo.save(newContact);
    }
}

// --- Infrastructure Layer ---
public class ContactRepository implements IContactRepository { // Implements the interface
    public Boolean isEmailUnique(String email) {
        // Actual SOQL query
        return == 0;
    }
    public void save(Contact contactSObject) {
        // Actual DML operation (Consider Unit of Work pattern for real implementation)
        insert contactSObject;
    }
}

// --- Interface Adapters (Controller Example) ---
public with sharing class ContactCreatorController {
    @AuraEnabled
    public static void createNewContact(String firstName, String lastName, String email) {
        // Dependency Injection setup needed (e.g., via Factory [54] or DI framework)
        // For simplicity here, we instantiate directly, but this hides the dependency inversion benefit.
        IContactRepository repo = new ContactRepository(); // In real scenario, use DI
        CreateContactUseCase useCase = new CreateContactUseCase(repo);
        try {
            useCase.execute(firstName, lastName, email);
        } catch (Exception e) {
            // Handle exception appropriately
            throw new AuraHandledException(e.getMessage());
        }
    }
}